import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tinytunes/features/player/application/device_system_volume_source.dart';
import 'package:tinytunes/features/player/application/just_audio_playback_engine.dart';
import 'package:tinytunes/features/player/application/playback_engine.dart';
import 'package:tinytunes/features/player/application/system_volume_source.dart';
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

/// [Random] for shuffle picks; tests override with a seeded instance.
@Riverpod(keepAlive: true)
Random playbackRandom(Ref ref) => Random();

/// Application-lifetime [PlaybackEngine]; tests override with a fake.
@Riverpod(keepAlive: true)
PlaybackEngine playbackEngine(Ref ref) {
  final engine = JustAudioPlaybackEngine();
  ref.onDispose(engine.dispose);
  return engine;
}

/// Application-lifetime OS media volume seam; tests override with a fake.
@Riverpod(keepAlive: true)
SystemVolumeSource systemVolumeSource(Ref ref) {
  final source = DeviceSystemVolumeSource();
  ref.onDispose(source.dispose);
  return source;
}

/// Live system volume (`0.0`–`1.0`) synced with hardware and the transport slider.
///
/// Purpose: Keep chrome volume UI in lockstep with OS media volume.
/// Usage Context: [TransportChrome] expandable volume row.
@Riverpod(keepAlive: true)
class SystemVolume extends _$SystemVolume {
  @override
  Future<double> build() async {
    final source = ref.watch(systemVolumeSourceProvider);
    final sub = source.volumeChanges.listen((volume) {
      state = AsyncData(volume.clamp(0.0, 1.0).toDouble());
    });
    ref.onDispose(sub.cancel);
    return (await source.getVolume()).clamp(0.0, 1.0).toDouble();
  }

  /// Writes [volume] to the OS media stream and optimistically updates UI state.
  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0).toDouble();
    state = AsyncData(clamped);
    await ref.read(systemVolumeSourceProvider).setVolume(clamped);
  }
}
