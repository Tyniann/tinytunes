import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/cloud/cloud_providers.dart';
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
import 'package:tinytunes/features/player/application/repeat_mode.dart';
import 'package:tinytunes/features/player/application/shuffle_session.dart';
import 'package:tinytunes/features/player/application/tinytunes_audio_handler.dart';

import '../../core/cloud/fake_cloud_library_source.dart';
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
        cloudLibrarySourceProvider.overrideWith(
          (ref) async => FakeCloudLibrarySource(),
        ),
        trackMetadataReaderProvider.overrideWithValue(
          const _EmptyFakeMetadataReader(),
        ),
        playbackRandomProvider.overrideWithValue(Random(1)),
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

  Future<int> appendTrack(String suffix) async {
    final root = (await db.select(db.libraryRoots).get()).single;
    final result = await db.upsertTracksBatch(root.id, [
      TracksCompanion.insert(
        rootId: root.id,
        sourceItemId: 'extra-$suffix',
        locator: 'content://item/extra-$suffix',
        displayName: 'extra-$suffix.mp3',
        title: Value('Extra $suffix'),
      ),
    ]);
    await db.appendTrackIds(result.insertedIds);
    final queue = await db.getOrderedQueue();
    return queue
        .singleWhere((entry) => entry.trackId == result.insertedIds.single)
        .queueEntryId;
  }

  test('playEntry loads and plays; tap current toggles pause', () async {
    final ids = await seedQueue(2);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.playEntry(ids[0]);
    expect(
      container.read(playbackControllerProvider).currentQueueEntryId,
      ids[0],
    );
    expect(container.read(playbackControllerProvider).playing, isTrue);
    expect(engine.setUriCount, 1);
    expect(engine.lastTag?.artUri, isNull);

    await controller.playEntry(ids[0]);
    expect(container.read(playbackControllerProvider).playing, isFalse);
  });

  test('playEntry sets MediaItem.artUri when artworkCacheRef exists', () async {
    final artDir = await Directory.systemTemp.createTemp('tt_play_art_');
    addTearDown(() async {
      if (await artDir.exists()) {
        await artDir.delete(recursive: true);
      }
    });
    final cover = File('${artDir.path}/cover.jpg');
    final image = img.Image(width: 8, height: 8);
    img.fill(image, color: img.ColorRgb8(1, 2, 3));
    await cover.writeAsBytes(img.encodeJpg(image));

    final ids = await seedQueue(1);
    final trackId = (await db.getOrderedQueue()).single.trackId;
    await (db.update(db.tracks)..where((t) => t.id.equals(trackId))).write(
      TracksCompanion(artworkCacheRef: Value(cover.path)),
    );

    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.playEntry(ids[0]);

    expect(engine.lastTag?.artUri, Uri.file(cover.path));
  });

  test('next advances; next at last is no-op', () async {
    final ids = await seedQueue(2);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.playEntry(ids[0]);
    await controller.next();
    expect(
      container.read(playbackControllerProvider).currentQueueEntryId,
      ids[1],
    );

    final setUriBefore = engine.setUriCount;
    await controller.next();
    expect(engine.setUriCount, setUriBefore);
    expect(
      container.read(playbackControllerProvider).currentQueueEntryId,
      ids[1],
    );
  });

  test('previous uses 3s rule then prior track', () async {
    final ids = await seedQueue(2);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.playEntry(ids[1]);
    await controller.seekTo(const Duration(seconds: 10));
    await controller.previous();
    expect(engine.position, Duration.zero);
    expect(
      container.read(playbackControllerProvider).currentQueueEntryId,
      ids[1],
    );

    await controller.previous();
    expect(
      container.read(playbackControllerProvider).currentQueueEntryId,
      ids[0],
    );
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

  test('failed setUri with no successor clears now-playing', () async {
    final ids = await seedQueue(2);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.playEntry(ids[0]);
    expect(
      container.read(playbackControllerProvider).currentQueueEntryId,
      ids[0],
    );

    engine.failNextSetUri = true;
    await controller.playEntry(ids[1]);
    await Future<void>.delayed(Duration.zero);

    final ui = container.read(playbackControllerProvider);
    expect(ui.currentQueueEntryId, isNull);
    expect(ui.playing, isFalse);
    expect((await db.getPlaybackState()).currentQueueEntryId, isNull);
  });

  test('restoreOnLaunch loads paused from checkpoint', () async {
    final ids = await seedQueue(1);
    await db.checkpoint(entryId: ids[0], positionMs: 5000);

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
        cloudLibrarySourceProvider.overrideWith(
          (ref) async => FakeCloudLibrarySource(),
        ),
        trackMetadataReaderProvider.overrideWithValue(
          const _EmptyFakeMetadataReader(),
        ),
        playbackRandomProvider.overrideWithValue(Random(1)),
      ],
    );

    container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final ui = container.read(playbackControllerProvider);
    expect(ui.currentQueueEntryId, ids[0]);
    expect(ui.playing, isFalse);
    expect(engine.position, const Duration(milliseconds: 5000));
  });

  test('setShuffleEnabled and cycleRepeatMode persist to Drift', () async {
    await seedQueue(1);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.setShuffleEnabled(true);
    await controller.cycleRepeatMode(); // off → one
    await controller.cycleRepeatMode(); // one → all

    final ui = container.read(playbackControllerProvider);
    expect(ui.shuffleEnabled, isTrue);
    expect(ui.repeatMode, RepeatMode.all);

    final playback = await db.getPlaybackState();
    expect(playback.shuffleEnabled, isTrue);
    expect(playback.repeatMode, 'all');
  });

  test('rapid mode changes persist the latest controller snapshot', () async {
    await seedQueue(2);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    final writes = [
      controller.setShuffleEnabled(true),
      controller.cycleRepeatMode(), // one
      controller.setShuffleEnabled(false),
      controller.cycleRepeatMode(), // all
    ];
    await Future.wait(writes);

    final ui = container.read(playbackControllerProvider);
    final playback = await db.getPlaybackState();
    expect(ui.shuffleEnabled, isFalse);
    expect(ui.repeatMode, RepeatMode.all);
    expect(playback.shuffleEnabled, ui.shuffleEnabled);
    expect(playback.repeatMode, ui.repeatMode.storageValue);
  });

  test('clear queue and remoteStop preserve modes', () async {
    final ids = await seedQueue(2);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    await controller.setShuffleEnabled(true);
    await controller.cycleRepeatMode(); // one
    await controller.playEntry(ids[0]);
    await db.clearQueue();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    var ui = container.read(playbackControllerProvider);
    expect(ui.currentQueueEntryId, isNull);
    expect(ui.shuffleEnabled, isTrue);
    expect(ui.repeatMode, RepeatMode.one);

    await db.appendTrackIds(
      (await db.select(db.tracks).get()).map((t) => t.id).toList(),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final ids2 = (await db.getOrderedQueue())
        .map((e) => e.queueEntryId)
        .toList();
    expect(ids2, isNotEmpty);
    await controller.playEntry(ids2.first);
    await controller.remoteStop();

    ui = container.read(playbackControllerProvider);
    expect(ui.currentQueueEntryId, isNull);
    expect(ui.shuffleEnabled, isTrue);
    expect(ui.repeatMode, RepeatMode.one);
    final playback = await db.getPlaybackState();
    expect(playback.shuffleEnabled, isTrue);
    expect(playback.repeatMode, 'one');
  });

  test('restore with null current still applies modes', () async {
    await db.updatePlaybackModes(shuffleEnabled: true, repeatMode: 'all');

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
        cloudLibrarySourceProvider.overrideWith(
          (ref) async => FakeCloudLibrarySource(),
        ),
        trackMetadataReaderProvider.overrideWithValue(
          const _EmptyFakeMetadataReader(),
        ),
        playbackRandomProvider.overrideWithValue(Random(1)),
      ],
    );

    container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final ui = container.read(playbackControllerProvider);
    expect(ui.currentQueueEntryId, isNull);
    expect(ui.shuffleEnabled, isTrue);
    expect(ui.repeatMode, RepeatMode.all);
  });

  test(
    'restore with missing current clears checkpoint but keeps modes',
    () async {
      await seedQueue(1);
      await db.updatePlaybackModes(shuffleEnabled: true, repeatMode: 'one');
      await db.customStatement('PRAGMA foreign_keys = OFF');
      await (db.update(
        db.playbackState,
      )..where((row) => row.id.equals(1))).write(
        const PlaybackStateCompanion(
          currentQueueEntryId: Value(999),
          positionMs: Value(1234),
        ),
      );
      await db.customStatement('PRAGMA foreign_keys = ON');

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
          cloudLibrarySourceProvider.overrideWith(
            (ref) async => FakeCloudLibrarySource(),
          ),
          trackMetadataReaderProvider.overrideWithValue(
            const _EmptyFakeMetadataReader(),
          ),
          playbackRandomProvider.overrideWithValue(Random(1)),
        ],
      );

      container.read(playbackControllerProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final ui = container.read(playbackControllerProvider);
      final playback = await db.getPlaybackState();
      expect(ui.currentQueueEntryId, isNull);
      expect(ui.shuffleEnabled, isTrue);
      expect(ui.repeatMode, RepeatMode.one);
      expect(playback.currentQueueEntryId, isNull);
      expect(playback.positionMs, 0);
      expect(playback.shuffleEnabled, isTrue);
      expect(playback.repeatMode, 'one');
    },
  );

  test('Repeat One complete seeks zero without new setUri', () async {
    final ids = await seedQueue(2);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.cycleRepeatMode(); // one
    await controller.playEntry(ids[0]);
    await controller.seekTo(const Duration(seconds: 5));
    final setUriBefore = engine.setUriCount;

    engine.emitCompleted();
    await Future<void>.delayed(Duration.zero);

    final ui = container.read(playbackControllerProvider);
    expect(ui.currentQueueEntryId, ids[0]);
    expect(engine.setUriCount, setUriBefore);
    expect(engine.position, Duration.zero);
    expect(ui.playing, isTrue);
  });

  test(
    'Repeat One ignores duplicate completion events while handling',
    () async {
      final ids = await seedQueue(1);
      final controller = container.read(playbackControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      await controller.cycleRepeatMode(); // one
      await controller.playEntry(ids[0]);
      final seekCountBefore = engine.seekCount;

      engine
        ..emitCompleted()
        ..emitCompleted();
      await Future<void>.delayed(Duration.zero);

      expect(engine.seekCount, seekCountBefore + 1);
      expect(
        container.read(playbackControllerProvider).currentQueueEntryId,
        ids[0],
      );
    },
  );

  test('Shuffle+Off remove current uses perm successor not suffix', () async {
    final ids = await seedQueue(3);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    await controller.playEntry(ids[0]);
    await controller.setShuffleEnabled(true);

    final expected = ShuffleSession.rebuildFromHead(
      headId: ids[0],
      queueIds: ids,
      random: Random(1),
    );
    expect(expected.permutation.first, ids[0]);
    final expectedSuccessor = expected.permutation[1];

    await db.removeQueueEntry(ids[0]);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final ui = container.read(playbackControllerProvider);
    expect(ui.currentQueueEntryId, expectedSuccessor);
  });

  test(
    'Shuffle+Off prunes non-current and appends new entry to perm',
    () async {
      final ids = await seedQueue(4);
      final controller = container.read(playbackControllerProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      await controller.playEntry(ids[0]);
      await controller.setShuffleEnabled(true);

      final expectedInitial = ShuffleSession.rebuildFromHead(
        headId: ids[0],
        queueIds: ids,
        random: Random(1),
      ).permutation;
      final removedId = expectedInitial[1];
      await db.removeQueueEntry(removedId);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      final appendedId = await appendTrack('perm-tail');
      await Future<void>.delayed(const Duration(milliseconds: 30));

      final expectedOrder = [
        for (final id in expectedInitial)
          if (id != removedId) id,
        appendedId,
      ];
      final observed = <int>[ids[0]];
      for (var i = 1; i < expectedOrder.length; i++) {
        await controller.next();
        observed.add(
          container.read(playbackControllerProvider).currentQueueEntryId!,
        );
      }

      expect(observed, expectedOrder);
      final setUriBefore = engine.setUriCount;
      await controller.next();
      expect(engine.setUriCount, setUriBefore);
    },
  );

  test(
    'Shuffle+Off unplayable skips by perm rather than canonical order',
    () async {
      final ids = await seedQueue(4);
      final controller = container.read(playbackControllerProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      await controller.playEntry(ids[0]);
      await controller.setShuffleEnabled(true);
      final perm = ShuffleSession.rebuildFromHead(
        headId: ids[0],
        queueIds: ids,
        random: Random(1),
      ).permutation;
      final failedId = perm[1];
      final expectedSuccessor = perm[2];

      engine.failNextSetUri = true;
      await controller.next();
      await Future<void>.delayed(Duration.zero);

      expect(failedId, isNot(expectedSuccessor));
      expect(
        container.read(playbackControllerProvider).currentQueueEntryId,
        expectedSuccessor,
      );
    },
  );

  test('Shuffle+All row tap records history for Previous', () async {
    final ids = await seedQueue(3);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.setShuffleEnabled(true);
    await controller.cycleRepeatMode(); // one
    await controller.cycleRepeatMode(); // all
    await controller.playEntry(ids[0]);
    await controller.playEntry(ids[2]);
    await controller.previous();

    expect(
      container.read(playbackControllerProvider).currentQueueEntryId,
      ids[0],
    );
  });

  test(
    'mode cycle All to Off while shuffle on keeps playing current',
    () async {
      final ids = await seedQueue(3);
      final controller = container.read(playbackControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      await controller.setShuffleEnabled(true);
      await controller.cycleRepeatMode(); // one
      await controller.cycleRepeatMode(); // all
      await controller.playEntry(ids[1]);
      await controller.cycleRepeatMode(); // all → off

      final ui = container.read(playbackControllerProvider);
      expect(ui.shuffleEnabled, isTrue);
      expect(ui.repeatMode, RepeatMode.off);
      expect(ui.currentQueueEntryId, ids[1]);

      final random = Random(1);
      ShuffleSession.rebuildFromHead(
        headId: null,
        queueIds: ids,
        random: random,
      );
      final expectedAfterTransition = ShuffleSession.rebuildFromHead(
        headId: ids[1],
        queueIds: ids,
        random: random,
      ).permutation[1];
      await controller.next();
      expect(
        container.read(playbackControllerProvider).currentQueueEntryId,
        expectedAfterTransition,
      );
    },
  );

  test('single-track Shuffle+All next re-picks same entry', () async {
    final ids = await seedQueue(1);
    final controller = container.read(playbackControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.setShuffleEnabled(true);
    await controller.cycleRepeatMode(); // one
    await controller.cycleRepeatMode(); // all
    await controller.playEntry(ids[0]);
    await controller.next();

    expect(
      container.read(playbackControllerProvider).currentQueueEntryId,
      ids[0],
    );
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
  }) async => '/tmp/x.mp3';

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
