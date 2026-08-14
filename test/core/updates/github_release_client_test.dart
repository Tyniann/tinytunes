import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tinytunes/core/updates/github_release.dart';
import 'package:tinytunes/core/updates/github_release_client.dart';
import 'package:tinytunes/core/updates/official_release.dart';

void main() {
  const body = '''
{
  "tag_name": "v1.3.0",
  "html_url": "https://github.com/Tyniann/tinytunes/releases/tag/v1.3.0",
  "assets": [
    {
      "name": "source.zip",
      "content_type": "application/zip",
      "browser_download_url": "https://example.com/source.zip"
    },
    {
      "name": "tinytunes-1.3.0.apk",
      "content_type": "application/vnd.android.package-archive",
      "browser_download_url": "https://github.com/Tyniann/tinytunes/releases/download/v1.3.0/tinytunes-1.3.0.apk",
      "digest": "sha256:abcdef"
    }
  ]
}
''';

  test('fromJson picks first APK asset and sha256 digest', () {
    final release = GithubRelease.fromJson({
      'tag_name': 'v1.3.0',
      'html_url': 'https://github.com/Tyniann/tinytunes/releases/tag/v1.3.0',
      'assets': [
        {
          'name': 'notes.md',
          'content_type': 'text/markdown',
          'browser_download_url': 'https://example.com/notes.md',
        },
        {
          'name': 'tinytunes-1.3.0.apk',
          'content_type': 'application/vnd.android.package-archive',
          'browser_download_url':
              'https://github.com/Tyniann/tinytunes/releases/download/v1.3.0/tinytunes-1.3.0.apk',
          'digest': 'sha256:abcdef',
        },
      ],
    });
    expect(release.tagName, 'v1.3.0');
    expect(
      release.apkDownloadUrl,
      'https://github.com/Tyniann/tinytunes/releases/download/v1.3.0/tinytunes-1.3.0.apk',
    );
    expect(release.apkSha256, 'abcdef');
  });

  test('HTTP client hits latest-release with User-Agent and parses APK', () async {
    http.BaseRequest? seen;
    final httpClient = MockClient((request) async {
      seen = request;
      return http.Response(body, 200);
    });
    final client = HttpGithubReleaseClient(httpClient);
    final release = await client.fetchLatest();

    expect(seen!.url, HttpGithubReleaseClient.latestReleaseUri);
    expect(seen!.headers['user-agent'], OfficialRelease.githubUserAgent);
    expect(seen!.headers['accept'], 'application/vnd.github+json');
    expect(release.tagName, 'v1.3.0');
    expect(release.apkSha256, 'abcdef');
  });

  test('HTTP client throws on non-200', () async {
    final client = HttpGithubReleaseClient(
      MockClient((request) async => http.Response('nope', 404)),
    );
    expect(client.fetchLatest(), throwsA(isA<GithubReleaseFetchException>()));
  });
}
