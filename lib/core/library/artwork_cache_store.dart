import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tinytunes/core/database/app_database.dart';

/// On-device capped JPEG covers keyed by catalog track id.
///
/// Purpose: Persist embedded (and later optional online) artwork under
/// application support without a parallel eviction policy — callers delete via
/// the same Forget / cloud-cache hooks as audio cache.
/// Usage Context: Local ingest, cloud play-path enrichment, [CloudCacheStore]
/// deletes, and Forget / prune.
class ArtworkCacheStore {
  /// Creates a store bound to [db].
  ///
  /// When [root] is null, the directory is resolved lazily under application
  /// support (`artwork/`). Tests should pass an explicit temp [root].
  ArtworkCacheStore({required AppDatabase db, Directory? root})
    : _db = db,
      _root = root;

  /// Longest edge for stored covers (queue thumb + notification / lock screen).
  static const int maxEdgePx = 512;

  /// JPEG encode quality for capped covers.
  static const int jpegQuality = 85;

  final AppDatabase _db;
  Directory? _root;

  /// Writes capped JPEG bytes for [trackId] and updates `artworkCacheRef`.
  ///
  /// Returns the absolute file path, or `null` when decode/encode fails.
  /// Overwrites any existing file for [trackId].
  Future<String?> writeFromBytes(int trackId, List<int> bytes) async {
    if (bytes.isEmpty) return null;
    final encoded = _encodeCappedJpeg(bytes);
    if (encoded == null) return null;

    final dir = await _ensureRoot();
    final file = File(p.join(dir.path, '$trackId.jpg'));
    await file.writeAsBytes(encoded, flush: true);
    final path = file.path;
    await (_db.update(_db.tracks)..where((t) => t.id.equals(trackId))).write(
      TracksCompanion(artworkCacheRef: Value(path)),
    );
    return path;
  }

  /// Deletes the artwork file for [trackId] and clears `artworkCacheRef`.
  ///
  /// When [clearDbRef] is false, only the file is removed (caller already
  /// deletes the track row).
  Future<void> deleteForTrack(int trackId, {bool clearDbRef = true}) async {
    final row = await (_db.select(
      _db.tracks,
    )..where((t) => t.id.equals(trackId))).getSingleOrNull();
    final ref = row?.artworkCacheRef;
    await _deleteFileQuietly(ref);
    await _deleteFileQuietly(await _conventionPath(trackId));
    if (clearDbRef && row != null) {
      await (_db.update(_db.tracks)..where((t) => t.id.equals(trackId))).write(
        const TracksCompanion(artworkCacheRef: Value(null)),
      );
    }
  }

  /// Deletes artwork for every track under library [rootId].
  Future<void> deleteForRoot(int rootId) async {
    final ids =
        await (_db.selectOnly(_db.tracks)
              ..addColumns([_db.tracks.id])
              ..where(_db.tracks.rootId.equals(rootId)))
            .map((row) => row.read(_db.tracks.id)!)
            .get();
    for (final id in ids) {
      await deleteForTrack(id);
    }
  }

  /// Deletes artwork for each id in [trackIds].
  Future<void> deleteForTrackIds(Iterable<int> trackIds) async {
    for (final id in trackIds) {
      await deleteForTrack(id);
    }
  }

  Future<Directory> _ensureRoot() async {
    final existing = _root;
    if (existing != null) {
      if (!existing.existsSync()) {
        await existing.create(recursive: true);
      }
      return existing;
    }
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'artwork'));
    await dir.create(recursive: true);
    _root = dir;
    return dir;
  }

  Future<String?> _conventionPath(int trackId) async {
    try {
      final dir = await _ensureRoot();
      return p.join(dir.path, '$trackId.jpg');
    } on Object {
      return null;
    }
  }

  Future<void> _deleteFileQuietly(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } on Object catch (error, stack) {
      debugPrint('artwork delete failed for $path: $error\n$stack');
    }
  }

  /// Decodes [bytes], caps longest edge to [maxEdgePx], encodes JPEG.
  static Uint8List? _encodeCappedJpeg(List<int> bytes) {
    try {
      final decoded = img.decodeImage(Uint8List.fromList(bytes));
      if (decoded == null) return null;
      final capped = _capLongestEdge(decoded, maxEdgePx);
      return Uint8List.fromList(img.encodeJpg(capped, quality: jpegQuality));
    } on Object {
      // Invalid or exotic embedded blobs — quiet miss (no toast).
      return null;
    }
  }

  static img.Image _capLongestEdge(img.Image src, int maxEdge) {
    final longest = src.width > src.height ? src.width : src.height;
    if (longest <= maxEdge) return src;
    if (src.width >= src.height) {
      return img.copyResize(src, width: maxEdge);
    }
    return img.copyResize(src, height: maxEdge);
  }
}
