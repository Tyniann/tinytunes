import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tinytunes/features/player/application/just_audio_playback_engine.dart';
import 'package:tinytunes/features/player/application/playback_engine.dart';
import 'package:tinytunes/features/player/application/tinytunes_audio_handler.dart';

part 'player_providers.g.dart';

/// Injected [TinyTunesAudioHandler] from [AudioService.init] (or a test fake).
///
/// Purpose: Avoid a hidden singleton — `main` overrides with the init result;
/// tests supply a detached handler without starting the OS service.
final audioHandlerProvider = Provider<TinyTunesAudioHandler>((ref) {
  throw StateError(
    'audioHandlerProvider must be overridden with the AudioService.init handler '
    '(or a test fake).',
  );
});

/// Application-lifetime [PlaybackEngine]; tests override with a fake.
@Riverpod(keepAlive: true)
PlaybackEngine playbackEngine(Ref ref) {
  final engine = JustAudioPlaybackEngine();
  ref.onDispose(engine.dispose);
  return engine;
}
