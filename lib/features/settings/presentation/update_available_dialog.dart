import 'package:flutter/material.dart';
import 'package:tinytunes/core/updates/github_release.dart';
import 'package:tinytunes/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Result of [showUpdateAvailableDialog].
enum UpdateAvailableChoice {
  /// User chose Later (or dismissed the barrier).
  later,

  /// User opened the GitHub release page.
  opened,
}

/// Shows a dialog with the newer GitHub release and a link to it.
///
/// Purpose: Tell the user a newer official release exists without downloading
/// the APK in v1. Usage Context: [UpdateCheckBinder] after a scheduled check;
/// About after a manual check.
/// Key Params: [release] — latest GitHub release; [installedVersion] — current
/// [PackageInfo.version].
Future<UpdateAvailableChoice> showUpdateAvailableDialog({
  required BuildContext context,
  required GithubRelease release,
  required String installedVersion,
  Future<bool> Function(Uri uri)? launch,
}) async {
  final opened = await showDialog<bool>(
    context: context,
    builder: (context) => _UpdateAvailableDialog(
      release: release,
      installedVersion: installedVersion,
      launch: launch ?? (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
    ),
  );
  return opened == true
      ? UpdateAvailableChoice.opened
      : UpdateAvailableChoice.later;
}

class _UpdateAvailableDialog extends StatelessWidget {
  const _UpdateAvailableDialog({
    required this.release,
    required this.installedVersion,
    required this.launch,
  });

  final GithubRelease release;
  final String installedVersion;
  final Future<bool> Function(Uri uri) launch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.updateAvailableTitle),
      content: Text(
        l10n.updateAvailableBody(release.tagName, installedVersion),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.updateAvailableLater),
        ),
        TextButton(
          onPressed: () async {
            final uri = Uri.tryParse(release.htmlUrl);
            if (uri != null) {
              await launch(uri);
            }
            if (context.mounted) Navigator.of(context).pop(true);
          },
          child: Text(l10n.updateAvailableOpen),
        ),
      ],
    );
  }
}
