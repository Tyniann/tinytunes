// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Application-lifetime [PlaybackEngine]; tests override with a fake.

@ProviderFor(playbackEngine)
final playbackEngineProvider = PlaybackEngineProvider._();

/// Application-lifetime [PlaybackEngine]; tests override with a fake.

final class PlaybackEngineProvider
    extends $FunctionalProvider<PlaybackEngine, PlaybackEngine, PlaybackEngine>
    with $Provider<PlaybackEngine> {
  /// Application-lifetime [PlaybackEngine]; tests override with a fake.
  PlaybackEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackEngineHash();

  @$internal
  @override
  $ProviderElement<PlaybackEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlaybackEngine create(Ref ref) {
    return playbackEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackEngine>(value),
    );
  }
}

String _$playbackEngineHash() => r'fd4d9f6e10e8e82275c3f2b888ac67809c8a29d7';
