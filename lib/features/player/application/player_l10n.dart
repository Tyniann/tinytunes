/// Localized (or test) copy for [PlaybackController] reporting.
///
/// Purpose: Keep [MessageReporter] free of [BuildContext] while still shipping
/// localized strings from the UI layer; english defaults for early restore /
/// background paths before gen-l10n is available.
class PlayerL10n {
  /// Creates player copy strings.
  const PlayerL10n({
    required this.fileMissing,
    required this.loadFailed,
    required this.restoreSkipped,
    required this.skipBoundReached,
  });

  /// English defaults for unit tests and pre-UI restore.
  const PlayerL10n.english()
      : fileMissing = 'Track file is missing or inaccessible.',
        loadFailed = 'Could not load track for playback.',
        restoreSkipped = 'Previous track is no longer in the queue.',
        skipBoundReached =
            'Stopped after several unplayable tracks in a row.';

  /// `player.file.missing` toast/body.
  final String fileMissing;

  /// `player.load.failed` toast/body.
  final String loadFailed;

  /// `player.restore.skipped` toast/body.
  final String restoreSkipped;

  /// `player.skip.bound` toast/body.
  final String skipBoundReached;
}
