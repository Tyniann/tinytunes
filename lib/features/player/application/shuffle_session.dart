import 'dart:math';

/// In-memory shuffle cursor for one playback session.
///
/// Purpose: Hold permutation + index (Shuffle+Off) and/or play history
/// (Shuffle+All / Shuffle+One) without persisting order across process death.
/// Usage Context: Owned by [PlaybackController]; proposed updates come from
/// [QueueNavigator] and commit only after a successful load.
class ShuffleSession {
  /// Creates a session snapshot.
  const ShuffleSession({
    this.permutation = const [],
    this.index = 0,
    this.history = const [],
  });

  /// Empty session (Shuffle Off, or freshly entered All/One).
  static const empty = ShuffleSession();

  /// Ordered queue-entry ids for Shuffle+Off; unused for All/One.
  final List<int> permutation;

  /// Cursor into [permutation] for the current track.
  final int index;

  /// Played-before stack for Shuffle+All / Shuffle+One Previous.
  final List<int> history;

  /// Copy with selective overrides.
  ShuffleSession copyWith({
    List<int>? permutation,
    int? index,
    List<int>? history,
  }) {
    return ShuffleSession(
      permutation: permutation ?? this.permutation,
      index: index ?? this.index,
      history: history ?? this.history,
    );
  }

  /// Builds Shuffle+Off order: `[headId]` then a shuffled remainder of [queueIds].
  ///
  /// When [headId] is absent from [queueIds], shuffles the full list and sets
  /// index to `0`.
  static ShuffleSession rebuildFromHead({
    required int? headId,
    required List<int> queueIds,
    required Random random,
  }) {
    if (queueIds.isEmpty) return ShuffleSession.empty;

    if (headId == null || !queueIds.contains(headId)) {
      final perm = List<int>.of(queueIds)..shuffle(random);
      return ShuffleSession(permutation: perm, index: 0);
    }

    final rest = [
      for (final id in queueIds)
        if (id != headId) id,
    ]..shuffle(random);

    return ShuffleSession(permutation: [headId, ...rest], index: 0);
  }

  /// Drops removed ids from perm/history and clamps [index].
  ShuffleSession pruned(Set<int> livingIds) {
    final perm = [
      for (final id in permutation)
        if (livingIds.contains(id)) id,
    ];
    final hist = [
      for (final id in history)
        if (livingIds.contains(id)) id,
    ];
    final clamped = perm.isEmpty ? 0 : index.clamp(0, perm.length - 1);
    return ShuffleSession(permutation: perm, index: clamped, history: hist);
  }

  /// Appends [newIds] (not already in perm) at the end — Shuffle+Off only.
  ShuffleSession appended(Iterable<int> newIds) {
    if (permutation.isEmpty) return this;
    final existing = permutation.toSet();
    final extra = [
      for (final id in newIds)
        if (!existing.contains(id)) id,
    ];
    if (extra.isEmpty) return this;
    return copyWith(permutation: [...permutation, ...extra]);
  }
}
