/// Public HTTPS URLs for legal / about links (Settings About dialog).
///
/// Purpose: Single place for privacy and changelog destinations so the UI and
/// docs stay aligned with the live site / GitHub.
/// Usage Context: [showAboutAppDialog] and README cross-links.
abstract final class LegalUrls {
  /// English privacy policy (authoritative HTML).
  static const privacyPolicyEn =
      'https://blumenlaube.at/apps/tinytunes/privacy-policy.html';

  /// German privacy policy HTML.
  static const privacyPolicyDe =
      'https://blumenlaube.at/apps/tinytunes/privacy-policy.de.html';

  /// Changelog on GitHub (`main`).
  static const changelog =
      'https://github.com/Tyniann/tinytunes/blob/main/docs/CHANGELOG.md';

  /// Public GitHub repository.
  static const githubRepo = 'https://github.com/Tyniann/tinytunes';

  /// Picks EN/DE privacy URL from [localeLanguageCode] (`de` → German).
  static String privacyPolicyForLanguage(String? localeLanguageCode) {
    if (localeLanguageCode?.toLowerCase().startsWith('de') ?? false) {
      return privacyPolicyDe;
    }
    return privacyPolicyEn;
  }
}
