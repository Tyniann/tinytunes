// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [Random] for shuffle picks; tests override with a seeded instance.

@ProviderFor(playbackRandom)
final playbackRandomProvider = PlaybackRandomProvider._();

/// [Random] for shuffle picks; tests override with a seeded instance.

final class PlaybackRandomProvider
    extends $FunctionalProvider<Random, Random, Random>
    with $Provider<Random> {
  /// [Random] for shuffle picks; tests override with a seeded instance.
  PlaybackRandomProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackRandomProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackRandomHash();

  @$internal
  @override
  $ProviderElement<Random> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Random create(Ref ref) {
    return playbackRandom(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Random value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Random>(value),
    );
  }
}

String _$playbackRandomHash() => r'5ee0fbd9b999afab8f56fabdc14b63999ad1f13e';

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

/// Application-lifetime OS media volume seam; tests override with a fake.

@ProviderFor(systemVolumeSource)
final systemVolumeSourceProvider = SystemVolumeSourceProvider._();

/// Application-lifetime OS media volume seam; tests override with a fake.

final class SystemVolumeSourceProvider
    extends
        $FunctionalProvider<
          SystemVolumeSource,
          SystemVolumeSource,
          SystemVolumeSource
        >
    with $Provider<SystemVolumeSource> {
  /// Application-lifetime OS media volume seam; tests override with a fake.
  SystemVolumeSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemVolumeSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemVolumeSourceHash();

  @$internal
  @override
  $ProviderElement<SystemVolumeSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SystemVolumeSource create(Ref ref) {
    return systemVolumeSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SystemVolumeSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SystemVolumeSource>(value),
    );
  }
}

String _$systemVolumeSourceHash() =>
    r'd904af2d246f9f586c7741afe9918db4a3fb3f1f';

/// Live system volume (`0.0`–`1.0`) synced with hardware and the transport slider.
///
/// Purpose: Keep chrome volume UI in lockstep with OS media volume.
/// Usage Context: [TransportChrome] expandable volume row.

@ProviderFor(SystemVolume)
final systemVolumeProvider = SystemVolumeProvider._();

/// Live system volume (`0.0`–`1.0`) synced with hardware and the transport slider.
///
/// Purpose: Keep chrome volume UI in lockstep with OS media volume.
/// Usage Context: [TransportChrome] expandable volume row.
final class SystemVolumeProvider
    extends $AsyncNotifierProvider<SystemVolume, double> {
  /// Live system volume (`0.0`–`1.0`) synced with hardware and the transport slider.
  ///
  /// Purpose: Keep chrome volume UI in lockstep with OS media volume.
  /// Usage Context: [TransportChrome] expandable volume row.
  SystemVolumeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemVolumeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemVolumeHash();

  @$internal
  @override
  SystemVolume create() => SystemVolume();
}

String _$systemVolumeHash() => r'4419bc70ff34e3739a8abf0930068385b7d4b734';

/// Live system volume (`0.0`–`1.0`) synced with hardware and the transport slider.
///
/// Purpose: Keep chrome volume UI in lockstep with OS media volume.
/// Usage Context: [TransportChrome] expandable volume row.

abstract class _$SystemVolume extends $AsyncNotifier<double> {
  FutureOr<double> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<double>, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<double>, double>,
              AsyncValue<double>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
