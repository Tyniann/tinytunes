import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart' hide RepeatMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tinytunes/core/cloud/cloud_providers.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/core/messages/session_message.dart';
import 'package:tinytunes/features/library/application/library_providers.dart';
import 'package:tinytunes/features/player/application/advance_reason.dart';
import 'package:tinytunes/features/player/application/just_audio_playback_engine.dart';
import 'package:tinytunes/features/player/application/navigation_action.dart';
import 'package:tinytunes/features/player/application/playback_engine.dart';
import 'package:tinytunes/features/player/application/playback_uri_resolver.dart';
import 'package:tinytunes/features/player/application/playback_ui_state.dart';
import 'package:tinytunes/features/player/application/player_l10n.dart';
import 'package:tinytunes/features/player/application/player_message_codes.dart';
import 'package:tinytunes/features/player/application/player_providers.dart';
import 'package:tinytunes/features/player/application/queue_navigator.dart';
import 'package:tinytunes/features/player/application/repeat_mode.dart';
import 'package:tinytunes/features/player/application/shuffle_session.dart';
import 'package:tinytunes/features/player/application/tinytunes_audio_handler.dart';

part 'playback_controller.g.dart';

/// Application-lifetime playback controller (Shuffle × Repeat matrix).
///
/// Purpose: Own the single [PlaybackEngine], Drift resume checkpoints, queue
/// mutation skip, session noisy/interrupt policy, and in-memory shuffle
/// session; feed the thin [TinyTunesAudioHandler].
/// Usage Context: Eagerly read from `main` after handler override; home transport
/// and row taps call public intents.
@Riverpod(keepAlive: true)
class PlaybackController extends _$PlaybackController
    implements PlaybackRemoteCommands {
  static const _prevRestartThreshold = Duration(seconds: 3);
  static const _positionThrottle = Duration(seconds: 2);
  static const _maxConsecutiveUnplayable = 5;

  late PlaybackEngine _engine;
  late QueueNavigator _navigator;
  TinyTunesAudioHandler? _handler;
  _PlaybackLifecycleObserver? _lifecycleObserver;

  int _generation = 0;
  int _loadedGeneration = -1;
  bool _restoreStarted = false;
  bool _sessionConfigured = false;
  bool _toastsReady = false;
  bool _initialized = false;
  bool _handlingCompletion = false;
  int _consecutiveUnplayable = 0;
  DateTime? _lastCheckpointAt;
  Future<void> _modesWriteTail = Future<void>.value();

  bool _shuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  ShuffleSession _session = ShuffleSession.empty;

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
      _navigator = QueueNavigator(random: ref.read(playbackRandomProvider));
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

  /// Enables or disables shuffle and rebuilds the in-memory session.
  Future<void> setShuffleEnabled(bool enabled) async {
    if (_shuffleEnabled == enabled) return;
    _shuffleEnabled = enabled;
    state = state.copyWith(shuffleEnabled: enabled);
    if (!enabled) {
      _session = ShuffleSession.empty;
    } else {
      _rebuildSessionAfterModeChange(headId: state.currentQueueEntryId);
    }
    await _persistModes();
  }

  /// Cycles Repeat Off → One → All and adjusts the in-memory session.
  Future<void> cycleRepeatMode() async {
    final next = _repeatMode.cycle();
    _repeatMode = next;
    state = state.copyWith(repeatMode: next);

    if (_shuffleEnabled) {
      if (next == RepeatMode.off) {
        // Leaving All/One into Off while shuffle on → rebuild perm.
        _rebuildSessionAfterModeChange(headId: state.currentQueueEntryId);
      } else {
        // Entering All or One → empty history, clear perm.
        _session = ShuffleSession.empty;
      }
    }

    await _persistModes();
  }

  /// Plays [queueEntryId], or toggles pause when it is already current.
  Future<void> playEntry(int queueEntryId) async {
    if (state.currentQueueEntryId == queueEntryId) {
      await togglePlayPause();
      return;
    }
    final view = _viewFor(queueEntryId);
    if (view == null) return;

    ShuffleSession? pending;
    if (_shuffleEnabled && _repeatMode == RepeatMode.off) {
      pending = ShuffleSession.rebuildFromHead(
        headId: queueEntryId,
        queueIds: _queueIds,
        random: ref.read(playbackRandomProvider),
      );
    } else if (_shuffleEnabled) {
      final prior = state.currentQueueEntryId;
      pending = ShuffleSession(history: [..._session.history, ?prior]);
    }

    await _loadAndPlay(
      view,
      position: Duration.zero,
      autoplay: true,
      commitSession: pending,
    );
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

  /// Advances per the Shuffle × Repeat matrix (manual Next).
  Future<void> next() =>
      advanceAfterCurrentGone(reason: AdvanceReason.manualNext);

  /// Previous with 3s restart rule, then matrix policy.
  Future<void> previous() async {
    final currentId = state.currentQueueEntryId;
    if (currentId == null) return;

    if (state.position > _prevRestartThreshold) {
      await seekTo(Duration.zero);
      return;
    }

    final action = _navigator.previous(
      shuffleEnabled: _shuffleEnabled,
      repeatMode: _repeatMode,
      queueIds: _queueIds,
      session: _session,
      currentId: currentId,
    );
    await _applyNavigationAction(action);
  }

  /// Shared advance seam for complete / next / remove / unplayable.
  Future<void> advanceAfterCurrentGone({
    required AdvanceReason reason,
    int? preferredSuccessorId,
    int? failedEntryId,
  }) async {
    if (reason == AdvanceReason.unplayable) {
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
    }

    final action = _navigator.resolve(
      shuffleEnabled: _shuffleEnabled,
      repeatMode: _repeatMode,
      queueIds: _queueIds,
      session: _session,
      currentId: state.currentQueueEntryId,
      reason: reason,
      preferredSuccessorId: preferredSuccessorId,
      failedEntryId: failedEntryId ?? state.currentQueueEntryId,
    );

    await _applyNavigationAction(action);
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

  List<int> get _queueIds =>
      _queue.map((e) => e.queueEntryId).toList(growable: false);

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
    // 1. Load queue
    _queue = await db.getOrderedQueue();
    // 2. Read modes + checkpoint
    final playback = await db.getPlaybackState();
    // 3. Apply modes to controller + UI
    _shuffleEnabled = playback.shuffleEnabled;
    _repeatMode = RepeatMode.fromStorage(playback.repeatMode);
    state = state.copyWith(
      shuffleEnabled: _shuffleEnabled,
      repeatMode: _repeatMode,
    );
    // 4. Rebuild/clear session per locked rules
    _rebuildSessionAfterModeChange(headId: playback.currentQueueEntryId);

    final entryId = playback.currentQueueEntryId;
    // 5. Load paused track if still present; if missing clear entry only — keep modes
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

  /// Rebuilds in-memory shuffle session after modes are applied (restore / toggles).
  void _rebuildSessionAfterModeChange({required int? headId}) {
    if (!_shuffleEnabled) {
      _session = ShuffleSession.empty;
      return;
    }
    if (_repeatMode == RepeatMode.off) {
      _session = ShuffleSession.rebuildFromHead(
        headId: headId,
        queueIds: _queueIds,
        random: ref.read(playbackRandomProvider),
      );
      return;
    }
    // Shuffle+All / Shuffle+One: empty history on enter / restore.
    _session = ShuffleSession.empty;
  }

  /// Serializes mode snapshots so rapid taps cannot persist an older pair last.
  Future<void> _persistModes() {
    final shuffle = _shuffleEnabled;
    final repeat = _repeatMode;
    final database = ref.read(appDatabaseProvider);
    final write = _modesWriteTail.then(
      (_) => database.updatePlaybackModes(
        shuffleEnabled: shuffle,
        repeatMode: repeat.storageValue,
      ),
    );
    _modesWriteTail = write.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return write;
  }

  Future<void> _onQueueChanged(List<QueueTrackView> next) async {
    final previous = _queue;
    final currentId = state.currentQueueEntryId;
    final oldSession = _session;
    _queue = next;

    if (next.isEmpty) {
      _session = ShuffleSession.empty;
      if (currentId != null) {
        await _engine.stop();
        await _clearNowPlaying();
      }
      return;
    }

    if (currentId == null) {
      _syncSessionWithQueue(previous: previous);
      return;
    }

    final stillThere = next.any((e) => e.queueEntryId == currentId);
    if (stillThere) {
      // Always prune/append even when current stays — never early-return first.
      _syncSessionWithQueue(previous: previous);
      return;
    }

    // Current removed: navigate from old-session snapshot, then prune via action.
    _session = oldSession;
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

  /// Prunes removed ids and appends new ones to the Shuffle+Off permutation.
  void _syncSessionWithQueue({required List<QueueTrackView> previous}) {
    final living = _queue.map((e) => e.queueEntryId).toSet();
    final prevIds = previous.map((e) => e.queueEntryId).toSet();
    final added = living.difference(prevIds);
    var session = _session.pruned(living);
    if (_shuffleEnabled && _repeatMode == RepeatMode.off) {
      session = session.appended(added);
    }
    _session = session;
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
    if (_generation != _loadedGeneration || _handlingCompletion) return;
    _handlingCompletion = true;
    try {
      await advanceAfterCurrentGone(reason: AdvanceReason.completed);
    } finally {
      _handlingCompletion = false;
    }
  }

  Future<void> _applyNavigationAction(NavigationAction action) async {
    switch (action.kind) {
      case NavigationKind.noop:
        _session = action.proposedSession;
        return;
      case NavigationKind.seekZero:
        _session = action.proposedSession;
        await _engine.seek(Duration.zero);
        state = state.copyWith(position: Duration.zero);
        if (action.autoplay) {
          await _engine.play();
          state = state.copyWith(playing: true);
          _pushHandlerState(playing: true);
        }
        await _checkpoint(force: true);
        return;
      case NavigationKind.stopAtEnd:
        _session = action.proposedSession;
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
      case NavigationKind.clear:
        _session = action.proposedSession;
        await _engine.stop();
        await _clearNowPlaying();
        return;
      case NavigationKind.play:
        final targetId = action.targetEntryId;
        if (targetId == null) {
          _session = action.proposedSession;
          await _engine.stop();
          await _clearNowPlaying();
          return;
        }
        final view = _viewFor(targetId);
        if (view == null) {
          _session = action.proposedSession;
          await _engine.stop();
          await _clearNowPlaying();
          return;
        }
        await _loadAndPlay(
          view,
          position: Duration.zero,
          autoplay: action.autoplay,
          commitSession: action.proposedSession,
        );
    }
  }

  Future<void> _loadAndPlay(
    QueueTrackView view, {
    required Duration position,
    required bool autoplay,
    bool sessionOnlyErrors = false,
    ShuffleSession? commitSession,
  }) async {
    final gen = ++_generation;

    Uri uri;
    try {
      final cloud = await ref.read(cloudLibrarySourceProvider.future);
      if (gen != _generation) return;
      final resolver = PlaybackUriResolver(
        localSource: ref.read(localLibrarySourceProvider),
        cloudSource: cloud,
        cacheStore: ref.read(cloudCacheStoreProvider),
        db: ref.read(appDatabaseProvider),
        metadataReader: ref.read(trackMetadataReaderProvider),
        budgetBytes: ref.read(cloudCacheBudgetControllerProvider),
      );
      final queuedIds = await ref.read(appDatabaseProvider).queuedTrackIds();
      if (gen != _generation) return;
      uri = await resolver.resolve(
        view,
        queuedTrackIds: queuedIds,
        onDownloadStarted: () {
          if (gen == _generation) {
            state = state.copyWith(downloading: true, downloadProgress: 0);
          }
        },
        onDownloadProgress: (received, total) {
          if (gen != _generation) return;
          final progress = total > 0
              ? (received / total).clamp(0.0, 1.0)
              : null;
          state = state.copyWith(
            downloading: true,
            downloadProgress: progress,
            clearDownloadProgress: progress == null,
          );
        },
      );
    } on Object {
      if (gen != _generation) return;
      state = state.copyWith(downloading: false, clearDownloadProgress: true);
      _report(
        code: PlayerMessageCodes.fileMissing,
        message: _l10n.fileMissing,
        error: true,
        sessionOnly: sessionOnlyErrors,
      );
      await advanceAfterCurrentGone(
        reason: AdvanceReason.unplayable,
        failedEntryId: view.queueEntryId,
      );
      return;
    }

    if (gen != _generation) return;
    state = state.copyWith(downloading: false, clearDownloadProgress: true);

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

      // Commit session only after successful setUri.
      if (commitSession != null) {
        _session = commitSession;
      }

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
        failedEntryId: view.queueEntryId,
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
    // Preserve shuffle/repeat preferences — modes are not part of now-playing.
    state = state.copyWith(
      clearCurrent: true,
      playing: false,
      position: Duration.zero,
      clearDuration: true,
      downloading: false,
      clearDownloadProgress: true,
    );
    _handler?.publishMediaItem(null);
    _pushHandlerState(playing: false, processing: AudioProcessingState.idle);
    await ref
        .read(appDatabaseProvider)
        .checkpoint(entryId: null, positionMs: 0);
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
    await ref
        .read(appDatabaseProvider)
        .checkpoint(
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
      ref
          .read(sessionMessagesProvider.notifier)
          .add(
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
