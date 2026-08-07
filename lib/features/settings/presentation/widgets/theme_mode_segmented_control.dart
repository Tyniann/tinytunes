import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/theme/app_theme_mode.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Compact Mode control: System / Light / Dark.
///
/// Purpose: Replace vertical radios with a horizontal M3 [SegmentedButton].
/// Usage Context: Settings Mode section.
class ThemeModeSegmentedControl extends ConsumerWidget {
  /// Creates the mode segmented control.
  const ThemeModeSegmentedControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mode = ref.watch(appThemeModeControllerProvider);

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<AppThemeMode>(
        segments: [
          ButtonSegment<AppThemeMode>(
            value: AppThemeMode.system,
            label: Text(l10n.settingsThemeSystem),
          ),
          ButtonSegment<AppThemeMode>(
            value: AppThemeMode.light,
            label: Text(l10n.settingsThemeLight),
          ),
          ButtonSegment<AppThemeMode>(
            value: AppThemeMode.dark,
            label: Text(l10n.settingsThemeDark),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (selected) {
          final next = selected.single;
          ref.read(appThemeModeControllerProvider.notifier).setMode(next);
        },
        showSelectedIcon: false,
      ),
    );
  }
}
