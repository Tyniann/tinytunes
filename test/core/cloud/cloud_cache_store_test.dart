import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/cloud_cache_budget.dart';
import 'package:tinytunes/core/cloud/cloud_cache_store.dart';
import 'package:tinytunes/core/cloud/drive_media_locator.dart';
import 'package:tinytunes/core/cloud/drive_remote.dart';
import 'package:tinytunes/core/cloud/google_drive_cloud_library_source.dart';
import 'package:tinytunes/core/cloud/source_kinds.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';

import 'fake_drive_remote.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase.memory();
    tempDir = await Directory.systemTemp.createTemp('tt_cloud_cache_');
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<int> insertCloudTrack({
    required String fileId,
    required String name,
  }) async {
    final rootId = await db.upsertRoot(
      locator: DriveMediaLocator.encode('folderRoot').value,
      displayName: 'Cloud',
      sourceKind: SourceKinds.cloud,
    );
    final locator = DriveMediaLocator.encode(fileId);
    final result = await db.upsertTracksBatch(rootId, [
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: locator.value,
        locator: locator.value,
        displayName: name,
        sourceKind: const Value(SourceKinds.cloud),
      ),
    ]);
    return result.insertedIds.single;
  }

  test('enforceBudget evicts oldest non-queued before queued', () async {
    final tOld = await insertCloudTrack(fileId: 'old', name: 'old.mp3');
    final tQueued = await insertCloudTrack(fileId: 'q', name: 'q.mp3');
    final tNew = await insertCloudTrack(fileId: 'new', name: 'new.mp3');

    final store = CloudCacheStore(db: db);
    final base = DateTime.utc(2026, 1, 1);

    Future<void> put(int trackId, String fileId, DateTime at) async {
      final path = '${tempDir.path}/$fileId.mp3';
      await File(path).writeAsBytes([1, 2, 3, 4, 5]);
      await store.upsert(
        trackId: trackId,
        remoteLocator: DriveMediaLocator.encode(fileId),
        localPath: path,
        sizeBytes: 5,
        accessedAt: at,
      );
    }

    await put(tOld, 'old', base);
    await put(tQueued, 'q', base.add(const Duration(hours: 1)));
    await put(tNew, 'new', base.add(const Duration(hours: 2)));

    // Budget fits only one 5-byte file.
    await store.enforceBudget(
      budgetBytes: 5,
      protectTrackId: tNew,
      queuedTrackIds: {tQueued, tNew},
    );

    expect(await store.getByTrackId(tNew), isNotNull);
    expect(await store.getByTrackId(tOld), isNull);
    // Queued but unprotected and older than protect — may be evicted after old.
    expect(await store.totalSizeBytes(), lessThanOrEqualTo(5));
    expect(File('${tempDir.path}/old.mp3').existsSync(), isFalse);
  });

  test('enforceBudget never deletes protectTrackId', () async {
    final tProtect = await insertCloudTrack(fileId: 'p', name: 'p.mp3');
    final tOther = await insertCloudTrack(fileId: 'o', name: 'o.mp3');
    final store = CloudCacheStore(db: db);

    await store.upsert(
      trackId: tProtect,
      remoteLocator: DriveMediaLocator.encode('p'),
      localPath: '${tempDir.path}/p.mp3',
      sizeBytes: 100,
      accessedAt: DateTime.utc(2026, 1, 1),
    );
    await File('${tempDir.path}/p.mp3').writeAsBytes(List.filled(100, 1));
    await store.upsert(
      trackId: tOther,
      remoteLocator: DriveMediaLocator.encode('o'),
      localPath: '${tempDir.path}/o.mp3',
      sizeBytes: 100,
      accessedAt: DateTime.utc(2026, 1, 2),
    );
    await File('${tempDir.path}/o.mp3').writeAsBytes(List.filled(100, 2));

    await store.enforceBudget(budgetBytes: 50, protectTrackId: tProtect);

    expect(await store.getByTrackId(tProtect), isNotNull);
    expect(await store.getByTrackId(tOther), isNull);
    expect(await store.totalSizeBytes(), 100);
  });

  test('downloadAndIndex writes Drift row and file', () async {
    const fileId = 'dl1';
    final trackId = await insertCloudTrack(fileId: fileId, name: 'dl.mp3');
    final remote = FakeDriveRemote(
      files: {
        fileId: const DriveRemoteFileMeta(
          fileId: fileId,
          name: 'dl.mp3',
          sizeBytes: 3,
        ),
      },
      fileBytes: {
        fileId: [9, 8, 7],
      },
    );
    final source = GoogleDriveCloudLibrarySource(
      remote: remote,
      cacheRootDirectory: tempDir,
    );
    final store = CloudCacheStore(db: db);

    final uri = await store.downloadAndIndex(
      source: source,
      trackId: trackId,
      remoteLocator: DriveMediaLocator.encode(fileId),
      budgetBytes: CloudCacheBudget.defaultBytes,
    );

    expect(uri.scheme, 'file');
    final row = await store.getByTrackId(trackId);
    expect(row, isNotNull);
    expect(row!.sizeBytes, 3);
    expect(File(row.localPath).readAsBytesSync(), [9, 8, 7]);
  });

  test('deleteForTrack removes Drift row and file', () async {
    final trackId = await insertCloudTrack(fileId: 'z', name: 'z.mp3');
    final path = '${tempDir.path}/z.mp3';
    await File(path).writeAsBytes([1]);
    final store = CloudCacheStore(db: db);
    await store.upsert(
      trackId: trackId,
      remoteLocator: DriveMediaLocator.encode('z'),
      localPath: path,
      sizeBytes: 1,
    );

    await store.deleteForTrack(trackId);
    expect(await store.getByTrackId(trackId), isNull);
    expect(File(path).existsSync(), isFalse);
  });
}
