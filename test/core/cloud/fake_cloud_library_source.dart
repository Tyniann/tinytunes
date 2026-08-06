import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';

/// In-memory [CloudLibrarySource] for ingest tests.
class FakeCloudLibrarySource implements CloudLibrarySource {
  /// Creates a fake with [childrenByParent] keyed by locator value.
  FakeCloudLibrarySource({
    Map<String, List<CloudLibraryEntry>>? childrenByParent,
  }) : childrenByParent = childrenByParent ?? {};

  /// Parent locator value → children.
  final Map<String, List<CloudLibraryEntry>> childrenByParent;

  final Map<String, String> _cachePaths = {};

  /// How many times [downloadToCache] was called.
  int downloadCalls = 0;

  @override
  Future<List<CloudLibraryEntry>> list(MediaLocator parent) async {
    return List.unmodifiable(childrenByParent[parent.value] ?? const []);
  }

  @override
  Future<MediaLocator> downloadToCache(
    MediaLocator item, {
    void Function(int receivedBytes, int totalBytes)? onProgress,
  }) async {
    downloadCalls++;
    final path = _cachePaths[item.value] ?? '/tmp/${item.value}.mp3';
    _cachePaths[item.value] = path;
    onProgress?.call(1, 1);
    return MediaLocator(path);
  }

  @override
  Future<Uri> resolveCached(MediaLocator item) async {
    final path = _cachePaths[item.value];
    if (path == null) {
      throw CloudCacheMissException(item);
    }
    return Uri.file(path);
  }
}
