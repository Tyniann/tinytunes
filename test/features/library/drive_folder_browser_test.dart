import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_cloud_library_source.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_media_locator.dart';
import 'package:tinytunes/features/library/presentation/drive_folder_browser_dialog.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

import '../../core/cloud/fake_cloud_library_source.dart';

void main() {
  final googleRoot = DriveMediaLocator.encode(
    GoogleDriveCloudLibrarySource.myDriveRootFileId,
  );
  final music = DriveMediaLocator.encode('music');
  final song = DriveMediaLocator.encode('song1');

  testWidgets('shows audio files in a folder that has no subfolders', (
    tester,
  ) async {
    final cloud = FakeCloudLibrarySource(
      childrenByParent: {
        googleRoot.value: [
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
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              body: TextButton(
                onPressed: () => showCloudFolderPicker(
                  context: context,
                  cloud: cloud,
                  config: CloudFolderBrowserConfig(
                    rootLocator: googleRoot,
                    rootDisplayName: l10n.cloudFolderBrowserMyDrive,
                  ),
                ),
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

  testWidgets('virtual OneDrive root cannot be selected', (tester) async {
    final cloud = FakeCloudLibrarySource(
      childrenByParent: {
        OneDriveMediaLocator.personalRoot.value: [
          CloudLibraryEntry(
            locator: OneDriveMediaLocator.encode(driveId: 'd', itemId: 'f'),
            name: 'Musik',
            isDirectory: true,
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
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              body: TextButton(
                onPressed: () => showCloudFolderPicker(
                  context: context,
                  cloud: cloud,
                  config: CloudFolderBrowserConfig(
                    rootLocator: OneDriveMediaLocator.personalRoot,
                    rootDisplayName: l10n.cloudFolderBrowserMyFiles,
                  ),
                ),
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

    expect(find.text('My files'), findsWidgets);
    final select = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Select this folder'),
    );
    expect(select.onPressed, isNull);
  });

  testWidgets('shows empty only when folder has no children', (tester) async {
    final cloud = FakeCloudLibrarySource(
      childrenByParent: {
        googleRoot.value: [
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
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              body: TextButton(
                onPressed: () => showCloudFolderPicker(
                  context: context,
                  cloud: cloud,
                  config: CloudFolderBrowserConfig(
                    rootLocator: googleRoot,
                    rootDisplayName: l10n.cloudFolderBrowserMyDrive,
                  ),
                ),
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

  testWidgets('shows scroll-down hint when folder list overflows', (
    tester,
  ) async {
    final folders = [
      for (var i = 0; i < 20; i++)
        CloudLibraryEntry(
          locator: DriveMediaLocator.encode('f$i'),
          name: 'Folder $i',
          isDirectory: true,
        ),
    ];
    final cloud = FakeCloudLibrarySource(
      childrenByParent: {googleRoot.value: folders},
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              body: TextButton(
                onPressed: () => showCloudFolderPicker(
                  context: context,
                  cloud: cloud,
                  config: CloudFolderBrowserConfig(
                    rootLocator: googleRoot,
                    rootDisplayName: l10n.cloudFolderBrowserMyDrive,
                  ),
                ),
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
    await tester.pump();

    expect(find.byKey(const Key('cloudFolderBrowserScrollHint')), findsOneWidget);
    expect(find.text('Folder 0'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Folder 19'),
      200,
      scrollable: find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Folder 19'), findsOneWidget);
  });
}
