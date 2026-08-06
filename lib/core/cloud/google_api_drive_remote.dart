import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:tinytunes/core/cloud/drive_remote.dart';
import 'package:tinytunes/core/cloud/google_access_token_client.dart';
import 'package:tinytunes/core/cloud/google_drive_auth.dart';

/// Production [DriveRemote] using Drive API v3 + OAuth access tokens.
///
/// Purpose: List/download only; never create, update, or delete remote files.
/// Usage Context: [GoogleDriveCloudLibrarySource] on Android.
class GoogleApiDriveRemote implements DriveRemote {
  /// Creates a remote that obtains tokens from [auth].
  GoogleApiDriveRemote(this._auth);

  final GoogleDriveAuth _auth;

  static const _folderMime = 'application/vnd.google-apps.folder';

  @override
  Future<List<DriveRemoteEntry>> listChildren(String parentFileId) async {
    return _withApi((api) async {
      final listed = await api.files.list(
        q: "'$parentFileId' in parents and trashed = false",
        $fields: 'files(id, name, mimeType, size, modifiedTime)',
        pageSize: 1000,
        spaces: 'drive',
        corpora: 'user',
        orderBy: 'name',
      );
      final files = listed.files ?? const <drive.File>[];
      return [
        for (final file in files)
          if (file.id != null && file.name != null)
            DriveRemoteEntry(
              fileId: file.id!,
              name: file.name!,
              isDirectory: file.mimeType == _folderMime,
              sizeBytes: int.tryParse(file.size ?? ''),
              modifiedAt: file.modifiedTime,
            ),
      ];
    });
  }

  @override
  Future<DriveRemoteFileMeta> getFileMeta(String fileId) async {
    return _withApi((api) async {
      final file =
          await api.files.get(fileId, $fields: 'id,name,size,mimeType')
              as drive.File;
      if (file.id == null || file.name == null) {
        throw StateError('Drive file meta missing id/name for $fileId');
      }
      if (file.mimeType == _folderMime) {
        throw StateError('Cannot download a Drive folder: $fileId');
      }
      return DriveRemoteFileMeta(
        fileId: file.id!,
        name: file.name!,
        sizeBytes: int.tryParse(file.size ?? '') ?? 0,
      );
    });
  }

  @override
  Future<void> downloadFile({
    required String fileId,
    required String destinationPath,
    void Function(int chunkBytes)? onBytes,
  }) async {
    await _withApi((api) async {
      final media =
          await api.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;
      final file = File(destinationPath);
      await file.parent.create(recursive: true);
      final sink = file.openWrite();
      try {
        await for (final chunk in media.stream) {
          onBytes?.call(chunk.length);
          sink.add(chunk);
        }
      } finally {
        await sink.close();
      }
    });
  }

  Future<T> _withApi<T>(Future<T> Function(drive.DriveApi api) action) async {
    final token = await _auth.accessTokenForDriveReadonly();
    final client = GoogleAccessTokenClient(accessToken: token);
    try {
      return await action(drive.DriveApi(client));
    } finally {
      client.close();
    }
  }
}
