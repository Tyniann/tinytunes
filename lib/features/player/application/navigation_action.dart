import 'package:tinytunes/features/player/application/shuffle_session.dart';

/// What [QueueNavigator] tells [PlaybackController] to do next.
///
/// Purpose: Keep matrix outcomes pure and commit [proposedSession] only after
/// a successful load (or immediately for seek/stop that do not change track).
enum NavigationKind {
  /// Load and optionally autoplay [NavigationAction.targetEntryId].
  play,

  /// Seek to zero and replay the current track (Repeat One complete).
  seekZero,

  /// Pause at end of current track; keep current id (Phase 3 stopAtEnd).
  stopAtEnd,

  /// No track change (e.g. Next at last with Repeat Off).
  noop,

  /// Stop engine and clear now-playing; keep modes.
  clear,
}

/// Immutable navigator result for one advance / previous / remove / unplayable.
///
/// Purpose: Carry both the engine intent and the session snapshot to commit.
class NavigationAction {
  /// Creates a navigation decision.
  const NavigationAction({
    required this.kind,
    this.targetEntryId,
    required this.proposedSession,
    this.autoplay = true,
  });

  /// [NavigationKind.noop] with unchanged session.
  factory NavigationAction.noop(ShuffleSession session) {
    return NavigationAction(
      kind: NavigationKind.noop,
      proposedSession: session,
      autoplay: false,
    );
  }

  /// [NavigationKind.seekZero] replaying the current entry.
  factory NavigationAction.seekZero(ShuffleSession session) {
    return NavigationAction(
      kind: NavigationKind.seekZero,
      proposedSession: session,
      autoplay: true,
    );
  }

  /// [NavigationKind.stopAtEnd] keeping the current entry.
  factory NavigationAction.stopAtEnd(ShuffleSession session) {
    return NavigationAction(
      kind: NavigationKind.stopAtEnd,
      proposedSession: session,
      autoplay: false,
    );
  }

  /// [NavigationKind.clear] when no successor exists.
  factory NavigationAction.clear(ShuffleSession session) {
    return NavigationAction(
      kind: NavigationKind.clear,
      proposedSession: session,
      autoplay: false,
    );
  }

  /// [NavigationKind.play] targeting [entryId].
  factory NavigationAction.play({
    required int entryId,
    required ShuffleSession session,
    bool autoplay = true,
  }) {
    return NavigationAction(
      kind: NavigationKind.play,
      targetEntryId: entryId,
      proposedSession: session,
      autoplay: autoplay,
    );
  }

  /// Engine / controller intent.
  final NavigationKind kind;

  /// Queue entry to load when [kind] is [NavigationKind.play].
  final int? targetEntryId;

  /// Session to commit after a successful load (or immediately for seek/stop).
  final ShuffleSession proposedSession;

  /// Whether [NavigationKind.play] / [NavigationKind.seekZero] should play.
  final bool autoplay;
}
