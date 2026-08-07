import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/cloud/cloud_cache_budget.dart';
import 'package:tinytunes/core/cloud/cloud_providers.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/core/settings/package_info_provider.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:tinytunes/features/settings/presentation/about_app_dialog.dart';
import 'package:tinytunes/features/settings/presentation/widgets/color_scheme_picker.dart';
import 'package:tinytunes/features/settings/presentation/widgets/theme_mode_segmented_control.dart';
import 'package:tinytunes/l10n/app_localizations.dart';
import 'package:tinytunes/shared/widgets/google_branding.dart';

/// Daily-driver Settings: theme, Google Drive account/cache, and About.
///
/// Purpose: Let the user pick Mode and Color scheme, manage Drive sign-in and
/// cloud cache budget, and open the About dialog (logo, version, changelog,
/// privacy).
/// Usage Context: Route `/settings` via [SettingsRoute].
class SettingsScreen extends ConsumerWidget {
  /// Creates the Settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final packageInfo = ref.watch(packageInfoProvider);
    final drive = ref.watch(googleDriveSessionControllerProvider);
    final driveCtrl = ref.read(googleDriveSessionControllerProvider.notifier);
    final dynamicAvailable = ref
        .watch(dynamicColorAvailabilityControllerProvider)
        .isAvailable;
    final aboutVersion = switch (packageInfo) {
      AsyncData(:final value) => value.version,
      AsyncError() => '—',
      _ => '…',
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(title: Text(l10n.settingsModeSection)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ThemeModeSegmentedControl(),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: Text(l10n.settingsColorSchemeSection),
            trailing: dynamicAvailable
                ? IconButton(
                    tooltip: l10n.settingsSchemeDynamicInfoTitle,
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => showDynamicSchemeInfoDialog(context),
                  )
                : null,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: ColorSchemePicker(),
          ),
          const Divider(),
          ListTile(
            leading: const GoogleDriveMark(size: 28),
            title: Text(l10n.settingsGoogleDriveSection),
          ),
          if (drive.account != null)
            ListTile(
              title: Text(
                l10n.settingsGoogleDriveSignedInAs(drive.account!.email),
              ),
            ),
          if (!drive.isSignedIn)
            SignInWithGoogleButton(
              label: l10n.settingsGoogleDriveSignIn,
              enabled: !drive.busy,
              onPressed: driveCtrl.signIn,
            )
          else
            ListTile(
              title: Text(l10n.settingsGoogleDriveSignOut),
              enabled: !drive.busy,
              onTap: driveCtrl.signOut,
            ),
          _CloudCacheBudgetSlider(enabled: !drive.busy),
          ListTile(
            title: Text(l10n.settingsCloudCacheClear),
            enabled: !drive.busy,
            onTap: () => _confirmClearCloudCache(context, ref, l10n),
          ),
          if (drive.lastError != null)
            ListTile(
              title: Text(
                drive.lastError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton.tonal(
              onPressed: () {
                final info = packageInfo.asData?.value;
                if (info == null) return;
                showAboutAppDialog(context: context, packageInfo: info);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(64),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                alignment: Alignment.centerLeft,
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.settingsAboutOpen),
                        Text(
                          l10n.settingsAboutVersion(aboutVersion),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearCloudCache(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsCloudCacheClearTitle),
        content: Text(l10n.settingsCloudCacheClearBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.settingsCloudCacheClear),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(googleDriveSessionControllerProvider.notifier)
        .clearCloudCache();
    ref
        .read(messageReporterProvider)
        .reportInfo(
          code: 'cloud.cache.cleared',
          message: l10n.settingsCloudCacheCleared,
        );
  }
}

/// Cloud cache budget slider that commits on finger-up only.
///
/// Purpose: Avoid prefs writes / LRU eviction on every drag tick.
/// Usage Context: Settings Google Drive section.
class _CloudCacheBudgetSlider extends ConsumerStatefulWidget {
  const _CloudCacheBudgetSlider({required this.enabled});

  final bool enabled;

  @override
  ConsumerState<_CloudCacheBudgetSlider> createState() =>
      _CloudCacheBudgetSliderState();
}

class _CloudCacheBudgetSliderState
    extends ConsumerState<_CloudCacheBudgetSlider> {
  int? _draftBytes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final persisted = ref.watch(cloudCacheBudgetControllerProvider);
    final value = _draftBytes ?? persisted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.settingsCloudCacheLimit(CloudCacheBudget.formatGbLabel(value)),
          ),
          Slider(
            min: CloudCacheBudget.minBytes.toDouble(),
            max: CloudCacheBudget.maxBytes.toDouble(),
            divisions: CloudCacheBudget.sliderDivisions,
            value: value.toDouble(),
            onChanged: widget.enabled
                ? (v) => setState(() => _draftBytes = v.round())
                : null,
            onChangeEnd: widget.enabled
                ? (v) async {
                    final snapped = CloudCacheBudget.clampAndSnap(v.round());
                    await ref
                        .read(cloudCacheBudgetControllerProvider.notifier)
                        .setBudgetBytes(snapped);
                    if (mounted) setState(() => _draftBytes = null);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
