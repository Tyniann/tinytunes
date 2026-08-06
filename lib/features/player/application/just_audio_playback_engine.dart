import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tinytunes/features/player/application/playback_engine.dart';

/// Production [PlaybackEngine] backed by a single [AudioPlayer].
///
/// Purpose: Decode one `content://` (or other) URI at a time with [MediaItem]
/// tags for the notification façade.
/// Usage Context: Owned by [PlaybackController] only — never by the handler.
class JustAudioPlaybackEngine implements PlaybackEngine {
  /// Creates an engine wrapping a new [AudioPlayer].
  JustAudioPlaybackEngine() : _player = AudioPlayer();

  final AudioPlayer _player;
  final _completedController = StreamController<void>.broadcast();
  StreamSubscription<PlaybackEvent>? _eventSub;
  bool _wasCompleted = false;

  /// Wires edge-triggered completion detection once after construction.
  ///
  /// Purpose: Emit once per transition into `completed`; [AudioPlayer] may
  /// publish several events while remaining completed, which would otherwise
  /// create a Repeat One seek/play loop and exhaust device memory.
  void attachListeners() {
    _eventSub?.cancel();
    _eventSub = _player.playbackEventStream.listen((event) {
      final isCompleted = event.processingState == ProcessingState.completed;
      if (isCompleted && !_wasCompleted) {
        _completedController.add(null);
      }
      _wasCompleted = isCompleted;
    });
  }

  @override
  Future<void> setUri(Uri uri, {required MediaItem tag}) async {
    await _player.setAudioSource(AudioSource.uri(uri, tag: tag));
  }

  /// Starts playback without waiting for the current source to finish.
  @override
  Future<void> play() async {
    // just_audio's play future may remain pending until playback stops. Start
    // it without awaiting completion so the controller can immediately publish
    // `playing = true` and promote audio_service to a foreground service.
    unawaited(_player.play());
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Stream<bool> get playingStream => _player.playingStream;

  @override
  Stream<void> get completedStream => _completedController.stream;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Duration get position => _player.position;

  @override
  Duration? get duration => _player.duration;

  @override
  bool get playing => _player.playing;

  @override
  Future<void> dispose() async {
    await _eventSub?.cancel();
    await _completedController.close();
    await _player.dispose();
  }
}
