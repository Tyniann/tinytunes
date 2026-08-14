import 'dart:io';

import 'package:tinytunes/core/cloud/one_drive/one_drive_remote.dart';

/// In-memory [OneDriveRemote] for unit tests (no network / MSAL).
class FakeOneDriveRemote implements OneDriveRemote {
  /// Creates a fake with optional listings, meta, and download bytes.
  FakeOneDriveRemote({
    List<OneDriveRemoteEntry>? rootChildren,
    Map<String, List<OneDriveRemoteEntry>>? childrenByParent,
    Map<String, OneDriveRemoteFileMeta>? files,
    Map<String, List<int>>? fileBytes,
    this.listError,
    this.downloadError,
  }) : rootChildren = rootChildren ?? const [],
       childrenByParent = childrenByParent ?? {},
       files = files ?? {},
       fileBytes = fileBytes ?? {};

  /// Children returned by [listRootChildren].
  final List<OneDriveRemoteEntry> rootChildren;

  /// Composite `driveId/itemId` → children for [listChildren].
  final Map<String, List<OneDriveRemoteEntry>> childrenByParent;

  /// Composite `driveId/itemId` → metadata.
  final Map<String, OneDriveRemoteFileMeta> files;

  /// Composite `driveId/itemId` → download payload bytes.
  final Map<String, List<int>> fileBytes;

  /// When set, list methods throw.
  final Object? listError;

  /// When set, [downloadFile] throws after incrementing [downloadCalls].
  final Object? downloadError;

  /// How many times [listRootChildren] was called.
  int listRootCalls = 0;

  /// How many times [downloadFile] was called.
  int downloadCalls = 0;

  static String _key(String driveId, String itemId) => '$driveId/$itemId';

  @override
  Future<List<OneDriveRemoteEntry>> listRootChildren() async {
    listRootCalls++;
    final error = listError;
    if (error != null) throw error;
    return List.unmodifiable(rootChildren);
  }

  @override
  Future<List<OneDriveRemoteEntry>> listChildren({
    required String driveId,
    required String itemId,
  }) async {
    final error = listError;
    if (error != null) throw error;
    return List.unmodifiable(
      childrenByParent[_key(driveId, itemId)] ?? const [],
    );
  }

  @override
  Future<OneDriveRemoteFileMeta> getFileMeta({
    required String driveId,
    required String itemId,
  }) async {
    final meta = files[_key(driveId, itemId)];
    if (meta == null) {
      throw StateError('Unknown OneDrive file: $driveId/$itemId');
    }
    return meta;
  }

  @override
  Future<void> downloadFile({
    required String driveId,
    required String itemId,
    required String destinationPath,
    void Function(int chunkBytes)? onBytes,
  }) async {
    downloadCalls++;
    final error = downloadError;
    if (error != null) throw error;
    final bytes = fileBytes[_key(driveId, itemId)];
    if (bytes == null) {
      throw StateError('No bytes for OneDrive file: $driveId/$itemId');
    }
    final file = File(destinationPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    const chunkSize = 2;
    for (var i = 0; i < bytes.length; i += chunkSize) {
      final end = (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize;
      onBytes?.call(end - i);
    }
  }
}
