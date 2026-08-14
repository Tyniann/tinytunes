import 'package:flutter/foundation.dart';

/// One GitHub Releases payload used for the in-app update check.
///
/// Purpose: Carry the latest tag, release page, and APK asset metadata so v1
/// can link out and a later in-app install can reuse the same parse.
/// Usage Context: [GithubReleaseClient.fetchLatest]; prompt UI uses [htmlUrl].
@immutable
class GithubRelease {
  /// Creates a parsed latest-release snapshot.
  const GithubRelease({
    required this.tagName,
    required this.htmlUrl,
    this.apkDownloadUrl,
    this.apkSha256,
  });

  /// Parses GitHub `GET /releases/latest` JSON.
  ///
  /// Picks the first `.apk` asset (by name or Android package content type).
  /// [apkSha256] comes from the asset `digest` field when it is `sha256:…`.
  factory GithubRelease.fromJson(Map<String, dynamic> json) {
    final tagName = json['tag_name'] as String? ?? '';
    final htmlUrl = json['html_url'] as String? ?? '';
    String? apkUrl;
    String? sha256;
    final assets = json['assets'];
    if (assets is List) {
      for (final raw in assets) {
        if (raw is! Map) continue;
        final name = (raw['name'] as String?) ?? '';
        final type = (raw['content_type'] as String?) ?? '';
        final isApk =
            name.toLowerCase().endsWith('.apk') ||
            type == 'application/vnd.android.package-archive';
        if (!isApk) continue;
        apkUrl = raw['browser_download_url'] as String?;
        sha256 = _sha256FromDigest(raw['digest'] as String?);
        break;
      }
    }
    return GithubRelease(
      tagName: tagName,
      htmlUrl: htmlUrl,
      apkDownloadUrl: apkUrl,
      apkSha256: sha256,
    );
  }

  /// GitHub `tag_name` (often `v1.2.0`).
  final String tagName;

  /// Browser URL for the release page.
  final String htmlUrl;

  /// Direct APK asset URL when GitHub lists one (unused in v1 UI).
  final String? apkDownloadUrl;

  /// SHA-256 of the APK asset when GitHub provides `digest` (unused in v1 UI).
  final String? apkSha256;

  @override
  bool operator ==(Object other) =>
      other is GithubRelease &&
      other.tagName == tagName &&
      other.htmlUrl == htmlUrl &&
      other.apkDownloadUrl == apkDownloadUrl &&
      other.apkSha256 == apkSha256;

  @override
  int get hashCode => Object.hash(tagName, htmlUrl, apkDownloadUrl, apkSha256);

  static String? _sha256FromDigest(String? digest) {
    if (digest == null) return null;
    const prefix = 'sha256:';
    if (!digest.startsWith(prefix)) return null;
    final hex = digest.substring(prefix.length).trim();
    return hex.isEmpty ? null : hex;
  }
}
