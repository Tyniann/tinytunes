/// Identifies a cloud storage provider in catalog / cache routing.
///
/// Purpose: Stable persisted tokens (`gdrive`, `onedrive`) without inventing
/// provider-specific [SourceKinds].
/// Usage Context: Locator parsing, cache wipe scoping, later root ownership.
enum CloudProviderId {
  /// Google Drive (`gdrive:` locators).
  googleDrive,

  /// Personal OneDrive (`onedrive:` locators).
  oneDrive;

  /// Canonical token stored in docs / future `cloud_provider` columns.
  String get token => switch (this) {
    CloudProviderId.googleDrive => 'gdrive',
    CloudProviderId.oneDrive => 'onedrive',
  };

  /// Locator value prefix including the trailing colon.
  String get locatorPrefix => '$token:';

  /// Cache subdirectory under `cloud_cache/` for new downloads.
  String get cacheDirectoryName => token;

  /// Parses a persisted [token], or `null` when unknown.
  static CloudProviderId? tryParseToken(String token) {
    return switch (token.trim()) {
      'gdrive' => CloudProviderId.googleDrive,
      'onedrive' => CloudProviderId.oneDrive,
      _ => null,
    };
  }
}
