import 'package:audio_service/audio_service.dart';

/// Commands the thin [TinyTunesAudioHandler] may invoke after attach.
///
/// Purpose: Keep the handler free of Riverpod / Drift while still forwarding
/// lock-screen controls into [PlaybackController].
abstract class PlaybackRemoteCommands {
  /// Resume or start playback of the current item.
  Future<void> remotePlay();

  /// Pause playback.
  Future<void> remotePause();

  /// Stop playback.
  Future<void> remoteStop();

  /// Seek within the current item.
  Future<void> remoteSeek(Duration position);

  /// Skip to next (Off/Off).
  Future<void> remoteSkipToNext();

  /// Skip to previous (Off/Off + 3s rule).
  Future<void> remoteSkipToPrevious();
}

/// Thin `audio_service` façade with no [AudioPlayer].
///
/// Purpose: Own OS notification / media-button wiring; delegate all behavior to
/// [PlaybackRemoteCommands] after [attach]. Pre-attach intents are no-ops.
/// Usage Context: Created by [AudioService.init]; injected via
/// `audioHandlerProvider`.
class TinyTunesAudioHandler extends BaseAudioHandler with SeekHandler {
  PlaybackRemoteCommands? _remote;

  /// Binds controller commands; replaces any prior attach.
  void attach(PlaybackRemoteCommands remote) {
    _remote = remote;
  }

  /// Clears the remote so intents become no-ops again.
  void detach() {
    _remote = null;
  }

  /// Publishes notification metadata (discrete events only).
  void publishMediaItem(MediaItem? item) {
    mediaItem.add(item);
  }

  /// Publishes compact playback state for the notification.
  void publishPlaybackState({
    required bool playing,
    required Duration position,
    required AudioProcessingState processingState,
  }) {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processingState,
        playing: playing,
        updatePosition: position,
        bufferedPosition: position,
        speed: 1.0,
        queueIndex: 0,
      ),
    );
  }

  @override
  Future<void> play() async => _remote?.remotePlay();

  @override
  Future<void> pause() async => _remote?.remotePause();

  @override
  Future<void> stop() async {
    await _remote?.remoteStop();
    // Sets processingState idle so Android tears down FGS + notification.
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async => _remote?.remoteSeek(position);

  @override
  Future<void> skipToNext() async => _remote?.remoteSkipToNext();

  @override
  Future<void> skipToPrevious() async => _remote?.remoteSkipToPrevious();

  /// Swipe-away / task removed: stop audio and dismiss the notification promptly.
  @override
  Future<void> onTaskRemoved() => stop();
}
