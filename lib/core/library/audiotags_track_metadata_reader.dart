import 'package:audiotags/audiotags.dart';
import 'package:tinytunes/core/library/track_metadata_reader.dart';

/// [TrackMetadataReader] backed by the `audiotags` package (path-only).
///
/// Purpose: Extract title/artist/album/artwork from a readable filesystem path.
/// Usage Context: After [LocalLibrarySource.materializeReadablePath].
class AudiotagsTrackMetadataReader implements TrackMetadataReader {
  /// Creates the path-based audiotags reader.
  const AudiotagsTrackMetadataReader();

  @override
  Future<TrackMetadata> read(String path) async {
    final tag = await AudioTags.read(path);
    if (tag == null) {
      return const TrackMetadata();
    }
    return TrackMetadata(
      title: tag.title,
      artist: tag.trackArtist,
      album: tag.album,
      artworkBytes: tag.pictures.isEmpty ? null : tag.pictures.first.bytes,
    );
  }
}
