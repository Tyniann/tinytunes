import 'package:tinytunes/core/library/media_locator.dart';

/// Read-only remote library access (list / download / cache only).
///
/// Purpose: Lock the cloud boundary early without choosing a provider SDK.
/// Usage Context: Phase 7 implements a real provider; Phase 0 ships a stub.
/// Never delete, rename, or overwrite remote content through this API.
abstract class CloudLibrarySource {
  /// Lists children under an opaque remote [parent] folder locator.
  Future<List<CloudLibraryEntry>> list(MediaLocator parent);

  /// Downloads a remote [item] into the local cache; returns a cache locator.
  Future<MediaLocator> downloadToCache(MediaLocator item);

  /// Resolves a previously cached [item] to a local playback URI.
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
  });

  /// Opaque remote item or folder locator.
  final MediaLocator locator;

  /// Display name from the provider.
  final String name;

  /// Whether this entry is a remote folder.
  final bool isDirectory;
}

/// Phase-0 stub that rejects all cloud operations until Phase 7.
///
/// Purpose: Keep call sites compilable without a provider implementation.
/// Usage Context: Default DI until a real [CloudLibrarySource] ships.
class UnimplementedCloudLibrarySource implements CloudLibrarySource {
  /// Creates the throwing Phase-0 cloud stub.
  const UnimplementedCloudLibrarySource();

  @override
  Future<List<CloudLibraryEntry>> list(MediaLocator parent) {
    throw UnimplementedError('CloudLibrarySource.list is Phase 7');
  }

  @override
  Future<MediaLocator> downloadToCache(MediaLocator item) {
    throw UnimplementedError('CloudLibrarySource.downloadToCache is Phase 7');
  }

  @override
  Future<Uri> resolveCached(MediaLocator item) {
    throw UnimplementedError('CloudLibrarySource.resolveCached is Phase 7');
  }
}
