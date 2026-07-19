/// Stable message codes for player reporting (frozen for Phase 3).
abstract final class PlayerMessageCodes {
  /// Resolve/SAF/unavailable current file.
  static const fileMissing = 'player.file.missing';

  /// Engine / `setAudioSource` failure.
  static const loadFailed = 'player.load.failed';

  /// Cold-start entry no longer in queue.
  static const restoreSkipped = 'player.restore.skipped';

  /// Stopped after too many consecutive unplayable skips.
  static const skipBoundReached = 'player.skip.bound';
}
