import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/drive_media_locator.dart';
import 'package:tinytunes/core/cloud/drive_remote.dart';
import 'package:tinytunes/core/cloud/free_space_source.dart';
import 'package:tinytunes/core/cloud/google_drive_cloud_library_source.dart';

import 'fake_drive_remote.dart';

class _FixedFreeSpace implements FreeSpaceSource {
  _FixedFreeSpace(this.bytes);

  final int bytes;

  @override
  Future<int> availableBytesFor(String directoryPath) async => bytes;
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tt_cloud_src_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('list sorts by display name like local SAF DISPLAY_NAME ASC', () async {
    final remote = FakeDriveRemote(
      childrenByParent: {
        'root': [
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
            fileId: 'm',
            name: 'Mid.mp3',
            isDirectory: false,
          ),
        ],
      },
    );
    final source = GoogleDriveCloudLibrarySource(
      remote: remote,
      cacheRootDirectory: tempDir,
    );

    final listed = await source.list(DriveMediaLocator.encode('root'));
    expect(listed.map((e) => e.name).toList(), [
      'alpha.mp3',
      'Mid.mp3',
      'zulu.mp3',
    ]);
  });

  test('list returns folders and audio files only', () async {
    final remote = FakeDriveRemote(
      childrenByParent: {
        'root': [
          const DriveRemoteEntry(
            fileId: 'f1',
            name: 'Musik',
            isDirectory: true,
          ),
          const DriveRemoteEntry(
            fileId: 't1',
            name: 'song.mp3',
            isDirectory: false,
            sizeBytes: 100,
          ),
          const DriveRemoteEntry(
            fileId: 'x1',
            name: 'notes.txt',
            isDirectory: false,
            sizeBytes: 10,
          ),
        ],
      },
    );
    final source = GoogleDriveCloudLibrarySource(
      remote: remote,
      cacheRootDirectory: tempDir,
    );

    final listed = await source.list(DriveMediaLocator.encode('root'));
    expect(listed, hasLength(2));
    expect(listed.map((e) => e.name), containsAll(['Musik', 'song.mp3']));
    expect(listed.any((e) => e.name == 'notes.txt'), isFalse);
  });

  test('downloadToCache then resolveCached returns file URI', () async {
    const fileId = 'audio1';
    final remote = FakeDriveRemote(
      files: {
        fileId: const DriveRemoteFileMeta(
          fileId: fileId,
          name: 'a.mp3',
          sizeBytes: 4,
        ),
      },
      fileBytes: {
        fileId: [1, 2, 3, 4],
      },
    );
    final source = GoogleDriveCloudLibrarySource(
      remote: remote,
      cacheRootDirectory: tempDir,
    );
    final remoteLocator = DriveMediaLocator.encode(fileId);

    final cacheLocator = await source.downloadToCache(remoteLocator);
    expect(File(cacheLocator.value).existsSync(), isTrue);
    expect(remote.downloadCalls, 1);

    final uri = await source.resolveCached(remoteLocator);
    expect(uri.scheme, 'file');
    expect(File.fromUri(uri).readAsBytesSync(), [1, 2, 3, 4]);
  });

  test('resolveCached throws CloudCacheMissException when absent', () async {
    final source = GoogleDriveCloudLibrarySource(
      remote: FakeDriveRemote(),
      cacheRootDirectory: tempDir,
    );
    expect(
      () => source.resolveCached(DriveMediaLocator.encode('missing')),
      throwsA(isA<CloudCacheMissException>()),
    );
  });

  test('downloadToCache throws when free space is insufficient', () async {
    const fileId = 'big';
    final remote = FakeDriveRemote(
      files: {
        fileId: const DriveRemoteFileMeta(
          fileId: fileId,
          name: 'big.flac',
          sizeBytes: 1000,
        ),
      },
      fileBytes: {fileId: List<int>.filled(1000, 9)},
    );
    final source = GoogleDriveCloudLibrarySource(
      remote: remote,
      cacheRootDirectory: tempDir,
      freeSpace: _FixedFreeSpace(100),
    );

    expect(
      () => source.downloadToCache(DriveMediaLocator.encode(fileId)),
      throwsA(isA<InsufficientFreeSpaceException>()),
    );
    expect(remote.downloadCalls, 0);
  });
}
