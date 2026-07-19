import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/core/messages/session_message.dart';
import 'package:tinytunes/features/library/application/library_providers.dart';
import 'package:tinytunes/features/player/application/advance_reason.dart';
import 'package:tinytunes/features/player/application/just_audio_playback_engine.dart';
import 'package:tinytunes/features/player/application/playback_engine.dart';
import 'package:tinytunes/features/player/application/playback_ui_state.dart';
import 'package:tinytunes/features/player/application/player_l10n.dart';
import 'package:tinytunes/features/player/application/player_message_codes.dart';
import 'package:tinytunes/features/player/application/player_providers.dart';
import 'package:tinytunes/features/player/application/tinytunes_audio_handler.dart';

part 'playback_controller.g.dart';

/// Application-lifetime Off/Off playback controller.
///
/// Purpose: Own the single [PlaybackEngine], Drift resume checkpoints, queue
/// mutation skip, and session noisy/interrupt policy; feed the thin
/// [TinyTunesAudioHandler].
/// Usage Context: Eagerly read from `main` after handler override; home transport
/// and row taps call public intents.
@Riverpod(keepAlive: true)
class PlaybackController extends _$PlaybackController
    implements PlaybackRemoteCommands {
  static const _prevRestartThreshold = Duration(seconds: 3);
  static const _positionThrottle = Duration(seconds: 2);
  static const _maxConsecutiveUnplayable = 5;

  late PlaybackEngine _engine;
  TinyTunesAudioHandler? _handler;
  _PlaybackLifecycleObserver? _lifecycleObserver;

  int _generation = 0;
  int _loadedGeneration = -1;
  bool _restoreStarted = false;
  bool _sessionConfigured = false;
  bool _toastsReady = false;
  bool _initialized = false;
  int _consecutiveUnplayable = 0;
  DateTime? _lastCheckpointAt;

  List<QueueTrackView> _queue = const [];
  PlayerL10n _l10n = const PlayerL10n.english();

  StreamSubscription<void>? _completedSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<List<QueueTrackView>>? _queueSub;
  StreamSubscription<void>? _noisySub;
  StreamSubscription<AudioInterruptionEvent>? _interruptSub;

  @override
  PlaybackUiState build() {
    if (!_initialized) {
      _initialized = true;
      _engine = ref.read(playbackEngineProvider);
      if (_engine is JustAudioPlaybackEngine) {
        (_engine as JustAudioPlaybackEngine).attachListeners();
      }
      _attachEngineListeners();
      _attachHandler();
      _watchQueue();
      unawaited(_ensureSession());
      _lifecycleObserver = _PlaybackLifecycleObserver(
        onPausedOrDetached: () => unawaited(_checkpoint(force: true)),
      );
      WidgetsBinding.instance.addObserver(_lifecycleObserver!);
      ref.onDispose(_disposeController);
      Future.microtask(_restoreOnLaunch);
    }

    return PlaybackUiState.idle;
  }

  /// Marks toast overlay as mounted so later reports may toast.
  void markToastsReady() {
    _toastsReady = true;
  }

  /// Optional localized copy from the UI layer (defaults to english).
  void updateL10n(PlayerL10n l10n) {
    _l10n = l10n;
  }

  /// Plays [queueEntryId], or toggles pause when it is already current.
  Future<void> playEntry(int queueEntryId) async {
    if (state.currentQueueEntryId == queueEntryId) {
      await togglePlayPause();
      return;
    }
    final view = _viewFor(queueEntryId);
    if (view == null) return;
    await _loadAndPlay(view, position: Duration.zero, autoplay: true);
  }

  /// Toggles play/pause for the current item.
  Future<void> togglePlayPause() async {
    if (state.currentQueueEntryId == null) return;
    if (_engine.playing) {
      await pauseAndCheckpoint();
    } else {
      await _engine.play();
      _pushHandlerState(playing: true);
      state = state.copyWith(playing: true);
    }
  }

  /// Seeks within the current track and checkpoints.
  Future<void> seekTo(Duration position) async {
    if (state.currentQueueEntryId == null) return;
    await _engine.seek(position);
    state = state.copyWith(position: position);
    await _checkpoint(force: true);
    _pushHandlerState(playing: _engine.playing);
  }

  /// Off/Off next (no wrap).
  Future<void> next() => advanceAfterCurrentGone(
        reason: AdvanceReason.manualNext,
      );

  /// Off/Off previous with 3s restart rule.
  Future<void> previous() async {
    final currentId = state.currentQueueEntryId;
    if (currentId == null) return;

    if (state.position > _prevRestartThreshold) {
      await seekTo(Duration.zero);
      return;
    }

    final index = _queue.indexWhere((e) => e.queueEntryId == currentId);
    if (index <= 0) {
      await seekTo(Duration.zero);
      return;
    }

    await _loadAndPlay(
      _queue[index - 1],
      position: Duration.zero,
      autoplay: true,
    );
  }

  /// Shared advance seam for Phase 3 Off/Off (Phase 4 swaps policy later).
  Future<void> advanceAfterCurrentGone({
    required AdvanceReason reason,
    int? preferredSuccessorId,
  }) async {
    switch (reason) {
      case AdvanceReason.completed:
        await _advanceCompleted();
      case AdvanceReason.manualNext:
        await _advanceManualNext();
      case AdvanceReason.currentRemoved:
        await _advanceToSuccessor(
          preferredSuccessorId,
          autoplay: true,
        );
      case AdvanceReason.unplayable:
        await _advanceUnplayable(preferredSuccessorId);
    }
  }

  @override
  Future<void> remotePlay() async {
    if (state.currentQueueEntryId == null) return;
    await _engine.play();
    _pushHandlerState(playing: true);
    state = state.copyWith(playing: true);
  }

  @override
  Future<void> remotePause() => pauseAndCheckpoint();

  @override
  Future<void> remoteStop() async {
    await _engine.stop();
    await _clearNowPlaying();
  }

  @override
  Future<void> remoteSeek(Duration position) => seekTo(position);

  @override
  Future<void> remoteSkipToNext() => next();

  @override
  Future<void> remoteSkipToPrevious() => previous();

  /// Pauses, checkpoints, and updates handler state.
  Future<void> pauseAndCheckpoint() async {
    await _engine.pause();
    state = state.copyWith(playing: false, position: _engine.position);
    await _checkpoint(force: true);
    _pushHandlerState(playing: false);
  }

  void _attachEngineListeners() {
    _completedSub = _engine.completedStream.listen((_) {
      unawaited(_onCompleted());
    });
    _positionSub = _engine.positionStream.listen((position) {
      if (state.currentQueueEntryId == null) return;
      state = state.copyWith(position: position);
      unawaited(_checkpoint(force: false));
    });
    _durationSub = _engine.durationStream.listen((duration) {
      state = state.copyWith(
        duration: duration,
        clearDuration: duration == null,
      );
    });
    _playingSub = _engine.playingStream.listen((playing) {
      if (state.currentQueueEntryId == null) return;
      state = state.copyWith(playing: playing);
    });
  }

  void _attachHandler() {
    final handler = ref.read(audioHandlerProvider);
    _handler = handler;
    handler.attach(this);
  }

  void _watchQueue() {
    _queueSub?.cancel();
    final db = ref.read(appDatabaseProvider);
    _queueSub = db.watchOrderedQueue().listen((next) {
      unawaited(_onQueueChanged(next));
    });
  }

  Future<void> _ensureSession() async {
    if (_sessionConfigured) return;
    _sessionConfigured = true;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _noisySub = session.becomingNoisyEventStream.listen((_) {
        unawaited(pauseAndCheckpoint());
      });
      _interruptSub = session.interruptionEventStream.listen((event) {
        if (event.begin) {
          unawaited(pauseAndCheckpoint());
        }
      });
    } on Object {
      // Host tests / unsupported platforms — ignore session wiring.
    }
  }

  Future<void> _restoreOnLaunch() async {
    if (_restoreStarted) return;
    _restoreStarted = true;

    final db = ref.read(appDatabaseProvider);
    _queue = await db.getOrderedQueue();
    final playback = await db.getPlaybackState();
    final entryId = playback.currentQueueEntryId;
    if (entryId == null) return;

    final view = _viewFor(entryId);
    if (view == null) {
      _report(
        code: PlayerMessageCodes.restoreSkipped,
        message: _l10n.restoreSkipped,
        error: false,
        sessionOnly: true,
      );
      await db.checkpoint(entryId: null, positionMs: 0);
      return;
    }

    await _loadAndPlay(
      view,
      position: Duration(milliseconds: playback.positionMs),
      autoplay: false,
      sessionOnlyErrors: true,
    );
  }

  Future<void> _onQueueChanged(List<QueueTrackView> next) async {
    final previous = _queue;
    final currentId = state.currentQueueEntryId;
    _queue = next;

    if (currentId == null) return;

    if (next.isEmpty) {
      await _engine.stop();
      await _clearNowPlaying();
      return;
    }

    final stillThere = next.any((e) => e.queueEntryId == currentId);
    if (stillThere) return;

    final successor = _successorFromSuffix(
      oldQueue: previous,
      vanishedId: currentId,
      newQueue: next,
    );
    await advanceAfterCurrentGone(
      reason: AdvanceReason.currentRemoved,
      preferredSuccessorId: successor,
    );
  }

  int? _successorFromSuffix({
    required List<QueueTrackView> oldQueue,
    required int vanishedId,
    required List<QueueTrackView> newQueue,
  }) {
    final start = oldQueue.indexWhere((e) => e.queueEntryId == vanishedId);
    if (start < 0) {
      return newQueue.isEmpty ? null : newQueue.first.queueEntryId;
    }
    final newIds = newQueue.map((e) => e.queueEntryId).toSet();
    for (var i = start + 1; i < oldQueue.length; i++) {
      final id = oldQueue[i].queueEntryId;
      if (newIds.contains(id)) return id;
    }
    return null;
  }

  Future<void> _onCompleted() async {
    if (_generation != _loadedGeneration) return;
    await advanceAfterCurrentGone(reason: AdvanceReason.completed);
  }

  Future<void> _advanceCompleted() async {
    final currentId = state.currentQueueEntryId;
    if (currentId == null) return;
    final index = _queue.indexWhere((e) => e.queueEntryId == currentId);
    if (index < 0) return;

    if (index >= _queue.length - 1) {
      final end = _engine.duration ?? _engine.position;
      await _engine.pause();
      await _engine.seek(end);
      state = state.copyWith(
        playing: false,
        position: end,
        duration: _engine.duration,
      );
      await _checkpoint(force: true);
      _pushHandlerState(playing: false);
      return;
    }

    await _loadAndPlay(
      _queue[index + 1],
      position: Duration.zero,
      autoplay: true,
    );
  }

  Future<void> _advanceManualNext() async {
    final currentId = state.currentQueueEntryId;
    if (currentId == null) return;
    final index = _queue.indexWhere((e) => e.queueEntryId == currentId);
    if (index < 0 || index >= _queue.length - 1) return;
    await _loadAndPlay(
      _queue[index + 1],
      position: Duration.zero,
      autoplay: true,
    );
  }

  Future<void> _advanceToSuccessor(
    int? preferredSuccessorId, {
    required bool autoplay,
  }) async {
    if (preferredSuccessorId == null) {
      await _engine.stop();
      await _clearNowPlaying();
      return;
    }
    final view = _viewFor(preferredSuccessorId);
    if (view == null) {
      await _engine.stop();
      await _clearNowPlaying();
      return;
    }
    await _loadAndPlay(view, position: Duration.zero, autoplay: autoplay);
  }

  Future<void> _advanceUnplayable(int? preferredSuccessorId) async {
    _consecutiveUnplayable++;
    if (_consecutiveUnplayable >= _maxConsecutiveUnplayable) {
      _report(
        code: PlayerMessageCodes.skipBoundReached,
        message: _l10n.skipBoundReached,
        error: true,
      );
      await _engine.pause();
      state = state.copyWith(playing: false, position: _engine.position);
      await _checkpoint(force: true);
      _pushHandlerState(playing: false);
      _consecutiveUnplayable = 0;
      return;
    }

    // Only the explicit successor after the failed candidate — do not fall
    // back to next-after-current (that re-selects the failed row).
    if (preferredSuccessorId == null) {
      await _engine.pause();
      state = state.copyWith(playing: false, position: _engine.position);
      await _checkpoint(force: true);
      _pushHandlerState(playing: false);
      return;
    }

    final view = _viewFor(preferredSuccessorId);
    if (view == null) {
      await _engine.pause();
      state = state.copyWith(playing: false, position: _engine.position);
      await _checkpoint(force: true);
      _pushHandlerState(playing: false);
      return;
    }
    await _loadAndPlay(view, position: Duration.zero, autoplay: true);
  }

  int? _nextAfter(int? entryId) {
    if (entryId == null) {
      return _queue.isEmpty ? null : _queue.first.queueEntryId;
    }
    final index = _queue.indexWhere((e) => e.queueEntryId == entryId);
    if (index < 0 || index >= _queue.length - 1) return null;
    return _queue[index + 1].queueEntryId;
  }

  Future<void> _loadAndPlay(
    QueueTrackView view, {
    required Duration position,
    required bool autoplay,
    bool sessionOnlyErrors = false,
  }) async {
    final gen = ++_generation;

    Uri uri;
    try {
      final source = ref.read(localLibrarySourceProvider);
      uri = await source.resolvePlaybackUri(MediaLocator(view.locator));
    } on Object {
      if (gen != _generation) return;
      _report(
        code: PlayerMessageCodes.fileMissing,
        message: _l10n.fileMissing,
        error: true,
        sessionOnly: sessionOnlyErrors,
      );
      await advanceAfterCurrentGone(
        reason: AdvanceReason.unplayable,
        preferredSuccessorId: _nextAfter(view.queueEntryId),
      );
      return;
    }

    try {
      final tag = MediaItem(
        id: view.trackId.toString(),
        title: view.listTitle,
        album: view.album,
        artist: view.artist,
      );
      await _engine.setUri(uri, tag: tag);
      if (gen != _generation) return;

      await _engine.seek(position);
      if (gen != _generation) return;

      _loadedGeneration = gen;
      _handler?.publishMediaItem(tag);
      state = state.copyWith(
        currentQueueEntryId: view.queueEntryId,
        playing: false,
        position: position,
        duration: _engine.duration,
      );
      await _checkpoint(force: true);
      _consecutiveUnplayable = 0;

      if (autoplay) {
        await _engine.play();
        if (gen != _generation) return;
        state = state.copyWith(playing: true);
      }
      _pushHandlerState(playing: autoplay);
    } on Object {
      if (gen != _generation) return;
      _report(
        code: PlayerMessageCodes.loadFailed,
        message: _l10n.loadFailed,
        error: true,
        sessionOnly: sessionOnlyErrors,
      );
      await advanceAfterCurrentGone(
        reason: AdvanceReason.unplayable,
        preferredSuccessorId: _nextAfter(view.queueEntryId),
      );
    }
  }

  QueueTrackView? _viewFor(int queueEntryId) {
    for (final row in _queue) {
      if (row.queueEntryId == queueEntryId) return row;
    }
    return null;
  }

  Future<void> _clearNowPlaying() async {
    state = PlaybackUiState.idle;
    _handler?.publishMediaItem(null);
    _pushHandlerState(playing: false, processing: AudioProcessingState.idle);
    await ref.read(appDatabaseProvider).checkpoint(
          entryId: null,
          positionMs: 0,
        );
  }

  Future<void> _checkpoint({required bool force}) async {
    final entryId = state.currentQueueEntryId;
    if (entryId == null) return;
    final now = DateTime.now();
    if (!force &&
        _lastCheckpointAt != null &&
        now.difference(_lastCheckpointAt!) < _positionThrottle) {
      return;
    }
    _lastCheckpointAt = now;
    await ref.read(appDatabaseProvider).checkpoint(
          entryId: entryId,
          positionMs: _engine.position.inMilliseconds,
        );
  }

  void _pushHandlerState({
    required bool playing,
    AudioProcessingState processing = AudioProcessingState.ready,
  }) {
    _handler?.publishPlaybackState(
      playing: playing,
      position: _engine.position,
      processingState: processing,
    );
  }

  void _report({
    required String code,
    required String message,
    required bool error,
    bool sessionOnly = false,
  }) {
    if (sessionOnly || !_toastsReady) {
      ref.read(sessionMessagesProvider.notifier).add(
            severity: error
                ? SessionMessageSeverity.error
                : SessionMessageSeverity.info,
            code: code,
            message: message,
          );
      return;
    }
    final reporter = ref.read(messageReporterProvider);
    if (error) {
      reporter.reportError(code: code, message: message);
    } else {
      reporter.reportInfo(code: code, message: message);
    }
  }

  Future<void> _disposeController() async {
    final observer = _lifecycleObserver;
    if (observer != null) {
      WidgetsBinding.instance.removeObserver(observer);
    }
    await _completedSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _playingSub?.cancel();
    await _queueSub?.cancel();
    await _noisySub?.cancel();
    await _interruptSub?.cancel();
    _handler?.detach();
    // Do not touch [state]/[ref] here — provider is already disposing.
    _initialized = false;
  }
}

/// Flushes playback checkpoints when the app backgrounds or detaches.
class _PlaybackLifecycleObserver with WidgetsBindingObserver {
  /// Creates an observer that invokes [onPausedOrDetached] on pause/detach.
  _PlaybackLifecycleObserver({required this.onPausedOrDetached});

  /// Checkpoint flush callback.
  final void Function() onPausedOrDetached;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      onPausedOrDetached();
    }
  }
}
