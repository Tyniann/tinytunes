import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/cloud_providers.dart';
import 'package:tinytunes/core/cloud/drive_media_locator.dart';
import 'package:tinytunes/core/cloud/google_drive_auth.dart';
import 'package:tinytunes/core/cloud/google_drive_probe.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/database_providers.dart';

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

  ProviderContainer makeContainer({
    required FakeGoogleDriveAuth auth,
    FakeGoogleDriveProbe? probe,
  }) {
    return ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        googleDriveAuthProvider.overrideWithValue(auth),
        googleDriveProbeProvider.overrideWithValue(
          probe ?? FakeGoogleDriveProbe(auth),
        ),
      ],
    );
  }

  test('session signIn then listMyDriveRoot then signOut', () async {
    final auth = FakeGoogleDriveAuth();
    final probe = FakeGoogleDriveProbe(
      auth,
      entries: [
        DriveProbeEntry(
          locator: DriveMediaLocator.encode('id1'),
          name: 'Tunes',
          isDirectory: true,
        ),
      ],
    );

    final container = makeContainer(auth: auth, probe: probe);
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

    await controller.listMyDriveRoot();
    state = container.read(googleDriveSessionControllerProvider);
    expect(state.rootEntries, hasLength(1));
    expect(state.rootEntries.single.name, 'Tunes');
    expect(probe.listCalls, 1);

    await controller.signOut();
    state = container.read(googleDriveSessionControllerProvider);
    expect(state.isSignedIn, isFalse);
    expect(state.rootEntries, isEmpty);
    expect(auth.signOutCalls, 1);
  });

  test('first build restores a prior Google session without interactive sign-in',
      () async {
    final auth = FakeGoogleDriveAuth(
      account: const GoogleDriveAccount(email: 'saved@example.com'),
    );
    final container = makeContainer(auth: auth);
    addTearDown(container.dispose);

    container.read(googleDriveSessionControllerProvider);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(googleDriveSessionControllerProvider);
    expect(auth.restoreCalls, 1);
    expect(auth.signInCalls, 0);
    expect(state.isSignedIn, isTrue);
    expect(state.account?.email, 'saved@example.com');
  });

  test('listMyDriveRoot without sign-in sets an error', () async {
    final auth = FakeGoogleDriveAuth();
    final container = makeContainer(auth: auth);
    addTearDown(container.dispose);

    await container
        .read(googleDriveSessionControllerProvider.notifier)
        .listMyDriveRoot();

    final state = container.read(googleDriveSessionControllerProvider);
    expect(state.lastError, 'Sign in first');
    expect(state.rootEntries, isEmpty);
  });

  test('signIn failure surfaces lastError and stays signed out', () async {
    final auth = FakeGoogleDriveAuth(signInError: Exception('cancelled'));
    final container = makeContainer(auth: auth);
    addTearDown(container.dispose);

    await container
        .read(googleDriveSessionControllerProvider.notifier)
        .signIn();

    final state = container.read(googleDriveSessionControllerProvider);
    expect(state.isSignedIn, isFalse);
    expect(state.lastError, contains('cancelled'));
    expect(state.busy, isFalse);
  });
}
