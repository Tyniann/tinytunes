/// Reports free disk space available for cloud downloads.
///
/// Purpose: Let [GoogleDriveCloudLibrarySource] refuse downloads when the
/// device cannot hold the remote file without binding tests to Android APIs.
abstract class FreeSpaceSource {
  /// Approximate free bytes under [directoryPath]'s filesystem.
  Future<int> availableBytesFor(String directoryPath);
}

/// [FreeSpaceSource] that always reports a very large free size.
///
/// Purpose: Tests and non-Android hosts where StatFs is unavailable.
class UnlimitedFreeSpaceSource implements FreeSpaceSource {
  /// Creates an always-plenty free-space stub.
  const UnlimitedFreeSpaceSource();

  @override
  Future<int> availableBytesFor(String directoryPath) async => 1 << 50;
}
