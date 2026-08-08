import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_cloud_library_source.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_remote.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_cloud_library_source.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_remote.dart';
import 'package:tinytunes/core/library/media_locator.dart';

import 'google_drive/fake_drive_remote.dart';
import 'one_drive/fake_one_drive_remote.dart';

/// Shared list/download/cache expectations for Google and OneDrive sources.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tt_cloud_contract_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Google Drive source contract', () {
    late FakeDriveRemote remote;
    late GoogleDriveCloudLibrarySource source;
    late MediaLocator root;
    late MediaLocator audio;

    setUp(() {
      remote = FakeDriveRemote(
        childrenByParent: {
          'root': [
            const DriveRemoteEntry(
              fileId: 'folder',
              name: 'Musik',
              isDirectory: true,
            ),
            const DriveRemoteEntry(
              fileId: 'z',
              name: 'zulu.mp3',
              isDirectory: false,
            ),
            const DriveRemoteEntry(
              fileId: 'a',
              name: 'alpha.mp3',
              isDirectory: false,
            ),
            const DriveRemoteEntry(
              fileId: 'txt',
              name: 'notes.txt',
              isDirectory: false,
            ),
          ],
        },
        files: {
          'a': const DriveRemoteFileMeta(
            fileId: 'a',
            name: 'alpha.mp3',
            sizeBytes: 3,
          ),
        },
        fileBytes: {
          'a': [9, 8, 7],
        },
      );
      source = GoogleDriveCloudLibrarySource(
        remote: remote,
        cacheRootDirectory: tempDir,
      );
      root = DriveMediaLocator.encode('root');
      audio = DriveMediaLocator.encode('a');
    });

    _runContract(
      listRoot: () => source.list(root),
      downloadAudio: () => source.downloadToCache(audio),
      resolveAudio: () => source.resolveCached(audio),
      downloadCalls: () => remote.downloadCalls,
      expectedCacheSegment: 'gdrive',
    );
  });

  group('OneDrive source contract', () {
    late FakeOneDriveRemote remote;
    late OneDriveCloudLibrarySource source;
    late MediaLocator root;
    late MediaLocator audio;

    setUp(() {
      remote = FakeOneDriveRemote(
        rootChildren: const [
          OneDriveRemoteEntry(
            driveId: 'd1',
            itemId: 'folder',
            name: 'Musik',
            isDirectory: true,
          ),
          OneDriveRemoteEntry(
            driveId: 'd1',
            itemId: 'z',
            name: 'zulu.mp3',
            isDirectory: false,
          ),
          OneDriveRemoteEntry(
            driveId: 'd1',
            itemId: 'a',
            name: 'alpha.mp3',
            isDirectory: false,
          ),
          OneDriveRemoteEntry(
            driveId: 'd1',
            itemId: 'txt',
            name: 'notes.txt',
            isDirectory: false,
          ),
        ],
        files: {
          'd1/a': const OneDriveRemoteFileMeta(
            driveId: 'd1',
            itemId: 'a',
            name: 'alpha.mp3',
            sizeBytes: 3,
          ),
        },
        fileBytes: {
          'd1/a': [9, 8, 7],
        },
      );
      source = OneDriveCloudLibrarySource(
        remote: remote,
        cacheRootDirectory: tempDir,
      );
      root = OneDriveMediaLocator.personalRoot;
      audio = OneDriveMediaLocator.encode(driveId: 'd1', itemId: 'a');
    });

    _runContract(
      listRoot: () => source.list(root),
      downloadAudio: () => source.downloadToCache(audio),
      resolveAudio: () => source.resolveCached(audio),
      downloadCalls: () => remote.downloadCalls,
      expectedCacheSegment: 'onedrive',
    );
  });
}

void _runContract({
  required Future<List<CloudLibraryEntry>> Function() listRoot,
  required Future<MediaLocator> Function() downloadAudio,
  required Future<Uri> Function() resolveAudio,
  required int Function() downloadCalls,
  required String expectedCacheSegment,
}) {
  test('lists folders+audio sorted; filters non-audio', () async {
    final listed = await listRoot();
    expect(listed.map((e) => e.name).toList(), [
      'alpha.mp3',
      'Musik',
      'zulu.mp3',
    ]);
  });

  test('download then resolve hits provider cache once', () async {
    final cached = await downloadAudio();
    expect(
      cached.value,
      contains(
        '${Platform.pathSeparator}$expectedCacheSegment${Platform.pathSeparator}',
      ),
    );
    final uri = await resolveAudio();
    expect(File.fromUri(uri).readAsBytesSync(), [9, 8, 7]);
    expect(downloadCalls(), 1);
  });
}
