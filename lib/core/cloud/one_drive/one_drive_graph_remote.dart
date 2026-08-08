import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tinytunes/core/cloud/one_drive/one_drive_auth.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_graph_http.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_remote.dart';

/// Production [OneDriveRemote] using Microsoft Graph HTTP (personal My files).
///
/// Purpose: Paginated list/meta/`/content` download only; never mutate remote.
/// Usage Context: [OneDriveCloudLibrarySource] on Android.
class OneDriveGraphRemote implements OneDriveRemote {
  /// Creates a remote that obtains tokens from [auth].
  ///
  /// When [httpClient] is omitted, a client is created and closed with this
  /// remote. Injectable clients are not closed here.
  OneDriveGraphRemote(this._auth, {http.Client? httpClient})
    : _http = httpClient ?? http.Client(),
      _ownsClient = httpClient == null;

  final OneDriveAuth _auth;
  final http.Client _http;
  final bool _ownsClient;

  static const _graphRoot = 'https://graph.microsoft.com/v1.0';
  static const _select =
      'id,name,folder,file,size,lastModifiedDateTime,parentReference';
  static const _top = 50;
  static const _maxRedirects = 8;

  /// Closes the owned HTTP client when this remote created it.
  void close() {
    if (_ownsClient) {
      _http.close();
    }
  }

  @override
  Future<List<OneDriveRemoteEntry>> listRootChildren() async {
    final driveId = await _personalDriveId();
    return _listPaginated(
      Uri.parse(
        '$_graphRoot/me/drive/root/children'
        '?\$select=$_select'
        '&\$top=$_top',
      ),
      fallbackDriveId: driveId,
    );
  }

  @override
  Future<List<OneDriveRemoteEntry>> listChildren({
    required String driveId,
    required String itemId,
  }) {
    final drive = Uri.encodeComponent(driveId);
    final item = Uri.encodeComponent(itemId);
    return _listPaginated(
      Uri.parse(
        '$_graphRoot/drives/$drive/items/$item/children'
        '?\$select=$_select'
        '&\$top=$_top',
      ),
      fallbackDriveId: driveId,
    );
  }

  @override
  Future<OneDriveRemoteFileMeta> getFileMeta({
    required String driveId,
    required String itemId,
  }) async {
    final drive = Uri.encodeComponent(driveId);
    final item = Uri.encodeComponent(itemId);
    final json = await _getJson(
      Uri.parse(
        '$_graphRoot/drives/$drive/items/$item?\$select=$_select',
      ),
      operation: 'meta',
    );
    final id = json['id']?.toString();
    final name = json['name']?.toString();
    if (id == null || id.isEmpty || name == null || name.isEmpty) {
      throw StateError('OneDrive meta missing id/name');
    }
    if (json['folder'] != null) {
      throw StateError('Cannot download a OneDrive folder: $itemId');
    }
    final resolvedDrive =
        _driveIdFrom(json, fallback: driveId) ?? driveId;
    return OneDriveRemoteFileMeta(
      driveId: resolvedDrive,
      itemId: id,
      name: name,
      sizeBytes: _parseSize(json['size']),
    );
  }

  @override
  Future<void> downloadFile({
    required String driveId,
    required String itemId,
    required String destinationPath,
    void Function(int chunkBytes)? onBytes,
  }) async {
    final token = await _auth.accessTokenForGraphReadonly();
    final drive = Uri.encodeComponent(driveId);
    final item = Uri.encodeComponent(itemId);
    var uri = Uri.parse(
      '$_graphRoot/drives/$drive/items/$item/content',
    );

    final dest = File(destinationPath);
    await dest.parent.create(recursive: true);
    final partial = File('$destinationPath.partial');
    if (await partial.exists()) {
      await partial.delete();
    }

    try {
      for (var hop = 0; hop <= _maxRedirects; hop++) {
        final request = http.Request('GET', uri)..followRedirects = false;
        if (isMicrosoftGraphHost(uri.host)) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        final response = await _http.send(request);
        if (response.statusCode >= 300 && response.statusCode < 400) {
          final location = response.headers['location'];
          await response.stream.drain<void>();
          if (location == null || location.isEmpty) {
            throw const OneDriveGraphHttpException(
              statusCode: 302,
              operation: 'download',
            );
          }
          uri = uri.resolve(location);
          continue;
        }
        if (response.statusCode < 200 || response.statusCode >= 300) {
          await response.stream.drain<void>();
          throw OneDriveGraphHttpException(
            statusCode: response.statusCode,
            operation: 'download',
          );
        }

        final sink = partial.openWrite();
        try {
          await for (final chunk in response.stream) {
            onBytes?.call(chunk.length);
            sink.add(chunk);
          }
        } finally {
          await sink.close();
        }
        if (await dest.exists()) {
          await dest.delete();
        }
        await partial.rename(destinationPath);
        return;
      }
      throw StateError('OneDrive download exceeded redirect limit');
    } on Object {
      if (await partial.exists()) {
        await partial.delete();
      }
      rethrow;
    }
  }

  Future<String> _personalDriveId() async {
    final json = await _getJson(
      Uri.parse('$_graphRoot/me/drive?\$select=id'),
      operation: 'list',
    );
    final id = json['id']?.toString();
    if (id == null || id.isEmpty) {
      throw StateError('Graph /me/drive missing id');
    }
    return id;
  }

  Future<List<OneDriveRemoteEntry>> _listPaginated(
    Uri firstPage, {
    required String fallbackDriveId,
  }) async {
    final token = await _auth.accessTokenForGraphReadonly();
    final entries = <OneDriveRemoteEntry>[];
    Uri? next = firstPage;
    while (next != null) {
      final response = await _http.get(
        next,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw OneDriveGraphHttpException(
          statusCode: response.statusCode,
          operation: 'list',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw StateError('Graph list returned a non-object body');
      }
      final values = decoded['value'];
      if (values is! List) {
        throw StateError('Graph list missing value array');
      }
      for (final raw in values) {
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        final mapped = _mapEntry(map, fallbackDriveId: fallbackDriveId);
        if (mapped != null) {
          entries.add(mapped);
        }
      }
      final link = decoded['@odata.nextLink']?.toString();
      next = (link == null || link.isEmpty) ? null : Uri.parse(link);
    }
    return entries;
  }

  Future<Map<String, dynamic>> _getJson(
    Uri uri, {
    required String operation,
  }) async {
    final token = await _auth.accessTokenForGraphReadonly();
    final response = await _http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OneDriveGraphHttpException(
        statusCode: response.statusCode,
        operation: operation,
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Graph $operation returned a non-object body');
    }
    return decoded;
  }

  OneDriveRemoteEntry? _mapEntry(
    Map<String, dynamic> map, {
    required String fallbackDriveId,
  }) {
    final id = map['id']?.toString();
    final name = map['name']?.toString();
    if (id == null || id.isEmpty || name == null || name.isEmpty) {
      return null;
    }
    final driveId = _driveIdFrom(map, fallback: fallbackDriveId);
    if (driveId == null || driveId.isEmpty) {
      return null;
    }
    return OneDriveRemoteEntry(
      driveId: driveId,
      itemId: id,
      name: name,
      isDirectory: map['folder'] != null,
      sizeBytes: map['folder'] != null ? null : _parseSizeOrNull(map['size']),
      modifiedAt: _parseDate(map['lastModifiedDateTime']),
    );
  }

  String? _driveIdFrom(Map<String, dynamic> map, {required String fallback}) {
    final parent = map['parentReference'];
    if (parent is Map) {
      final fromParent = parent['driveId']?.toString();
      if (fromParent != null && fromParent.isNotEmpty) {
        return fromParent;
      }
    }
    return fallback;
  }

  int _parseSize(Object? raw) => _parseSizeOrNull(raw) ?? 0;

  int? _parseSizeOrNull(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  DateTime? _parseDate(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
