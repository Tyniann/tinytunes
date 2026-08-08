import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/free_space_source.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_cloud_library_source.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_remote.dart';

import 'fake_one_drive_remote.dart';

class _FixedFreeSpace implements FreeSpaceSource {
  _FixedFreeSpace(this.bytes);

  final int bytes;

  @override
  Future<int> availableBytesFor(String directoryPath) async => bytes;
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tt_od_src_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('list personal root sorts by display name', () async {
    final remote = FakeOneDriveRemote(
      rootChildren: const [
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
          itemId: 'm',
          name: 'Mid.mp3',
          isDirectory: false,
        ),
      ],
    );
    final source = OneDriveCloudLibrarySource(
      remote: remote,
      cacheRootDirectory: tempDir,
    );

    final listed = await source.list(OneDriveMediaLocator.personalRoot);
    expect(listed.map((e) => e.name).toList(), [
      'alpha.mp3',
      'Mid.mp3',
      'zulu.mp3',
    ]);
    expect(remote.listRootCalls, 1);
  });

  test('list returns folders and audio files only', () async {
    final remote = FakeOneDriveRemote(
      rootChildren: const [
        OneDriveRemoteEntry(
          driveId: 'd1',
          itemId: 'f1',
          name: 'Musik',
          isDirectory: true,
        ),
        OneDriveRemoteEntry(
          driveId: 'd1',
          itemId: 't1',
          name: 'song.mp3',
          isDirectory: false,
          sizeBytes: 100,
        ),
        OneDriveRemoteEntry(
          driveId: 'd1',
          itemId: 'x1',
          name: 'notes.txt',
          isDirectory: false,
          sizeBytes: 10,
        ),
      ],
    );
    final source = OneDriveCloudLibrarySource(
      remote: remote,
      cacheRootDirectory: tempDir,
    );

    final listed = await source.list(OneDriveMediaLocator.personalRoot);
    expect(listed, hasLength(2));
    expect(listed.map((e) => e.name), containsAll(['Musik', 'song.mp3']));
    expect(listed.any((e) => e.name == 'notes.txt'), isFalse);
  });

  test('list nested parent uses drive/item children', () async {
    final parent = OneDriveMediaLocator.encode(driveId: 'd1', itemId: 'folder');
    final remote = FakeOneDriveRemote(
      childrenByParent: {
        'd1/folder': const [
          OneDriveRemoteEntry(
            driveId: 'd1',
            itemId: 'child',
            name: 'nested.flac',
            isDirectory: false,
          ),
        ],
      },
    );
    final source = OneDriveCloudLibrarySource(
      remote: remote,
      cacheRootDirectory: tempDir,
    );

    final listed = await source.list(parent);
    expect(listed, hasLength(1));
    expect(listed.single.name, 'nested.flac');
    expect(
      listed.single.locator,
      OneDriveMediaLocator.encode(driveId: 'd1', itemId: 'child'),
    );
  });

  test('downloadToCache then resolveCached returns file URI under onedrive/', () async {
    const driveId = 'driveA';
    const itemId = 'audio1';
    final remote = FakeOneDriveRemote(
      files: {
        '$driveId/$itemId': const OneDriveRemoteFileMeta(
          driveId: driveId,
          itemId: itemId,
          name: 'a.mp3',
          sizeBytes: 4,
        ),
      },
      fileBytes: {
        '$driveId/$itemId': [1, 2, 3, 4],
      },
    );
    final source = OneDriveCloudLibrarySource(
      remote: remote,
      cacheRootDirectory: tempDir,
    );
    final remoteLocator = OneDriveMediaLocator.encode(
      driveId: driveId,
      itemId: itemId,
    );

    final cacheLocator = await source.downloadToCache(remoteLocator);
    expect(File(cacheLocator.value).existsSync(), isTrue);
    expect(
      cacheLocator.value,
      contains('${Platform.pathSeparator}onedrive${Platform.pathSeparator}'),
    );
    expect(remote.downloadCalls, 1);

    final uri = await source.resolveCached(remoteLocator);
    expect(uri.scheme, 'file');
    expect(File.fromUri(uri).readAsBytesSync(), [1, 2, 3, 4]);
  });

  test('resolveCached throws CloudCacheMissException when absent', () async {
    final source = OneDriveCloudLibrarySource(
      remote: FakeOneDriveRemote(),
      cacheRootDirectory: tempDir,
    );
    expect(
      () => source.resolveCached(
        OneDriveMediaLocator.encode(driveId: 'd', itemId: 'missing'),
      ),
      throwsA(isA<CloudCacheMissException>()),
    );
  });

  test('downloadToCache throws when free space is insufficient', () async {
    const driveId = 'd';
    const itemId = 'big';
    final remote = FakeOneDriveRemote(
      files: {
        '$driveId/$itemId': const OneDriveRemoteFileMeta(
          driveId: driveId,
          itemId: itemId,
          name: 'big.flac',
          sizeBytes: 1000,
        ),
      },
      fileBytes: {'$driveId/$itemId': List<int>.filled(1000, 9)},
    );
    final source = OneDriveCloudLibrarySource(
      remote: remote,
      cacheRootDirectory: tempDir,
      freeSpace: _FixedFreeSpace(100),
    );

    expect(
      () => source.downloadToCache(
        OneDriveMediaLocator.encode(driveId: driveId, itemId: itemId),
      ),
      throwsA(isA<InsufficientFreeSpaceException>()),
    );
    expect(remote.downloadCalls, 0);
  });

  test('duplicate names keep distinct locators by item id', () async {
    final remote = FakeOneDriveRemote(
      rootChildren: const [
        OneDriveRemoteEntry(
          driveId: 'd1',
          itemId: 'id-a',
          name: 'track.mp3',
          isDirectory: false,
        ),
        OneDriveRemoteEntry(
          driveId: 'd1',
          itemId: 'id-b',
          name: 'track.mp3',
          isDirectory: false,
        ),
      ],
    );
    final source = OneDriveCloudLibrarySource(
      remote: remote,
      cacheRootDirectory: tempDir,
    );
    final listed = await source.list(OneDriveMediaLocator.personalRoot);
    expect(listed, hasLength(2));
    expect(listed[0].locator.value, isNot(listed[1].locator.value));
  });
}
