import 'package:tinytunes/features/player/application/player_l10n.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Builds [PlayerL10n] from generated [AppLocalizations].
///
/// Purpose: Keep player reporting localized without [BuildContext] inside the
/// controller.
PlayerL10n playerL10nFrom(AppLocalizations l10n) {
  return PlayerL10n(
    fileMissing: l10n.playerFileMissing,
    loadFailed: l10n.playerLoadFailed,
    restoreSkipped: l10n.playerRestoreSkipped,
    skipBoundReached: l10n.playerSkipBoundReached,
  );
}
