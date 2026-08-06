/// Catalog `source_kind` values written to Drift roots/tracks.
///
/// Purpose: Single place for local vs cloud origin tokens.
abstract final class SourceKinds {
  /// SAF / local library roots and tracks.
  static const local = 'local';

  /// Google Drive (Phase 7) roots and tracks.
  static const cloud = 'cloud';
}
