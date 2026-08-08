import 'dart:io';

import 'package:drift/drift.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/cloud_provider_id.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/library/artwork_cache_store.dart';
import 'package:tinytunes/core/library/media_locator.dart';

/// Filesystem + Drift index for downloaded cloud tracks.
///
/// Purpose: Record cache rows, touch LRU timestamps, delete on queue/Forget,
/// and silently evict oldest files when over budget.
/// Usage Context: Playback download path and Settings Clear cache.
class CloudCacheStore {
  /// Creates a store bound to [db].
  ///
  /// When [artwork] is set, track artwork is deleted with each audio cache
  /// removal (queue remove, clear, budget eviction, clearAll, forget).
  CloudCacheStore({required AppDatabase db, ArtworkCacheStore? artwork})
    : _db = db,
      _artwork = artwork;

  final AppDatabase _db;
  final ArtworkCacheStore? _artwork;

  /// Upserts a cache row after a successful download and touches access time.
  Future<void> upsert({
    required int trackId,
    required MediaLocator remoteLocator,
    required String localPath,
    required int sizeBytes,
    DateTime? accessedAt,
  }) async {
    final now = accessedAt ?? DateTime.now().toUtc();
    await _db
        .into(_db.cloudCacheEntries)
        .insertOnConflictUpdate(
          CloudCacheEntriesCompanion.insert(
            trackId: Value(trackId),
            remoteLocator: remoteLocator.value,
            localPath: localPath,
            sizeBytes: sizeBytes,
            lastAccessedAt: now,
          ),
        );
  }

  /// Updates [lastAccessedAt] for [trackId] when present.
  Future<void> touch(int trackId, {DateTime? accessedAt}) async {
    final now = accessedAt ?? DateTime.now().toUtc();
    await (_db.update(_db.cloudCacheEntries)
          ..where((t) => t.trackId.equals(trackId)))
        .write(CloudCacheEntriesCompanion(lastAccessedAt: Value(now)));
  }

  /// Returns the cache row for [trackId], or `null`.
  Future<CloudCacheEntry?> getByTrackId(int trackId) {
    return (_db.select(
      _db.cloudCacheEntries,
    )..where((t) => t.trackId.equals(trackId))).getSingleOrNull();
  }

  /// Returns the cache row for a remote locator string, or `null`.
  Future<CloudCacheEntry?> getByRemoteLocator(String remoteLocator) {
    return (_db.select(
      _db.cloudCacheEntries,
    )..where((t) => t.remoteLocator.equals(remoteLocator))).getSingleOrNull();
  }

  /// Sum of [CloudCacheEntries.sizeBytes] for all rows.
  Future<int> totalSizeBytes() async {
    final rows = await _db.select(_db.cloudCacheEntries).get();
    return rows.fold<int>(0, (sum, row) => sum + row.sizeBytes);
  }

  /// Deletes the cache row and local file for [trackId].
  Future<void> deleteForTrack(int trackId) async {
    final row = await getByTrackId(trackId);
    if (row == null) return;
    await _deleteRowAndFile(row);
  }

  /// Deletes cache for every track under library [rootId].
  Future<void> deleteForRoot(int rootId) async {
    final trackIds =
        await (_db.selectOnly(_db.tracks)
              ..addColumns([_db.tracks.id])
              ..where(_db.tracks.rootId.equals(rootId)))
            .map((row) => row.read(_db.tracks.id)!)
            .get();
    for (final id in trackIds) {
      await deleteForTrack(id);
    }
  }

  /// Deletes cache rows whose remote locator belongs to [provider].
  ///
  /// Purpose: Provider sign-out must not wipe another provider’s downloads.
  Future<void> clearForProvider(CloudProviderId provider) async {
    final prefix = provider.locatorPrefix;
    final rows = await _db.select(_db.cloudCacheEntries).get();
    for (final row in rows) {
      if (row.remoteLocator.startsWith(prefix)) {
        await _deleteRowAndFile(row);
      }
    }
  }

  /// Deletes all cloud cache rows and files.
  Future<void> clearAll() async {
    final rows = await _db.select(_db.cloudCacheEntries).get();
    for (final row in rows) {
      await _deleteRowAndFile(row);
    }
  }

  /// Evicts oldest cache files until total size ≤ [budgetBytes].
  ///
  /// Never deletes [protectTrackId]. Prefers evicting tracks whose ids are
  /// **not** in [queuedTrackIds] before queued ones.
  Future<void> enforceBudget({
    required int budgetBytes,
    int? protectTrackId,
    Set<int> queuedTrackIds = const {},
  }) async {
    if (budgetBytes < 0) {
      throw ArgumentError.value(budgetBytes, 'budgetBytes');
    }

    var total = await totalSizeBytes();
    if (total <= budgetBytes) return;

    final rows = await _db.select(_db.cloudCacheEntries).get();
    final candidates = [...rows]
      ..sort((a, b) {
        final queuedA = queuedTrackIds.contains(a.trackId);
        final queuedB = queuedTrackIds.contains(b.trackId);
        if (queuedA != queuedB) {
          return queuedA ? 1 : -1;
        }
        return a.lastAccessedAt.compareTo(b.lastAccessedAt);
      });

    for (final row in candidates) {
      if (total <= budgetBytes) break;
      if (protectTrackId != null && row.trackId == protectTrackId) {
        continue;
      }
      await _deleteRowAndFile(row);
      total -= row.sizeBytes;
    }
  }

  /// Downloads via [source], records Drift, then enforces [budgetBytes].
  ///
  /// [onProgress] is forwarded to [CloudLibrarySource.downloadToCache].
  Future<Uri> downloadAndIndex({
    required CloudLibrarySource source,
    required int trackId,
    required MediaLocator remoteLocator,
    required int budgetBytes,
    int? protectTrackId,
    Set<int> queuedTrackIds = const {},
    void Function(int receivedBytes, int totalBytes)? onProgress,
  }) async {
    final cacheLocator = await source.downloadToCache(
      remoteLocator,
      onProgress: onProgress,
    );
    final file = File(cacheLocator.value);
    final size = await file.length();
    await upsert(
      trackId: trackId,
      remoteLocator: remoteLocator,
      localPath: cacheLocator.value,
      sizeBytes: size,
    );
    await enforceBudget(
      budgetBytes: budgetBytes,
      protectTrackId: protectTrackId ?? trackId,
      queuedTrackIds: queuedTrackIds,
    );
    return Uri.file(cacheLocator.value);
  }

  Future<void> _deleteRowAndFile(CloudCacheEntry row) async {
    await (_db.delete(
      _db.cloudCacheEntries,
    )..where((t) => t.trackId.equals(row.trackId))).go();
    try {
      final file = File(row.localPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      final parent = file.parent;
      if (parent.existsSync() && parent.listSync().isEmpty) {
        parent.deleteSync();
      }
    } on Object {
      // Best-effort filesystem cleanup; Drift row is already gone.
    }
    await _artwork?.deleteForTrack(row.trackId);
  }
}
