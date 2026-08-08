/// One Drive child returned by [OneDriveRemote] listing methods.
///
/// Purpose: Keep [OneDriveCloudLibrarySource] free of Graph HTTP types in tests
/// by injecting a fake remote.
class OneDriveRemoteEntry {
  /// Creates a remote listing row with durable [driveId]/[itemId].
  const OneDriveRemoteEntry({
    required this.driveId,
    required this.itemId,
    required this.name,
    required this.isDirectory,
    this.sizeBytes,
    this.modifiedAt,
  });

  /// Graph drive id (personal OneDrive).
  final String driveId;

  /// Graph item id within [driveId].
  final String itemId;

  /// Display name.
  final String name;

  /// Whether this entry is a folder.
  final bool isDirectory;

  /// Size in bytes when known (files only).
  final int? sizeBytes;

  /// Last modified time when known.
  final DateTime? modifiedAt;
}

/// File metadata needed before downloading from OneDrive.
class OneDriveRemoteFileMeta {
  /// Creates metadata for a drive/item pair.
  const OneDriveRemoteFileMeta({
    required this.driveId,
    required this.itemId,
    required this.name,
    required this.sizeBytes,
  });

  /// Graph drive id.
  final String driveId;

  /// Graph item id.
  final String itemId;

  /// Display name (used for the cached filename / extension).
  final String name;

  /// Remote size in bytes (`0` when Graph omits size).
  final int sizeBytes;
}

/// Thrown when a Graph call fails with a known HTTP status.
///
/// Purpose: Let callers map 401/404/429 without parsing response bodies that
/// may contain tokens.
class OneDriveGraphHttpException implements Exception {
  /// Creates an error for [statusCode] on a Graph operation.
  const OneDriveGraphHttpException({
    required this.statusCode,
    required this.operation,
  });

  /// HTTP status from Graph (or the final download host).
  final int statusCode;

  /// Short operation label (`list`, `meta`, `download`).
  final String operation;

  /// Whether the session likely needs interactive re-auth.
  bool get isUnauthorized => statusCode == 401;

  /// Whether the remote item is missing / deleted.
  bool get isNotFound => statusCode == 404;

  /// Whether Graph asked the client to slow down.
  bool get isThrottled => statusCode == 429;

  @override
  String toString() =>
      'OneDriveGraphHttpException($operation HTTP $statusCode)';
}

/// Read-only OneDrive Graph operations used by [OneDriveCloudLibrarySource].
///
/// Purpose: Seam for fakes in unit tests without HTTP / MSAL.
abstract class OneDriveRemote {
  /// Lists children under the signed-in user's personal My files root.
  Future<List<OneDriveRemoteEntry>> listRootChildren();

  /// Lists children of [itemId] inside [driveId].
  Future<List<OneDriveRemoteEntry>> listChildren({
    required String driveId,
    required String itemId,
  });

  /// Loads name/size for a file before download.
  Future<OneDriveRemoteFileMeta> getFileMeta({
    required String driveId,
    required String itemId,
  });

  /// Downloads item bytes into [destinationPath] (overwrites if present).
  ///
  /// [onBytes] is invoked with each chunk length as data arrives.
  /// Implementations must not forward the Graph bearer token to non-Graph hosts
  /// when following `/content` redirects.
  Future<void> downloadFile({
    required String driveId,
    required String itemId,
    required String destinationPath,
    void Function(int chunkBytes)? onBytes,
  });
}
