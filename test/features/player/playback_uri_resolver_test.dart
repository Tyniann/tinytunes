import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/cloud_cache_store.dart';
import 'package:tinytunes/core/cloud/drive_media_locator.dart';
import 'package:tinytunes/core/cloud/drive_remote.dart';
import 'package:tinytunes/core/cloud/free_space_source.dart';
import 'package:tinytunes/core/cloud/google_drive_cloud_library_source.dart';
import 'package:tinytunes/core/cloud/source_kinds.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/library/local_library_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/core/library/track_metadata_reader.dart';
import 'package:tinytunes/features/player/application/playback_uri_resolver.dart';

import '../../core/cloud/fake_drive_remote.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;
  late FakeDriveRemote remote;
  late GoogleDriveCloudLibrarySource cloud;
  late CloudCacheStore cache;
  late _RecordingLocalSource local;
  late _StubMetadataReader reader;

  setUp(() async {
    db = AppDatabase.memory();
    tempDir = await Directory.systemTemp.createTemp('tt_uri_resolver_');
    remote = FakeDriveRemote(
      files: {
        'song1': const DriveRemoteFileMeta(
          fileId: 'song1',
          name: 'song1.mp3',
          sizeBytes: 4,
        ),
      },
      fileBytes: {
        'song1': [1, 2, 3, 4],
      },
    );
    cloud = GoogleDriveCloudLibrarySource(
      remote: remote,
      cacheRootDirectory: tempDir,
      freeSpace: const UnlimitedFreeSpaceSource(),
    );
    cache = CloudCacheStore(db: db);
    local = _RecordingLocalSource();
    reader = _StubMetadataReader();
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  PlaybackUriResolver makeResolver() => PlaybackUriResolver(
    localSource: local,
    cloudSource: cloud,
    cacheStore: cache,
    db: db,
    metadataReader: reader,
    budgetBytes: 1024 * 1024,
  );

  Future<QueueTrackView> insertCloudTrack({
    String? title,
    String? artist,
    String? album,
  }) async {
    final rootId = await db.upsertRoot(
      locator: DriveMediaLocator.encode('folder').value,
      displayName: 'Cloud',
      sourceKind: SourceKinds.cloud,
    );
    final locator = DriveMediaLocator.encode('song1');
    final result = await db.upsertTracksBatch(rootId, [
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: locator.value,
        locator: locator.value,
        displayName: 'song1.mp3',
        title: Value(title),
        artist: Value(artist),
        album: Value(album),
        sourceKind: const Value(SourceKinds.cloud),
      ),
    ]);
    final trackId = result.insertedIds.single;
    await db.appendTrackIds([trackId]);
    final queue = await db.getOrderedQueue();
    return queue.single;
  }

  test('local track uses LocalLibrarySource only', () async {
    final view = QueueTrackView(
      queueEntryId: 1,
      trackId: 1,
      sortIndex: 0,
      displayName: 'a.mp3',
      locator: 'content://a',
      sourceKind: SourceKinds.local,
    );

    final uri = await makeResolver().resolve(view);

    expect(uri.toString(), 'content://a');
    expect(local.resolveCalls, 1);
    expect(remote.downloadCalls, 0);
    expect(reader.readCalls, 0);
  });

  test('cloud miss downloads once then cache hit skips download', () async {
    final view = await insertCloudTrack();
    final resolver = makeResolver();
    var downloadStarted = 0;

    final first = await resolver.resolve(
      view,
      queuedTrackIds: {view.trackId},
      onDownloadStarted: () => downloadStarted++,
    );
    expect(downloadStarted, 1);
    expect(remote.downloadCalls, 1);
    expect(reader.readCalls, 1);
    expect(await File(first.toFilePath()).exists(), isTrue);

    final second = await resolver.resolve(
      view,
      queuedTrackIds: {view.trackId},
      onDownloadStarted: () => downloadStarted++,
    );
    expect(downloadStarted, 1);
    expect(remote.downloadCalls, 1);
    expect(reader.readCalls, 1);
    expect(second.toFilePath(), first.toFilePath());
    expect(local.resolveCalls, 0);
  });

  test('cloud download fills null tags from local file', () async {
    final view = await insertCloudTrack();
    await makeResolver().resolve(
      view,
      queuedTrackIds: {view.trackId},
    );

    expect(reader.readCalls, 1);
    final track = await (db.select(
      db.tracks,
    )..where((t) => t.id.equals(view.trackId))).getSingle();
    expect(track.title, 'Stub Title');
    expect(track.artist, 'Stub Artist');
    expect(track.album, 'Stub Album');
  });

  test('cache hit with null tags reads file once without re-download', () async {
    final view = await insertCloudTrack();
    final resolver = makeResolver();
    await resolver.resolve(view, queuedTrackIds: {view.trackId});
    expect(remote.downloadCalls, 1);
    expect(reader.readCalls, 1);

    // Simulate "played then tags cleared" / Forget→re-add with cache still warm.
    await db.updateTrackTags(trackId: view.trackId);
    final cleared = (await db.getOrderedQueue()).single;
    expect(PlaybackUriResolver.needsTagEnrichment(cleared), isTrue);

    await resolver.resolve(cleared, queuedTrackIds: {cleared.trackId});

    expect(remote.downloadCalls, 1);
    expect(reader.readCalls, 2);
    final track = await (db.select(
      db.tracks,
    )..where((t) => t.id.equals(view.trackId))).getSingle();
    expect(track.title, 'Stub Title');
  });

  test('does not re-read tags when already present', () async {
    final view = await insertCloudTrack(
      title: 'Existing',
      artist: 'Artist',
      album: 'Album',
    );
    await makeResolver().resolve(view, queuedTrackIds: {view.trackId});
    expect(reader.readCalls, 0);
    final track = await (db.select(
      db.tracks,
    )..where((t) => t.id.equals(view.trackId))).getSingle();
    expect(track.title, 'Existing');
  });
}

class _StubMetadataReader implements TrackMetadataReader {
  int readCalls = 0;

  @override
  Future<TrackMetadata> read(String path) async {
    readCalls++;
    return const TrackMetadata(
      title: 'Stub Title',
      artist: 'Stub Artist',
      album: 'Stub Album',
    );
  }
}

class _RecordingLocalSource implements LocalLibrarySource {
  int resolveCalls = 0;

  @override
  Future<MediaLocator?> pickAndRetainRoot() async => null;

  @override
  Future<List<LibraryEntry>> listChildren(MediaLocator parent) async =>
      const [];

  @override
  Future<Uri> resolvePlaybackUri(MediaLocator item) async {
    resolveCalls++;
    return Uri.parse(item.value);
  }

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
