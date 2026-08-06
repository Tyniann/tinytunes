import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/drive_media_locator.dart';
import 'package:tinytunes/core/cloud/google_drive_cloud_library_source.dart';
import 'package:tinytunes/features/library/presentation/drive_folder_browser_dialog.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

import '../../core/cloud/fake_cloud_library_source.dart';

void main() {
  final root = DriveMediaLocator.encode(
    GoogleDriveCloudLibrarySource.myDriveRootFileId,
  );
  final music = DriveMediaLocator.encode('music');
  final song = DriveMediaLocator.encode('song1');

  testWidgets('shows audio files in a folder that has no subfolders', (
    tester,
  ) async {
    final cloud = FakeCloudLibrarySource(
      childrenByParent: {
        root.value: [
          CloudLibraryEntry(locator: music, name: 'Musik', isDirectory: true),
        ],
        music.value: [
          CloudLibraryEntry(
            locator: song,
            name: 'track.mp3',
            isDirectory: false,
            sizeBytes: 10,
          ),
        ],
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () =>
                    showDriveFolderPicker(context: context, cloud: cloud),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Musik'), findsOneWidget);
    await tester.tap(find.text('Musik'));
    await tester.pump();
    await tester.pump();

    expect(find.text('track.mp3'), findsOneWidget);
    expect(find.text('This folder is empty.'), findsNothing);
    expect(find.text('Select this folder'), findsOneWidget);
  });

  testWidgets('shows empty only when folder has no children', (tester) async {
    final cloud = FakeCloudLibrarySource(
      childrenByParent: {
        root.value: [
          CloudLibraryEntry(locator: music, name: 'Empty', isDirectory: true),
        ],
        music.value: const [],
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () =>
                    showDriveFolderPicker(context: context, cloud: cloud),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Empty'));
    await tester.pump();
    await tester.pump();

    expect(find.text('This folder is empty.'), findsOneWidget);
  });
}
