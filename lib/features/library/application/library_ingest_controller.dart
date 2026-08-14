import 'dart:collection';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/cloud_provider_id.dart';
import 'package:tinytunes/core/cloud/cloud_providers.dart';
import 'package:tinytunes/core/cloud/source_kinds.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/library/android/android_local_library_source.dart';
import 'package:tinytunes/core/library/artwork_providers.dart';
import 'package:tinytunes/core/library/local_library_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/core/library/track_metadata_reader.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/features/library/application/audio_extensions.dart';
import 'package:tinytunes/features/library/application/cloud_folder_pick.dart';
import 'package:tinytunes/features/library/application/library_entry_order.dart';
import 'package:tinytunes/features/library/application/library_ingest_l10n.dart';
import 'package:tinytunes/features/library/application/library_message_codes.dart';
import 'package:tinytunes/features/library/application/library_providers.dart';

part 'library_ingest_controller.g.dart';

/// Phase of a catalog-mutating ingest operation.
enum IngestPhase {
  /// No mutating op in flight.
  idle,

  /// SAF / folder picker is open (busy; no scan banner or scanStarted).
  picking,

  /// Add or re-scan walk/metadata in progress.
  scanning,

  /// Forget-folder cascade in progress.
  forgetting,
}

/// One library root whose persisted grant is currently missing.
///
/// Purpose: Drive per-root home strips without a Drift revoked flag.
class RevokedRootInfo {
  /// Creates a revoked-root UI row.
  const RevokedRootInfo({
    required this.id,
    required this.displayName,
    required this.locator,
  });

  /// Drift `library_roots.id`.
  final int id;

  /// User-facing folder name for the strip.
  final String displayName;

  /// Opaque root locator (toast dedupe key).
  final String locator;

  @override
  bool operator ==(Object other) =>
      other is RevokedRootInfo &&
      other.id == id &&
      other.displayName == displayName &&
      other.locator == locator;

  @override
  int get hashCode => Object.hash(id, displayName, locator);
}

/// Progress snapshot for home banner / action disablement.
///
/// Purpose: Drive scan/forget strips, single-flight buttons, and revoked UI.
class ScanProgress {
  /// Creates a progress snapshot.
  const ScanProgress({
    required this.phase,
    required this.processedCount,
    this.revokedRoots = const [],
  });

  /// Idle progress with no revoked roots.
  static const idle = ScanProgress(phase: IngestPhase.idle, processedCount: 0);

  /// Current mutating phase.
  final IngestPhase phase;

  /// Audio files processed so far in this run.
  final int processedCount;

  /// Roots currently missing persisted access (watchable UI list).
  final List<RevokedRootInfo> revokedRoots;

  /// Whether Add/Re-scan/Forget should be disabled.
  bool get isBusy => phase != IngestPhase.idle;

  /// Copies this snapshot with optional field overrides.
  ScanProgress copyWith({
    IngestPhase? phase,
    int? processedCount,
    List<RevokedRootInfo>? revokedRoots,
  }) {
    return ScanProgress(
      phase: phase ?? this.phase,
      processedCount: processedCount ?? this.processedCount,
      revokedRoots: revokedRoots ?? this.revokedRoots,
    );
  }
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

  /// Once-per-session toast/message dedupe (separate from UI [ScanProgress.revokedRoots]).
  final Set<String> _revokedReportedLocators = {};

  @override
  ScanProgress build() => ScanProgress.idle;

  /// Requests cancel of the active scan (ignored when idle/picking/forgetting).
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

    _begin(IngestPhase.picking);
    try {
      final picked = await source.pickAndRetainRoot();
      if (picked == null) {
        _finishIdle();
        return;
      }

      _begin(IngestPhase.scanning);
      reporter.reportInfo(
        code: LibraryMessageCodes.scanStarted,
        message: l10n.scanStarted,
      );

      final db = ref.read(appDatabaseProvider);
      final existing = await db.getRootByLocator(picked.value);
      if (existing != null) {
        await _rescanRoot(
          rootId: existing.id,
          rootLocator: MediaLocator(existing.locator),
          displayName: existing.displayName,
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

  /// Picks a cloud folder and imports it as a catalog root + queue refill.
  ///
  /// [provider] selects which session/ownership stamp to use. [pick] owns UI
  /// (folder browser + subfolders dialog). Cancel returns `null`.
  Future<void> addCloudFolder({
    required LibraryIngestL10n l10n,
    required CloudProviderId provider,
    required Future<CloudFolderPick?> Function() pick,
  }) async {
    if (state.isBusy) return;

    final reporter = ref.read(messageReporterProvider);
    final String? accountKey;
    switch (provider) {
      case CloudProviderId.googleDrive:
        final session = ref.read(googleDriveSessionControllerProvider);
        if (session.accountChangeRequired ||
            !session.canUseProvider ||
            session.account == null) {
          reporter.reportError(
            code: LibraryMessageCodes.cloudSignInRequired,
            message: l10n.cloudSignInRequired,
          );
          return;
        }
        accountKey = session.account!.stableAccountKey;
      case CloudProviderId.oneDrive:
        final session = ref.read(oneDriveSessionControllerProvider);
        if (session.accountChangeRequired ||
            !session.canUseProvider ||
            session.account == null) {
          reporter.reportError(
            code: LibraryMessageCodes.cloudSignInRequired,
            message: l10n.cloudSignInRequired,
          );
          return;
        }
        accountKey = session.account!.stableAccountKey;
    }

    _begin(IngestPhase.picking);
    try {
      final picked = await pick();
      if (picked == null) {
        _finishIdle();
        return;
      }

      _begin(IngestPhase.scanning);
      reporter.reportInfo(
        code: LibraryMessageCodes.scanStarted,
        message: l10n.scanStarted,
      );

      final cloud = await ref.read(cloudLibrarySourceProvider.future);
      final db = ref.read(appDatabaseProvider);
      final existing = await db.getRootByLocator(picked.locator.value);
      if (existing != null) {
        await _rescanCloudRoot(
          rootId: existing.id,
          rootLocator: MediaLocator(existing.locator),
          cloud: cloud,
          includeSubfolders: picked.includeSubfolders,
          l10n: l10n,
          appendAllTouched: true,
        );
        return;
      }

      final rootId = await db.upsertRoot(
        locator: picked.locator.value,
        displayName: picked.displayName,
        sourceKind: SourceKinds.cloud,
        cloudProvider: provider.token,
        cloudAccountKey: accountKey,
      );
      await _scanNewCloudRoot(
        rootId: rootId,
        rootLocator: picked.locator,
        cloud: cloud,
        includeSubfolders: picked.includeSubfolders,
        l10n: l10n,
      );
    } on Object catch (error, stack) {
      debugPrint('addCloudFolder failed: $error\n$stack');
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

    if (root.sourceKind == SourceKinds.cloud) {
      final cloud = await ref.read(cloudLibrarySourceProvider.future);
      await _rescanCloudRoot(
        rootId: root.id,
        rootLocator: MediaLocator(root.locator),
        cloud: cloud,
        includeSubfolders: true,
        l10n: l10n,
      );
      return;
    }

    await _rescanRoot(
      rootId: root.id,
      rootLocator: MediaLocator(root.locator),
      displayName: root.displayName,
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
      final artwork = ref.read(artworkCacheStoreProvider);
      await artwork.deleteForRoot(rootId);
      if (root.sourceKind == SourceKinds.cloud) {
        await ref.read(cloudCacheStoreProvider).deleteForRoot(rootId);
        await db.deleteRootCascade(rootId);
        _clearRevokedRoot(rootId);
        reporter.reportInfo(
          code: LibraryMessageCodes.forgetComplete,
          message: l10n.forgetComplete,
        );
        return;
      }

      await db.deleteRootCascade(rootId);
      _clearRevokedRoot(rootId);
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

  /// Forgets every library root in one busy phase (art + cloud cache + grants).
  Future<void> forgetAllRoots({required LibraryIngestL10n l10n}) async {
    if (state.isBusy) return;

    final db = ref.read(appDatabaseProvider);
    final roots = await db.select(db.libraryRoots).get();
    if (roots.isEmpty) return;

    final source = ref.read(localLibrarySourceProvider);
    final reporter = ref.read(messageReporterProvider);
    final artwork = ref.read(artworkCacheStoreProvider);
    final cloudCache = ref.read(cloudCacheStoreProvider);

    _begin(IngestPhase.forgetting);
    var anyReleaseFailed = false;
    try {
      for (final root in roots) {
        await artwork.deleteForRoot(root.id);
        if (root.sourceKind == SourceKinds.cloud) {
          await cloudCache.deleteForRoot(root.id);
          await db.deleteRootCascade(root.id);
          _clearRevokedRoot(root.id);
          continue;
        }

        final locator = MediaLocator(root.locator);
        await db.deleteRootCascade(root.id);
        _clearRevokedRoot(root.id);
        try {
          await source.releaseRoot(locator);
        } on Object catch (error, stack) {
          debugPrint('releaseRoot failed: $error\n$stack');
          anyReleaseFailed = true;
        }
      }

      if (anyReleaseFailed) {
        reporter.reportError(
          code: LibraryMessageCodes.forgetAllFailed,
          message: l10n.forgetAllFailed,
        );
      } else {
        reporter.reportInfo(
          code: LibraryMessageCodes.forgetAllComplete,
          message: l10n.forgetAllComplete,
        );
      }
    } finally {
      _finishIdle();
    }
  }

  /// Recomputes revoked UI strips; reports each newly revoked root once per session.
  ///
  /// Cold-start / explicit path only — no live OS grant watcher while open.
  Future<void> checkRevokedRoots({required LibraryIngestL10n l10n}) async {
    final db = ref.read(appDatabaseProvider);
    final source = ref.read(localLibrarySourceProvider);
    final reporter = ref.read(messageReporterProvider);
    final roots = await db.select(db.libraryRoots).get();

    final nextRevoked = <RevokedRootInfo>[];
    for (final root in roots) {
      if (root.sourceKind == SourceKinds.cloud) {
        continue;
      }
      final bool ok;
      try {
        ok = await source.hasPersistedAccess(MediaLocator(root.locator));
      } on Object catch (error, stack) {
        // Startup checks must never escape a post-frame callback. Continue so
        // later roots are still evaluated.
        debugPrint('persisted access check failed: $error\n$stack');
        continue;
      }
      if (!ok) {
        nextRevoked.add(
          RevokedRootInfo(
            id: root.id,
            displayName: root.displayName,
            locator: root.locator,
          ),
        );
        if (!_revokedReportedLocators.contains(root.locator)) {
          _revokedReportedLocators.add(root.locator);
          reporter.reportError(
            code: LibraryMessageCodes.rootRevoked,
            message: l10n.rootRevoked,
          );
        }
      }
    }
    state = state.copyWith(revokedRoots: List.unmodifiable(nextRevoked));
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
    required String displayName,
    required LibraryIngestL10n l10n,
    bool appendAllTouched = false,
  }) async {
    final reporter = ref.read(messageReporterProvider);
    final source = ref.read(localLibrarySourceProvider);

    final ok = await source.hasPersistedAccess(rootLocator);
    if (!ok) {
      _markRevoked(
        RevokedRootInfo(
          id: rootId,
          displayName: displayName,
          locator: rootLocator.value,
        ),
      );
      if (!_revokedReportedLocators.contains(rootLocator.value)) {
        _revokedReportedLocators.add(rootLocator.value);
        reporter.reportError(
          code: LibraryMessageCodes.rootRevoked,
          message: l10n.rootRevoked,
        );
      }
      _finishIdle();
      return;
    }

    _clearRevokedRoot(rootId);

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

  Future<void> _scanNewCloudRoot({
    required int rootId,
    required MediaLocator rootLocator,
    required CloudLibrarySource cloud,
    required bool includeSubfolders,
    required LibraryIngestL10n l10n,
  }) async {
    final reporter = ref.read(messageReporterProvider);
    final outcome = await _walkCloudAndUpsert(
      rootId: rootId,
      rootLocator: rootLocator,
      cloud: cloud,
      includeSubfolders: includeSubfolders,
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

  Future<void> _rescanCloudRoot({
    required int rootId,
    required MediaLocator rootLocator,
    required CloudLibrarySource cloud,
    required bool includeSubfolders,
    required LibraryIngestL10n l10n,
    bool appendAllTouched = false,
  }) async {
    final reporter = ref.read(messageReporterProvider);
    final outcome = await _walkCloudAndUpsert(
      rootId: rootId,
      rootLocator: rootLocator,
      cloud: cloud,
      includeSubfolders: includeSubfolders,
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

  /// Walks a Drive folder tree (list-only; tags fill on play download).
  Future<_WalkOutcome> _walkCloudAndUpsert({
    required int rootId,
    required MediaLocator rootLocator,
    required CloudLibrarySource cloud,
    required bool includeSubfolders,
    required bool pruneMissing,
  }) async {
    final db = ref.read(appDatabaseProvider);

    final seenSourceItemIds = <String>{};
    final newlyInserted = <int>[];
    final allTouched = <int>[];
    var processed = 0;
    var cancelled = false;
    var failed = false;
    var batchesFailed = false;
    String? failureDetail;

    final rootRow = await (db.select(db.libraryRoots)
          ..where((t) => t.id.equals(rootId)))
        .getSingle();
    final dirs = Queue<_DirFrame>()
      ..add(_DirFrame(rootLocator, rootRow.displayName));
    final pending = <_PendingCloud>[];

    Future<bool> flushBatch() async {
      if (pending.isEmpty) return true;
      final chunk = List<_PendingCloud>.from(pending);
      pending.clear();

      // Leave title/artist/album absent so re-scan does not wipe play-path tags.
      final companions = <TracksCompanion>[
        for (final item in chunk)
          TracksCompanion.insert(
            rootId: rootId,
            sourceItemId: item.entry.locator.value,
            locator: item.entry.locator.value,
            displayName: item.entry.name,
            parentFolderName: Value(item.parentFolderName),
            sizeBytes: Value(item.entry.sizeBytes),
            modifiedAt: Value(item.entry.modifiedAt),
            sourceKind: const Value(SourceKinds.cloud),
          ),
      ];
      for (final item in chunk) {
        seenSourceItemIds.add(item.entry.locator.value);
        processed++;
        state = state.copyWith(
          phase: IngestPhase.scanning,
          processedCount: processed,
        );
      }

      try {
        for (var i = 0; i < companions.length; i += _batchSize) {
          final batch = companions.skip(i).take(_batchSize).toList();
          final result = await db.upsertTracksBatch(rootId, batch);
          newlyInserted.addAll(result.insertedIds);
          allTouched.addAll(result.insertedIds);
          allTouched.addAll(result.updatedIds);
        }
        return true;
      } on Object catch (error, stack) {
        debugPrint('cloud upsert batch failed: $error\n$stack');
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
      final frame = dirs.removeFirst();
      final List<CloudLibraryEntry> children;
      try {
        children = List<CloudLibraryEntry>.of(await cloud.list(frame.locator))
          ..sort((a, b) => compareDisplayNames(a.name, b.name));
      } on Object catch (error, stack) {
        debugPrint('cloud list failed: $error\n$stack');
        failed = true;
        failureDetail = error.toString();
        await flushBatch();
        break;
      }

      for (final child in children) {
        if (child.isDirectory) {
          if (includeSubfolders) {
            dirs.add(_DirFrame(child.locator, child.name));
          }
        } else {
          pending.add(_PendingCloud(child, frame.folderName));
          if (pending.length >= _batchSize) {
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
      await _pruneMissingTracks(db, rootId, seenSourceItemIds);
    }

    return _WalkOutcome(
      success: success,
      cancelled: cancelled,
      newlyInsertedTrackIds: List.unmodifiable(newlyInserted),
      allTouchedTrackIds: List.unmodifiable(allTouched),
      failureDetail: failureDetail,
    );
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

    final rootRow = await (db.select(db.libraryRoots)
          ..where((t) => t.id.equals(rootId)))
        .getSingle();
    final dirs = Queue<_DirFrame>()
      ..add(_DirFrame(rootLocator, rootRow.displayName));
    final pendingFiles = <_PendingLocal>[];

    Future<bool> flushBatch() async {
      if (pendingFiles.isEmpty) return true;
      final chunk = List<_PendingLocal>.from(pendingFiles);
      pendingFiles.clear();

      final companions = <TracksCompanion>[];
      final artworkBySource = <String, List<int>>{};
      for (var i = 0; i < chunk.length; i += _metadataConcurrency) {
        if (_cancelRequested) {
          cancelled = true;
          return false;
        }
        final slice = chunk.skip(i).take(_metadataConcurrency).toList();
        final results = await Future.wait(
          slice.map((pending) => _readTags(source, reader, pending.entry)),
        );
        for (var j = 0; j < slice.length; j++) {
          final pending = slice[j];
          final entry = pending.entry;
          final tags = results[j];
          seenSourceItemIds.add(entry.locator.value);
          companions.add(
            TracksCompanion.insert(
              rootId: rootId,
              sourceItemId: entry.locator.value,
              locator: entry.locator.value,
              displayName: entry.name,
              parentFolderName: Value(pending.parentFolderName),
              title: Value(tags?.title),
              artist: Value(tags?.artist),
              album: Value(tags?.album),
            ),
          );
          final bytes = tags?.artworkBytes;
          if (bytes != null && bytes.isNotEmpty) {
            artworkBySource[entry.locator.value] = bytes;
          }
          processed++;
          state = state.copyWith(
            phase: IngestPhase.scanning,
            processedCount: processed,
          );
        }
      }

      try {
        final artwork = ref.read(artworkCacheStoreProvider);
        for (var i = 0; i < companions.length; i += _batchSize) {
          final batch = companions.skip(i).take(_batchSize).toList();
          final result = await db.upsertTracksBatch(rootId, batch);
          newlyInserted.addAll(result.insertedIds);
          allTouched.addAll(result.insertedIds);
          allTouched.addAll(result.updatedIds);
          for (final entry in result.idsBySourceItemId.entries) {
            final bytes = artworkBySource[entry.key];
            if (bytes == null) continue;
            await artwork.writeFromBytes(entry.value, bytes);
          }
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
      final frame = dirs.removeFirst();
      final List<LibraryEntry> children;
      try {
        children = await source.listChildren(frame.locator);
      } on Object catch (error, stack) {
        debugPrint('listChildren failed: $error\n$stack');
        failed = true;
        failureDetail = error.toString();
        await flushBatch();
        break;
      }

      for (final child in children) {
        if (child.isDirectory) {
          dirs.add(_DirFrame(child.locator, child.name));
        } else if (isAudioFileName(child.name)) {
          pendingFiles.add(_PendingLocal(child, frame.folderName));
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
      await _pruneMissingTracks(db, rootId, seenSourceItemIds);
    }

    return _WalkOutcome(
      success: success,
      cancelled: cancelled,
      newlyInsertedTrackIds: List.unmodifiable(newlyInserted),
      allTouchedTrackIds: List.unmodifiable(allTouched),
      failureDetail: failureDetail,
    );
  }

  /// Deletes cloud cache + artwork for pruned tracks, then catalog rows.
  Future<void> _pruneMissingTracks(
    AppDatabase db,
    int rootId,
    Set<String> seenSourceItemIds,
  ) async {
    final doomed = await db.trackIdsNotIn(rootId, seenSourceItemIds);
    if (doomed.isNotEmpty) {
      final cache = ref.read(cloudCacheStoreProvider);
      for (final id in doomed) {
        await cache.deleteForTrack(id);
      }
      await ref.read(artworkCacheStoreProvider).deleteForTrackIds(doomed);
    }
    await db.deleteTracksNotIn(rootId, seenSourceItemIds);
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
      return meta;
    } on Object catch (error, stack) {
      debugPrint('metadata failed for ${entry.name}: $error\n$stack');
      return null;
    } finally {
      if (path != null) deleteQuietly(path);
    }
  }

  void _begin(IngestPhase phase) {
    _cancelRequested = false;
    state = state.copyWith(phase: phase, processedCount: 0);
  }

  void _finishIdle() {
    _cancelRequested = false;
    state = state.copyWith(phase: IngestPhase.idle, processedCount: 0);
  }

  void _markRevoked(RevokedRootInfo info) {
    final without = state.revokedRoots.where((r) => r.id != info.id).toList();
    state = state.copyWith(revokedRoots: List.unmodifiable([...without, info]));
  }

  void _clearRevokedRoot(int rootId) {
    if (!state.revokedRoots.any((r) => r.id == rootId)) return;
    state = state.copyWith(
      revokedRoots: List.unmodifiable(
        state.revokedRoots.where((r) => r.id != rootId),
      ),
    );
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

/// One directory to visit during ingest, with the folder name files sit in.
class _DirFrame {
  /// Creates a visit frame for [locator] whose files sit in [folderName].
  const _DirFrame(this.locator, this.folderName);

  /// Folder to list.
  final MediaLocator locator;

  /// Display name stored on files found in this folder.
  final String folderName;
}

/// Local file waiting for a tag-read batch, plus its containing folder.
class _PendingLocal {
  /// Creates a pending local file in [parentFolderName].
  const _PendingLocal(this.entry, this.parentFolderName);

  /// Listed file.
  final LibraryEntry entry;

  /// Immediate parent folder display name.
  final String parentFolderName;
}

/// Cloud file waiting for an upsert batch, plus its containing folder.
class _PendingCloud {
  /// Creates a pending cloud file in [parentFolderName].
  const _PendingCloud(this.entry, this.parentFolderName);

  /// Listed remote file.
  final CloudLibraryEntry entry;

  /// Immediate parent folder display name.
  final String parentFolderName;
}
