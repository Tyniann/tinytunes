import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tinytunes/core/legal/legal_urls.dart';
import 'package:tinytunes/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows the About dialog (logo, version, changelog, privacy link).
///
/// Purpose: Give Settings a single polished entry point for app identity and
/// legal transparency before a public GitHub release.
/// Usage Context: Settings → About row.
Future<void> showAboutAppDialog({
  required BuildContext context,
  required PackageInfo packageInfo,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _AboutAppDialog(packageInfo: packageInfo),
  );
}

class _AboutAppDialog extends StatefulWidget {
  const _AboutAppDialog({required this.packageInfo});

  final PackageInfo packageInfo;

  @override
  State<_AboutAppDialog> createState() => _AboutAppDialogState();
}

class _AboutAppDialogState extends State<_AboutAppDialog> {
  late final Future<String> _changelogFuture;

  @override
  void initState() {
    super.initState();
    _changelogFuture = rootBundle.loadString('docs/CHANGELOG.md');
  }

  Future<void> _open(Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsAboutOpenLinkFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final info = widget.packageInfo;
    final versionLabel = info.buildNumber.trim().isEmpty
        ? info.version
        : '${info.version}+${info.buildNumber}';
    final appName = info.appName.trim().isEmpty ? l10n.appTitle : info.appName;
    final privacyUri = Uri.parse(
      LegalUrls.privacyPolicyForLanguage(
        Localizations.localeOf(context).languageCode,
      ),
    );

    return AlertDialog(
      title: Text(l10n.settingsAboutOpen),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/branding/tinytunes_logo.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                appName,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.settingsAboutVersion(versionLabel),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.settingsAboutChangelogHeading,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FutureBuilder<String>(
                    future: _changelogFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || snapshot.data == null) {
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(l10n.settingsAboutChangelogLoadFailed),
                        );
                      }
                      return Scrollbar(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(
                            snapshot.data!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _open(Uri.parse(LegalUrls.githubRepo)),
                  icon: const Icon(Icons.code),
                  label: Text(l10n.settingsAboutGitHub),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => _open(Uri.parse(LegalUrls.changelog)),
                  child: Text(l10n.settingsAboutOpenChangelogOnline),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => _open(privacyUri),
                  child: Text(l10n.settingsAboutPrivacyPolicy),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.settingsAboutClose),
        ),
      ],
    );
  }
}
