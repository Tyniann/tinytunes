/// Identity of the official TinyTunes GitHub APK.
///
/// Purpose: Single place for the GitHub repo the app checks and the Android
/// application id + release signing hash that must both match before any
/// GitHub ping (forks and debug builds stay offline for this feature).
/// Usage Context: [HttpGithubReleaseClient]; [isOfficialApk].
abstract final class OfficialRelease {
  /// GitHub user/org that publishes official releases.
  static const githubOwner = 'Tyniann';

  /// GitHub repository name.
  static const githubRepo = 'tinytunes';

  /// Android `applicationId` of official builds.
  static const androidApplicationId = 'at.blumenlaube.tinytunes';

  /// Official **release** signing-certificate hash (Base64 of SHA-1).
  ///
  /// Same public value as the Entra Android redirect hash. Debug keystore
  /// hashes are not official — `flutter run` must not contact GitHub.
  static const androidReleaseSignatureHash = 'yA+8T1x4a9pYEu1mYe58Quq7f5Y=';

  /// `User-Agent` for GitHub REST (GitHub rejects requests without one).
  static const githubUserAgent =
      'TinyTunes (+https://github.com/Tyniann/tinytunes)';

  /// Whether this install is the official GitHub APK (package + release cert).
  ///
  /// Package name alone is not enough: this repo’s application id is shared
  /// with forks until they change it.
  static bool isOfficialApk({
    required String packageName,
    required String? signatureSha1Base64,
  }) {
    return packageName == androidApplicationId &&
        signatureSha1Base64 == androidReleaseSignatureHash;
  }
}
