import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/cloud_cache_store.dart';
import 'package:tinytunes/core/cloud/cloud_providers.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/source_kinds.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/library/artwork_cache_store.dart';
import 'package:tinytunes/core/library/artwork_providers.dart';
import 'package:tinytunes/core/theme/app_theme_mode.dart';
import 'package:tinytunes/core/theme/dynamic_color_availability.dart';
import 'package:tinytunes/core/theme/theme_catalog.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

import '../../core/cloud/google_drive/fake_google_drive.dart';
import '../../core/theme/fixed_dynamic_availability.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets('theme mode segmented control persists Light selection', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initialLocation: '/settings',
      overrides: [
        dynamicColorAvailabilityControllerProvider.overrideWith(
          () => FixedDynamicAvailability(DynamicColorAvailability.unavailable),
        ),
      ],
    );

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.settingsTitle), findsOneWidget);
    expect(find.text(l10n.settingsModeSection), findsOneWidget);
    expect(find.text(l10n.settingsColorSchemeSection), findsOneWidget);
    expect(find.text(l10n.settingsSchemeDefault), findsOneWidget);
    expect(find.text(l10n.settingsSchemeElectricBlue), findsOneWidget);
    expect(find.text(l10n.settingsSchemeEmberSignal), findsOneWidget);
    expect(find.text(l10n.settingsSchemeHighContrast), findsOneWidget);

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

    expect(find.text(l10n.settingsGoogleDriveSection), findsOneWidget);
    expect(find.text(l10n.settingsGoogleDriveSignIn), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(l10n.settingsOneDriveSignIn),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.text(l10n.settingsOneDriveSection), findsOneWidget);
    expect(find.text(l10n.settingsOneDriveSignIn), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(l10n.settingsCloudCacheClear),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.text(l10n.settingsCloudCacheClear), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(l10n.settingsAboutOpen),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.text(l10n.settingsAboutOpen), findsOneWidget);
    expect(
      find.text(l10n.settingsCloudCacheLimit('2.0 GB')),
      findsOneWidget,
    );

    await endPumpApp(tester);
  });

  testWidgets('scheme chips select High contrast when Dynamic available', (
    tester,
  ) async {
    final fakeLight = ColorScheme.fromSeed(
      seedColor: const Color(0xFF334455),
      brightness: Brightness.light,
    );
    final fakeDark = ColorScheme.fromSeed(
      seedColor: const Color(0xFF334455),
      brightness: Brightness.dark,
    );

    await pumpApp(
      tester,
      initialLocation: '/settings',
      overrides: [
        dynamicColorAvailabilityControllerProvider.overrideWith(
          () => FixedDynamicAvailability(
            DynamicColorAvailability(
              resolved: true,
              light: fakeLight,
              dark: fakeDark,
            ),
          ),
        ),
      ],
    );

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.settingsSchemeDefault), findsOneWidget);
    expect(find.text(l10n.settingsSchemeElectricBlue), findsOneWidget);
    expect(find.text(l10n.settingsSchemeEmberSignal), findsOneWidget);
    expect(find.text(l10n.settingsSchemeHighContrast), findsOneWidget);
    expect(find.text(l10n.settingsSchemeDynamic), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsWidgets);

    await tester.tap(find.text(l10n.settingsSchemeHighContrast));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(
      container.read(appThemeSchemeIdControllerProvider),
      ThemeCatalog.highContrastSchemeId,
    );
    expect(
      container.read(themePreferencesProvider).readSchemeId(),
      ThemeCatalog.highContrastSchemeId,
    );

    await endPumpApp(tester);
  });

  testWidgets('Dynamic chip and info hidden when unavailable', (tester) async {
    await pumpApp(
      tester,
      initialLocation: '/settings',
      overrides: [
        dynamicColorAvailabilityControllerProvider.overrideWith(
          () => FixedDynamicAvailability(DynamicColorAvailability.unavailable),
        ),
      ],
    );

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.settingsSchemeDefault), findsOneWidget);
    expect(find.text(l10n.settingsSchemeHighContrast), findsOneWidget);
    expect(find.text(l10n.settingsSchemeDynamic), findsNothing);
    // About uses info_outline too — Color scheme trailing info must be absent.
    expect(find.byTooltip(l10n.settingsSchemeDynamicInfoTitle), findsNothing);

    await endPumpApp(tester);
  });

  testWidgets('Dynamic info dialog opens from Color scheme header', (
    tester,
  ) async {
    final fakeLight = ColorScheme.fromSeed(
      seedColor: const Color(0xFFAA5500),
      brightness: Brightness.light,
    );
    final fakeDark = ColorScheme.fromSeed(
      seedColor: const Color(0xFFAA5500),
      brightness: Brightness.dark,
    );

    await pumpApp(
      tester,
      initialLocation: '/settings',
      overrides: [
        dynamicColorAvailabilityControllerProvider.overrideWith(
          () => FixedDynamicAvailability(
            DynamicColorAvailability(
              resolved: true,
              light: fakeLight,
              dark: fakeDark,
            ),
          ),
        ),
      ],
    );

    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.tap(find.byTooltip(l10n.settingsSchemeDynamicInfoTitle));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(l10n.settingsSchemeDynamicInfoBody), findsOneWidget);
    await tester.tap(find.text(l10n.settingsSchemeDynamicInfoClose));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(l10n.settingsSchemeDynamicInfoBody), findsNothing);

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

  testWidgets('Clear cloud cache removes audio index and artwork', (
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
    final artworkRoot = Directory.systemTemp.createTempSync(
      'tinytunes_settings_artwork_',
    );
    addTearDown(() {
      if (artworkRoot.existsSync()) {
        artworkRoot.deleteSync(recursive: true);
      }
    });
    final artworkFile = File(
      '${artworkRoot.path}${Platform.pathSeparator}$trackId.jpg',
    )..writeAsBytesSync([1, 2, 3]);
    await (db.update(db.tracks)..where((t) => t.id.equals(trackId))).write(
      TracksCompanion(artworkCacheRef: Value(artworkFile.path)),
    );

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
      overrides: [
        artworkCacheStoreProvider.overrideWithValue(
          ArtworkCacheStore(db: db, root: artworkRoot),
        ),
      ],
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(await container.read(cloudCacheStoreProvider).totalSizeBytes(), 3);

    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.scrollUntilVisible(
      find.text(l10n.settingsCloudCacheClear),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.text(l10n.settingsCloudCacheClear), findsOneWidget);

    // Artwork deletion performs real dart:io work. Widget tests otherwise run
    // in FakeAsync, where that I/O future cannot make progress.
    await tester.runAsync(
      () => container.read(cloudCacheStoreProvider).clearAll(),
    );
    await tester.pump();

    expect(await container.read(cloudCacheStoreProvider).totalSizeBytes(), 0);
    expect(artworkFile.existsSync(), isFalse);
    final track = await (db.select(
      db.tracks,
    )..where((t) => t.id.equals(trackId))).getSingle();
    expect(track.artworkCacheRef, isNull);

    await endPumpApp(tester);
  });

  testWidgets('About dialog shows logo version changelog and privacy link', (
    tester,
  ) async {
    await pumpApp(tester, initialLocation: '/settings');
    final l10n = lookupAppLocalizations(const Locale('en'));

    await tester.scrollUntilVisible(
      find.text(l10n.settingsAboutOpen),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(find.text(l10n.settingsAboutOpen));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(l10n.settingsAboutChangelogHeading), findsOneWidget);
    expect(find.text(l10n.settingsAboutPrivacyPolicy), findsOneWidget);
    expect(find.text(l10n.settingsAboutOpenChangelogOnline), findsOneWidget);
    expect(find.text(l10n.settingsAboutGitHub), findsOneWidget);
    expect(find.byType(Image), findsWidgets);

    await tester.ensureVisible(find.text(l10n.settingsAboutClose));
    await tester.tap(find.text(l10n.settingsAboutClose));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AlertDialog), findsNothing);

    await endPumpApp(tester);
  });
}
