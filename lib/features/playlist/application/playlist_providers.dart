import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/cloud/cloud_cache_store.dart';
import 'package:tinytunes/core/cloud/cloud_providers.dart';
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

/// Queue-only mutations (remove row / clear playlist) with cloud cache cleanup.
class QueueActions {
  /// Creates actions bound to [db] and optional [cache] for cloud cleanup.
  QueueActions(this._db, [this._cache]);

  final AppDatabase _db;
  final CloudCacheStore? _cache;

  /// Removes one queue entry and deletes that track's cloud cache if present.
  Future<void> removeEntry(int entryId) async {
    final trackId = await _db.trackIdForQueueEntry(entryId);
    await _db.removeQueueEntry(entryId);
    if (trackId != null && _cache != null) {
      await _cache.deleteForTrack(trackId);
    }
  }

  /// Clears the queue and deletes cloud cache for every previously queued track.
  Future<void> clearQueue() async {
    final ids = await _db.queuedTrackIds();
    await _db.clearQueue();
    final cache = _cache;
    if (cache == null) return;
    for (final id in ids) {
      await cache.deleteForTrack(id);
    }
  }
}

/// Provides [QueueActions] for the playlist home.
final queueActionsProvider = Provider<QueueActions>((ref) {
  return QueueActions(
    ref.watch(appDatabaseProvider),
    ref.watch(cloudCacheStoreProvider),
  );
});
