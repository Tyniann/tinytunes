/// One Drive child returned by [DriveRemote.listChildren].
///
/// Purpose: Keep [GoogleDriveCloudLibrarySource] free of `googleapis` types in
/// tests by injecting a fake remote.
class DriveRemoteEntry {
  /// Creates a remote listing row.
  const DriveRemoteEntry({
    required this.fileId,
    required this.name,
    required this.isDirectory,
    this.sizeBytes,
    this.modifiedAt,
  });

  /// Drive file id (not a `gdrive:` locator).
  final String fileId;

  /// Display name.
  final String name;

  /// Whether this entry is a folder.
  final bool isDirectory;

  /// Size in bytes when known (files only).
  final int? sizeBytes;

  /// Last modified time when known.
  final DateTime? modifiedAt;
}

/// File metadata needed before downloading.
class DriveRemoteFileMeta {
  /// Creates metadata for [fileId].
  const DriveRemoteFileMeta({
    required this.fileId,
    required this.name,
    required this.sizeBytes,
  });

  /// Drive file id.
  final String fileId;

  /// Display name (used for the cached filename / extension).
  final String name;

  /// Remote size in bytes (`0` when Drive omits size).
  final int sizeBytes;
}

/// Read-only Drive operations used by [GoogleDriveCloudLibrarySource].
///
/// Purpose: Seam for fakes in unit tests without HTTP / OAuth.
abstract class DriveRemote {
  /// Lists non-trashed children of [parentFileId] (`root` for My Drive).
  Future<List<DriveRemoteEntry>> listChildren(String parentFileId);

  /// Loads name/size for [fileId] before download.
  Future<DriveRemoteFileMeta> getFileMeta(String fileId);

  /// Downloads [fileId] bytes into [destinationPath] (overwrites if present).
  ///
  /// [onBytes] is invoked with each chunk length as data arrives.
  Future<void> downloadFile({
    required String fileId,
    required String destinationPath,
    void Function(int chunkBytes)? onBytes,
  });
}
