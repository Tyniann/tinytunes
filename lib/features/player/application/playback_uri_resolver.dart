import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tinytunes/core/cloud/cloud_cache_budget.dart';
import 'package:tinytunes/core/cloud/cloud_cache_store.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/source_kinds.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/library/local_library_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/core/library/track_metadata_reader.dart';

/// Resolves a queue track to a local playback [Uri] (SAF or cloud cache).
///
/// Purpose: Keep [PlaybackController] free of cloud vs local branching details
/// while supporting download-then-play for Drive tracks.
/// Usage Context: Called from `_loadAndPlay` before the audio engine load.
class PlaybackUriResolver {
  /// Creates a resolver with local/cloud sources and [cacheStore].
  PlaybackUriResolver({
    required LocalLibrarySource localSource,
    required CloudLibrarySource cloudSource,
    required CloudCacheStore cacheStore,
    required AppDatabase db,
    required TrackMetadataReader metadataReader,
    this.budgetBytes = CloudCacheBudget.defaultBytes,
  }) : _local = localSource,
       _cloud = cloudSource,
       _cache = cacheStore,
       _db = db,
       _reader = metadataReader;

  final LocalLibrarySource _local;
  final CloudLibrarySource _cloud;
  final CloudCacheStore _cache;
  final AppDatabase _db;
  final TrackMetadataReader _reader;

  /// Cloud cache size budget applied after each download.
  final int budgetBytes;

  /// Resolves [view] to a playable URI.
  ///
  /// For cloud tracks: returns cached file if present (touching LRU); otherwise
  /// downloads, indexes, enforces budget, then returns the file URI.
  /// When the local file is available and tags are still empty, reads tags once
  /// from that file (no extra download) and upserts the track row.
  /// [onDownloadStarted] runs once when a network download begins.
  /// [onDownloadProgress] reports bytes received vs remote total when known.
  Future<Uri> resolve(
    QueueTrackView view, {
    void Function()? onDownloadStarted,
    void Function(int receivedBytes, int totalBytes)? onDownloadProgress,
    Set<int> queuedTrackIds = const {},
  }) async {
    if (view.sourceKind != SourceKinds.cloud) {
      return _local.resolvePlaybackUri(MediaLocator(view.locator));
    }

    final remote = MediaLocator(view.locator);
    final existing = await _cache.getByTrackId(view.trackId);
    if (existing != null) {
      final file = File(existing.localPath);
      if (await file.exists()) {
        await _cache.touch(view.trackId);
        await _enrichTagsIfNeeded(view, existing.localPath);
        return Uri.file(existing.localPath);
      }
      await _cache.deleteForTrack(view.trackId);
    }

    try {
      final uri = await _cloud.resolveCached(remote);
      final path = uri.toFilePath();
      final size = await File(path).length();
      await _cache.upsert(
        trackId: view.trackId,
        remoteLocator: remote,
        localPath: path,
        sizeBytes: size,
      );
      await _enrichTagsIfNeeded(view, path);
      return uri;
    } on CloudCacheMissException {
      // Download required.
    }

    onDownloadStarted?.call();
    final uri = await _cache.downloadAndIndex(
      source: _cloud,
      trackId: view.trackId,
      remoteLocator: remote,
      budgetBytes: budgetBytes,
      protectTrackId: view.trackId,
      queuedTrackIds: queuedTrackIds,
      onProgress: onDownloadProgress,
    );
    await _enrichTagsIfNeeded(view, uri.toFilePath());
    return uri;
  }

  /// Whether tag fields are all empty (needs one local `audiotags` read).
  static bool tagsAreEmpty({
    String? title,
    String? artist,
    String? album,
  }) {
    final t = title?.trim();
    final a = artist?.trim();
    final al = album?.trim();
    return (t == null || t.isEmpty) &&
        (a == null || a.isEmpty) &&
        (al == null || al.isEmpty);
  }

  /// Whether [view] still needs tag enrichment from a local file.
  static bool needsTagEnrichment(QueueTrackView view) => tagsAreEmpty(
    title: view.title,
    artist: view.artist,
    album: view.album,
  );

  /// Reads tags from [path] once when the track row has no tags yet; never
  /// re-downloads. Checks Drift (not only [view]) so a stale queue snapshot
  /// after a prior enrich does not trigger another read.
  Future<void> _enrichTagsIfNeeded(QueueTrackView view, String path) async {
    final row =
        await (_db.select(_db.tracks)
              ..where((t) => t.id.equals(view.trackId)))
            .getSingleOrNull();
    if (row == null) return;
    if (!tagsAreEmpty(
      title: row.title,
      artist: row.artist,
      album: row.album,
    )) {
      return;
    }
    try {
      final meta = await _reader.read(path);
      await _db.updateTrackTags(
        trackId: view.trackId,
        title: meta.title,
        artist: meta.artist,
        album: meta.album,
      );
    } on Object catch (error, stack) {
      debugPrint('cloud tag enrich failed for ${view.trackId}: $error\n$stack');
    }
  }
}
