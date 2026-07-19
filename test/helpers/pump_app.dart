import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:tinytunes/features/library/application/library_providers.dart';
import 'package:tinytunes/features/player/application/player_providers.dart';
import 'package:tinytunes/features/player/application/tinytunes_audio_handler.dart';
import 'package:tinytunes/features/playlist/application/playlist_providers.dart';
import 'package:tinytunes/main.dart';

import '../features/player/fake_playback_engine.dart';

export '../features/player/fake_playback_engine.dart';

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
  bool liveQueueStreams = false,
}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();
  final db = database ?? AppDatabase.memory();
  final engine = playbackEngine ?? FakePlaybackEngine();
  final handler = TinyTunesAudioHandler();

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
        localLibrarySourceProvider.overrideWithValue(
          librarySource ?? const _EmptyFakeLibrarySource(),
        ),
        trackMetadataReaderProvider.overrideWithValue(
          const _EmptyFakeMetadataReader(),
        ),
        toastDeliveryProvider.overrideWithValue(const NoopToastDelivery()),
        audioHandlerProvider.overrideWithValue(handler),
        playbackEngineProvider.overrideWithValue(engine),
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
  await tester.pumpAndSettle();
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
  }) async =>
      '/tmp/empty.mp3';

  @override
  Future<bool> hasPersistedAccess(MediaLocator root) async => false;

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
