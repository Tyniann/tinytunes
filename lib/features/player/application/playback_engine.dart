import 'dart:async';

import 'package:audio_service/audio_service.dart';

/// Testable seam over the single app-lifetime audio decoder.
///
/// Purpose: Let [PlaybackController] drive play/load without binding tests to a
/// real [AudioPlayer] or platform channels.
/// Usage Context: Production [JustAudioPlaybackEngine]; fakes in `pump_app`.
abstract class PlaybackEngine {
  /// Loads one URI with notification metadata; replaces any prior source.
  Future<void> setUri(Uri uri, {required MediaItem tag});

  /// Starts or resumes playback.
  Future<void> play();

  /// Pauses playback.
  Future<void> pause();

  /// Seeks within the current source.
  Future<void> seek(Duration position);

  /// Stops playback and clears the active source when possible.
  Future<void> stop();

  /// Whether the engine considers itself playing.
  Stream<bool> get playingStream;

  /// Fires when the current source completes naturally.
  Stream<void> get completedStream;

  /// Position updates while a source is loaded.
  Stream<Duration> get positionStream;

  /// Duration when known; may emit null while loading.
  Stream<Duration?> get durationStream;

  /// Current position snapshot.
  Duration get position;

  /// Current duration snapshot, if known.
  Duration? get duration;

  /// Whether currently playing.
  bool get playing;

  /// Releases native resources.
  Future<void> dispose();
}
