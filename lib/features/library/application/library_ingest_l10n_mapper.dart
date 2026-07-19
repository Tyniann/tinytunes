import 'package:tinytunes/features/library/application/library_ingest_l10n.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Builds [LibraryIngestL10n] from generated [AppLocalizations].
///
/// Purpose: Keep ingest reporting localized without [BuildContext] inside the
/// scanner.
LibraryIngestL10n libraryIngestL10nFrom(AppLocalizations l10n) {
  return LibraryIngestL10n(
    scanStarted: l10n.libraryScanStarted,
    scanComplete: l10n.libraryScanComplete,
    scanCancelled: l10n.libraryScanCancelled,
    scanFailed: l10n.libraryScanFailed,
    rootRevoked: l10n.libraryRootRevoked,
    forgetComplete: l10n.libraryForgetComplete,
    forgetFailed: l10n.libraryForgetFailed,
  );
}
