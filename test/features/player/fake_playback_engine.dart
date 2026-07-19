import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:tinytunes/features/player/application/playback_engine.dart';

/// In-memory [PlaybackEngine] for unit/widget tests (no platform audio).
class FakePlaybackEngine implements PlaybackEngine {
  final _playingController = StreamController<bool>.broadcast();
  final _completedController = StreamController<void>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();

  MediaItem? lastTag;
  Uri? lastUri;
  bool failNextSetUri = false;
  int setUriCount = 0;

  Duration _position = Duration.zero;
  Duration? _duration = const Duration(minutes: 3);
  bool _playing = false;

  /// Emits a natural completion event for the current generation tests.
  void emitCompleted() => _completedController.add(null);

  @override
  Future<void> setUri(Uri uri, {required MediaItem tag}) async {
    setUriCount++;
    if (failNextSetUri) {
      failNextSetUri = false;
      throw StateError('fake setUri failure');
    }
    lastUri = uri;
    lastTag = tag;
    _position = Duration.zero;
    _duration = const Duration(minutes: 3);
    _durationController.add(_duration);
    _positionController.add(_position);
  }

  @override
  Future<void> play() async {
    _playing = true;
    _playingController.add(true);
  }

  @override
  Future<void> pause() async {
    _playing = false;
    _playingController.add(false);
  }

  @override
  Future<void> seek(Duration position) async {
    _position = position;
    _positionController.add(position);
  }

  @override
  Future<void> stop() async {
    _playing = false;
    _playingController.add(false);
    _position = Duration.zero;
    _positionController.add(_position);
  }

  @override
  Stream<bool> get playingStream => _playingController.stream;

  @override
  Stream<void> get completedStream => _completedController.stream;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration?> get durationStream => _durationController.stream;

  @override
  Duration get position => _position;

  @override
  Duration? get duration => _duration;

  @override
  bool get playing => _playing;

  @override
  Future<void> dispose() async {
    await _playingController.close();
    await _completedController.close();
    await _positionController.close();
    await _durationController.close();
  }
}
