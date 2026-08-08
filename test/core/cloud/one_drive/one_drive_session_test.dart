import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/cloud/cloud_account_ownership.dart';
import 'package:tinytunes/core/cloud/cloud_cache_store.dart';
import 'package:tinytunes/core/cloud/cloud_provider_id.dart';
import 'package:tinytunes/core/cloud/cloud_providers.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_auth.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/source_kinds.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';

import 'fake_one_drive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  Future<ProviderContainer> createContainer({
    required FakeOneDriveAuth auth,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        oneDriveAuthProvider.overrideWithValue(auth),
      ],
    );
  }

  test('signIn then signOut', () async {
    final auth = FakeOneDriveAuth();
    final container = await createContainer(auth: auth);
    addTearDown(container.dispose);

    final notifier = container.read(oneDriveSessionControllerProvider.notifier);
    await notifier.signIn();
    var state = container.read(oneDriveSessionControllerProvider);
    expect(state.isSignedIn, isTrue);
    expect(state.account?.email, 'user@outlook.com');
    expect(state.account?.stableAccountKey, 'oid-example');
    expect(auth.signInCalls, 1);

    await notifier.signOut();
    state = container.read(oneDriveSessionControllerProvider);
    expect(state.isSignedIn, isFalse);
    expect(auth.signOutCalls, 1);
  });

  test('restoreSession on first build restores prior account', () async {
    final auth = FakeOneDriveAuth(
      account: const OneDriveAccount(
        stableAccountKey: 'oid-saved',
        email: 'saved@outlook.com',
      ),
    );
    final container = await createContainer(auth: auth);
    addTearDown(container.dispose);

    container.read(oneDriveSessionControllerProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(oneDriveSessionControllerProvider);
    expect(auth.restoreCalls, greaterThanOrEqualTo(1));
    expect(state.isSignedIn, isTrue);
    expect(state.account?.email, 'saved@outlook.com');
  });

  test('cancelled sign-in clears busy without error', () async {
    final auth = FakeOneDriveAuth(
      signInError: const OneDriveAuthCancelledException(),
    );
    final container = await createContainer(auth: auth);
    addTearDown(container.dispose);

    await container.read(oneDriveSessionControllerProvider.notifier).signIn();
    final state = container.read(oneDriveSessionControllerProvider);
    expect(state.isSignedIn, isFalse);
    expect(state.lastError, isNull);
    expect(state.busy, isFalse);
  });

  test('different account requires confirmation; cancel keeps roots', () async {
    await db.upsertRoot(
      locator: 'onedrive:d/r',
      displayName: 'OD',
      sourceKind: SourceKinds.cloud,
      cloudProvider: 'onedrive',
      cloudAccountKey: 'oid-old',
    );
    final auth = FakeOneDriveAuth(
      signInAccount: const OneDriveAccount(
        stableAccountKey: 'oid-new',
        email: 'new@outlook.com',
      ),
    );
    SharedPreferences.setMockInitialValues({
      CloudAccountOwnership.displayEmailPrefsKey(
        CloudProviderId.oneDrive,
      ): 'old@outlook.com',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        oneDriveAuthProvider.overrideWithValue(auth),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(oneDriveSessionControllerProvider.notifier);
    await notifier.signIn();
    expect(
      container.read(oneDriveSessionControllerProvider).accountChangeRequired,
      isTrue,
    );

    await notifier.cancelAccountReplacement();
    expect(container.read(oneDriveSessionControllerProvider).isSignedIn, isFalse);
    expect(await db.cloudRootsForProvider('onedrive'), hasLength(1));
    expect(auth.signOutCalls, 1);
  });

  test('confirm replacement forgets old OneDrive roots', () async {
    await db.upsertRoot(
      locator: 'onedrive:d/r',
      displayName: 'OD',
      sourceKind: SourceKinds.cloud,
      cloudProvider: 'onedrive',
      cloudAccountKey: 'oid-old',
    );
    final auth = FakeOneDriveAuth(
      signInAccount: const OneDriveAccount(
        stableAccountKey: 'oid-new',
        email: 'new@outlook.com',
      ),
    );
    final container = await createContainer(auth: auth);
    addTearDown(container.dispose);
    final notifier = container.read(oneDriveSessionControllerProvider.notifier);
    await notifier.signIn();
    await notifier.confirmAccountReplacement();
    expect(container.read(oneDriveSessionControllerProvider).isSignedIn, isTrue);
    expect(await db.cloudRootsForProvider('onedrive'), isEmpty);
  });

  test('signOut clears only OneDrive cache rows', () async {
    final auth = FakeOneDriveAuth(
      account: const OneDriveAccount(
        stableAccountKey: 'oid-user',
        email: 'od@example.com',
      ),
    );
    final gPath = '${Directory.systemTemp.path}/tt_g_od_signout.mp3';
    final oPath = '${Directory.systemTemp.path}/tt_o_od_signout.mp3';
    await File(gPath).writeAsBytes([1]);
    await File(oPath).writeAsBytes([2]);
    addTearDown(() {
      for (final path in [gPath, oPath]) {
        final f = File(path);
        if (f.existsSync()) f.deleteSync();
      }
    });

    final gRoot = await db.upsertRoot(
      locator: DriveMediaLocator.encode('folder').value,
      displayName: 'G',
      sourceKind: SourceKinds.cloud,
      cloudProvider: 'gdrive',
      cloudAccountKey: 'gid-1',
    );
    final gLoc = DriveMediaLocator.encode('gfile');
    final gTrack = (await db.upsertTracksBatch(gRoot, [
      TracksCompanion.insert(
        rootId: gRoot,
        sourceItemId: gLoc.value,
        locator: gLoc.value,
        displayName: 'g.mp3',
        sourceKind: const Value(SourceKinds.cloud),
      ),
    ])).insertedIds.single;

    final oRoot = await db.upsertRoot(
      locator: OneDriveMediaLocator.encode(driveId: 'd', itemId: 'r').value,
      displayName: 'O',
      sourceKind: SourceKinds.cloud,
      cloudProvider: 'onedrive',
      cloudAccountKey: 'oid-user',
    );
    final oLoc = OneDriveMediaLocator.encode(driveId: 'd', itemId: 'i');
    final oTrack = (await db.upsertTracksBatch(oRoot, [
      TracksCompanion.insert(
        rootId: oRoot,
        sourceItemId: oLoc.value,
        locator: oLoc.value,
        displayName: 'o.mp3',
        sourceKind: const Value(SourceKinds.cloud),
      ),
    ])).insertedIds.single;

    final store = CloudCacheStore(db: db);
    await store.upsert(
      trackId: gTrack,
      remoteLocator: gLoc,
      localPath: gPath,
      sizeBytes: 1,
    );
    await store.upsert(
      trackId: oTrack,
      remoteLocator: oLoc,
      localPath: oPath,
      sizeBytes: 1,
    );

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        cloudCacheStoreProvider.overrideWithValue(store),
        sharedPreferencesProvider.overrideWithValue(prefs),
        oneDriveAuthProvider.overrideWithValue(auth),
      ],
    );
    addTearDown(container.dispose);

    container.read(oneDriveSessionControllerProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    await container.read(oneDriveSessionControllerProvider.notifier).signOut();

    expect(await store.getByTrackId(oTrack), isNull);
    expect(await store.getByTrackId(gTrack), isNotNull);
    expect(auth.signOutCalls, 1);
  });
}
