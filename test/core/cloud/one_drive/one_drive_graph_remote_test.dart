import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_auth.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_graph_http.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_graph_remote.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_remote.dart';

import 'fake_one_drive.dart';

void main() {
  FakeOneDriveAuth signedInAuth() => FakeOneDriveAuth(
    account: const OneDriveAccount(
      stableAccountKey: 'oid-1',
      email: 'a@b.com',
    ),
  );

  test('isMicrosoftGraphHost accepts only Graph hosts', () {
    expect(isMicrosoftGraphHost('graph.microsoft.com'), isTrue);
    expect(isMicrosoftGraphHost('cdn.example.com'), isFalse);
  });

  test('Graph access token client strips Authorization off non-Graph hosts', () async {
    http.BaseRequest? seen;
    final inner = MockClient((request) async {
      seen = request;
      return http.Response('ok', 200);
    });
    final client = OneDriveGraphAccessTokenClient(
      accessToken: 'secret',
      inner: inner,
    );
    await client.get(Uri.parse('https://cdn.example.com/file'));
    expect(seen!.headers.containsKey('Authorization'), isFalse);

    await client.get(Uri.parse('https://graph.microsoft.com/v1.0/me'));
    expect(seen!.headers['Authorization'], 'Bearer secret');
    client.close();
  });

  test('listRootChildren pages and maps drive/item metadata', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      if (request.url.path == '/v1.0/me/drive') {
        return http.Response(
          jsonEncode({'id': 'drive-1'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (calls == 2) {
        return http.Response(
          jsonEncode({
            'value': [
              {
                'id': 'folder-1',
                'name': 'Musik',
                'folder': {'childCount': 1},
                'parentReference': {'driveId': 'drive-1'},
                'lastModifiedDateTime': '2024-01-02T03:04:05Z',
              },
              {
                'id': 'file-1',
                'name': 'song.mp3',
                'file': {'mimeType': 'audio/mpeg'},
                'size': 12,
                'parentReference': {'driveId': 'drive-1'},
              },
            ],
            '@odata.nextLink':
                'https://graph.microsoft.com/v1.0/me/drive/root/children?\$skiptoken=p2',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response(
        jsonEncode({
          'value': [
            {
              'id': 'file-2',
              'name': 'more.mp3',
              'file': {'mimeType': 'audio/mpeg'},
              'size': 4,
              'parentReference': {'driveId': 'drive-1'},
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final remote = OneDriveGraphRemote(signedInAuth(), httpClient: client);
    final entries = await remote.listRootChildren();
    expect(entries, hasLength(3));
    expect(entries[0].isDirectory, isTrue);
    expect(entries[0].driveId, 'drive-1');
    expect(entries[1].sizeBytes, 12);
    expect(entries[2].name, 'more.mp3');
  });

  test('listChildren uses drives/{drive}/items/{item}/children', () async {
    final client = MockClient((request) async {
      expect(
        request.url.path,
        '/v1.0/drives/drive-1/items/folder-1/children',
      );
      return http.Response(
        jsonEncode({
          'value': [
            {
              'id': 'nested',
              'name': 'nested.flac',
              'file': {},
              'size': 9,
              'parentReference': {'driveId': 'drive-1'},
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final remote = OneDriveGraphRemote(signedInAuth(), httpClient: client);
    final entries = await remote.listChildren(
      driveId: 'drive-1',
      itemId: 'folder-1',
    );
    expect(entries.single.itemId, 'nested');
    expect(entries.single.sizeBytes, 9);
  });

  test('getFileMeta maps size and rejects folders', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'id': 'file-1',
          'name': 'a.mp3',
          'file': {},
          'size': 42,
          'parentReference': {'driveId': 'drive-1'},
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final remote = OneDriveGraphRemote(signedInAuth(), httpClient: client);
    final meta = await remote.getFileMeta(driveId: 'drive-1', itemId: 'file-1');
    expect(meta.sizeBytes, 42);
    expect(meta.name, 'a.mp3');
  });

  test('downloadFile follows redirect without Graph bearer on CDN host', () async {
    final temp = await Directory.systemTemp.createTemp('tt_od_dl_');
    addTearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });
    final dest = '${temp.path}${Platform.pathSeparator}out.mp3';
    final authHeaders = <String?>[];

    final client = MockClient((request) async {
      authHeaders.add(request.headers['Authorization']);
      if (request.url.host == 'graph.microsoft.com') {
        return http.Response(
          '',
          302,
          headers: {
            'location': 'https://cdn.example.com/preauth/blob',
          },
        );
      }
      expect(request.url.host, 'cdn.example.com');
      return http.Response.bytes([1, 2, 3, 4], 200);
    });

    final remote = OneDriveGraphRemote(signedInAuth(), httpClient: client);
    final progress = <int>[];
    await remote.downloadFile(
      driveId: 'drive-1',
      itemId: 'file-1',
      destinationPath: dest,
      onBytes: progress.add,
    );

    expect(File(dest).readAsBytesSync(), [1, 2, 3, 4]);
    expect(authHeaders[0], startsWith('Bearer '));
    expect(authHeaders[1], isNull);
    expect(progress, isNotEmpty);
    expect(File('$dest.partial').existsSync(), isFalse);
  });

  test('downloadFile cleans partial file after failure', () async {
    final temp = await Directory.systemTemp.createTemp('tt_od_dl_fail_');
    addTearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });
    final dest = '${temp.path}${Platform.pathSeparator}out.mp3';
    final client = MockClient((request) async {
      return http.Response('nope', 500);
    });
    final remote = OneDriveGraphRemote(signedInAuth(), httpClient: client);
    await expectLater(
      remote.downloadFile(
        driveId: 'drive-1',
        itemId: 'file-1',
        destinationPath: dest,
      ),
      throwsA(
        isA<OneDriveGraphHttpException>().having(
          (e) => e.statusCode,
          'status',
          500,
        ),
      ),
    );
    expect(File(dest).existsSync(), isFalse);
    expect(File('$dest.partial').existsSync(), isFalse);
  });

  test('list maps 401/404/429 without leaking response body tokens', () async {
    for (final status in [401, 404, 429]) {
      final client = MockClient((request) async {
        if (request.url.path == '/v1.0/me/drive') {
          return http.Response(
            jsonEncode({'id': 'drive-1'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode({'error': 'Bearer eyJhbGciOiJIUzI1NiJ9.aaa.bbb'}),
          status,
          headers: {'content-type': 'application/json'},
        );
      });
      final remote = OneDriveGraphRemote(signedInAuth(), httpClient: client);
      await expectLater(
        remote.listRootChildren(),
        throwsA(
          isA<OneDriveGraphHttpException>()
              .having((e) => e.statusCode, 'status', status)
              .having(
                (e) => e.toString(),
                'message',
                isNot(contains('eyJ')),
              ),
        ),
      );
    }
  });

  test('malformed list body throws StateError', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/v1.0/me/drive') {
        return http.Response(
          jsonEncode({'id': 'drive-1'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response(
        jsonEncode({'oops': true}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final remote = OneDriveGraphRemote(signedInAuth(), httpClient: client);
    await expectLater(remote.listRootChildren(), throwsStateError);
  });
}
