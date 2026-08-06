import 'package:tinytunes/features/player/application/repeat_mode.dart';

/// Immutable UI snapshot for transport chrome and row highlight.
///
/// Purpose: Drive home transport without exposing engine internals. Shuffle /
/// repeat are preferences and survive clear/stop separately from now-playing.
class PlaybackUiState {
  /// Creates a UI snapshot.
  const PlaybackUiState({
    this.currentQueueEntryId,
    this.playing = false,
    this.position = Duration.zero,
    this.duration,
    this.shuffleEnabled = false,
    this.repeatMode = RepeatMode.off,
    this.downloading = false,
    this.downloadProgress,
  });

  /// Idle / nothing loaded (modes default Off until restore or toggles).
  static const idle = PlaybackUiState();

  /// Current queue entry id, if any.
  final int? currentQueueEntryId;

  /// Whether audio is playing.
  final bool playing;

  /// Current position.
  final Duration position;

  /// Known duration, if any.
  final Duration? duration;

  /// Shuffle transport toggle.
  final bool shuffleEnabled;

  /// Repeat transport cycle value.
  final RepeatMode repeatMode;

  /// Whether a cloud track download is in progress before play.
  final bool downloading;

  /// Download fraction `0..1` when total size is known; `null` → indeterminate.
  final double? downloadProgress;

  /// Copy with selective overrides.
  PlaybackUiState copyWith({
    int? currentQueueEntryId,
    bool clearCurrent = false,
    bool? playing,
    Duration? position,
    Duration? duration,
    bool clearDuration = false,
    bool? shuffleEnabled,
    RepeatMode? repeatMode,
    bool? downloading,
    double? downloadProgress,
    bool clearDownloadProgress = false,
  }) {
    return PlaybackUiState(
      currentQueueEntryId: clearCurrent
          ? null
          : (currentQueueEntryId ?? this.currentQueueEntryId),
      playing: playing ?? this.playing,
      position: position ?? this.position,
      duration: clearDuration ? null : (duration ?? this.duration),
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      downloading: downloading ?? this.downloading,
      downloadProgress: clearDownloadProgress
          ? null
          : (downloadProgress ?? this.downloadProgress),
    );
  }
}
