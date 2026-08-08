import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/cloud/cloud_providers.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_auth.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_auth.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/library/local_library_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/core/library/track_metadata_reader.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/core/messages/toast_delivery.dart';
import 'package:tinytunes/core/routing/app_router.dart';
import 'package:tinytunes/core/routing/app_routes.dart';
import 'package:tinytunes/core/settings/package_info_provider.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tinytunes/features/library/application/library_providers.dart';
import 'package:tinytunes/features/player/application/player_providers.dart';
import 'package:tinytunes/features/player/application/system_volume_source.dart';
import 'package:tinytunes/features/player/application/tinytunes_audio_handler.dart';
import 'package:tinytunes/features/playlist/application/playlist_providers.dart';
import 'package:tinytunes/main.dart';

import '../core/cloud/fake_cloud_library_source.dart';
import '../core/cloud/google_drive/fake_google_drive.dart';
import '../core/cloud/one_drive/fake_one_drive.dart';
import '../features/player/fake_playback_engine.dart';
import '../features/player/fake_system_volume_source.dart';

export '../features/player/fake_playback_engine.dart';
export '../features/player/fake_system_volume_source.dart';

/// Pumps [TinyTunesApp] with mock prefs, in-memory DB, fake library/player, noop toasts.
///
/// Does **not** call [AudioService.init]. Override [liveQueueStreams] for
/// remove→skip tests that need Drift watch after mutations.
///
/// Call [endPumpApp] at the end of every widget test that uses this helper.
Future<void> pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefsValues = const {},
  List<Override> overrides = const [],
  String initialLocation = '/',
  AppDatabase? database,
  LocalLibrarySource? librarySource,
  FakePlaybackEngine? playbackEngine,
  SystemVolumeSource? systemVolumeSource,
  GoogleDriveAuth? googleDriveAuth,
  OneDriveAuth? oneDriveAuth,
  bool liveQueueStreams = false,
}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();
  final db = database ?? AppDatabase.memory();
  final engine = playbackEngine ?? FakePlaybackEngine();
  final volume = systemVolumeSource ?? FakeSystemVolumeSource();
  final handler = TinyTunesAudioHandler();
  final driveAuth = googleDriveAuth ?? FakeGoogleDriveAuth();
  final odAuth = oneDriveAuth ?? FakeOneDriveAuth();

  final streamOverrides = <Override>[
    if (!liveQueueStreams) ...[
      // One-shot gets — no Drift [watch], so no post-cancel Timer(Duration.zero).
      orderedQueueProvider.overrideWith((ref) async* {
        yield await db.getOrderedQueue();
      }),
      libraryRootsProvider.overrideWith((ref) async* {
        yield await db.select(db.libraryRoots).get();
      }),
    ],
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        packageInfoProvider.overrideWith(
          (ref) async => PackageInfo(
            appName: 'TinyTunes',
            packageName: 'at.blumenlaube.tinytunes',
            version: '0.6.0',
            buildNumber: '6',
          ),
        ),
        localLibrarySourceProvider.overrideWithValue(
          librarySource ?? const _EmptyFakeLibrarySource(),
        ),
        trackMetadataReaderProvider.overrideWithValue(
          const _EmptyFakeMetadataReader(),
        ),
        googleDriveAuthProvider.overrideWithValue(driveAuth),
        oneDriveAuthProvider.overrideWithValue(odAuth),
        cloudLibrarySourceProvider.overrideWith(
          (ref) async => FakeCloudLibrarySource(),
        ),
        toastDeliveryProvider.overrideWithValue(const NoopToastDelivery()),
        audioHandlerProvider.overrideWithValue(handler),
        playbackEngineProvider.overrideWithValue(engine),
        systemVolumeSourceProvider.overrideWithValue(volume),
        appRouterProvider.overrideWithValue(
          GoRouter(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'test-root'),
            initialLocation: initialLocation,
            routes: $appRoutes,
          ),
        ),
        ...streamOverrides,
        ...overrides,
      ],
      child: const TinyTunesApp(),
    ),
  );
  // Resolve FutureProviders without pumpAndSettle — an indeterminate
  // LinearProgressIndicator (e.g. Drive busy) never finishes settle.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Disposes the pumped app and flushes any leftover zero-duration timers.
Future<void> endPumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
}

class _EmptyFakeLibrarySource implements LocalLibrarySource {
  const _EmptyFakeLibrarySource();

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
  }) async => '/tmp/empty.mp3';

  @override
  Future<bool> hasPersistedAccess(MediaLocator root) async => true;

  @override
  Future<List<MediaLocator>> listPersistedRoots() async => const [];

  @override
  Future<void> releaseRoot(MediaLocator root) async {}
}

class _EmptyFakeMetadataReader implements TrackMetadataReader {
  const _EmptyFakeMetadataReader();

  @override
  Future<TrackMetadata> read(String path) async => const TrackMetadata();
}
