import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  test('seeds singleton playback_state row on open', () async {
    // Touch the DB so beforeOpen runs.
    final rows = await db.select(db.playbackState).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 1);
    expect(rows.single.currentQueueEntryId, isNull);
    expect(rows.single.positionMs, 0);
    expect(rows.single.shuffleEnabled, isFalse);
    expect(rows.single.repeatMode, 'off');
  });

  test('currentQueueEntryId SET NULL when queue entry is deleted', () async {
    final rootId = await db.into(db.libraryRoots).insert(
          LibraryRootsCompanion.insert(
            locator: 'content://tree/root',
            displayName: 'Music',
            addedAt: DateTime.utc(2026, 1, 1),
          ),
        );
    final trackId = await db.into(db.tracks).insert(
          TracksCompanion.insert(
            rootId: rootId,
            sourceItemId: 'content://tree/root/doc/a.mp3',
            locator: 'content://tree/root/doc/a.mp3',
            displayName: 'a.mp3',
          ),
        );
    final entryId = await db.into(db.queueEntries).insert(
          QueueEntriesCompanion.insert(
            trackId: trackId,
            sortIndex: 0,
          ),
        );

    await (db.update(db.playbackState)..where((t) => t.id.equals(1))).write(
      PlaybackStateCompanion(
        currentQueueEntryId: Value(entryId),
      ),
    );

    await (db.delete(db.queueEntries)..where((t) => t.id.equals(entryId))).go();

    final state = await (db.select(db.playbackState)
          ..where((t) => t.id.equals(1)))
        .getSingle();
    expect(state.currentQueueEntryId, isNull);
  });
}
