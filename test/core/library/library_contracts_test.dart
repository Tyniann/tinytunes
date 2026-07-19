import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/library/local_library_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/core/library/track_metadata_reader.dart';

void main() {
  test('fake LocalLibrarySource + TrackMetadataReader round-trip', () async {
    final root = MediaLocator('content://fake/tree/music');
    final track = MediaLocator('content://fake/tree/music/document/a.mp3');
    final source = _FakeLocalLibrarySource(
      root: root,
      children: [
        LibraryEntry(locator: track, name: 'a.mp3', isDirectory: false),
      ],
    );
    const reader = _FakeTrackMetadataReader(
      TrackMetadata(
        title: 'Demo',
        artist: 'Artist',
        album: 'Album',
        artworkBytes: [1, 2, 3],
      ),
    );

    final picked = await source.pickAndRetainRoot();
    expect(picked, root);
    expect(await source.hasPersistedAccess(root), isTrue);

    final listed = await source.listChildren(root);
    expect(listed, hasLength(1));
    expect(listed.single.locator, track);

    final playback = await source.resolvePlaybackUri(track);
    expect(playback.scheme, 'content');

    final path = await source.materializeReadablePath(
      track,
      fileNameHint: 'a.mp3',
    );
    expect(path, endsWith('.mp3'));

    final tags = await reader.read(path);
    expect(tags.title, 'Demo');
    expect(tags.artworkBytes, isNotEmpty);
  });

  test('MediaLocator equality uses exact token', () {
    const a = MediaLocator('content://x/tree/a');
    const b = MediaLocator('content://x/tree/a');
    const c = MediaLocator('content://x/tree/b');
    expect(a, b);
    expect(a, isNot(c));
  });
}

class _FakeLocalLibrarySource implements LocalLibrarySource {
  _FakeLocalLibrarySource({required this.root, required this.children});

  final MediaLocator root;
  final List<LibraryEntry> children;

  @override
  Future<MediaLocator?> pickAndRetainRoot() async => root;

  @override
  Future<List<LibraryEntry>> listChildren(MediaLocator parent) async {
    if (parent != root) return const [];
    return children;
  }

  @override
  Future<Uri> resolvePlaybackUri(MediaLocator item) async =>
      Uri.parse(item.value);

  @override
  Future<String> materializeReadablePath(
    MediaLocator item, {
    String? fileNameHint,
  }) async {
    final ext = (fileNameHint != null && fileNameHint.contains('.'))
        ? '.${fileNameHint.split('.').last}'
        : '.bin';
    return '/tmp/fake$ext';
  }

  @override
  Future<bool> hasPersistedAccess(MediaLocator root) async =>
      root == this.root;

  @override
  Future<List<MediaLocator>> listPersistedRoots() async => [root];

  @override
  Future<void> releaseRoot(MediaLocator root) async {}
}

class _FakeTrackMetadataReader implements TrackMetadataReader {
  const _FakeTrackMetadataReader(this.metadata);

  final TrackMetadata metadata;

  @override
  Future<TrackMetadata> read(String path) async => metadata;
}
