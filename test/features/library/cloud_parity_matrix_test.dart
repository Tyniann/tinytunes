import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/cloud/cloud_cache_store.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/cloud_provider_id.dart';
import 'package:tinytunes/core/cloud/cloud_providers.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_auth.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_auth.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/source_kinds.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/library/local_library_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/core/library/track_metadata_reader.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/core/messages/toast_delivery.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:tinytunes/features/library/application/cloud_folder_pick.dart';
import 'package:tinytunes/features/library/application/library_ingest_controller.dart';
import 'package:tinytunes/features/library/application/library_ingest_l10n.dart';
import 'package:tinytunes/features/library/application/library_providers.dart';
import 'package:tinytunes/features/playlist/application/playlist_providers.dart';

import '../../core/cloud/fake_cloud_library_source.dart';
import '../../core/cloud/google_drive/fake_google_drive.dart';
import '../../core/cloud/one_drive/fake_one_drive.dart';

/// Provider-parameterized end-to-end parity for Google Drive and OneDrive.
void main() {
  for (final fixture in _fixtures) {
    group('cloud parity (${fixture.provider.token})', () {
      late AppDatabase db;
      late Directory tempDir;
      late FakeCloudLibrarySource cloud;
      late ProviderContainer container;
      late CloudCacheStore cache;
      const l10n = LibraryIngestL10n.english();

      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        db = AppDatabase.memory();
        tempDir = await Directory.systemTemp.createTemp('tt_parity_');
        cloud = FakeCloudLibrarySource(
          childrenByParent: {
            fixture.music.value: [
              CloudLibraryEntry(
                locator: fixture.nested,
                name: 'album',
                isDirectory: true,
              ),
              CloudLibraryEntry(
                locator: fixture.trackA,
                name: 'a.mp3',
                isDirectory: false,
                sizeBytes: 10,
              ),
              CloudLibraryEntry(
                locator: fixture.trackZ,
                name: 'zulu.mp3',
                isDirectory: false,
                sizeBytes: 10,
              ),
            ],
            fixture.nested.value: [
              CloudLibraryEntry(
                locator: fixture.trackB,
                name: 'b.mp3',
                isDirectory: false,
                sizeBytes: 20,
              ),
            ],
          },
        );

        final overrides = <Override>[
          appDatabaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
          cloudLibrarySourceProvider.overrideWith((ref) async => cloud),
          localLibrarySourceProvider.overrideWithValue(
            const _UnusedLocalLibrarySource(),
          ),
          trackMetadataReaderProvider.overrideWithValue(
            const _UnusedMetadataReader(),
          ),
          toastDeliveryProvider.overrideWithValue(const NoopToastDelivery()),
          ...fixture.authOverrides(),
        ];
        container = ProviderContainer(overrides: overrides);
        cache = container.read(cloudCacheStoreProvider);
        fixture.primeSession(container);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
      });

      tearDown(() async {
        container.dispose();
        await db.close();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('flat import orders by display name and stamps ownership', () async {
        await container
            .read(libraryIngestControllerProvider.notifier)
            .addCloudFolder(
              l10n: l10n,
              provider: fixture.provider,
              pick: () async => CloudFolderPick(
                locator: fixture.music,
                displayName: 'Musik',
                includeSubfolders: false,
              ),
            );

        final queue = await db.getOrderedQueue();
        expect(queue.map((e) => e.displayName).toList(), [
          'a.mp3',
          'zulu.mp3',
        ]);
        final root = (await db.select(db.libraryRoots).get()).single;
        expect(root.cloudProvider, fixture.provider.token);
        expect(root.cloudAccountKey, fixture.accountKey);
        expect(cloud.downloadCalls, 0);
      });

      test('recursive import indexes nested audio', () async {
        await container
            .read(libraryIngestControllerProvider.notifier)
            .addCloudFolder(
              l10n: l10n,
              provider: fixture.provider,
              pick: () async => CloudFolderPick(
                locator: fixture.music,
                displayName: 'Musik',
                includeSubfolders: true,
              ),
            );

        final tracks = await db.select(db.tracks).get();
        expect(tracks, hasLength(3));
        expect(tracks.every((t) => t.sourceKind == SourceKinds.cloud), isTrue);
      });

      test('rescan prunes missing remote track and its cache', () async {
        await container
            .read(libraryIngestControllerProvider.notifier)
            .addCloudFolder(
              l10n: l10n,
              provider: fixture.provider,
              pick: () async => CloudFolderPick(
                locator: fixture.music,
                displayName: 'Musik',
                includeSubfolders: false,
              ),
            );

        final doomed = (await db.select(db.tracks).get())
            .firstWhere((t) => t.locator == fixture.trackZ.value);
        final path = '${tempDir.path}/doomed.mp3';
        await File(path).writeAsBytes([9, 9, 9]);
        await cache.upsert(
          trackId: doomed.id,
          remoteLocator: fixture.trackZ,
          localPath: path,
          sizeBytes: 3,
        );

        cloud.childrenByParent[fixture.music.value] = [
          CloudLibraryEntry(
            locator: fixture.trackA,
            name: 'a.mp3',
            isDirectory: false,
            sizeBytes: 10,
          ),
        ];

        final rootId = (await db.select(db.libraryRoots).get()).single.id;
        await container
            .read(libraryIngestControllerProvider.notifier)
            .rescanRoot(rootId: rootId, l10n: l10n);

        final tracks = await db.select(db.tracks).get();
        expect(tracks, hasLength(1));
        expect(tracks.single.locator, fixture.trackA.value);
        expect(await cache.getByTrackId(doomed.id), isNull);
        expect(File(path).existsSync(), isFalse);
        expect(await db.getOrderedQueue(), hasLength(1));
      });

      test('forget root removes catalog, queue, and cache', () async {
        await container
            .read(libraryIngestControllerProvider.notifier)
            .addCloudFolder(
              l10n: l10n,
              provider: fixture.provider,
              pick: () async => CloudFolderPick(
                locator: fixture.music,
                displayName: 'Musik',
                includeSubfolders: false,
              ),
            );
        final track = (await db.select(db.tracks).get()).first;
        final path = '${tempDir.path}/keep.mp3';
        await File(path).writeAsBytes([1]);
        await cache.upsert(
          trackId: track.id,
          remoteLocator: MediaLocator(track.locator),
          localPath: path,
          sizeBytes: 1,
        );

        final rootId = (await db.select(db.libraryRoots).get()).single.id;
        await container
            .read(libraryIngestControllerProvider.notifier)
            .forgetRoot(rootId: rootId, l10n: l10n);

        expect(await db.select(db.libraryRoots).get(), isEmpty);
        expect(await db.select(db.tracks).get(), isEmpty);
        expect(await db.getOrderedQueue(), isEmpty);
        expect(await cache.getByTrackId(track.id), isNull);
        expect(File(path).existsSync(), isFalse);
      });

      test('queue remove deletes cache but keeps catalog tags', () async {
        await container
            .read(libraryIngestControllerProvider.notifier)
            .addCloudFolder(
              l10n: l10n,
              provider: fixture.provider,
              pick: () async => CloudFolderPick(
                locator: fixture.music,
                displayName: 'Musik',
                includeSubfolders: false,
              ),
            );
        final track = (await db.select(db.tracks).get()).first;
        await db.updateTrackTags(
          trackId: track.id,
          title: 'Kept Title',
          artist: 'Kept Artist',
        );
        final path = '${tempDir.path}/queued.mp3';
        await File(path).writeAsBytes([1, 2]);
        await cache.upsert(
          trackId: track.id,
          remoteLocator: MediaLocator(track.locator),
          localPath: path,
          sizeBytes: 2,
        );
        final entryId = (await db.getOrderedQueue())
            .firstWhere((e) => e.trackId == track.id)
            .queueEntryId;

        await QueueActions(db, cache).removeEntry(entryId);

        expect(
          (await db.getOrderedQueue()).any((e) => e.trackId == track.id),
          isFalse,
        );
        expect(await cache.getByTrackId(track.id), isNull);
        expect(File(path).existsSync(), isFalse);
        final kept = await (db.select(
          db.tracks,
        )..where((t) => t.id.equals(track.id))).getSingle();
        expect(kept.title, 'Kept Title');
        expect(kept.artist, 'Kept Artist');
      });
    });
  }

  test('shared budget may evict either provider by LRU', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final temp = await Directory.systemTemp.createTemp('tt_budget_x_');
    addTearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });
    final store = CloudCacheStore(db: db);

    Future<int> seed({
      required String rootLocator,
      required MediaLocator trackLocator,
      required String path,
      required int size,
      required DateTime accessedAt,
    }) async {
      final rootId = await db.upsertRoot(
        locator: rootLocator,
        displayName: 'R',
        sourceKind: SourceKinds.cloud,
      );
      final trackId = (await db.upsertTracksBatch(rootId, [
        TracksCompanion.insert(
          rootId: rootId,
          sourceItemId: trackLocator.value,
          locator: trackLocator.value,
          displayName: 't.mp3',
          sourceKind: const Value(SourceKinds.cloud),
        ),
      ])).insertedIds.single;
      await File(path).writeAsBytes(List.filled(size, 1));
      await store.upsert(
        trackId: trackId,
        remoteLocator: trackLocator,
        localPath: path,
        sizeBytes: size,
      );
      await (db.update(db.cloudCacheEntries)
            ..where((t) => t.trackId.equals(trackId)))
          .write(CloudCacheEntriesCompanion(lastAccessedAt: Value(accessedAt)));
      return trackId;
    }

    final gId = await seed(
      rootLocator: DriveMediaLocator.encode('gf').value,
      trackLocator: DriveMediaLocator.encode('g1'),
      path: '${temp.path}/g.mp3',
      size: 5,
      accessedAt: DateTime.utc(2020),
    );
    final oId = await seed(
      rootLocator: 'onedrive:d/r',
      trackLocator: OneDriveMediaLocator.encode(driveId: 'd', itemId: 'o1'),
      path: '${temp.path}/o.mp3',
      size: 5,
      accessedAt: DateTime.utc(2024),
    );

    await store.enforceBudget(budgetBytes: 5);
    expect(await store.getByTrackId(gId), isNull);
    expect(await store.getByTrackId(oId), isNotNull);
    expect(await store.totalSizeBytes(), 5);
  });
}

class _ProviderFixture {
  const _ProviderFixture({
    required this.provider,
    required this.accountKey,
    required this.music,
    required this.nested,
    required this.trackA,
    required this.trackB,
    required this.trackZ,
    required this.authOverrides,
    required this.primeSession,
  });

  final CloudProviderId provider;
  final String accountKey;
  final MediaLocator music;
  final MediaLocator nested;
  final MediaLocator trackA;
  final MediaLocator trackB;
  final MediaLocator trackZ;
  final List<Override> Function() authOverrides;
  final void Function(ProviderContainer container) primeSession;
}

final _fixtures = <_ProviderFixture>[
  _ProviderFixture(
    provider: CloudProviderId.googleDrive,
    accountKey: 'gid-user',
    music: DriveMediaLocator.encode('musicFolder'),
    nested: DriveMediaLocator.encode('nestedFolder'),
    trackA: DriveMediaLocator.encode('a'),
    trackB: DriveMediaLocator.encode('b'),
    trackZ: DriveMediaLocator.encode('z'),
    authOverrides: () {
      final auth = FakeGoogleDriveAuth()
        ..account = const GoogleDriveAccount(
          stableAccountKey: 'gid-user',
          email: 'user@example.com',
        );
      return [googleDriveAuthProvider.overrideWithValue(auth)];
    },
    primeSession: (container) {
      container.read(googleDriveSessionControllerProvider);
    },
  ),
  _ProviderFixture(
    provider: CloudProviderId.oneDrive,
    accountKey: 'oid-user',
    music: OneDriveMediaLocator.encode(driveId: 'd1', itemId: 'music'),
    nested: OneDriveMediaLocator.encode(driveId: 'd1', itemId: 'nested'),
    trackA: OneDriveMediaLocator.encode(driveId: 'd1', itemId: 'a'),
    trackB: OneDriveMediaLocator.encode(driveId: 'd1', itemId: 'b'),
    trackZ: OneDriveMediaLocator.encode(driveId: 'd1', itemId: 'z'),
    authOverrides: () {
      final auth = FakeOneDriveAuth(
        account: const OneDriveAccount(
          stableAccountKey: 'oid-user',
          email: 'od@example.com',
        ),
      );
      return [oneDriveAuthProvider.overrideWithValue(auth)];
    },
    primeSession: (container) {
      container.read(oneDriveSessionControllerProvider);
    },
  ),
];

class _UnusedLocalLibrarySource implements LocalLibrarySource {
  const _UnusedLocalLibrarySource();

  @override
  Future<MediaLocator?> pickAndRetainRoot() async => null;

  @override
  Future<List<LibraryEntry>> listChildren(MediaLocator parent) async =>
      const [];

  @override
  Future<Uri> resolvePlaybackUri(MediaLocator item) async =>
      Uri.parse(item.value);

  @override
  Future<String> materializeReadablePath(
    MediaLocator item, {
    String? fileNameHint,
  }) async => '/tmp/x.mp3';

  @override
  Future<bool> hasPersistedAccess(MediaLocator root) async => false;

  @override
  Future<List<MediaLocator>> listPersistedRoots() async => const [];

  @override
  Future<void> releaseRoot(MediaLocator root) async {}
}

class _UnusedMetadataReader implements TrackMetadataReader {
  const _UnusedMetadataReader();

  @override
  Future<TrackMetadata> read(String path) async => const TrackMetadata();
}
