/// Read-only audio tags and embedded artwork for a local file.
///
/// Purpose: Decouple tag extraction from a concrete package (`audiotags`).
/// Usage Context: Library scan and now-playing metadata enrichment.
class TrackMetadata {
  /// Creates tag fields extracted from a readable audio source.
  const TrackMetadata({
    this.title,
    this.artist,
    this.album,
    this.artworkBytes,
  });

  /// Track title when present in tags.
  final String? title;

  /// Primary artist when present in tags.
  final String? artist;

  /// Album name when present in tags.
  final String? album;

  /// Embedded cover art bytes when present; `null` if absent or unread.
  final List<int>? artworkBytes;
}

/// Reads title/artist/album/artwork from a readable audio source.
///
/// Purpose: Keep metadata backends swappable behind one app-facing API.
/// Usage Context: Called after [LocalLibrarySource.materializeReadablePath]
/// (temp path must include a real audio extension).
abstract class TrackMetadataReader {
  /// Reads tags from a temporary or otherwise readable filesystem [path].
  Future<TrackMetadata> read(String path);
}
