import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/features/player/application/advance_reason.dart';
import 'package:tinytunes/features/player/application/navigation_action.dart';
import 'package:tinytunes/features/player/application/queue_navigator.dart';
import 'package:tinytunes/features/player/application/repeat_mode.dart';
import 'package:tinytunes/features/player/application/shuffle_session.dart';

void main() {
  const queue = [1, 2, 3];

  group('Off/Off', () {
    late QueueNavigator nav;

    setUp(() => nav = QueueNavigator(random: Random(1)));

    test('complete mid-queue plays next', () {
      final action = nav.resolve(
        shuffleEnabled: false,
        repeatMode: RepeatMode.off,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 1,
        reason: AdvanceReason.completed,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 2);
    });

    test('complete at last is stopAtEnd', () {
      final action = nav.resolve(
        shuffleEnabled: false,
        repeatMode: RepeatMode.off,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 3,
        reason: AdvanceReason.completed,
      );
      expect(action.kind, NavigationKind.stopAtEnd);
    });

    test('manualNext at last is noop', () {
      final action = nav.resolve(
        shuffleEnabled: false,
        repeatMode: RepeatMode.off,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 3,
        reason: AdvanceReason.manualNext,
      );
      expect(action.kind, NavigationKind.noop);
    });

    test('previous at first is seekZero', () {
      final action = nav.previous(
        shuffleEnabled: false,
        repeatMode: RepeatMode.off,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 1,
      );
      expect(action.kind, NavigationKind.seekZero);
    });

    test('previous mid-queue plays prior', () {
      final action = nav.previous(
        shuffleEnabled: false,
        repeatMode: RepeatMode.off,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 2,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 1);
    });
  });

  group('Off/All', () {
    late QueueNavigator nav;

    setUp(() => nav = QueueNavigator(random: Random(1)));

    test('complete at last wraps to first', () {
      final action = nav.resolve(
        shuffleEnabled: false,
        repeatMode: RepeatMode.all,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 3,
        reason: AdvanceReason.completed,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 1);
    });

    test('previous at first wraps to last', () {
      final action = nav.previous(
        shuffleEnabled: false,
        repeatMode: RepeatMode.all,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 1,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 3);
    });

    test('manualNext at last wraps to first', () {
      final action = nav.resolve(
        shuffleEnabled: false,
        repeatMode: RepeatMode.all,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 3,
        reason: AdvanceReason.manualNext,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 1);
    });

    test('currentRemoved with null suffix wraps to first', () {
      final action = nav.resolve(
        shuffleEnabled: false,
        repeatMode: RepeatMode.all,
        queueIds: [1, 2],
        session: ShuffleSession.empty,
        currentId: 3,
        reason: AdvanceReason.currentRemoved,
        preferredSuccessorId: null,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 1);
    });
  });

  group('Off/One', () {
    late QueueNavigator nav;

    setUp(() => nav = QueueNavigator(random: Random(1)));

    test('complete is seekZero', () {
      final action = nav.resolve(
        shuffleEnabled: false,
        repeatMode: RepeatMode.one,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 2,
        reason: AdvanceReason.completed,
      );
      expect(action.kind, NavigationKind.seekZero);
    });

    test('manualNext advances canonical', () {
      final action = nav.resolve(
        shuffleEnabled: false,
        repeatMode: RepeatMode.one,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 1,
        reason: AdvanceReason.manualNext,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 2);
    });

    test('previous walks canonical and selected track then loops', () {
      final action = nav.previous(
        shuffleEnabled: false,
        repeatMode: RepeatMode.one,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 2,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 1);
    });

    test('previous at first restarts current rather than Repeat All wrap', () {
      final action = nav.previous(
        shuffleEnabled: false,
        repeatMode: RepeatMode.one,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 1,
      );
      expect(action.kind, NavigationKind.seekZero);
    });

    test('unplayable at last follows Next and wraps to first', () {
      final action = nav.resolve(
        shuffleEnabled: false,
        repeatMode: RepeatMode.one,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 3,
        reason: AdvanceReason.unplayable,
        failedEntryId: 3,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 1);
    });

    test('currentRemoved with null suffix clears', () {
      final action = nav.resolve(
        shuffleEnabled: false,
        repeatMode: RepeatMode.one,
        queueIds: [1, 2],
        session: ShuffleSession.empty,
        currentId: 3,
        reason: AdvanceReason.currentRemoved,
        preferredSuccessorId: null,
      );
      expect(action.kind, NavigationKind.clear);
    });
  });

  group('Shuffle+Off', () {
    late QueueNavigator nav;
    const perm = ShuffleSession(permutation: [2, 1, 3], index: 0);

    setUp(() => nav = QueueNavigator(random: Random(1)));

    test('complete advances permutation', () {
      final action = nav.resolve(
        shuffleEnabled: true,
        repeatMode: RepeatMode.off,
        queueIds: queue,
        session: perm,
        currentId: 2,
        reason: AdvanceReason.completed,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 1);
      expect(action.proposedSession.index, 1);
    });

    test('complete at last is stopAtEnd', () {
      final action = nav.resolve(
        shuffleEnabled: true,
        repeatMode: RepeatMode.off,
        queueIds: queue,
        session: const ShuffleSession(permutation: [2, 1, 3], index: 2),
        currentId: 3,
        reason: AdvanceReason.completed,
      );
      expect(action.kind, NavigationKind.stopAtEnd);
    });

    test('manualNext at last is noop', () {
      final action = nav.resolve(
        shuffleEnabled: true,
        repeatMode: RepeatMode.off,
        queueIds: queue,
        session: const ShuffleSession(permutation: [2, 1, 3], index: 2),
        currentId: 3,
        reason: AdvanceReason.manualNext,
      );
      expect(action.kind, NavigationKind.noop);
    });

    test('previous walks permutation', () {
      final action = nav.previous(
        shuffleEnabled: true,
        repeatMode: RepeatMode.off,
        queueIds: queue,
        session: const ShuffleSession(permutation: [2, 1, 3], index: 1),
        currentId: 1,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 2);
      expect(action.proposedSession.index, 0);
    });

    test('currentRemoved uses next after slot in old perm', () {
      final action = nav.resolve(
        shuffleEnabled: true,
        repeatMode: RepeatMode.off,
        queueIds: [1, 3],
        session: const ShuffleSession(permutation: [2, 1, 3], index: 0),
        currentId: 2,
        reason: AdvanceReason.currentRemoved,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 1);
      expect(action.proposedSession.permutation, isNot(contains(2)));
    });

    test('unplayable never re-picks failed', () {
      final action = nav.resolve(
        shuffleEnabled: true,
        repeatMode: RepeatMode.off,
        queueIds: queue,
        session: const ShuffleSession(permutation: [2, 1, 3], index: 0),
        currentId: 2,
        reason: AdvanceReason.unplayable,
        failedEntryId: 2,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, isNot(2));
    });
  });

  group('Shuffle+All', () {
    late QueueNavigator nav;

    setUp(() => nav = QueueNavigator(random: Random(42)));

    test('complete picks random excluding current and pushes history', () {
      final action = nav.resolve(
        shuffleEnabled: true,
        repeatMode: RepeatMode.all,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 1,
        reason: AdvanceReason.completed,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, isNot(1));
      expect(action.proposedSession.history, [1]);
    });

    test('manualNext picks random excluding current and pushes history', () {
      final action = nav.resolve(
        shuffleEnabled: true,
        repeatMode: RepeatMode.all,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 1,
        reason: AdvanceReason.manualNext,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, isNot(1));
      expect(action.proposedSession.history, [1]);
    });

    test('unplayable excludes failed entry', () {
      final action = nav.resolve(
        shuffleEnabled: true,
        repeatMode: RepeatMode.all,
        queueIds: queue,
        session: const ShuffleSession(history: [1]),
        currentId: 1,
        reason: AdvanceReason.unplayable,
        failedEntryId: 2,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, isNot(2));
      expect(action.proposedSession.history, [1]);
    });

    test('previous pops history', () {
      final action = nav.previous(
        shuffleEnabled: true,
        repeatMode: RepeatMode.all,
        queueIds: queue,
        session: const ShuffleSession(history: [1, 2]),
        currentId: 3,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 2);
      expect(action.proposedSession.history, [1]);
    });

    test('previous with empty history is seekZero', () {
      final action = nav.previous(
        shuffleEnabled: true,
        repeatMode: RepeatMode.all,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 1,
      );
      expect(action.kind, NavigationKind.seekZero);
    });

    test('currentRemoved picks random from remaining', () {
      final action = nav.resolve(
        shuffleEnabled: true,
        repeatMode: RepeatMode.all,
        queueIds: [2, 3],
        session: const ShuffleSession(history: [1]),
        currentId: 1,
        reason: AdvanceReason.currentRemoved,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, anyOf(2, 3));
      expect(action.proposedSession.history, isEmpty);
    });
  });

  group('Shuffle+One', () {
    late QueueNavigator nav;

    setUp(() => nav = QueueNavigator(random: Random(7)));

    test('complete is seekZero', () {
      final action = nav.resolve(
        shuffleEnabled: true,
        repeatMode: RepeatMode.one,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 2,
        reason: AdvanceReason.completed,
      );
      expect(action.kind, NavigationKind.seekZero);
    });

    test('manualNext is random + history', () {
      final action = nav.resolve(
        shuffleEnabled: true,
        repeatMode: RepeatMode.one,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 1,
        reason: AdvanceReason.manualNext,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, isNot(1));
      expect(action.proposedSession.history, [1]);
      expect(action.proposedSession.permutation, isEmpty);
    });

    test('previous pops history then loops that track', () {
      final action = nav.previous(
        shuffleEnabled: true,
        repeatMode: RepeatMode.one,
        queueIds: queue,
        session: const ShuffleSession(history: [2]),
        currentId: 1,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 2);
    });

    test('currentRemoved picks random remaining entry and prunes history', () {
      final action = nav.resolve(
        shuffleEnabled: true,
        repeatMode: RepeatMode.one,
        queueIds: const [2, 3],
        session: const ShuffleSession(history: [1, 2]),
        currentId: 1,
        reason: AdvanceReason.currentRemoved,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, anyOf(2, 3));
      expect(action.proposedSession.history, [2]);
    });
  });

  group('edge cases', () {
    late QueueNavigator nav;

    setUp(() => nav = QueueNavigator(random: Random(1)));

    test('empty queue clears', () {
      final action = nav.resolve(
        shuffleEnabled: false,
        repeatMode: RepeatMode.off,
        queueIds: const [],
        session: ShuffleSession.empty,
        currentId: 1,
        reason: AdvanceReason.completed,
      );
      expect(action.kind, NavigationKind.clear);
    });

    test('single track Off/Off complete is stopAtEnd', () {
      final action = nav.resolve(
        shuffleEnabled: false,
        repeatMode: RepeatMode.off,
        queueIds: const [1],
        session: ShuffleSession.empty,
        currentId: 1,
        reason: AdvanceReason.completed,
      );
      expect(action.kind, NavigationKind.stopAtEnd);
    });

    test('single track Shuffle+All next re-picks sole track', () {
      final action = nav.resolve(
        shuffleEnabled: true,
        repeatMode: RepeatMode.all,
        queueIds: const [1],
        session: ShuffleSession.empty,
        currentId: 1,
        reason: AdvanceReason.manualNext,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 1);
    });

    test('unplayable Off excludes failed and walks forward', () {
      final action = nav.resolve(
        shuffleEnabled: false,
        repeatMode: RepeatMode.off,
        queueIds: queue,
        session: ShuffleSession.empty,
        currentId: 1,
        reason: AdvanceReason.unplayable,
        failedEntryId: 1,
      );
      expect(action.kind, NavigationKind.play);
      expect(action.targetEntryId, 2);
    });

    test('unplayable with no successor clears now-playing', () {
      final action = nav.resolve(
        shuffleEnabled: false,
        repeatMode: RepeatMode.off,
        queueIds: const [1],
        session: ShuffleSession.empty,
        currentId: 1,
        reason: AdvanceReason.unplayable,
        failedEntryId: 1,
      );
      expect(action.kind, NavigationKind.clear);
    });

    test('invalid stored repeat mode falls back to Off', () {
      expect(RepeatMode.fromStorage('invalid'), RepeatMode.off);
    });

    test('rebuildFromHead keeps head and shuffles rest', () {
      final session = ShuffleSession.rebuildFromHead(
        headId: 2,
        queueIds: queue,
        random: Random(99),
      );
      expect(session.permutation.first, 2);
      expect(session.permutation.toSet(), queue.toSet());
      expect(session.index, 0);
    });
  });
}
