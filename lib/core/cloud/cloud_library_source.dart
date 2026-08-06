import 'package:tinytunes/core/library/media_locator.dart';

/// Read-only remote library access (list / download / cache only).
///
/// Purpose: Lock the cloud boundary without choosing a provider SDK in Phase 0;
/// Phase 7 implements Google Drive behind this API.
/// Usage Context: Ingest, cache, and playback resolvers.
/// Never delete, rename, or overwrite remote content through this API.
abstract class CloudLibrarySource {
  /// Lists children under an opaque remote [parent] folder locator.
  Future<List<CloudLibraryEntry>> list(MediaLocator parent);

  /// Downloads a remote [item] into the local cache; returns a cache path locator.
  ///
  /// The returned [MediaLocator.value] is an absolute local filesystem path.
  /// [onProgress] reports bytes received vs remote total when known.
  Future<MediaLocator> downloadToCache(
    MediaLocator item, {
    void Function(int receivedBytes, int totalBytes)? onProgress,
  });

  /// Resolves a previously cached remote [item] to a local `file:` playback URI.
  Future<Uri> resolveCached(MediaLocator item);
}

/// One child entry in a remote (cloud) folder listing.
///
/// Purpose: Mirror local listing shape without implying write access.
/// Usage Context: Returned by [CloudLibrarySource.list].
class CloudLibraryEntry {
  /// Creates a remote listing row.
  const CloudLibraryEntry({
    required this.locator,
    required this.name,
    required this.isDirectory,
    this.sizeBytes,
    this.modifiedAt,
  });

  /// Opaque remote item or folder locator.
  final MediaLocator locator;

  /// Display name from the provider.
  final String name;

  /// Whether this entry is a remote folder.
  final bool isDirectory;

  /// Remote size in bytes when known (files).
  final int? sizeBytes;

  /// Remote modified time when known.
  final DateTime? modifiedAt;
}

/// Thrown when [CloudLibrarySource.resolveCached] has no local file yet.
class CloudCacheMissException implements Exception {
  /// Creates a miss for [item].
  CloudCacheMissException(this.item);

  /// Remote item that was not cached.
  final MediaLocator item;

  @override
  String toString() => 'CloudCacheMissException(${item.value})';
}

/// Thrown when a download cannot proceed due to insufficient free space.
class InsufficientFreeSpaceException implements Exception {
  /// Creates an insufficient-space error.
  InsufficientFreeSpaceException({
    required this.requiredBytes,
    required this.availableBytes,
  });

  /// Bytes needed for the download (remote size).
  final int requiredBytes;

  /// Bytes free on the target filesystem.
  final int availableBytes;

  @override
  String toString() =>
      'InsufficientFreeSpaceException(need: $requiredBytes, free: $availableBytes)';
}

/// Phase-0 stub that rejects all cloud operations.
///
/// Purpose: Keep call sites compilable before a provider is wired.
/// Usage Context: Tests that intentionally leave cloud unimplemented.
class UnimplementedCloudLibrarySource implements CloudLibrarySource {
  /// Creates the throwing stub.
  const UnimplementedCloudLibrarySource();

  @override
  Future<List<CloudLibraryEntry>> list(MediaLocator parent) {
    throw UnimplementedError('CloudLibrarySource.list is Phase 7');
  }

  @override
  Future<MediaLocator> downloadToCache(
    MediaLocator item, {
    void Function(int receivedBytes, int totalBytes)? onProgress,
  }) {
    throw UnimplementedError('CloudLibrarySource.downloadToCache is Phase 7');
  }

  @override
  Future<Uri> resolveCached(MediaLocator item) {
    throw UnimplementedError('CloudLibrarySource.resolveCached is Phase 7');
  }
}
