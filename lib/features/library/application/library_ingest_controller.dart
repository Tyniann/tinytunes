import 'dart:collection';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/library/android/android_local_library_source.dart';
import 'package:tinytunes/core/library/local_library_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/core/library/track_metadata_reader.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/features/library/application/audio_extensions.dart';
import 'package:tinytunes/features/library/application/library_ingest_l10n.dart';
import 'package:tinytunes/features/library/application/library_message_codes.dart';
import 'package:tinytunes/features/library/application/library_providers.dart';

part 'library_ingest_controller.g.dart';

/// Phase of a catalog-mutating ingest operation.
enum IngestPhase {
  /// No mutating op in flight.
  idle,

  /// Add or re-scan walk/metadata in progress.
  scanning,

  /// Forget-folder cascade in progress.
  forgetting,
}

/// Progress snapshot for home banner / action disablement.
///
/// Purpose: Drive `Scanning… n` UI and single-flight button state.
class ScanProgress {
  /// Creates a progress snapshot.
  const ScanProgress({required this.phase, required this.processedCount});

  /// Idle progress.
  static const idle = ScanProgress(phase: IngestPhase.idle, processedCount: 0);

  /// Current mutating phase.
  final IngestPhase phase;

  /// Audio files processed so far in this run.
  final int processedCount;

  /// Whether Add/Re-scan/Forget should be disabled.
  bool get isBusy => phase != IngestPhase.idle;
}

/// Single-flight library ingest: add folder, re-scan, forget.
///
/// Purpose: Mutate catalog/queue safely with prune-after-batches-succeed rules.
/// Usage Context: Playlist home actions; tests override source/reader/DB.
@Riverpod(keepAlive: true)
class LibraryIngestController extends _$LibraryIngestController {
  static const _batchSize = 25;
  static const _metadataConcurrency = 2;

  bool _cancelRequested = false;
  final Set<String> _revokedReportedLocators = {};

  @override
  ScanProgress build() => ScanProgress.idle;

  /// Requests cancel of the active scan (ignored when idle/forgetting).
  void cancelScan() {
    _cancelRequested = true;
  }

  /// Picks a folder and appends its tracks that are not currently queued.
  ///
  /// Selecting an existing root refreshes its catalog and restores missing
  /// queue entries. Use [rescanRoot] when removed entries must stay removed.
  Future<void> addFolder({required LibraryIngestL10n l10n}) async {
    if (state.isBusy) return;

    final source = ref.read(localLibrarySourceProvider);
    final reporter = ref.read(messageReporterProvider);

    _begin(IngestPhase.scanning);
    reporter.reportInfo(
      code: LibraryMessageCodes.scanStarted,
      message: l10n.scanStarted,
    );

    try {
      final picked = await source.pickAndRetainRoot();
      if (picked == null) {
        _finishIdle();
        return;
      }

      final db = ref.read(appDatabaseProvider);
      final existing = await db.getRootByLocator(picked.value);
      if (existing != null) {
        await _rescanRoot(
          rootId: existing.id,
          rootLocator: MediaLocator(existing.locator),
          l10n: l10n,
          appendAllTouched: true,
        );
        return;
      }

      final rootId = await db.upsertRoot(
        locator: picked.value,
        displayName: displayNameFromRootLocator(picked.value),
      );
      await _scanNewRoot(rootId: rootId, rootLocator: picked, l10n: l10n);
    } on Object catch (error, stack) {
      debugPrint('addFolder failed: $error\n$stack');
      reporter.reportError(
        code: LibraryMessageCodes.scanFailed,
        message: '${l10n.scanFailed} ($error)',
      );
      _finishIdle();
    }
  }

  /// Re-scans an existing root by database [rootId].
  Future<void> rescanRoot({
    required int rootId,
    required LibraryIngestL10n l10n,
  }) async {
    if (state.isBusy) return;

    final db = ref.read(appDatabaseProvider);
    final root = await (db.select(
      db.libraryRoots,
    )..where((t) => t.id.equals(rootId))).getSingleOrNull();
    if (root == null) return;

    _begin(IngestPhase.scanning);
    ref
        .read(messageReporterProvider)
        .reportInfo(
          code: LibraryMessageCodes.scanStarted,
          message: l10n.scanStarted,
        );

    await _rescanRoot(
      rootId: root.id,
      rootLocator: MediaLocator(root.locator),
      l10n: l10n,
    );
  }

  /// Forgets a folder: DB cascade first, then best-effort grant release.
  Future<void> forgetRoot({
    required int rootId,
    required LibraryIngestL10n l10n,
  }) async {
    if (state.isBusy) return;

    final db = ref.read(appDatabaseProvider);
    final source = ref.read(localLibrarySourceProvider);
    final reporter = ref.read(messageReporterProvider);

    final root = await (db.select(
      db.libraryRoots,
    )..where((t) => t.id.equals(rootId))).getSingleOrNull();
    if (root == null) return;

    _begin(IngestPhase.forgetting);
    try {
      final locator = MediaLocator(root.locator);
      await db.deleteRootCascade(rootId);
      try {
        await source.releaseRoot(locator);
        reporter.reportInfo(
          code: LibraryMessageCodes.forgetComplete,
          message: l10n.forgetComplete,
        );
      } on Object catch (error, stack) {
        debugPrint('releaseRoot failed: $error\n$stack');
        reporter.reportError(
          code: LibraryMessageCodes.forgetFailed,
          message: l10n.forgetFailed,
        );
      }
    } finally {
      _finishIdle();
    }
  }

  /// Reports revoked grants once per root locator per session.
  Future<void> checkRevokedRoots({required LibraryIngestL10n l10n}) async {
    final db = ref.read(appDatabaseProvider);
    final source = ref.read(localLibrarySourceProvider);
    final reporter = ref.read(messageReporterProvider);
    final roots = await db.select(db.libraryRoots).get();

    for (final root in roots) {
      if (_revokedReportedLocators.contains(root.locator)) continue;
      final bool ok;
      try {
        ok = await source.hasPersistedAccess(MediaLocator(root.locator));
      } on Object catch (error, stack) {
        // Startup checks must never escape a post-frame callback. A
        // MissingPluginException here usually means native code was changed
        // but the app was only hot-reloaded instead of rebuilt.
        debugPrint('persisted access check failed: $error\n$stack');
        return;
      }
      if (!ok) {
        _revokedReportedLocators.add(root.locator);
        reporter.reportError(
          code: LibraryMessageCodes.rootRevoked,
          message: l10n.rootRevoked,
        );
      }
    }
  }

  Future<void> _scanNewRoot({
    required int rootId,
    required MediaLocator rootLocator,
    required LibraryIngestL10n l10n,
  }) async {
    final reporter = ref.read(messageReporterProvider);
    final outcome = await _walkAndUpsert(
      rootId: rootId,
      rootLocator: rootLocator,
      pruneMissing: false,
    );

    if (outcome.cancelled) {
      reporter.reportInfo(
        code: LibraryMessageCodes.scanCancelled,
        message: l10n.scanCancelled,
      );
      _finishIdle();
      return;
    }
    if (!outcome.success) {
      reporter.reportError(
        code: LibraryMessageCodes.scanFailed,
        message: outcome.failureDetail == null
            ? l10n.scanFailed
            : '${l10n.scanFailed} (${outcome.failureDetail})',
      );
      _finishIdle();
      return;
    }

    final db = ref.read(appDatabaseProvider);
    await db.appendTrackIds(outcome.allTouchedTrackIds);
    reporter.reportInfo(
      code: LibraryMessageCodes.scanComplete,
      message: l10n.scanComplete,
    );
    _finishIdle();
  }

  Future<void> _rescanRoot({
    required int rootId,
    required MediaLocator rootLocator,
    required LibraryIngestL10n l10n,
    bool appendAllTouched = false,
  }) async {
    final reporter = ref.read(messageReporterProvider);
    final source = ref.read(localLibrarySourceProvider);

    final ok = await source.hasPersistedAccess(rootLocator);
    if (!ok) {
      reporter.reportError(
        code: LibraryMessageCodes.rootRevoked,
        message: l10n.rootRevoked,
      );
      _finishIdle();
      return;
    }

    final outcome = await _walkAndUpsert(
      rootId: rootId,
      rootLocator: rootLocator,
      pruneMissing: true,
    );

    if (outcome.cancelled) {
      reporter.reportInfo(
        code: LibraryMessageCodes.scanCancelled,
        message: l10n.scanCancelled,
      );
      _finishIdle();
      return;
    }
    if (!outcome.success) {
      reporter.reportError(
        code: LibraryMessageCodes.scanFailed,
        message: outcome.failureDetail == null
            ? l10n.scanFailed
            : '${l10n.scanFailed} (${outcome.failureDetail})',
      );
      _finishIdle();
      return;
    }

    final db = ref.read(appDatabaseProvider);
    await db.appendTrackIds(
      appendAllTouched
          ? outcome.allTouchedTrackIds
          : outcome.newlyInsertedTrackIds,
    );
    reporter.reportInfo(
      code: LibraryMessageCodes.scanComplete,
      message: l10n.scanComplete,
    );
    _finishIdle();
  }

  Future<_WalkOutcome> _walkAndUpsert({
    required int rootId,
    required MediaLocator rootLocator,
    required bool pruneMissing,
  }) async {
    final source = ref.read(localLibrarySourceProvider);
    final reader = ref.read(trackMetadataReaderProvider);
    final db = ref.read(appDatabaseProvider);

    final seenSourceItemIds = <String>{};
    final newlyInserted = <int>[];
    final allTouched = <int>[];
    var processed = 0;
    var cancelled = false;
    var failed = false;
    var batchesFailed = false;
    String? failureDetail;

    final dirs = Queue<MediaLocator>()..add(rootLocator);
    final pendingFiles = <LibraryEntry>[];

    Future<bool> flushBatch() async {
      if (pendingFiles.isEmpty) return true;
      final chunk = List<LibraryEntry>.from(pendingFiles);
      pendingFiles.clear();

      final companions = <TracksCompanion>[];
      for (var i = 0; i < chunk.length; i += _metadataConcurrency) {
        if (_cancelRequested) {
          cancelled = true;
          return false;
        }
        final slice = chunk.skip(i).take(_metadataConcurrency).toList();
        final results = await Future.wait(
          slice.map((entry) => _readTags(source, reader, entry)),
        );
        for (var j = 0; j < slice.length; j++) {
          final entry = slice[j];
          final tags = results[j];
          seenSourceItemIds.add(entry.locator.value);
          companions.add(
            TracksCompanion.insert(
              rootId: rootId,
              sourceItemId: entry.locator.value,
              locator: entry.locator.value,
              displayName: entry.name,
              title: Value(tags?.title),
              artist: Value(tags?.artist),
              album: Value(tags?.album),
            ),
          );
          processed++;
          state = ScanProgress(
            phase: IngestPhase.scanning,
            processedCount: processed,
          );
        }
      }

      try {
        // Flush in DB batch sizes.
        for (var i = 0; i < companions.length; i += _batchSize) {
          final batch = companions.skip(i).take(_batchSize).toList();
          final result = await db.upsertTracksBatch(rootId, batch);
          newlyInserted.addAll(result.insertedIds);
          allTouched.addAll(result.insertedIds);
          allTouched.addAll(result.updatedIds);
        }
        return true;
      } on Object catch (error, stack) {
        debugPrint('upsert batch failed: $error\n$stack');
        batchesFailed = true;
        failureDetail = error.toString();
        return false;
      }
    }

    while (dirs.isNotEmpty) {
      if (_cancelRequested) {
        cancelled = true;
        break;
      }
      final parent = dirs.removeFirst();
      final List<LibraryEntry> children;
      try {
        children = await source.listChildren(parent);
      } on Object catch (error, stack) {
        debugPrint('listChildren failed: $error\n$stack');
        failed = true;
        failureDetail = error.toString();
        // Best-effort flush already-listed files so add-folder can keep a
        // partial catalog; still no queue append / prune on failure.
        await flushBatch();
        break;
      }

      for (final child in children) {
        if (child.isDirectory) {
          dirs.add(child.locator);
        } else if (isAudioFileName(child.name)) {
          pendingFiles.add(child);
          if (pendingFiles.length >= _batchSize) {
            final ok = await flushBatch();
            if (!ok) break;
          }
        }
      }
      if (failed || cancelled || batchesFailed) break;
    }

    if (!failed && !cancelled && !batchesFailed) {
      final ok = await flushBatch();
      if (!ok && !cancelled) {
        failed = true;
      }
    }

    final success = !failed && !cancelled && !batchesFailed;
    if (success && pruneMissing) {
      await db.deleteTracksNotIn(rootId, seenSourceItemIds);
    }

    return _WalkOutcome(
      success: success,
      cancelled: cancelled,
      newlyInsertedTrackIds: List.unmodifiable(newlyInserted),
      allTouchedTrackIds: List.unmodifiable(allTouched),
      failureDetail: failureDetail,
    );
  }

  Future<TrackMetadata?> _readTags(
    LocalLibrarySource source,
    TrackMetadataReader reader,
    LibraryEntry entry,
  ) async {
    String? path;
    try {
      path = await source.materializeReadablePath(
        entry.locator,
        fileNameHint: entry.name,
      );
      final meta = await reader.read(path);
      // Discard artwork bytes immediately (never persist in Phase 2).
      return TrackMetadata(
        title: meta.title,
        artist: meta.artist,
        album: meta.album,
      );
    } on Object catch (error, stack) {
      debugPrint('metadata failed for ${entry.name}: $error\n$stack');
      return null;
    } finally {
      if (path != null) deleteQuietly(path);
    }
  }

  void _begin(IngestPhase phase) {
    _cancelRequested = false;
    state = ScanProgress(phase: phase, processedCount: 0);
  }

  void _finishIdle() {
    _cancelRequested = false;
    state = ScanProgress.idle;
  }
}

class _WalkOutcome {
  const _WalkOutcome({
    required this.success,
    required this.cancelled,
    required this.newlyInsertedTrackIds,
    required this.allTouchedTrackIds,
    this.failureDetail,
  });

  final bool success;
  final bool cancelled;
  final List<int> newlyInsertedTrackIds;
  final List<int> allTouchedTrackIds;
  final String? failureDetail;
}
