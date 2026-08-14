import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> seedRoot() {
    return db.upsertRoot(
      locator: 'content://tree/root',
      displayName: 'Music',
      addedAt: DateTime.utc(2026, 1, 1),
    );
  }

  TracksCompanion trackRow(String id, String name) {
    return TracksCompanion.insert(
      rootId: 0,
      sourceItemId: id,
      locator: id,
      displayName: name,
      title: Value('Title $name'),
      artist: const Value('Artist'),
    );
  }

  test('appendTrackIds skips duplicates and orders by sortIndex', () async {
    final rootId = await seedRoot();
    final result = await db.upsertTracksBatch(rootId, [
      trackRow('a', 'a.mp3'),
      trackRow('b', 'b.mp3'),
    ]);
    await db.appendTrackIds(result.insertedIds);
    await db.appendTrackIds(result.insertedIds);

    final queue = await db.watchOrderedQueue().first;
    expect(queue, hasLength(2));
    expect(queue.map((e) => e.displayName).toList(), ['a.mp3', 'b.mp3']);
    expect(queue.map((e) => e.sortIndex).toList(), [0, 1]);
  });

  test('clearQueue leaves catalog tracks intact', () async {
    final rootId = await seedRoot();
    final result = await db.upsertTracksBatch(rootId, [trackRow('a', 'a.mp3')]);
    await db.appendTrackIds(result.insertedIds);
    await db.clearQueue();

    expect(await db.watchOrderedQueue().first, isEmpty);
    final tracks = await db.select(db.tracks).get();
    expect(tracks, hasLength(1));
  });

  test('deleteRootCascade removes tracks and queue entries', () async {
    final rootId = await seedRoot();
    final result = await db.upsertTracksBatch(rootId, [trackRow('a', 'a.mp3')]);
    await db.appendTrackIds(result.insertedIds);

    await db.deleteRootCascade(rootId);

    expect(await db.select(db.libraryRoots).get(), isEmpty);
    expect(await db.select(db.tracks).get(), isEmpty);
    expect(await db.select(db.queueEntries).get(), isEmpty);
  });

  test('deleteTracksNotIn prunes missing and cascades queue rows', () async {
    final rootId = await seedRoot();
    final first = await db.upsertTracksBatch(rootId, [
      trackRow('a', 'a.mp3'),
      trackRow('b', 'b.mp3'),
    ]);
    await db.appendTrackIds(first.insertedIds);

    final removed = await db.deleteTracksNotIn(rootId, {'a'});
    expect(removed, 1);

    final queue = await db.watchOrderedQueue().first;
    expect(queue, hasLength(1));
    expect(queue.single.displayName, 'a.mp3');
  });

  test('queue view maps artworkCacheRef; upsert update does not wipe it', () async {
    final rootId = await seedRoot();
    final inserted = await db.upsertTracksBatch(rootId, [
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: 'a',
        locator: 'a',
        displayName: 'a.mp3',
        artworkCacheRef: const Value('/tmp/a.jpg'),
      ),
    ]);
    await db.appendTrackIds(inserted.insertedIds);

    var queue = await db.getOrderedQueue();
    expect(queue.single.artworkCacheRef, '/tmp/a.jpg');

    await db.upsertTracksBatch(rootId, [
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: 'a',
        locator: 'a',
        displayName: 'a-renamed.mp3',
        title: const Value('Retitled'),
      ),
    ]);

    queue = await db.getOrderedQueue();
    expect(queue.single.displayName, 'a-renamed.mp3');
    expect(queue.single.title, 'Retitled');
    expect(queue.single.artworkCacheRef, '/tmp/a.jpg');
  });

  test('upsertTracksBatch reports inserted vs updated', () async {
    final rootId = await seedRoot();
    final first = await db.upsertTracksBatch(rootId, [trackRow('a', 'a.mp3')]);
    expect(first.insertedIds, hasLength(1));
    expect(first.updatedIds, isEmpty);

    final second = await db.upsertTracksBatch(rootId, [
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: 'a',
        locator: 'a',
        displayName: 'a.mp3',
        title: const Value('Updated'),
      ),
    ]);
    expect(second.insertedIds, isEmpty);
    expect(second.updatedIds, [first.insertedIds.single]);

    final track = await (db.select(db.tracks)
          ..where((t) => t.id.equals(first.insertedIds.single)))
        .getSingle();
    expect(track.title, 'Updated');
  });

  test('queue view exposes containing folder from parent or root', () async {
    final rootId = await seedRoot();
    final result = await db.upsertTracksBatch(rootId, [
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: 'a',
        locator: 'a',
        displayName: 'a.mp3',
        parentFolderName: const Value('CD 1'),
      ),
      trackRow('b', 'b.mp3'),
    ]);
    await db.appendTrackIds(result.insertedIds);

    final queue = await db.getOrderedQueue();
    expect(queue.map((e) => e.containingFolderName).toList(), ['CD 1', 'Music']);
    expect(queue.first.rootDisplayName, 'Music');
  });

  test('removing queue entry nulls playback_state.currentQueueEntryId', () async {
    final rootId = await seedRoot();
    final result = await db.upsertTracksBatch(rootId, [trackRow('a', 'a.mp3')]);
    await db.appendTrackIds(result.insertedIds);
    final entryId = (await db.select(db.queueEntries).get()).single.id;

    await (db.update(db.playbackState)..where((t) => t.id.equals(1))).write(
      PlaybackStateCompanion(currentQueueEntryId: Value(entryId)),
    );

    await db.removeQueueEntry(entryId);

    final state = await (db.select(db.playbackState)
          ..where((t) => t.id.equals(1)))
        .getSingle();
    expect(state.currentQueueEntryId, isNull);
  });

  test('checkpoint atomically writes entry and position', () async {
    final rootId = await seedRoot();
    final result = await db.upsertTracksBatch(rootId, [trackRow('a', 'a.mp3')]);
    await db.appendTrackIds(result.insertedIds);
    final entryId = (await db.select(db.queueEntries).get()).single.id;

    await db.checkpoint(entryId: entryId, positionMs: 12345);
    final state = await db.getPlaybackState();
    expect(state.currentQueueEntryId, entryId);
    expect(state.positionMs, 12345);

    await db.checkpoint(entryId: null, positionMs: 0);
    final cleared = await db.getPlaybackState();
    expect(cleared.currentQueueEntryId, isNull);
    expect(cleared.positionMs, 0);
  });

  test('upsertRoot is idempotent on locator', () async {
    final a = await db.upsertRoot(
      locator: 'content://tree/root',
      displayName: 'Music',
    );
    final b = await db.upsertRoot(
      locator: 'content://tree/root',
      displayName: 'Other',
    );
    expect(a, b);
    expect(await db.select(db.libraryRoots).get(), hasLength(1));
  });

  test('provider account queries do not cross providers', () async {
    await db.upsertRoot(
      locator: 'gdrive:a',
      displayName: 'G',
      sourceKind: 'cloud',
      cloudProvider: 'gdrive',
      cloudAccountKey: 'gid-1',
    );
    await db.upsertRoot(
      locator: 'onedrive:d/i',
      displayName: 'O',
      sourceKind: 'cloud',
      cloudProvider: 'onedrive',
      cloudAccountKey: 'oid-1',
    );
    await db.upsertRoot(
      locator: 'gdrive:b',
      displayName: 'G2',
      sourceKind: 'cloud',
      cloudProvider: 'gdrive',
      cloudAccountKey: 'gid-2',
    );

    final g = await db.cloudRootsForProvider('gdrive');
    final o = await db.cloudRootsForAccount(
      providerToken: 'onedrive',
      accountKey: 'oid-1',
    );
    final keys = await db.distinctCloudAccountKeys('gdrive');

    expect(g, hasLength(2));
    expect(o, hasLength(1));
    expect(o.single.locator, 'onedrive:d/i');
    expect(keys, {'gid-1', 'gid-2'});
  });

  test('bindUnboundCloudRoots only fills null keys for that provider', () async {
    await db.upsertRoot(
      locator: 'gdrive:unbound',
      displayName: 'U',
      sourceKind: 'cloud',
      cloudProvider: 'gdrive',
    );
    await db.upsertRoot(
      locator: 'gdrive:owned',
      displayName: 'O',
      sourceKind: 'cloud',
      cloudProvider: 'gdrive',
      cloudAccountKey: 'gid-keep',
    );
    await db.upsertRoot(
      locator: 'onedrive:d/u',
      displayName: 'OD',
      sourceKind: 'cloud',
      cloudProvider: 'onedrive',
    );

    await db.bindUnboundCloudRoots(
      providerToken: 'gdrive',
      accountKey: 'gid-new',
    );

    final gUnbound = await db.unboundCloudRoots('gdrive');
    final gOwned = await db.cloudRootsForAccount(
      providerToken: 'gdrive',
      accountKey: 'gid-new',
    );
    final odUnbound = await db.unboundCloudRoots('onedrive');

    expect(gUnbound, isEmpty);
    expect(gOwned.map((r) => r.locator), contains('gdrive:unbound'));
    expect(
      (await db.cloudRootsForAccount(
        providerToken: 'gdrive',
        accountKey: 'gid-keep',
      )).single.locator,
      'gdrive:owned',
    );
    expect(odUnbound, hasLength(1));
  });
}
