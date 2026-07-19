/// Why [PlaybackController] advances past the current queue entry.
///
/// Purpose: Single seam for Off/Off Phase 3 and Phase 4 matrix policies without
/// changing [TinyTunesAudioHandler].
enum AdvanceReason {
  /// Natural end of the current track.
  completed,

  /// User or lock-screen Next.
  manualNext,

  /// Current queue row vanished (remove / forget / clear path).
  currentRemoved,

  /// Resolve or load failure on the candidate track.
  unplayable,
}
