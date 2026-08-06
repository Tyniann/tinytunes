/// Frozen message [code] values for library ingest.
///
/// Purpose: Stable refs for session messages / toasts across UI and scanner.
abstract final class LibraryMessageCodes {
  /// Scan or re-scan started.
  static const scanStarted = 'library.scan.started';

  /// Scan finished successfully.
  static const scanComplete = 'library.scan.complete';

  /// User cancelled an in-flight scan.
  static const scanCancelled = 'library.scan.cancelled';

  /// Scan aborted due to listing/walk failure.
  static const scanFailed = 'library.scan.failed';

  /// Persisted SAF grant missing for a known root.
  static const rootRevoked = 'library.root.revoked';

  /// Forget folder DB cascade succeeded (release may still fail separately).
  static const forgetComplete = 'library.forget.complete';

  /// Grant release failed after DB delete.
  static const forgetFailed = 'library.forget.failed';

  /// Forget-all finished; every root removed from the catalog.
  static const forgetAllComplete = 'library.forget_all.complete';

  /// Forget-all removed roots, but one or more SAF releases failed.
  static const forgetAllFailed = 'library.forget_all.failed';

  /// Cloud add attempted while signed out of Google.
  static const cloudSignInRequired = 'library.cloud.sign_in_required';
}
