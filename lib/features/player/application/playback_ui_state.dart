/// Immutable UI snapshot for transport chrome and row highlight.
///
/// Purpose: Drive home transport without exposing engine internals.
class PlaybackUiState {
  /// Creates a UI snapshot.
  const PlaybackUiState({
    this.currentQueueEntryId,
    this.playing = false,
    this.position = Duration.zero,
    this.duration,
  });

  /// Idle / nothing loaded.
  static const idle = PlaybackUiState();

  /// Current queue entry id, if any.
  final int? currentQueueEntryId;

  /// Whether audio is playing.
  final bool playing;

  /// Current position.
  final Duration position;

  /// Known duration, if any.
  final Duration? duration;

  /// Copy with selective overrides.
  PlaybackUiState copyWith({
    int? currentQueueEntryId,
    bool clearCurrent = false,
    bool? playing,
    Duration? position,
    Duration? duration,
    bool clearDuration = false,
  }) {
    return PlaybackUiState(
      currentQueueEntryId:
          clearCurrent ? null : (currentQueueEntryId ?? this.currentQueueEntryId),
      playing: playing ?? this.playing,
      position: position ?? this.position,
      duration: clearDuration ? null : (duration ?? this.duration),
    );
  }
}
