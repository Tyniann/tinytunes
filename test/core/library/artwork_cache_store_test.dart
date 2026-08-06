import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/library/artwork_cache_store.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;
  late ArtworkCacheStore store;

  setUp(() async {
    db = AppDatabase.memory();
    tempDir = await Directory.systemTemp.createTemp('tt_artwork_');
    store = ArtworkCacheStore(db: db, root: tempDir);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<int> insertTrack() async {
    final rootId = await db.upsertRoot(
      locator: 'root',
      displayName: 'Root',
    );
    final result = await db.upsertTracksBatch(rootId, [
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: 'a',
        locator: 'a',
        displayName: 'a.mp3',
      ),
    ]);
    return result.insertedIds.single;
  }

  Uint8List largePngBytes() {
    final image = img.Image(width: 800, height: 600);
    img.fill(image, color: img.ColorRgb8(20, 40, 60));
    return Uint8List.fromList(img.encodePng(image));
  }

  test('writeFromBytes caps longest edge and sets artworkCacheRef', () async {
    final trackId = await insertTrack();
    final path = await store.writeFromBytes(trackId, largePngBytes());

    expect(path, isNotNull);
    expect(File(path!).existsSync(), isTrue);

    final decoded = img.decodeImage(await File(path).readAsBytes());
    expect(decoded, isNotNull);
    expect(decoded!.width, lessThanOrEqualTo(ArtworkCacheStore.maxEdgePx));
    expect(decoded.height, lessThanOrEqualTo(ArtworkCacheStore.maxEdgePx));
    expect(
      decoded.width == ArtworkCacheStore.maxEdgePx ||
          decoded.height == ArtworkCacheStore.maxEdgePx,
      isTrue,
    );

    final row = await (db.select(
      db.tracks,
    )..where((t) => t.id.equals(trackId))).getSingle();
    expect(row.artworkCacheRef, path);
  });

  test('writeFromBytes overwrites existing file', () async {
    final trackId = await insertTrack();
    final first = await store.writeFromBytes(trackId, largePngBytes());
    final secondBytes = Uint8List.fromList(
      img.encodePng(
        () {
          final image = img.Image(width: 100, height: 100);
          img.fill(image, color: img.ColorRgb8(200, 10, 10));
          return image;
        }(),
      ),
    );
    final second = await store.writeFromBytes(trackId, secondBytes);

    expect(second, first);
    expect(File(second!).existsSync(), isTrue);
  });

  test('deleteForTrack removes file and clears ref', () async {
    final trackId = await insertTrack();
    final path = await store.writeFromBytes(trackId, largePngBytes());
    expect(File(path!).existsSync(), isTrue);

    await store.deleteForTrack(trackId);

    expect(File(path).existsSync(), isFalse);
    final row = await (db.select(
      db.tracks,
    )..where((t) => t.id.equals(trackId))).getSingle();
    expect(row.artworkCacheRef, isNull);
  });

  test('deleteForRoot removes art for all tracks under root', () async {
    final rootId = await db.upsertRoot(locator: 'r', displayName: 'R');
    final result = await db.upsertTracksBatch(rootId, [
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: '1',
        locator: '1',
        displayName: '1.mp3',
      ),
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: '2',
        locator: '2',
        displayName: '2.mp3',
      ),
    ]);
    final paths = <String>[];
    for (final id in result.insertedIds) {
      paths.add((await store.writeFromBytes(id, largePngBytes()))!);
    }

    await store.deleteForRoot(rootId);

    for (final path in paths) {
      expect(File(path).existsSync(), isFalse);
    }
  });
}
