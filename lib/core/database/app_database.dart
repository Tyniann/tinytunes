import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:tinytunes/core/database/tables.dart';

part 'app_database.g.dart';

/// TinyTunes Drift database (catalog, queue, playback singleton, cloud cache).
///
/// Purpose: Persist library roots/tracks and the single queue across restarts.
/// Usage Context: Opened once via [appDatabaseProvider]; tests use
/// [AppDatabase.memory].
@DriftDatabase(
  tables: [
    LibraryRoots,
    Tracks,
    QueueEntries,
    PlaybackState,
    CloudCacheEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens [executor] (production file DB or in-memory test DB).
  AppDatabase(super.executor);

  /// Production opener under the app documents directory.
  ///
  /// Uses [driftDatabase] with [DriftNativeOptions.shareAcrossIsolates] so a
  /// Flutter hot restart cannot leave a background isolate holding the file
  /// lock (`SqliteException(5) database is locked` during schema create).
  AppDatabase.defaults()
      : super(
          driftDatabase(
            name: 'tinytunes',
            native: DriftNativeOptions(
              shareAcrossIsolates: true,
              setup: (raw) {
                raw.execute('PRAGMA foreign_keys = ON');
                raw.execute('PRAGMA busy_timeout = 5000');
              },
            ),
          ),
        );

  /// In-memory database for unit and widget tests.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _ensurePlaybackStateRow();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(cloudCacheEntries);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          if (!details.wasCreated) {
            await _ensurePlaybackStateRow();
          }
        },
      );

  /// Inserts the singleton `playback_state` row when missing.
  Future<void> _ensurePlaybackStateRow() async {
    final existing = await (select(playbackState)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (existing != null) return;
    await into(playbackState).insert(
      PlaybackStateCompanion.insert(
        id: const Value(1),
      ),
    );
  }
}
