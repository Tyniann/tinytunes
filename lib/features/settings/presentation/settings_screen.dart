import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/settings/package_info_provider.dart';
import 'package:tinytunes/core/theme/app_theme_mode.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Daily-driver Settings: theme mode and About.
///
/// Purpose: Let the user pick System/Light/Dark and see app name + version.
/// Usage Context: Route `/settings` via [SettingsRoute].
/// Key Params: none — reads [appThemeModeControllerProvider] and
/// [packageInfoProvider].
class SettingsScreen extends ConsumerWidget {
  /// Creates the Settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mode = ref.watch(appThemeModeControllerProvider);
    final packageInfo = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.settingsAppearanceSection),
          ),
          RadioGroup<AppThemeMode>(
            groupValue: mode,
            onChanged: (value) {
              if (value == null) return;
              ref.read(appThemeModeControllerProvider.notifier).setMode(value);
            },
            child: Column(
              children: [
                RadioListTile<AppThemeMode>(
                  title: Text(l10n.settingsThemeSystem),
                  value: AppThemeMode.system,
                ),
                RadioListTile<AppThemeMode>(
                  title: Text(l10n.settingsThemeLight),
                  value: AppThemeMode.light,
                ),
                RadioListTile<AppThemeMode>(
                  title: Text(l10n.settingsThemeDark),
                  value: AppThemeMode.dark,
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.settingsAboutSection),
          ),
          packageInfo.when(
            data: (info) => ListTile(
              title: Text(
                info.appName.trim().isEmpty ? l10n.appTitle : info.appName,
              ),
              subtitle: Text(l10n.settingsAboutVersion(info.version)),
            ),
            loading: () => ListTile(
              title: Text(l10n.appTitle),
              subtitle: Text(l10n.settingsAboutVersion('…')),
            ),
            error: (_, _) => ListTile(
              title: Text(l10n.appTitle),
              subtitle: Text(l10n.settingsAboutVersion('—')),
            ),
          ),
        ],
      ),
    );
  }
}
