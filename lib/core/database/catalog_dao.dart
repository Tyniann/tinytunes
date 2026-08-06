import 'package:drift/drift.dart';
import 'package:tinytunes/core/database/app_database.dart';

/// Result of upserting a batch of catalog tracks.
///
/// Purpose: Let ingest distinguish newly inserted rows (queue append on re-scan)
/// from updates to existing catalog rows.
class UpsertTracksResult {
  /// Creates an upsert result with [insertedIds], [updatedIds], and id map.
  const UpsertTracksResult({
    required this.insertedIds,
    required this.updatedIds,
    required this.idsBySourceItemId,
  });

  /// Track ids created in this batch.
  final List<int> insertedIds;

  /// Track ids that already existed and were updated.
  final List<int> updatedIds;

  /// `sourceItemId` → track id for every row in this batch.
  final Map<String, int> idsBySourceItemId;

  /// All affected track ids (inserted then updated order is undefined; prefer lists).
  List<int> get allIds => [...insertedIds, ...updatedIds];
}

/// Queue row joined with catalog fields for the home list.
///
/// Purpose: One read model for playlist UI without Freezed Drift mirrors.
class QueueTrackView {
  /// Creates a joined queue+track projection.
  const QueueTrackView({
    required this.queueEntryId,
    required this.trackId,
    required this.sortIndex,
    required this.displayName,
    required this.locator,
    this.title,
    this.artist,
    this.album,
    this.artworkCacheRef,
    this.sourceKind = 'local',
  });

  /// `queue_entries.id`.
  final int queueEntryId;

  /// `tracks.id`.
  final int trackId;

  /// Canonical queue order.
  final int sortIndex;

  /// File display name.
  final String displayName;

  /// Opaque item locator.
  final String locator;

  /// Optional tag title.
  final String? title;

  /// Optional tag artist.
  final String? artist;

  /// Optional tag album.
  final String? album;

  /// Absolute path to capped cover JPEG, when extracted.
  final String? artworkCacheRef;

  /// Catalog origin (`local` / `cloud`).
  final String sourceKind;

  /// Prefer tag title, else [displayName].
  String get listTitle =>
      (title != null && title!.trim().isNotEmpty) ? title! : displayName;
}

/// Thin catalog/queue data access on [AppDatabase].
///
/// Purpose: Keep ingest and UI off raw table APIs while avoiding a fat repository
/// layer.
extension CatalogDao on AppDatabase {
  /// Inserts a root or returns the existing id for the same [locator].
  Future<int> upsertRoot({
    required String locator,
    required String displayName,
    String sourceKind = 'local',
    DateTime? addedAt,
  }) async {
    final existing = await getRootByLocator(locator);
    if (existing != null) return existing.id;

    return into(libraryRoots).insert(
      LibraryRootsCompanion.insert(
        locator: locator,
        displayName: displayName,
        sourceKind: Value(sourceKind),
        addedAt: addedAt ?? DateTime.now().toUtc(),
      ),
    );
  }

  /// Looks up a root by opaque [locator], or null.
  Future<LibraryRoot?> getRootByLocator(String locator) {
    return (select(
      libraryRoots,
    )..where((t) => t.locator.equals(locator))).getSingleOrNull();
  }

  /// Watches all library roots ordered by add time.
  Stream<List<LibraryRoot>> watchRoots() {
    return (select(
      libraryRoots,
    )..orderBy([(t) => OrderingTerm.asc(t.addedAt)])).watch();
  }

  /// Deletes a root and all dependent catalog/queue rows (DB only).
  ///
  /// Deletes dependents explicitly so Forget remains correct even if a
  /// connection was opened before SQLite foreign-key enforcement was enabled.
  Future<void> deleteRootCascade(int rootId) async {
    await transaction(() async {
      final rootTrackIds = selectOnly(tracks)
        ..addColumns([tracks.id])
        ..where(tracks.rootId.equals(rootId));
      await (delete(
        queueEntries,
      )..where((entry) => entry.trackId.isInQuery(rootTrackIds))).go();
      await (delete(
        tracks,
      )..where((track) => track.rootId.equals(rootId))).go();
      await (delete(
        libraryRoots,
      )..where((root) => root.id.equals(rootId))).go();
    });
  }

  /// Upserts tracks for [rootId]; returns inserted vs updated ids.
  Future<UpsertTracksResult> upsertTracksBatch(
    int rootId,
    List<TracksCompanion> rows,
  ) async {
    final inserted = <int>[];
    final updated = <int>[];
    final idsBySourceItemId = <String, int>{};

    await transaction(() async {
      for (final row in rows) {
        final sourceItemId = row.sourceItemId.value;
        final existing =
            await (select(tracks)..where(
                  (t) =>
                      t.rootId.equals(rootId) &
                      t.sourceItemId.equals(sourceItemId),
                ))
                .getSingleOrNull();

        if (existing == null) {
          final id = await into(
            tracks,
          ).insert(row.copyWith(rootId: Value(rootId)));
          inserted.add(id);
          idsBySourceItemId[sourceItemId] = id;
        } else {
          await (update(tracks)..where((t) => t.id.equals(existing.id))).write(
            TracksCompanion(
              displayName: row.displayName,
              locator: row.locator,
              // Absent tag fields (cloud list-only re-scan) must not wipe play-path tags.
              title: row.title,
              artist: row.artist,
              album: row.album,
              sizeBytes: row.sizeBytes.present
                  ? row.sizeBytes
                  : const Value.absent(),
              modifiedAt: row.modifiedAt.present
                  ? row.modifiedAt
                  : const Value.absent(),
              // Artwork is written separately via [ArtworkCacheStore]; do not wipe.
              artworkCacheRef: row.artworkCacheRef.present
                  ? row.artworkCacheRef
                  : const Value.absent(),
              sourceKind: row.sourceKind.present
                  ? row.sourceKind
                  : const Value.absent(),
            ),
          );
          updated.add(existing.id);
          idsBySourceItemId[sourceItemId] = existing.id;
        }
      }
    });

    return UpsertTracksResult(
      insertedIds: inserted,
      updatedIds: updated,
      idsBySourceItemId: idsBySourceItemId,
    );
  }

  /// Writes tag fields for an existing [trackId] (cloud play-path enrichment).
  Future<void> updateTrackTags({
    required int trackId,
    String? title,
    String? artist,
    String? album,
  }) {
    return (update(tracks)..where((t) => t.id.equals(trackId))).write(
      TracksCompanion(
        title: Value(title),
        artist: Value(artist),
        album: Value(album),
      ),
    );
  }

  /// Track ids under [rootId] whose source ids are not in [seenSourceItemIds].
  Future<List<int>> trackIdsNotIn(
    int rootId,
    Set<String> seenSourceItemIds,
  ) async {
    final query = select(tracks)..where((t) => t.rootId.equals(rootId));
    if (seenSourceItemIds.isNotEmpty) {
      query.where((t) => t.sourceItemId.isNotIn(seenSourceItemIds.toList()));
    }
    final rows = await query.get();
    return rows.map((r) => r.id).toList(growable: false);
  }

  /// Hard-deletes catalog tracks under [rootId] whose source ids are not in [seen].
  Future<int> deleteTracksNotIn(int rootId, Set<String> seenSourceItemIds) {
    if (seenSourceItemIds.isEmpty) {
      return (delete(tracks)..where((t) => t.rootId.equals(rootId))).go();
    }
    return (delete(tracks)..where(
          (t) =>
              t.rootId.equals(rootId) &
              t.sourceItemId.isNotIn(seenSourceItemIds.toList()),
        ))
        .go();
  }

  /// Appends [trackIds] at the end of the queue; skips ids already queued.
  Future<void> appendTrackIds(List<int> trackIds) async {
    if (trackIds.isEmpty) return;

    await transaction(() async {
      final maxRow =
          await (select(queueEntries)
                ..orderBy([(t) => OrderingTerm.desc(t.sortIndex)])
                ..limit(1))
              .getSingleOrNull();
      var nextIndex = (maxRow?.sortIndex ?? -1) + 1;

      for (final trackId in trackIds) {
        final existing = await (select(
          queueEntries,
        )..where((t) => t.trackId.equals(trackId))).getSingleOrNull();
        if (existing != null) continue;

        await into(queueEntries).insert(
          QueueEntriesCompanion.insert(trackId: trackId, sortIndex: nextIndex),
        );
        nextIndex++;
      }
    });
  }

  /// Removes one queue row by entry id.
  Future<void> removeQueueEntry(int entryId) async {
    await (delete(queueEntries)..where((t) => t.id.equals(entryId))).go();
  }

  /// Clears the entire queue; catalog untouched.
  Future<void> clearQueue() async {
    await delete(queueEntries).go();
  }

  /// Returns the catalog track id for [entryId], or `null` if missing.
  Future<int?> trackIdForQueueEntry(int entryId) async {
    final row = await (select(
      queueEntries,
    )..where((t) => t.id.equals(entryId))).getSingleOrNull();
    return row?.trackId;
  }

  /// Returns every catalog track id currently linked from the queue.
  Future<Set<int>> queuedTrackIds() async {
    final rows = await select(queueEntries).get();
    return rows.map((r) => r.trackId).toSet();
  }

  /// Watches the queue joined with track fields, ordered by [sortIndex].
  Stream<List<QueueTrackView>> watchOrderedQueue() {
    final query = select(queueEntries).join([
      innerJoin(tracks, tracks.id.equalsExp(queueEntries.trackId)),
    ])..orderBy([OrderingTerm.asc(queueEntries.sortIndex)]);

    return query.watch().map(_mapQueueRows);
  }

  /// One-shot queue read (tests / non-watching callers).
  Future<List<QueueTrackView>> getOrderedQueue() async {
    final query = select(queueEntries).join([
      innerJoin(tracks, tracks.id.equalsExp(queueEntries.trackId)),
    ])..orderBy([OrderingTerm.asc(queueEntries.sortIndex)]);
    return _mapQueueRows(await query.get());
  }

  List<QueueTrackView> _mapQueueRows(List<TypedResult> rows) {
    return rows
        .map((row) {
          final entry = row.readTable(queueEntries);
          final track = row.readTable(tracks);
          return QueueTrackView(
            queueEntryId: entry.id,
            trackId: track.id,
            sortIndex: entry.sortIndex,
            displayName: track.displayName,
            locator: track.locator,
            title: track.title,
            artist: track.artist,
            album: track.album,
            artworkCacheRef: track.artworkCacheRef,
            sourceKind: track.sourceKind,
          );
        })
        .toList(growable: false);
  }

  /// Loads all track ids under [rootId] (for add-folder queue append).
  Future<List<int>> trackIdsForRoot(int rootId) async {
    final rows = await (select(
      tracks,
    )..where((t) => t.rootId.equals(rootId))).get();
    return rows.map((r) => r.id).toList(growable: false);
  }

  /// Watches the singleton `playback_state` row (`id = 1`).
  Stream<PlaybackStateData> watchPlaybackState() {
    return (select(playbackState)..where((t) => t.id.equals(1))).watchSingle();
  }

  /// One-shot read of the singleton `playback_state` row.
  Future<PlaybackStateData> getPlaybackState() {
    return (select(playbackState)..where((t) => t.id.equals(1))).getSingle();
  }

  /// Atomically writes resume fields on the singleton playback row.
  Future<void> checkpoint({int? entryId, required int positionMs}) {
    return (update(playbackState)..where((t) => t.id.equals(1))).write(
      PlaybackStateCompanion(
        currentQueueEntryId: Value(entryId),
        positionMs: Value(positionMs),
      ),
    );
  }

  /// Writes shuffle/repeat toggles only — never touches entry or position.
  ///
  /// Purpose: Persist transport modes independently of the resume checkpoint so
  /// clear/stop can keep modes while wiping now-playing fields.
  Future<void> updatePlaybackModes({
    required bool shuffleEnabled,
    required String repeatMode,
  }) {
    return (update(playbackState)..where((t) => t.id.equals(1))).write(
      PlaybackStateCompanion(
        shuffleEnabled: Value(shuffleEnabled),
        repeatMode: Value(repeatMode),
      ),
    );
  }
}
