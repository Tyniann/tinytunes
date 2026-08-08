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
import 'package:tinytunes/core/cloud/google_drive/google_drive_auth.dart';
import 'package:tinytunes/core/cloud/source_kinds.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';

import 'fake_google_drive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  Future<ProviderContainer> makeContainer({
    required FakeGoogleDriveAuth auth,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        googleDriveAuthProvider.overrideWithValue(auth),
      ],
    );
  }

  test('session signIn then signOut', () async {
    final auth = FakeGoogleDriveAuth();
    final container = await makeContainer(auth: auth);
    addTearDown(container.dispose);

    final controller = container.read(
      googleDriveSessionControllerProvider.notifier,
    );

    await controller.signIn();
    var state = container.read(googleDriveSessionControllerProvider);
    expect(state.isSignedIn, isTrue);
    expect(state.account?.email, 'user@example.com');
    expect(state.busy, isFalse);
    expect(auth.signInCalls, 1);

    await controller.signOut();
    state = container.read(googleDriveSessionControllerProvider);
    expect(state.isSignedIn, isFalse);
    expect(auth.signOutCalls, 1);
  });

  test('first build restores a prior Google session without interactive sign-in',
      () async {
    final auth = FakeGoogleDriveAuth(
      account: const GoogleDriveAccount(
        stableAccountKey: 'gid-saved',
        email: 'saved@example.com',
      ),
    );
    final container = await makeContainer(auth: auth);
    addTearDown(container.dispose);

    container.read(googleDriveSessionControllerProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(googleDriveSessionControllerProvider);
    expect(auth.restoreCalls, 1);
    expect(auth.signInCalls, 0);
    expect(state.isSignedIn, isTrue);
    expect(state.account?.email, 'saved@example.com');
  });


  test('signIn failure surfaces lastError and stays signed out', () async {
    final auth = FakeGoogleDriveAuth(signInError: Exception('cancelled'));
    final container = await makeContainer(auth: auth);
    addTearDown(container.dispose);

    await container
        .read(googleDriveSessionControllerProvider.notifier)
        .signIn();

    final state = container.read(googleDriveSessionControllerProvider);
    expect(state.isSignedIn, isFalse);
    expect(state.lastError, contains('cancelled'));
    expect(state.busy, isFalse);
  });

  test('same-account reauth binds unbound roots', () async {
    await db.upsertRoot(
      locator: DriveMediaLocator.encode('folderA').value,
      displayName: 'A',
      sourceKind: SourceKinds.cloud,
      cloudProvider: 'gdrive',
    );
    final auth = FakeGoogleDriveAuth();
    final container = await makeContainer(auth: auth);
    addTearDown(container.dispose);

    await container.read(googleDriveSessionControllerProvider.notifier).signIn();
    final roots = await db.cloudRootsForProvider('gdrive');
    expect(roots.single.cloudAccountKey, 'gid-user');
    expect(
      container.read(googleDriveSessionControllerProvider).isSignedIn,
      isTrue,
    );
  });

  test('different account enters pending and blocks list', () async {
    await db.upsertRoot(
      locator: DriveMediaLocator.encode('folderA').value,
      displayName: 'A',
      sourceKind: SourceKinds.cloud,
      cloudProvider: 'gdrive',
      cloudAccountKey: 'gid-old',
    );
    final auth = FakeGoogleDriveAuth(
      signInAccount: const GoogleDriveAccount(
        stableAccountKey: 'gid-new',
        email: 'new@example.com',
      ),
    );
    SharedPreferences.setMockInitialValues({
      CloudAccountOwnership.displayEmailPrefsKey(
        CloudProviderId.googleDrive,
      ): 'old@example.com',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        googleDriveAuthProvider.overrideWithValue(auth),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      googleDriveSessionControllerProvider.notifier,
    );
    await controller.signIn();
    var state = container.read(googleDriveSessionControllerProvider);
    expect(state.accountChangeRequired, isTrue);
    expect(state.pendingAccount?.email, 'new@example.com');
    expect(state.previousAccountEmail, 'old@example.com');
    expect(state.isSignedIn, isFalse);
    expect(state.canUseProvider, isFalse);
  });

  test('cancel account replacement signs out pending without deleting roots',
      () async {
    await db.upsertRoot(
      locator: DriveMediaLocator.encode('folderA').value,
      displayName: 'A',
      sourceKind: SourceKinds.cloud,
      cloudProvider: 'gdrive',
      cloudAccountKey: 'gid-old',
    );
    final auth = FakeGoogleDriveAuth(
      signInAccount: const GoogleDriveAccount(
        stableAccountKey: 'gid-new',
        email: 'new@example.com',
      ),
    );
    final container = await makeContainer(auth: auth);
    addTearDown(container.dispose);
    final controller = container.read(
      googleDriveSessionControllerProvider.notifier,
    );
    await controller.signIn();
    expect(
      container.read(googleDriveSessionControllerProvider).accountChangeRequired,
      isTrue,
    );

    await controller.cancelAccountReplacement();
    final state = container.read(googleDriveSessionControllerProvider);
    expect(state.isSignedIn, isFalse);
    expect(state.accountChangeRequired, isFalse);
    expect(auth.signOutCalls, 1);
    expect(await db.cloudRootsForProvider('gdrive'), hasLength(1));
  });

  test('confirm account replacement forgets old roots then accepts', () async {
    final rootId = await db.upsertRoot(
      locator: DriveMediaLocator.encode('folderA').value,
      displayName: 'A',
      sourceKind: SourceKinds.cloud,
      cloudProvider: 'gdrive',
      cloudAccountKey: 'gid-old',
    );
    final trackId = (await db.upsertTracksBatch(rootId, [
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: 'gdrive:t1',
        locator: 'gdrive:t1',
        displayName: 't.mp3',
        sourceKind: const Value(SourceKinds.cloud),
      ),
    ])).insertedIds.single;
    final path = '${Directory.systemTemp.path}/tt_replace_g.mp3';
    await File(path).writeAsBytes([1]);
    addTearDown(() {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
    });
    final store = CloudCacheStore(db: db);
    await store.upsert(
      trackId: trackId,
      remoteLocator: const MediaLocator('gdrive:t1'),
      localPath: path,
      sizeBytes: 1,
    );

    final auth = FakeGoogleDriveAuth(
      signInAccount: const GoogleDriveAccount(
        stableAccountKey: 'gid-new',
        email: 'new@example.com',
      ),
    );
    final container = await makeContainer(auth: auth);
    addTearDown(container.dispose);
    // Override cache store used by confirm (default provider uses same db).
    final controller = container.read(
      googleDriveSessionControllerProvider.notifier,
    );
    await controller.signIn();
    await controller.confirmAccountReplacement();

    final state = container.read(googleDriveSessionControllerProvider);
    expect(state.isSignedIn, isTrue);
    expect(state.account?.stableAccountKey, 'gid-new');
    expect(await db.cloudRootsForProvider('gdrive'), isEmpty);
    expect(await store.getByTrackId(trackId), isNull);
  });

  test('signOut clears only Google cache rows', () async {
    final auth = FakeGoogleDriveAuth(
      account: const GoogleDriveAccount(
        stableAccountKey: 'gid-user',
        email: 'user@example.com',
      ),
    );
    final gPath = '${Directory.systemTemp.path}/tt_g_signout.mp3';
    final oPath = '${Directory.systemTemp.path}/tt_o_signout.mp3';
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
      cloudAccountKey: 'gid-user',
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
      locator: 'onedrive:d/r',
      displayName: 'O',
      sourceKind: SourceKinds.cloud,
      cloudProvider: 'onedrive',
      cloudAccountKey: 'oid-1',
    );
    const oLoc = 'onedrive:d/i';
    final oTrack = (await db.upsertTracksBatch(oRoot, [
      TracksCompanion.insert(
        rootId: oRoot,
        sourceItemId: oLoc,
        locator: oLoc,
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
      remoteLocator: MediaLocator(oLoc),
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
        googleDriveAuthProvider.overrideWithValue(auth),
      ],
    );
    addTearDown(container.dispose);

    container.read(googleDriveSessionControllerProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    await container.read(googleDriveSessionControllerProvider.notifier).signOut();

    expect(await store.getByTrackId(gTrack), isNull);
    expect(await store.getByTrackId(oTrack), isNotNull);
    expect(auth.signOutCalls, 1);
  });
}
