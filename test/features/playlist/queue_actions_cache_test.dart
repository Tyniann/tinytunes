import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/cloud_cache_store.dart';
import 'package:tinytunes/core/cloud/drive_media_locator.dart';
import 'package:tinytunes/core/cloud/source_kinds.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/features/playlist/application/playlist_providers.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;
  late CloudCacheStore cache;
  late QueueActions actions;

  setUp(() async {
    db = AppDatabase.memory();
    tempDir = await Directory.systemTemp.createTemp('tt_queue_cache_');
    cache = CloudCacheStore(db: db);
    actions = QueueActions(db, cache);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<({int trackId, int entryId, String path})> seedCachedCloudTrack(
    String fileId,
  ) async {
    final rootId = await db.upsertRoot(
      locator: DriveMediaLocator.encode('folder').value,
      displayName: 'Cloud',
      sourceKind: SourceKinds.cloud,
    );
    final locator = DriveMediaLocator.encode(fileId);
    final result = await db.upsertTracksBatch(rootId, [
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: locator.value,
        locator: locator.value,
        displayName: '$fileId.mp3',
        sourceKind: const Value(SourceKinds.cloud),
      ),
    ]);
    final trackId = result.insertedIds.single;
    await db.appendTrackIds([trackId]);
    final queue = await db.getOrderedQueue();
    final path = '${tempDir.path}/$fileId.mp3';
    await File(path).writeAsBytes([1, 2, 3]);
    await cache.upsert(
      trackId: trackId,
      remoteLocator: locator,
      localPath: path,
      sizeBytes: 3,
    );
    return (trackId: trackId, entryId: queue.single.queueEntryId, path: path);
  }

  test('removeEntry deletes that track cloud cache file', () async {
    final seeded = await seedCachedCloudTrack('a');
    expect(await File(seeded.path).exists(), isTrue);

    await actions.removeEntry(seeded.entryId);

    expect(await db.getOrderedQueue(), isEmpty);
    expect(await cache.getByTrackId(seeded.trackId), isNull);
    expect(await File(seeded.path).exists(), isFalse);
  });

  test('clearQueue deletes cache for all previously queued tracks', () async {
    final a = await seedCachedCloudTrack('a');
    // Second track: append after first so both are queued.
    final rootId = (await db.select(db.libraryRoots).get()).single.id;
    final locator = DriveMediaLocator.encode('b');
    final result = await db.upsertTracksBatch(rootId, [
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: locator.value,
        locator: locator.value,
        displayName: 'b.mp3',
        sourceKind: const Value(SourceKinds.cloud),
      ),
    ]);
    final trackB = result.insertedIds.single;
    await db.appendTrackIds([trackB]);
    final pathB = '${tempDir.path}/b.mp3';
    await File(pathB).writeAsBytes([4, 5, 6]);
    await cache.upsert(
      trackId: trackB,
      remoteLocator: locator,
      localPath: pathB,
      sizeBytes: 3,
    );

    await actions.clearQueue();

    expect(await db.getOrderedQueue(), isEmpty);
    expect(await cache.getByTrackId(a.trackId), isNull);
    expect(await cache.getByTrackId(trackB), isNull);
    expect(await File(a.path).exists(), isFalse);
    expect(await File(pathB).exists(), isFalse);
  });
}
