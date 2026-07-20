// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Application-lifetime playback controller (Shuffle × Repeat matrix).
///
/// Purpose: Own the single [PlaybackEngine], Drift resume checkpoints, queue
/// mutation skip, session noisy/interrupt policy, and in-memory shuffle
/// session; feed the thin [TinyTunesAudioHandler].
/// Usage Context: Eagerly read from `main` after handler override; home transport
/// and row taps call public intents.

@ProviderFor(PlaybackController)
final playbackControllerProvider = PlaybackControllerProvider._();

/// Application-lifetime playback controller (Shuffle × Repeat matrix).
///
/// Purpose: Own the single [PlaybackEngine], Drift resume checkpoints, queue
/// mutation skip, session noisy/interrupt policy, and in-memory shuffle
/// session; feed the thin [TinyTunesAudioHandler].
/// Usage Context: Eagerly read from `main` after handler override; home transport
/// and row taps call public intents.
final class PlaybackControllerProvider
    extends $NotifierProvider<PlaybackController, PlaybackUiState> {
  /// Application-lifetime playback controller (Shuffle × Repeat matrix).
  ///
  /// Purpose: Own the single [PlaybackEngine], Drift resume checkpoints, queue
  /// mutation skip, session noisy/interrupt policy, and in-memory shuffle
  /// session; feed the thin [TinyTunesAudioHandler].
  /// Usage Context: Eagerly read from `main` after handler override; home transport
  /// and row taps call public intents.
  PlaybackControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackControllerHash();

  @$internal
  @override
  PlaybackController create() => PlaybackController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackUiState>(value),
    );
  }
}

String _$playbackControllerHash() =>
    r'36eca32034f61187e515de134917353ae25ad170';

/// Application-lifetime playback controller (Shuffle × Repeat matrix).
///
/// Purpose: Own the single [PlaybackEngine], Drift resume checkpoints, queue
/// mutation skip, session noisy/interrupt policy, and in-memory shuffle
/// session; feed the thin [TinyTunesAudioHandler].
/// Usage Context: Eagerly read from `main` after handler override; home transport
/// and row taps call public intents.

abstract class _$PlaybackController extends $Notifier<PlaybackUiState> {
  PlaybackUiState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PlaybackUiState, PlaybackUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlaybackUiState, PlaybackUiState>,
              PlaybackUiState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
