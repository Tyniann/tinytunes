import 'package:tinytunes/core/library/media_locator.dart';

/// Result of the Add-cloud-folder picker dialogs.
///
/// Purpose: Carry the chosen Drive folder and recurse flag into ingest without
/// binding [LibraryIngestController] to Flutter dialogs.
class CloudFolderPick {
  /// Creates a pick for [locator] with [displayName] and [includeSubfolders].
  const CloudFolderPick({
    required this.locator,
    required this.displayName,
    required this.includeSubfolders,
  });

  /// Opaque `gdrive:` folder locator.
  final MediaLocator locator;

  /// Folder display name for `library_roots.display_name`.
  final String displayName;

  /// When `true`, walk all nested folders; when `false`, only this folder's files.
  final bool includeSubfolders;
}
