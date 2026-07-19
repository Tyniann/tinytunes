import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/library/local_library_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/core/library/track_metadata_reader.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/core/messages/toast_delivery.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:tinytunes/features/library/application/library_providers.dart';
import 'package:tinytunes/features/player/application/playback_controller.dart';
import 'package:tinytunes/features/player/application/player_providers.dart';
import 'package:tinytunes/features/player/application/tinytunes_audio_handler.dart';

import 'fake_playback_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakePlaybackEngine engine;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase.memory();
    engine = FakePlaybackEngine();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        audioHandlerProvider.overrideWithValue(TinyTunesAudioHandler()),
        playbackEngineProvider.overrideWithValue(engine),
        toastDeliveryProvider.overrideWithValue(const NoopToastDelivery()),
        localLibrarySourceProvider.overrideWithValue(
          const _ResolvingFakeLibrarySource(),
        ),
        trackMetadataReaderProvider.overrideWithValue(
          const _EmptyFakeMetadataReader(),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<List<int>> seedQueue(int count) async {
    final rootId = await db.upsertRoot(
      locator: 'content://tree/root',
      displayName: 'Music',
    );
    final rows = <TracksCompanion>[
      for (var i = 0; i < count; i++)
        TracksCompanion.insert(
          rootId: rootId,
          sourceItemId: 't$i',
          locator: 'content://item/$i',
          displayName: 't$i.mp3',
          title: Value('Title $i'),
        ),
    ];
    final result = await db.upsertTracksBatch(rootId, rows);
    await db.appendTrackIds(result.insertedIds);
    final queue = await db.getOrderedQueue();
    return queue.map((e) => e.queueEntryId).toList();
  }

  test('playEntry loads and plays; tap current toggles pause', () async {
    final ids = await seedQueue(2);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.playEntry(ids[0]);
    expect(container.read(playbackControllerProvider).currentQueueEntryId, ids[0]);
    expect(container.read(playbackControllerProvider).playing, isTrue);
    expect(engine.setUriCount, 1);

    await controller.playEntry(ids[0]);
    expect(container.read(playbackControllerProvider).playing, isFalse);
  });

  test('next advances; next at last is no-op', () async {
    final ids = await seedQueue(2);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.playEntry(ids[0]);
    await controller.next();
    expect(container.read(playbackControllerProvider).currentQueueEntryId, ids[1]);

    final setUriBefore = engine.setUriCount;
    await controller.next();
    expect(engine.setUriCount, setUriBefore);
    expect(container.read(playbackControllerProvider).currentQueueEntryId, ids[1]);
  });

  test('previous uses 3s rule then prior track', () async {
    final ids = await seedQueue(2);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.playEntry(ids[1]);
    await controller.seekTo(const Duration(seconds: 10));
    await controller.previous();
    expect(engine.position, Duration.zero);
    expect(container.read(playbackControllerProvider).currentQueueEntryId, ids[1]);

    await controller.previous();
    expect(container.read(playbackControllerProvider).currentQueueEntryId, ids[0]);
  });

  test('completed on last keeps id paused at end', () async {
    final ids = await seedQueue(1);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.playEntry(ids[0]);
    engine.emitCompleted();
    await Future<void>.delayed(Duration.zero);

    final ui = container.read(playbackControllerProvider);
    expect(ui.currentQueueEntryId, ids[0]);
    expect(ui.playing, isFalse);
  });

  test('completed advances to next with autoplay', () async {
    final ids = await seedQueue(2);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.playEntry(ids[0]);
    engine.emitCompleted();
    await Future<void>.delayed(Duration.zero);

    final ui = container.read(playbackControllerProvider);
    expect(ui.currentQueueEntryId, ids[1]);
    expect(ui.playing, isTrue);
  });

  test('remove current autoplays successor via live queue', () async {
    final ids = await seedQueue(3);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    await controller.playEntry(ids[0]);
    await db.removeQueueEntry(ids[0]);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final ui = container.read(playbackControllerProvider);
    expect(ui.currentQueueEntryId, ids[1]);
    expect(ui.playing, isTrue);
  });

  test('clear queue stops and clears checkpoint', () async {
    final ids = await seedQueue(2);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    await controller.playEntry(ids[0]);
    await db.clearQueue();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final ui = container.read(playbackControllerProvider);
    expect(ui.currentQueueEntryId, isNull);
    final playback = await db.getPlaybackState();
    expect(playback.currentQueueEntryId, isNull);
  });

  test('failed setUri does not commit; keeps prior when no successor', () async {
    final ids = await seedQueue(2);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.playEntry(ids[0]);
    expect(container.read(playbackControllerProvider).currentQueueEntryId, ids[0]);

    engine.failNextSetUri = true;
    await controller.playEntry(ids[1]);
    await Future<void>.delayed(Duration.zero);

    final ui = container.read(playbackControllerProvider);
    expect(ui.currentQueueEntryId, ids[0]);
    expect(ui.playing, isFalse);
  });

  test('restoreOnLaunch loads paused from checkpoint', () async {
    final ids = await seedQueue(1);
    await db.checkpoint(entryId: ids[0], positionMs: 5000);

    // New container to trigger restore
    container.dispose();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    engine = FakePlaybackEngine();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        audioHandlerProvider.overrideWithValue(TinyTunesAudioHandler()),
        playbackEngineProvider.overrideWithValue(engine),
        toastDeliveryProvider.overrideWithValue(const NoopToastDelivery()),
        localLibrarySourceProvider.overrideWithValue(
          const _ResolvingFakeLibrarySource(),
        ),
        trackMetadataReaderProvider.overrideWithValue(
          const _EmptyFakeMetadataReader(),
        ),
      ],
    );

    container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final ui = container.read(playbackControllerProvider);
    expect(ui.currentQueueEntryId, ids[0]);
    expect(ui.playing, isFalse);
    expect(engine.position, const Duration(milliseconds: 5000));
  });
}

class _ResolvingFakeLibrarySource implements LocalLibrarySource {
  const _ResolvingFakeLibrarySource();

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
      '/tmp/x.mp3';

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
