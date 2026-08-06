import 'dart:io';

import 'package:tinytunes/core/cloud/drive_remote.dart';

/// In-memory [DriveRemote] for unit tests (no network / OAuth).
class FakeDriveRemote implements DriveRemote {
  /// Creates a fake with optional [childrenByParent] and [files].
  FakeDriveRemote({
    Map<String, List<DriveRemoteEntry>>? childrenByParent,
    Map<String, DriveRemoteFileMeta>? files,
    Map<String, List<int>>? fileBytes,
  }) : childrenByParent = childrenByParent ?? {},
       files = files ?? {},
       fileBytes = fileBytes ?? {};

  /// Parent file id → children.
  final Map<String, List<DriveRemoteEntry>> childrenByParent;

  /// File id → metadata.
  final Map<String, DriveRemoteFileMeta> files;

  /// File id → download payload bytes.
  final Map<String, List<int>> fileBytes;

  /// How many times [downloadFile] was called.
  int downloadCalls = 0;

  @override
  Future<List<DriveRemoteEntry>> listChildren(String parentFileId) async {
    return List.unmodifiable(childrenByParent[parentFileId] ?? const []);
  }

  @override
  Future<DriveRemoteFileMeta> getFileMeta(String fileId) async {
    final meta = files[fileId];
    if (meta == null) {
      throw StateError('Unknown Drive file: $fileId');
    }
    return meta;
  }

  @override
  Future<void> downloadFile({
    required String fileId,
    required String destinationPath,
    void Function(int chunkBytes)? onBytes,
  }) async {
    downloadCalls++;
    final bytes = fileBytes[fileId];
    if (bytes == null) {
      throw StateError('No bytes for Drive file: $fileId');
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
