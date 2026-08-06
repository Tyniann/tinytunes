import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/cloud_cache_store.dart';
import 'package:tinytunes/core/cloud/cloud_providers.dart';
import 'package:tinytunes/core/cloud/drive_media_locator.dart';
import 'package:tinytunes/core/cloud/source_kinds.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/theme/app_theme_mode.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

import '../../core/cloud/fake_google_drive.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets('theme mode radios persist Light selection', (tester) async {
    await pumpApp(
      tester,
      initialLocation: '/settings',
    );

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.settingsTitle), findsOneWidget);
    expect(find.text(l10n.settingsAppearanceSection), findsOneWidget);
    expect(find.text(l10n.settingsGoogleDriveSection), findsOneWidget);
    expect(find.text(l10n.settingsGoogleDriveSignIn), findsOneWidget);
    expect(find.text(l10n.settingsCloudCacheClear), findsOneWidget);
    expect(
      find.text(l10n.settingsCloudCacheLimit('2.0 GB')),
      findsOneWidget,
    );

    await tester.tap(find.text(l10n.settingsThemeLight));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(container.read(appThemeModeControllerProvider), AppThemeMode.light);
    expect(
      container.read(themePreferencesProvider).readMode(),
      AppThemeMode.light,
    );

    await endPumpApp(tester);
  });

  testWidgets('Google Drive sign-in then sign-out shows account', (
    tester,
  ) async {
    final auth = FakeGoogleDriveAuth();

    await pumpApp(
      tester,
      initialLocation: '/settings',
      googleDriveAuth: auth,
    );

    final l10n = lookupAppLocalizations(const Locale('en'));

    await tester.tap(find.text(l10n.settingsGoogleDriveSignIn));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.text(l10n.settingsGoogleDriveSignedInAs('user@example.com')),
      findsOneWidget,
    );
    expect(find.text(l10n.settingsGoogleDriveSignOut), findsOneWidget);
    expect(find.text(l10n.settingsGoogleDriveSignIn), findsNothing);

    await tester.tap(find.text(l10n.settingsGoogleDriveSignOut));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(l10n.settingsGoogleDriveSignIn), findsOneWidget);
    expect(auth.signOutCalls, 1);

    await endPumpApp(tester);
  });

  testWidgets('Clear cloud cache action empties store after confirm', (
    tester,
  ) async {
    final auth = FakeGoogleDriveAuth();
    final db = AppDatabase.memory();
    addTearDown(db.close);

    final rootId = await db.upsertRoot(
      locator: DriveMediaLocator.encode('folder').value,
      displayName: 'Cloud',
      sourceKind: SourceKinds.cloud,
    );
    final locator = DriveMediaLocator.encode('song');
    final result = await db.upsertTracksBatch(rootId, [
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: locator.value,
        locator: locator.value,
        displayName: 'song.mp3',
        sourceKind: const Value(SourceKinds.cloud),
      ),
    ]);
    final trackId = result.insertedIds.single;
    // Missing file path — exercises Drift cleanup without filesystem races.
    await CloudCacheStore(db: db).upsert(
      trackId: trackId,
      remoteLocator: locator,
      localPath: 'C:\\tinytunes_test_missing\\song.mp3',
      sizeBytes: 3,
    );

    await pumpApp(
      tester,
      initialLocation: '/settings',
      googleDriveAuth: auth,
      database: db,
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(await container.read(cloudCacheStoreProvider).totalSizeBytes(), 3);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.settingsCloudCacheClear), findsOneWidget);

    await container
        .read(googleDriveSessionControllerProvider.notifier)
        .clearCloudCache();
    await tester.pump();

    expect(await container.read(cloudCacheStoreProvider).totalSizeBytes(), 0);

    await endPumpApp(tester);
  });
}
