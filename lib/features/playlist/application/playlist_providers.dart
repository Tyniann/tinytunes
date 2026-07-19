import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/database/database_providers.dart';

/// Ordered queue rows joined with catalog fields for the home list.
final orderedQueueProvider = StreamProvider<List<QueueTrackView>>((ref) {
  return ref.watch(appDatabaseProvider).watchOrderedQueue();
});

/// Library roots for forget/re-scan pickers.
final libraryRootsProvider = StreamProvider<List<LibraryRoot>>((ref) {
  return ref.watch(appDatabaseProvider).watchRoots();
});

/// Queue-only mutations (remove row / clear playlist).
class QueueActions {
  /// Creates actions bound to [db].
  QueueActions(this._db);

  final AppDatabase _db;

  /// Removes one queue entry; catalog untouched.
  Future<void> removeEntry(int entryId) => _db.removeQueueEntry(entryId);

  /// Clears the queue; catalog untouched.
  Future<void> clearQueue() => _db.clearQueue();
}

/// Provides [QueueActions] for the playlist home.
final queueActionsProvider = Provider<QueueActions>((ref) {
  return QueueActions(ref.watch(appDatabaseProvider));
});
