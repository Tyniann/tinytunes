import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/cloud/cloud_provider_id.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_auth.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/cloud_providers.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_media_locator.dart';
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
import 'package:tinytunes/features/library/application/library_message_codes.dart';
import 'package:tinytunes/features/library/application/library_providers.dart';

import '../../core/cloud/fake_cloud_library_source.dart';
import '../../core/cloud/google_drive/fake_google_drive.dart';

void main() {
  late AppDatabase db;
  late FakeCloudLibrarySource cloud;
  late FakeGoogleDriveAuth auth;
  late ProviderContainer container;
  const l10n = LibraryIngestL10n.english();

  final music = DriveMediaLocator.encode('musicFolder');
  final nested = DriveMediaLocator.encode('nestedFolder');
  final trackA = DriveMediaLocator.encode('a');
  final trackB = DriveMediaLocator.encode('b');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase.memory();
    auth = FakeGoogleDriveAuth()
      ..account = const GoogleDriveAccount(
        stableAccountKey: 'gid-user',
        email: 'user@example.com',
      );
    cloud = FakeCloudLibrarySource(
      childrenByParent: {
        music.value: [
          CloudLibraryEntry(locator: nested, name: 'album', isDirectory: true),
          CloudLibraryEntry(
            locator: trackA,
            name: 'a.mp3',
            isDirectory: false,
            sizeBytes: 10,
          ),
        ],
        nested.value: [
          CloudLibraryEntry(
            locator: trackB,
            name: 'b.mp3',
            isDirectory: false,
            sizeBytes: 20,
          ),
        ],
      },
    );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        googleDriveAuthProvider.overrideWithValue(auth),
        cloudLibrarySourceProvider.overrideWith((ref) async => cloud),
        localLibrarySourceProvider.overrideWithValue(
          const _UnusedLocalLibrarySource(),
        ),
        trackMetadataReaderProvider.overrideWithValue(
          const _UnusedMetadataReader(),
        ),
        toastDeliveryProvider.overrideWithValue(const NoopToastDelivery()),
      ],
    );
    // Eager restore so session.canUseProvider is true for signed-in auth.
    container.read(googleDriveSessionControllerProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('addCloudFolder queues tracks in display-name order', () async {
    cloud = FakeCloudLibrarySource(
      childrenByParent: {
        music.value: [
          CloudLibraryEntry(
            locator: DriveMediaLocator.encode('z'),
            name: 'zulu.mp3',
            isDirectory: false,
            sizeBytes: 1,
          ),
          CloudLibraryEntry(
            locator: DriveMediaLocator.encode('a'),
            name: 'alpha.mp3',
            isDirectory: false,
            sizeBytes: 1,
          ),
          CloudLibraryEntry(
            locator: DriveMediaLocator.encode('m'),
            name: 'Mid.mp3',
            isDirectory: false,
            sizeBytes: 1,
          ),
        ],
      },
    );
    container.dispose();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        googleDriveAuthProvider.overrideWithValue(auth),
        cloudLibrarySourceProvider.overrideWith((ref) async => cloud),
        localLibrarySourceProvider.overrideWithValue(
          const _UnusedLocalLibrarySource(),
        ),
        trackMetadataReaderProvider.overrideWithValue(
          const _UnusedMetadataReader(),
        ),
        toastDeliveryProvider.overrideWithValue(const NoopToastDelivery()),
      ],
    );
    container.read(googleDriveSessionControllerProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    await container
        .read(libraryIngestControllerProvider.notifier)
        .addCloudFolder(
          l10n: l10n,
          provider: CloudProviderId.googleDrive,
          pick: () async => CloudFolderPick(
            locator: music,
            displayName: 'Musik',
            includeSubfolders: false,
          ),
        );

    final queue = await db.getOrderedQueue();
    expect(queue.map((e) => e.displayName).toList(), [
      'alpha.mp3',
      'Mid.mp3',
      'zulu.mp3',
    ]);
  });

  test('addCloudFolder with subfolders indexes nested audio', () async {
    await container
        .read(libraryIngestControllerProvider.notifier)
        .addCloudFolder(
          l10n: l10n,
          provider: CloudProviderId.googleDrive,
          pick: () async => CloudFolderPick(
            locator: music,
            displayName: 'Musik',
            includeSubfolders: true,
          ),
        );

    final tracks = await db.select(db.tracks).get();
    expect(tracks, hasLength(2));
    expect(tracks.every((t) => t.sourceKind == SourceKinds.cloud), isTrue);
    final queue = await db.getOrderedQueue();
    expect(queue, hasLength(2));
  });

  test('addCloudFolder without subfolders skips nested folder files', () async {
    await container
        .read(libraryIngestControllerProvider.notifier)
        .addCloudFolder(
          l10n: l10n,
          provider: CloudProviderId.googleDrive,
          pick: () async => CloudFolderPick(
            locator: music,
            displayName: 'Musik',
            includeSubfolders: false,
          ),
        );

    final tracks = await db.select(db.tracks).get();
    expect(tracks, hasLength(1));
    expect(tracks.single.locator, trackA.value);
  });

  test('addCloudFolder while signed out reports sign-in required', () async {
    await container
        .read(googleDriveSessionControllerProvider.notifier)
        .signOut();
    auth.account = null;
    await container
        .read(libraryIngestControllerProvider.notifier)
        .addCloudFolder(
          l10n: l10n,
          provider: CloudProviderId.googleDrive,
          pick: () async => fail('pick should not run'),
        );

    final codes = container
        .read(sessionMessagesProvider.notifier)
        .store
        .messages
        .map((m) => m.code)
        .toList();
    expect(codes, contains(LibraryMessageCodes.cloudSignInRequired));
    expect(await db.select(db.tracks).get(), isEmpty);
  });

  test('checkRevokedRoots ignores cloud roots', () async {
    await db.upsertRoot(
      locator: music.value,
      displayName: 'Musik',
      sourceKind: SourceKinds.cloud,
    );
    await container
        .read(libraryIngestControllerProvider.notifier)
        .checkRevokedRoots(l10n: l10n);
    expect(
      container.read(libraryIngestControllerProvider).revokedRoots,
      isEmpty,
    );
  });

  test('addCloudFolder is list-only (no download, tags null)', () async {
    await container
        .read(libraryIngestControllerProvider.notifier)
        .addCloudFolder(
          l10n: l10n,
          provider: CloudProviderId.googleDrive,
          pick: () async => CloudFolderPick(
            locator: music,
            displayName: 'Musik',
            includeSubfolders: false,
          ),
        );

    final track = (await db.select(db.tracks).get()).single;
    expect(track.displayName, 'a.mp3');
    expect(track.title, isNull);
    expect(track.artist, isNull);
    expect(cloud.downloadCalls, 0);

    await db.updateTrackTags(
      trackId: track.id,
      title: 'Played Title',
      artist: 'Played Artist',
    );
    await container
        .read(libraryIngestControllerProvider.notifier)
        .addCloudFolder(
          l10n: l10n,
          provider: CloudProviderId.googleDrive,
          pick: () async => CloudFolderPick(
            locator: music,
            displayName: 'Musik',
            includeSubfolders: false,
          ),
        );
    final afterRescan = (await db.select(db.tracks).get()).single;
    expect(afterRescan.title, 'Played Title');
    expect(afterRescan.artist, 'Played Artist');
    expect(cloud.downloadCalls, 0);
  });
}

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
