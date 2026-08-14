import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tinytunes/core/updates/github_release.dart';
import 'package:tinytunes/core/updates/official_release.dart';

/// Fetches the latest GitHub release for TinyTunes.
///
/// Purpose: Isolate HTTP so tests inject a fake and production can fail
/// closed without blocking app start.
/// Usage Context: [UpdateCheckController] scheduled and manual checks.
abstract class GithubReleaseClient {
  /// Latest non-draft, non-prerelease release, or throws on failure.
  Future<GithubRelease> fetchLatest();
}

/// `GET /repos/{owner}/{repo}/releases/latest` against GitHub's REST API.
class HttpGithubReleaseClient implements GithubReleaseClient {
  /// Creates a client using [httpClient] (caller owns close).
  HttpGithubReleaseClient(this._httpClient);

  static const _timeout = Duration(seconds: 10);

  final http.Client _httpClient;

  /// Public latest-release API URL for the official repo.
  static Uri get latestReleaseUri => Uri.https(
    'api.github.com',
    '/repos/${OfficialRelease.githubOwner}/${OfficialRelease.githubRepo}/releases/latest',
  );

  @override
  Future<GithubRelease> fetchLatest() async {
    final response = await _httpClient
        .get(
          latestReleaseUri,
          headers: const {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
            'User-Agent': OfficialRelease.githubUserAgent,
          },
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw GithubReleaseFetchException(
        'GitHub latest release HTTP ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const GithubReleaseFetchException(
        'GitHub latest release JSON was not an object',
      );
    }
    final release = GithubRelease.fromJson(Map<String, dynamic>.from(decoded));
    if (release.tagName.isEmpty || release.htmlUrl.isEmpty) {
      throw const GithubReleaseFetchException(
        'GitHub latest release missing tag_name or html_url',
      );
    }
    return release;
  }
}

/// Thrown when the GitHub latest-release request cannot be used.
class GithubReleaseFetchException implements Exception {
  /// Creates a fetch failure with [message] for logs.
  const GithubReleaseFetchException(this.message);

  /// Short reason (HTTP status, parse, timeout).
  final String message;

  @override
  String toString() => 'GithubReleaseFetchException: $message';
}
