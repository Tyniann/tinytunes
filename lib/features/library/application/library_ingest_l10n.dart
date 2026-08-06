/// Localized (or test) copy passed into [LibraryIngestController] operations.
///
/// Purpose: Keep [MessageReporter] call sites free of [BuildContext] while still
/// shipping localized strings from the UI layer.
class LibraryIngestL10n {
  /// Creates ingest copy strings.
  const LibraryIngestL10n({
    required this.scanStarted,
    required this.scanComplete,
    required this.scanCancelled,
    required this.scanFailed,
    required this.rootRevoked,
    required this.forgetComplete,
    required this.forgetFailed,
    required this.forgetAllComplete,
    required this.forgetAllFailed,
    required this.cloudSignInRequired,
  });

  /// English defaults for unit tests.
  const LibraryIngestL10n.english()
    : scanStarted = 'Scanning library…',
      scanComplete = 'Library scan complete.',
      scanCancelled = 'Library scan cancelled.',
      scanFailed = 'Library scan failed.',
      rootRevoked = 'Folder access was revoked.',
      forgetComplete = 'Folder forgotten.',
      forgetFailed = 'Folder removed locally, but access release failed.',
      forgetAllComplete = 'All folders forgotten.',
      forgetAllFailed =
          'Folders removed locally, but some access releases failed.',
      cloudSignInRequired = 'Sign in to Google Drive in Settings first.';

  /// `library.scan.started` toast/body.
  final String scanStarted;

  /// `library.scan.complete` toast/body.
  final String scanComplete;

  /// `library.scan.cancelled` toast/body.
  final String scanCancelled;

  /// `library.scan.failed` toast/body.
  final String scanFailed;

  /// `library.root.revoked` toast/body.
  final String rootRevoked;

  /// `library.forget.complete` toast/body.
  final String forgetComplete;

  /// `library.forget.failed` toast/body.
  final String forgetFailed;

  /// `library.forget_all.complete` toast/body.
  final String forgetAllComplete;

  /// `library.forget_all.failed` toast/body.
  final String forgetAllFailed;

  /// `library.cloud.sign_in_required` toast/body.
  final String cloudSignInRequired;
}
