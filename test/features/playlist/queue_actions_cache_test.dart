import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/cloud_cache_store.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/source_kinds.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/library/media_locator.dart';
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

  Future<({int trackId, int entryId, String path})> seedCachedCloudTrack({
    required String rootLocator,
    required MediaLocator trackLocator,
    required String fileName,
  }) async {
    final rootId = await db.upsertRoot(
      locator: rootLocator,
      displayName: 'Cloud',
      sourceKind: SourceKinds.cloud,
    );
    final result = await db.upsertTracksBatch(rootId, [
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: trackLocator.value,
        locator: trackLocator.value,
        displayName: fileName,
        sourceKind: const Value(SourceKinds.cloud),
      ),
    ]);
    final trackId = result.insertedIds.single;
    await db.appendTrackIds([trackId]);
    final queue = await db.getOrderedQueue();
    final path = '${tempDir.path}/$fileName';
    await File(path).writeAsBytes([1, 2, 3]);
    await cache.upsert(
      trackId: trackId,
      remoteLocator: trackLocator,
      localPath: path,
      sizeBytes: 3,
    );
    return (trackId: trackId, entryId: queue.single.queueEntryId, path: path);
  }

  Future<({int trackId, int entryId, String path})> seedGoogle(String fileId) {
    return seedCachedCloudTrack(
      rootLocator: DriveMediaLocator.encode('folder').value,
      trackLocator: DriveMediaLocator.encode(fileId),
      fileName: '$fileId.mp3',
    );
  }

  Future<({int trackId, int entryId, String path})> seedOneDrive(
    String itemId,
  ) {
    return seedCachedCloudTrack(
      rootLocator: OneDriveMediaLocator.encode(
        driveId: 'd',
        itemId: 'folder',
      ).value,
      trackLocator: OneDriveMediaLocator.encode(driveId: 'd', itemId: itemId),
      fileName: '$itemId.mp3',
    );
  }

  test('removeEntry deletes that track cloud cache file', () async {
    final seeded = await seedGoogle('a');
    expect(await File(seeded.path).exists(), isTrue);

    await actions.removeEntry(seeded.entryId);

    expect(await db.getOrderedQueue(), isEmpty);
    expect(await cache.getByTrackId(seeded.trackId), isNull);
    expect(await File(seeded.path).exists(), isFalse);
  });

  test('removeEntry OneDrive: deletes cache, keeps catalog tags', () async {
    final seeded = await seedOneDrive('song');
    await db.updateTrackTags(
      trackId: seeded.trackId,
      title: 'Kept',
      artist: 'Artist',
      album: 'Album',
    );

    await actions.removeEntry(seeded.entryId);

    expect(await db.getOrderedQueue(), isEmpty);
    expect(await cache.getByTrackId(seeded.trackId), isNull);
    expect(await File(seeded.path).exists(), isFalse);
    final kept = await (db.select(
      db.tracks,
    )..where((t) => t.id.equals(seeded.trackId))).getSingle();
    expect(kept.title, 'Kept');
    expect(kept.artist, 'Artist');
    expect(kept.album, 'Album');
  });

  test('clearQueue deletes cache for all previously queued tracks', () async {
    final a = await seedGoogle('a');
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
