import 'package:tinytunes/core/library/media_locator.dart';

/// One child entry under a local library folder.
///
/// Purpose: Carry enough listing metadata for scan/UI without platform types.
/// Usage Context: Returned by [LocalLibrarySource.listChildren].
/// Key Params: [locator], [name], [isDirectory].
class LibraryEntry {
  /// Creates a listed child with [locator], display [name], and [isDirectory].
  const LibraryEntry({
    required this.locator,
    required this.name,
    required this.isDirectory,
  });

  /// Opaque locator for this child (document URI on Android).
  final MediaLocator locator;

  /// Display name from the platform document provider.
  final String name;

  /// Whether this entry is a directory (folder) rather than a file.
  final bool isDirectory;
}

/// Platform-backed access to a user-picked local music tree.
///
/// Purpose: Pick/retain a root, list children, and resolve items for playback
/// and metadata without exposing SAF/`file_picker` types to features.
/// Usage Context: Library ingest and playback adapters (Android first).
abstract class LocalLibrarySource {
  /// Opens the system folder picker and retains durable read access.
  ///
  /// Returns the opaque root [MediaLocator], or `null` if the user cancels.
  Future<MediaLocator?> pickAndRetainRoot();

  /// Lists one level of children under [parent] (root or subdirectory).
  Future<List<LibraryEntry>> listChildren(MediaLocator parent);

  /// Resolves [item] to a URI string suitable for audio playback.
  Future<Uri> resolvePlaybackUri(MediaLocator item);

  /// Copies [item] to a temporary readable file path for path-only tag APIs.
  ///
  /// [fileNameHint] should be the display name (e.g. `track.mp3`) so the temp
  /// file keeps a recognizable extension — many tag readers require it.
  /// Caller must delete the path (prefer `try`/`finally`). May fail for oversized
  /// files per the adapter's size budget.
  Future<String> materializeReadablePath(
    MediaLocator item, {
    String? fileNameHint,
  });


  /// Whether [root] still has a persisted read grant.
  Future<bool> hasPersistedAccess(MediaLocator root);

  /// Lists currently persisted root locator tokens (diagnostics / restore).
  Future<List<MediaLocator>> listPersistedRoots();

  /// Releases persisted access for [root] when the user forgets a folder.
  Future<void> releaseRoot(MediaLocator root);
}
