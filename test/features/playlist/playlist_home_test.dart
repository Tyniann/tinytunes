import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/core/library/local_library_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/features/playlist/presentation/playlist_home_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedQueue() async {
    final rootId = await db.upsertRoot(
      locator: 'content://tree/root',
      displayName: 'Music',
      addedAt: DateTime.utc(2026, 1, 1),
    );
    final result = await db.upsertTracksBatch(rootId, [
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: 'a',
        locator: 'a',
        displayName: 'a.mp3',
        title: const Value('Alpha'),
        artist: const Value('Artist A'),
      ),
      TracksCompanion.insert(
        rootId: rootId,
        sourceItemId: 'b',
        locator: 'b',
        displayName: 'b.mp3',
        title: const Value('Beta'),
        artist: const Value('Artist B'),
      ),
    ]);
    await db.appendTrackIds(result.insertedIds);
  }

  testWidgets('shows empty state then seeded queue rows', (tester) async {
    await seedQueue();
    await pumpApp(tester, database: db);

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Artist A'), findsOneWidget);
    await endPumpApp(tester);
  });

  testWidgets('remove queue row updates the list', (tester) async {
    await seedQueue();
    await pumpApp(tester, database: db, liveQueueStreams: true);

    expect(find.text('Alpha'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove from queue').first);
    await tester.pumpAndSettle();

    expect(find.text('Alpha'), findsNothing);
    expect(find.text('Beta'), findsOneWidget);
    await endPumpApp(tester);
  });

  testWidgets('clear queue confirm empties the list', (tester) async {
    await seedQueue();
    await pumpApp(tester, database: db, liveQueueStreams: true);

    await tester.tap(find.byTooltip('Playlist actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear queue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(
      find.text('Queue is empty. Add a folder to get started.'),
      findsOneWidget,
    );
    expect(await db.select(db.tracks).get(), hasLength(2));
    await endPumpApp(tester);
  });

  testWidgets('add folder disabled while scan is busy', (tester) async {
    final gate = Completer<MediaLocator?>();
    final source = _GatedLibrarySource(gate);

    await pumpApp(tester, database: db, librarySource: source);

    await tester.tap(find.byTooltip('Add folder'));
    await tester.pump();

    final addButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.create_new_folder_outlined),
    );
    expect(addButton.onPressed, isNull);
    expect(find.textContaining('Scanning'), findsOneWidget);

    gate.complete(null);
    await tester.pumpAndSettle();

    final addAfter = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.create_new_folder_outlined),
    );
    expect(addAfter.onPressed, isNotNull);
    expect(find.byType(PlaylistHomeScreen), findsOneWidget);
    await endPumpApp(tester);
  });
}

class _GatedLibrarySource implements LocalLibrarySource {
  _GatedLibrarySource(this._pickGate);

  final Completer<MediaLocator?> _pickGate;

  @override
  Future<MediaLocator?> pickAndRetainRoot() => _pickGate.future;

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
  }) async =>
      '/tmp/empty.mp3';

  @override
  Future<bool> hasPersistedAccess(MediaLocator root) async => true;

  @override
  Future<List<MediaLocator>> listPersistedRoots() async => const [];

  @override
  Future<void> releaseRoot(MediaLocator root) async {}
}
