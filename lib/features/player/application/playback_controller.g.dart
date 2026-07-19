// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Application-lifetime Off/Off playback controller.
///
/// Purpose: Own the single [PlaybackEngine], Drift resume checkpoints, queue
/// mutation skip, and session noisy/interrupt policy; feed the thin
/// [TinyTunesAudioHandler].
/// Usage Context: Eagerly read from `main` after handler override; home transport
/// and row taps call public intents.

@ProviderFor(PlaybackController)
final playbackControllerProvider = PlaybackControllerProvider._();

/// Application-lifetime Off/Off playback controller.
///
/// Purpose: Own the single [PlaybackEngine], Drift resume checkpoints, queue
/// mutation skip, and session noisy/interrupt policy; feed the thin
/// [TinyTunesAudioHandler].
/// Usage Context: Eagerly read from `main` after handler override; home transport
/// and row taps call public intents.
final class PlaybackControllerProvider
    extends $NotifierProvider<PlaybackController, PlaybackUiState> {
  /// Application-lifetime Off/Off playback controller.
  ///
  /// Purpose: Own the single [PlaybackEngine], Drift resume checkpoints, queue
  /// mutation skip, and session noisy/interrupt policy; feed the thin
  /// [TinyTunesAudioHandler].
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
    r'be8fe59bbe715dccb846a4d1c915ad3c02604e77';

/// Application-lifetime Off/Off playback controller.
///
/// Purpose: Own the single [PlaybackEngine], Drift resume checkpoints, queue
/// mutation skip, and session noisy/interrupt policy; feed the thin
/// [TinyTunesAudioHandler].
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
