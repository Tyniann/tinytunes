import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/library/local_library_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/core/library/track_metadata_reader.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/core/messages/toast_delivery.dart';
import 'package:tinytunes/features/library/application/library_ingest_controller.dart';
import 'package:tinytunes/features/library/application/library_ingest_l10n.dart';
import 'package:tinytunes/features/library/application/library_message_codes.dart';
import 'package:tinytunes/features/library/application/library_providers.dart';

void main() {
  late AppDatabase db;
  late _FakeLocalLibrarySource source;
  late ProviderContainer container;
  const l10n = LibraryIngestL10n.english();

  final root = MediaLocator('content://fake/tree/music');
  final nestedDir = MediaLocator('content://fake/tree/music/document/album');
  final trackA = MediaLocator('content://fake/tree/music/document/a.mp3');
  final trackB = MediaLocator('content://fake/tree/music/document/album/b.mp3');
  final trackC = MediaLocator('content://fake/tree/music/document/c.mp3');
  final skipTxt = MediaLocator('content://fake/tree/music/document/readme.txt');

  setUp(() {
    db = AppDatabase.memory();
    source = _FakeLocalLibrarySource(
      root: root,
      tree: {
        root.value: [
          LibraryEntry(locator: nestedDir, name: 'album', isDirectory: true),
          LibraryEntry(locator: trackA, name: 'a.mp3', isDirectory: false),
          LibraryEntry(
            locator: skipTxt,
            name: 'readme.txt',
            isDirectory: false,
          ),
        ],
        nestedDir.value: [
          LibraryEntry(locator: trackB, name: 'b.mp3', isDirectory: false),
        ],
      },
    );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        localLibrarySourceProvider.overrideWithValue(source),
        trackMetadataReaderProvider.overrideWithValue(
          const _FakeTrackMetadataReader(),
        ),
        toastDeliveryProvider.overrideWithValue(const NoopToastDelivery()),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  List<String> messageCodes() {
    return container
        .read(sessionMessagesProvider.notifier)
        .store
        .messages
        .map((m) => m.code)
        .toList();
  }

  Future<void> pumpAdd() async {
    await container
        .read(libraryIngestControllerProvider.notifier)
        .addFolder(l10n: l10n);
  }

  test('nested add appends audio only and persists tags', () async {
    await pumpAdd();

    final queue = await db.watchOrderedQueue().first;
    expect(queue.map((e) => e.displayName).toList(), ['a.mp3', 'b.mp3']);
    expect(queue.every((e) => e.title == 'Tagged'), isTrue);
    expect(messageCodes(), contains(LibraryMessageCodes.scanComplete));
  });

  test(
    'add mid-fail keeps partial catalog and does not append queue',
    () async {
      source.failListAfter = 1;
      await pumpAdd();

      expect(await db.select(db.tracks).get(), isNotEmpty);
      expect(await db.watchOrderedQueue().first, isEmpty);
      expect(messageCodes(), contains(LibraryMessageCodes.scanFailed));
    },
  );

  test('explicit re-scan does not resurrect removed rows', () async {
    await pumpAdd();
    final queue = await db.watchOrderedQueue().first;
    await db.removeQueueEntry(queue.first.queueEntryId);

    source.tree[root.value] = [
      LibraryEntry(locator: nestedDir, name: 'album', isDirectory: true),
      LibraryEntry(locator: trackA, name: 'a.mp3', isDirectory: false),
      LibraryEntry(locator: trackC, name: 'c.mp3', isDirectory: false),
    ];
    source.tree[nestedDir.value] = [
      LibraryEntry(locator: trackB, name: 'b.mp3', isDirectory: false),
    ];

    final rootId = (await db.select(db.libraryRoots).get()).single.id;
    await container
        .read(libraryIngestControllerProvider.notifier)
        .rescanRoot(rootId: rootId, l10n: l10n);

    final after = await db.watchOrderedQueue().first;
    final names = after.map((e) => e.displayName).toSet();
    expect(names.contains('a.mp3'), isFalse);
    expect(names.contains('b.mp3'), isTrue);
    expect(names.contains('c.mp3'), isTrue);
    expect(await db.select(db.libraryRoots).get(), hasLength(1));
  });

  test(
    'complete re-scan prunes missing files from catalog and queue',
    () async {
      await pumpAdd();
      source.tree[root.value] = [
        LibraryEntry(locator: trackA, name: 'a.mp3', isDirectory: false),
      ];
      source.tree.remove(nestedDir.value);

      final rootId = (await db.select(db.libraryRoots).get()).single.id;
      await container
          .read(libraryIngestControllerProvider.notifier)
          .rescanRoot(rootId: rootId, l10n: l10n);

      final tracks = await db.select(db.tracks).get();
      expect(tracks, hasLength(1));
      expect(tracks.single.displayName, 'a.mp3');
      final queue = await db.watchOrderedQueue().first;
      expect(queue, hasLength(1));
      expect(queue.single.displayName, 'a.mp3');
    },
  );

  test('cancelled scan does not prune', () async {
    await pumpAdd();
    source.tree[root.value] = [
      LibraryEntry(locator: trackA, name: 'a.mp3', isDirectory: false),
    ];
    source.tree.remove(nestedDir.value);

    final rootId = (await db.select(db.libraryRoots).get()).single.id;
    final notifier = container.read(libraryIngestControllerProvider.notifier);
    var cancelledOnce = false;
    source.beforeListChildren = () {
      if (!cancelledOnce) {
        cancelledOnce = true;
        notifier.cancelScan();
      }
    };

    await notifier.rescanRoot(rootId: rootId, l10n: l10n);

    expect(await db.select(db.tracks).get(), hasLength(2));
    expect(messageCodes(), contains(LibraryMessageCodes.scanCancelled));
  });

  test('single-flight rejects overlapping add', () async {
    source.delayPick = const Duration(milliseconds: 80);
    final notifier = container.read(libraryIngestControllerProvider.notifier);
    final first = notifier.addFolder(l10n: l10n);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final second = notifier.addFolder(l10n: l10n);
    await Future.wait([first, second]);

    expect(await db.select(db.libraryRoots).get(), hasLength(1));
  });

  test('failed startup access check does not escape', () async {
    await pumpAdd();
    source.hasPersistedThrows = true;

    await expectLater(
      container
          .read(libraryIngestControllerProvider.notifier)
          .checkRevokedRoots(l10n: l10n),
      completes,
    );
  });

  test('adding same folder twice does not duplicate queue entries', () async {
    await pumpAdd();
    await pumpAdd();

    final queue = await db.watchOrderedQueue().first;
    expect(queue.map((e) => e.displayName).toList(), ['a.mp3', 'b.mp3']);
    expect(await db.select(db.libraryRoots).get(), hasLength(1));
  });

  test('clear then add same folder refills queue', () async {
    await pumpAdd();
    await db.clearQueue();

    await pumpAdd();

    final queue = await db.watchOrderedQueue().first;
    expect(queue.map((e) => e.displayName).toList(), ['a.mp3', 'b.mp3']);
    expect(await db.select(db.libraryRoots).get(), hasLength(1));
  });

  test('clear then re-scan does not refill queue (no resurrection)', () async {
    await pumpAdd();
    await db.clearQueue();
    expect(await db.watchOrderedQueue().first, isEmpty);
    expect(await db.select(db.tracks).get(), isNotEmpty);

    final rootId = (await db.select(db.libraryRoots).get()).single.id;
    await container
        .read(libraryIngestControllerProvider.notifier)
        .rescanRoot(rootId: rootId, l10n: l10n);

    expect(await db.watchOrderedQueue().first, isEmpty);
    expect(await db.select(db.tracks).get(), isNotEmpty);
  });

  test('forget then add folder refills queue', () async {
    await pumpAdd();
    final rootId = (await db.select(db.libraryRoots).get()).single.id;
    await container
        .read(libraryIngestControllerProvider.notifier)
        .forgetRoot(rootId: rootId, l10n: l10n);
    expect(await db.select(db.libraryRoots).get(), isEmpty);
    expect(await db.select(db.tracks).get(), isEmpty);

    await pumpAdd();

    final queue = await db.watchOrderedQueue().first;
    expect(queue.map((e) => e.displayName).toList(), ['a.mp3', 'b.mp3']);
    expect(await db.select(db.libraryRoots).get(), hasLength(1));
  });

  test('forget deletes DB then releases grant', () async {
    await pumpAdd();
    final rootId = (await db.select(db.libraryRoots).get()).single.id;
    await container
        .read(libraryIngestControllerProvider.notifier)
        .forgetRoot(rootId: rootId, l10n: l10n);

    expect(await db.select(db.libraryRoots).get(), isEmpty);
    expect(source.released, contains(root));
    expect(messageCodes(), contains(LibraryMessageCodes.forgetComplete));
  });

  test(
    'forget reports failure when release throws but keeps DB deleted',
    () async {
      await pumpAdd();
      source.releaseThrows = true;
      final rootId = (await db.select(db.libraryRoots).get()).single.id;
      await container
          .read(libraryIngestControllerProvider.notifier)
          .forgetRoot(rootId: rootId, l10n: l10n);

      expect(await db.select(db.libraryRoots).get(), isEmpty);
      expect(messageCodes(), contains(LibraryMessageCodes.forgetFailed));
    },
  );

  test('cancel pick leaves idle with no scanStarted message', () async {
    source.returnNullPick = true;
    await pumpAdd();

    expect(
      container.read(libraryIngestControllerProvider).phase,
      IngestPhase.idle,
    );
    expect(messageCodes(), isEmpty);
  });

  test('checkRevokedRoots populates UI list and continues after throws', () async {
    await pumpAdd();
    final secondRoot = MediaLocator('content://fake/tree/other');
    await db.upsertRoot(
      locator: secondRoot.value,
      displayName: 'Other',
    );

    // First root throws; second is revoked — must still populate second.
    source.hasPersistedThrowsFor = {root.value};
    source.hasPersistedFor = {
      root.value: false,
      secondRoot.value: false,
    };

    await container
        .read(libraryIngestControllerProvider.notifier)
        .checkRevokedRoots(l10n: l10n);

    final progress = container.read(libraryIngestControllerProvider);
    expect(
      progress.revokedRoots.map((r) => r.locator),
      contains(secondRoot.value),
    );
    expect(progress.revokedRoots.map((r) => r.locator), isNot(contains(root.value)));
    expect(messageCodes(), contains(LibraryMessageCodes.rootRevoked));
  });

  test('forget clears revoked UI entry', () async {
    await pumpAdd();
    source.hasPersistedFor = {root.value: false};
    await container
        .read(libraryIngestControllerProvider.notifier)
        .checkRevokedRoots(l10n: l10n);
    expect(
      container.read(libraryIngestControllerProvider).revokedRoots,
      isNotEmpty,
    );

    final rootId = (await db.select(db.libraryRoots).get()).single.id;
    await container
        .read(libraryIngestControllerProvider.notifier)
        .forgetRoot(rootId: rootId, l10n: l10n);

    expect(
      container.read(libraryIngestControllerProvider).revokedRoots,
      isEmpty,
    );
  });

  test('restored access clears revoked UI entry on re-add', () async {
    await pumpAdd();
    source.hasPersistedFor = {root.value: false};
    await container
        .read(libraryIngestControllerProvider.notifier)
        .checkRevokedRoots(l10n: l10n);
    expect(
      container.read(libraryIngestControllerProvider).revokedRoots,
      isNotEmpty,
    );

    source.hasPersistedFor = {root.value: true};
    await pumpAdd();

    expect(
      container.read(libraryIngestControllerProvider).revokedRoots,
      isEmpty,
    );
  });

  test('rescan early-fail when revoked populates UI list', () async {
    await pumpAdd();
    source.hasPersistedFor = {root.value: false};
    final rootId = (await db.select(db.libraryRoots).get()).single.id;

    await container
        .read(libraryIngestControllerProvider.notifier)
        .rescanRoot(rootId: rootId, l10n: l10n);

    final progress = container.read(libraryIngestControllerProvider);
    expect(progress.phase, IngestPhase.idle);
    expect(progress.revokedRoots.map((r) => r.locator), contains(root.value));
    expect(messageCodes(), contains(LibraryMessageCodes.rootRevoked));
  });
}

class _FakeTrackMetadataReader implements TrackMetadataReader {
  const _FakeTrackMetadataReader();

  @override
  Future<TrackMetadata> read(String path) async {
    return const TrackMetadata(
      title: 'Tagged',
      artist: 'Artist',
      album: 'Album',
      artworkBytes: [9, 9, 9],
    );
  }
}

class _FakeLocalLibrarySource implements LocalLibrarySource {
  _FakeLocalLibrarySource({required this.root, required this.tree});

  final MediaLocator root;
  final Map<String, List<LibraryEntry>> tree;
  final List<MediaLocator> released = [];

  int listCalls = 0;
  int? failListAfter;
  bool releaseThrows = false;
  bool hasPersistedThrows = false;
  bool returnNullPick = false;
  Map<String, bool>? hasPersistedFor;
  Set<String> hasPersistedThrowsFor = {};
  Duration? delayPick;
  void Function()? beforeListChildren;

  @override
  Future<MediaLocator?> pickAndRetainRoot() async {
    if (delayPick != null) await Future<void>.delayed(delayPick!);
    if (returnNullPick) return null;
    return root;
  }

  @override
  Future<List<LibraryEntry>> listChildren(MediaLocator parent) async {
    beforeListChildren?.call();
    listCalls++;
    if (failListAfter != null && listCalls > failListAfter!) {
      throw StateError('simulated list failure');
    }
    return tree[parent.value] ?? const [];
  }

  @override
  Future<Uri> resolvePlaybackUri(MediaLocator item) async =>
      Uri.parse(item.value);

  @override
  Future<String> materializeReadablePath(
    MediaLocator item, {
    String? fileNameHint,
  }) async {
    final ext = (fileNameHint != null && fileNameHint.contains('.'))
        ? '.${fileNameHint.split('.').last}'
        : '.bin';
    return '/tmp/fake_${item.value.hashCode}$ext';
  }

  @override
  Future<bool> hasPersistedAccess(MediaLocator root) async {
    if (hasPersistedThrows) throw StateError('plugin unavailable');
    if (hasPersistedThrowsFor.contains(root.value)) {
      throw StateError('plugin unavailable for ${root.value}');
    }
    if (hasPersistedFor != null) {
      return hasPersistedFor![root.value] ?? true;
    }
    return !released.any((r) => r.value == root.value);
  }

  @override
  Future<List<MediaLocator>> listPersistedRoots() async => [root];

  @override
  Future<void> releaseRoot(MediaLocator root) async {
    if (releaseThrows) throw StateError('release failed');
    released.add(root);
  }
}
