import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/cloud_media_locator.dart';
import 'package:tinytunes/core/cloud/cloud_provider_id.dart';
import 'package:tinytunes/core/library/media_locator.dart';

/// [CloudLibrarySource] that routes by locator prefix to provider sources.
///
/// Purpose: Keep ingest/playback on one [CloudLibrarySource] while Google and
/// OneDrive implementations stay isolated.
/// Usage Context: Production [cloudLibrarySourceProvider] composition.
class DelegatingCloudLibrarySource implements CloudLibrarySource {
  /// Creates a router over [sources] keyed by [CloudProviderId].
  DelegatingCloudLibrarySource(Map<CloudProviderId, CloudLibrarySource> sources)
    : _sources = Map.unmodifiable(sources);

  final Map<CloudProviderId, CloudLibrarySource> _sources;

  CloudLibrarySource _sourceFor(MediaLocator locator) {
    final provider = CloudMediaLocator.providerOf(locator);
    final source = _sources[provider];
    if (source == null) {
      throw StateError(
        'No CloudLibrarySource registered for ${provider.token}',
      );
    }
    return source;
  }

  @override
  Future<List<CloudLibraryEntry>> list(MediaLocator parent) {
    return _sourceFor(parent).list(parent);
  }

  @override
  Future<MediaLocator> downloadToCache(
    MediaLocator item, {
    void Function(int receivedBytes, int totalBytes)? onProgress,
  }) {
    return _sourceFor(item).downloadToCache(item, onProgress: onProgress);
  }

  @override
  Future<Uri> resolveCached(MediaLocator item) {
    return _sourceFor(item).resolveCached(item);
  }
}
