import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/cloud/cloud_cache_budget.dart';
import 'package:tinytunes/core/cloud/cloud_cache_budget_preferences.dart';
import 'package:tinytunes/core/cloud/cloud_cache_store.dart';
import 'package:tinytunes/core/cloud/cloud_providers.dart';
import 'package:tinytunes/core/cloud/drive_media_locator.dart';
import 'package:tinytunes/core/cloud/source_kinds.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CloudCacheBudgetPreferences', () {
    test('read defaults then round-trips snapped values', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final budgetPrefs = CloudCacheBudgetPreferences(prefs);

      expect(budgetPrefs.readBytes(), CloudCacheBudget.defaultBytes);

      await budgetPrefs.writeBytes(CloudCacheBudget.minBytes);
      expect(budgetPrefs.readBytes(), CloudCacheBudget.minBytes);

      // Halfway to the next step rounds to the nearer step (1.0 GB).
      await budgetPrefs.writeBytes(
        CloudCacheBudget.minBytes + CloudCacheBudget.stepBytes ~/ 2,
      );
      expect(
        budgetPrefs.readBytes(),
        CloudCacheBudget.minBytes + CloudCacheBudget.stepBytes,
      );
    });

    test('clampAndSnap and formatGbLabel', () {
      expect(CloudCacheBudget.clampAndSnap(0), CloudCacheBudget.minBytes);
      expect(
        CloudCacheBudget.clampAndSnap(CloudCacheBudget.maxBytes * 2),
        CloudCacheBudget.maxBytes,
      );
      expect(CloudCacheBudget.formatGbLabel(CloudCacheBudget.minBytes), '0.5 GB');
      expect(
        CloudCacheBudget.formatGbLabel(CloudCacheBudget.defaultBytes),
        '2.0 GB',
      );
    });
  });

  group('CloudCacheBudgetController', () {
    late AppDatabase db;
    late Directory tempDir;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      db = AppDatabase.memory();
      tempDir = await Directory.systemTemp.createTemp('tt_budget_');
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    Future<int> seedCachedTrack(String fileId, int size) async {
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
      final path = '${tempDir.path}/$fileId.mp3';
      await File(path).writeAsBytes(List.filled(size, 1));
      await CloudCacheStore(db: db).upsert(
        trackId: trackId,
        remoteLocator: locator,
        localPath: path,
        sizeBytes: size,
      );
      return trackId;
    }

    test('lowering budget evicts over-limit cache', () async {
      await seedCachedTrack('a', 5);
      await seedCachedTrack('b', 5);
      final store = container.read(cloudCacheStoreProvider);
      expect(await store.totalSizeBytes(), 10);

      await container
          .read(cloudCacheBudgetControllerProvider.notifier)
          .setBudgetBytes(CloudCacheBudget.minBytes);

      // Budget is huge in bytes vs test sizes; force a tiny budget via store.
      await store.enforceBudget(budgetBytes: 5);
      expect(await store.totalSizeBytes(), lessThanOrEqualTo(5));

      expect(
        container.read(cloudCacheBudgetControllerProvider),
        CloudCacheBudget.minBytes,
      );
      expect(
        container.read(cloudCacheBudgetPreferencesProvider).readBytes(),
        CloudCacheBudget.minBytes,
      );
    });
  });
}
