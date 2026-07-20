import 'dart:math';

import 'package:tinytunes/features/player/application/advance_reason.dart';
import 'package:tinytunes/features/player/application/navigation_action.dart';
import 'package:tinytunes/features/player/application/repeat_mode.dart';
import 'package:tinytunes/features/player/application/shuffle_session.dart';

/// Pure Shuffle × Repeat navigation policy for the single Winamp queue.
///
/// Purpose: Encode the locked matrix (and remove/unplayable successors) without
/// touching Drift, the engine, or [TinyTunesAudioHandler].
/// Usage Context: Called by [PlaybackController]; commit [NavigationAction.proposedSession]
/// only after a successful load when [NavigationKind.play].
class QueueNavigator {
  /// Creates a navigator; inject [random] for deterministic tests.
  QueueNavigator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Resolves the next action for [reason] under the current modes/session.
  ///
  /// [preferredSuccessorId] is the Phase 3 suffix pick for Off/`currentRemoved`
  /// (may be null). [failedEntryId] is the unplayable candidate to exclude.
  NavigationAction resolve({
    required bool shuffleEnabled,
    required RepeatMode repeatMode,
    required List<int> queueIds,
    required ShuffleSession session,
    required int? currentId,
    required AdvanceReason reason,
    int? preferredSuccessorId,
    int? failedEntryId,
  }) {
    if (queueIds.isEmpty) {
      return NavigationAction.clear(session.pruned(const {}));
    }

    return switch (reason) {
      AdvanceReason.completed => _completed(
        shuffleEnabled: shuffleEnabled,
        repeatMode: repeatMode,
        queueIds: queueIds,
        session: session,
        currentId: currentId,
      ),
      AdvanceReason.manualNext => _manualNext(
        shuffleEnabled: shuffleEnabled,
        repeatMode: repeatMode,
        queueIds: queueIds,
        session: session,
        currentId: currentId,
      ),
      AdvanceReason.currentRemoved => _currentRemoved(
        shuffleEnabled: shuffleEnabled,
        repeatMode: repeatMode,
        queueIds: queueIds,
        session: session,
        vanishedId: currentId,
        preferredSuccessorId: preferredSuccessorId,
      ),
      AdvanceReason.unplayable => _unplayable(
        shuffleEnabled: shuffleEnabled,
        repeatMode: repeatMode,
        queueIds: queueIds,
        session: session,
        failedEntryId: failedEntryId ?? currentId,
      ),
    };
  }

  /// Previous-track decision after the controller's 3s seek-0 short-circuit.
  NavigationAction previous({
    required bool shuffleEnabled,
    required RepeatMode repeatMode,
    required List<int> queueIds,
    required ShuffleSession session,
    required int? currentId,
  }) {
    if (queueIds.isEmpty || currentId == null) {
      return NavigationAction.clear(session);
    }

    if (!shuffleEnabled) {
      return _previousCanonical(
        repeatMode: repeatMode,
        queueIds: queueIds,
        session: session,
        currentId: currentId,
      );
    }

    if (repeatMode == RepeatMode.off) {
      return _previousPermutation(session: session, currentId: currentId);
    }

    // Shuffle+All / Shuffle+One: pop history, else seek0.
    if (session.history.isNotEmpty) {
      final hist = List<int>.of(session.history);
      final target = hist.removeLast();
      if (!queueIds.contains(target)) {
        return previous(
          shuffleEnabled: shuffleEnabled,
          repeatMode: repeatMode,
          queueIds: queueIds,
          session: session.copyWith(history: hist),
          currentId: currentId,
        );
      }
      return NavigationAction.play(
        entryId: target,
        session: session.copyWith(history: hist),
      );
    }

    return NavigationAction.seekZero(session);
  }

  NavigationAction _completed({
    required bool shuffleEnabled,
    required RepeatMode repeatMode,
    required List<int> queueIds,
    required ShuffleSession session,
    required int? currentId,
  }) {
    if (repeatMode == RepeatMode.one) {
      return NavigationAction.seekZero(session);
    }
    return _advanceForward(
      shuffleEnabled: shuffleEnabled,
      repeatMode: repeatMode,
      queueIds: queueIds,
      session: session,
      currentId: currentId,
      atEnd: repeatMode == RepeatMode.all
          ? _AtEndBehavior.wrapOrRandom
          : _AtEndBehavior.stopAtEnd,
    );
  }

  NavigationAction _manualNext({
    required bool shuffleEnabled,
    required RepeatMode repeatMode,
    required List<int> queueIds,
    required ShuffleSession session,
    required int? currentId,
  }) {
    return _advanceForward(
      shuffleEnabled: shuffleEnabled,
      repeatMode: repeatMode,
      queueIds: queueIds,
      session: session,
      currentId: currentId,
      atEnd: repeatMode == RepeatMode.off
          ? _AtEndBehavior.noop
          : _AtEndBehavior.wrapOrRandom,
    );
  }

  NavigationAction _advanceForward({
    required bool shuffleEnabled,
    required RepeatMode repeatMode,
    required List<int> queueIds,
    required ShuffleSession session,
    required int? currentId,
    required _AtEndBehavior atEnd,
  }) {
    if (currentId == null) {
      return NavigationAction.play(entryId: queueIds.first, session: session);
    }

    if (!shuffleEnabled) {
      final index = queueIds.indexOf(currentId);
      if (index < 0) {
        return NavigationAction.play(entryId: queueIds.first, session: session);
      }
      if (index < queueIds.length - 1) {
        return NavigationAction.play(
          entryId: queueIds[index + 1],
          session: session,
        );
      }
      return switch (atEnd) {
        _AtEndBehavior.stopAtEnd => NavigationAction.stopAtEnd(session),
        _AtEndBehavior.noop => NavigationAction.noop(session),
        _AtEndBehavior.wrapOrRandom => NavigationAction.play(
          entryId: queueIds.first,
          session: session,
        ),
      };
    }

    if (repeatMode == RepeatMode.off) {
      return _nextInPermutation(
        session: session,
        currentId: currentId,
        atEnd: atEnd,
      );
    }

    // Shuffle+All (and Shuffle+One Next): random excl. current when len > 1.
    final target = _randomPick(queueIds: queueIds, exclude: currentId);
    final hist = [...session.history, currentId];
    return NavigationAction.play(
      entryId: target,
      session: ShuffleSession(history: hist),
    );
  }

  NavigationAction _nextInPermutation({
    required ShuffleSession session,
    required int currentId,
    required _AtEndBehavior atEnd,
  }) {
    final perm = session.permutation;
    if (perm.isEmpty) {
      return NavigationAction.noop(session);
    }
    var index = session.index;
    if (index < 0 || index >= perm.length || perm[index] != currentId) {
      index = perm.indexOf(currentId);
    }
    if (index < 0) {
      return NavigationAction.play(
        entryId: perm.first,
        session: session.copyWith(index: 0),
      );
    }
    if (index < perm.length - 1) {
      final nextIndex = index + 1;
      return NavigationAction.play(
        entryId: perm[nextIndex],
        session: session.copyWith(index: nextIndex),
      );
    }
    return switch (atEnd) {
      _AtEndBehavior.stopAtEnd => NavigationAction.stopAtEnd(
        session.copyWith(index: index),
      ),
      _AtEndBehavior.noop => NavigationAction.noop(
        session.copyWith(index: index),
      ),
      _AtEndBehavior.wrapOrRandom => NavigationAction.play(
        entryId: perm.first,
        session: session.copyWith(index: 0),
      ),
    };
  }

  NavigationAction _previousCanonical({
    required RepeatMode repeatMode,
    required List<int> queueIds,
    required ShuffleSession session,
    required int currentId,
  }) {
    final index = queueIds.indexOf(currentId);
    if (index < 0) {
      return NavigationAction.seekZero(session);
    }
    if (index > 0) {
      return NavigationAction.play(
        entryId: queueIds[index - 1],
        session: session,
      );
    }
    if (repeatMode == RepeatMode.all) {
      return NavigationAction.play(entryId: queueIds.last, session: session);
    }
    return NavigationAction.seekZero(session);
  }

  NavigationAction _previousPermutation({
    required ShuffleSession session,
    required int currentId,
  }) {
    final perm = session.permutation;
    if (perm.isEmpty) {
      return NavigationAction.seekZero(session);
    }
    var index = session.index;
    if (index < 0 || index >= perm.length || perm[index] != currentId) {
      index = perm.indexOf(currentId);
    }
    if (index < 0) {
      return NavigationAction.seekZero(session);
    }
    if (index > 0) {
      final prev = index - 1;
      return NavigationAction.play(
        entryId: perm[prev],
        session: session.copyWith(index: prev),
      );
    }
    return NavigationAction.seekZero(session.copyWith(index: 0));
  }

  NavigationAction _currentRemoved({
    required bool shuffleEnabled,
    required RepeatMode repeatMode,
    required List<int> queueIds,
    required ShuffleSession session,
    required int? vanishedId,
    required int? preferredSuccessorId,
  }) {
    // Snapshot session before prune; choose successor from old state.
    final oldSession = session;

    if (!shuffleEnabled) {
      if (preferredSuccessorId != null &&
          queueIds.contains(preferredSuccessorId)) {
        return NavigationAction.play(
          entryId: preferredSuccessorId,
          session: oldSession.pruned(queueIds.toSet()),
        );
      }
      if (repeatMode == RepeatMode.all && queueIds.isNotEmpty) {
        return NavigationAction.play(
          entryId: queueIds.first,
          session: oldSession.pruned(queueIds.toSet()),
        );
      }
      // Off/One with no suffix: clear.
      return NavigationAction.clear(oldSession.pruned(queueIds.toSet()));
    }

    if (repeatMode == RepeatMode.off) {
      final perm = oldSession.permutation;
      final vanished = vanishedId;
      if (vanished != null && perm.isNotEmpty) {
        final idx = perm.indexOf(vanished);
        if (idx >= 0) {
          for (var i = idx + 1; i < perm.length; i++) {
            if (queueIds.contains(perm[i])) {
              final living = queueIds.toSet();
              final pruned = oldSession.pruned(living);
              final newIndex = pruned.permutation.indexOf(perm[i]);
              return NavigationAction.play(
                entryId: perm[i],
                session: pruned.copyWith(index: newIndex < 0 ? 0 : newIndex),
              );
            }
          }
        }
      }
      return NavigationAction.clear(oldSession.pruned(queueIds.toSet()));
    }

    // Shuffle+All / One: random from remaining.
    if (queueIds.isEmpty) {
      return NavigationAction.clear(oldSession.pruned(const {}));
    }
    final target = _randomPick(queueIds: queueIds, exclude: vanishedId);
    return NavigationAction.play(
      entryId: target,
      session: ShuffleSession(
        history: [
          for (final id in oldSession.history)
            if (queueIds.contains(id) && id != vanishedId) id,
        ],
      ),
    );
  }

  NavigationAction _unplayable({
    required bool shuffleEnabled,
    required RepeatMode repeatMode,
    required List<int> queueIds,
    required ShuffleSession session,
    required int? failedEntryId,
  }) {
    final candidates = [
      for (final id in queueIds)
        if (id != failedEntryId) id,
    ];
    if (candidates.isEmpty) {
      return NavigationAction.clear(session.pruned(queueIds.toSet()));
    }

    if (!shuffleEnabled) {
      // Same as Next from failed id: walk canonical after failed.
      if (failedEntryId == null) {
        return NavigationAction.play(
          entryId: candidates.first,
          session: session,
        );
      }
      final index = queueIds.indexOf(failedEntryId);
      if (index >= 0) {
        for (var i = index + 1; i < queueIds.length; i++) {
          if (queueIds[i] != failedEntryId) {
            return NavigationAction.play(
              entryId: queueIds[i],
              session: session,
            );
          }
        }
        if (repeatMode == RepeatMode.all || repeatMode == RepeatMode.one) {
          for (final id in queueIds) {
            if (id != failedEntryId) {
              return NavigationAction.play(entryId: id, session: session);
            }
          }
        }
      }
      return NavigationAction.clear(session);
    }

    if (repeatMode == RepeatMode.off) {
      final perm = session.permutation;
      if (failedEntryId != null) {
        final idx = perm.indexOf(failedEntryId);
        if (idx >= 0) {
          for (var i = idx + 1; i < perm.length; i++) {
            if (perm[i] != failedEntryId && queueIds.contains(perm[i])) {
              return NavigationAction.play(
                entryId: perm[i],
                session: session.copyWith(index: i),
              );
            }
          }
        }
      }
      // Fall through: try any remaining in perm order.
      for (var i = 0; i < perm.length; i++) {
        if (perm[i] != failedEntryId && queueIds.contains(perm[i])) {
          return NavigationAction.play(
            entryId: perm[i],
            session: session.copyWith(index: i),
          );
        }
      }
      return NavigationAction.clear(session);
    }

    // Shuffle+All / One: random excl. failed.
    final target = _randomPick(queueIds: candidates, exclude: null);
    final hist = [
      for (final id in session.history)
        if (id != failedEntryId) id,
    ];
    if (failedEntryId != null) {
      // Do not push failed onto history.
    }
    return NavigationAction.play(
      entryId: target,
      session: ShuffleSession(history: hist),
    );
  }

  int _randomPick({required List<int> queueIds, required int? exclude}) {
    if (queueIds.isEmpty) {
      throw StateError('Cannot pick from empty queue');
    }
    if (queueIds.length == 1) {
      return queueIds.first;
    }
    final pool = [
      for (final id in queueIds)
        if (id != exclude) id,
    ];
    final choices = pool.isEmpty ? queueIds : pool;
    return choices[_random.nextInt(choices.length)];
  }
}

enum _AtEndBehavior { stopAtEnd, noop, wrapOrRandom }
