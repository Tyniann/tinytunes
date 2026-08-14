import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/theme/app_theme_mode.dart';
import 'package:tinytunes/core/theme/theme_catalog.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Horizontal color-scheme chips with swatches + labels.
///
/// Purpose: Let the user pick a named color scheme (Lucky Lime, Electric Blue,
/// Ember Signal, High contrast, Dynamic when available) with visible names
/// and preview dots.
/// Usage Context: Settings Color scheme section.
class ColorSchemePicker extends ConsumerWidget {
  /// Creates the scheme picker row.
  const ColorSchemePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final catalog = ref.watch(themeCatalogProvider);
    final selectedId = ref.watch(appThemeSchemeIdControllerProvider);
    final availability = ref.watch(dynamicColorAvailabilityControllerProvider);
    final mode = ref.watch(appThemeModeControllerProvider);
    final brightness = _effectiveBrightness(context, mode);
    final ids = catalog.pickerSchemeIds(
      dynamicAvailable: availability.isAvailable,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final columns = constraints.maxWidth >= 560 ? 3 : 2;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final id in ids)
              SizedBox(
                width: width,
                child: _SchemePreviewChip(
                  schemeId: id,
                  label: _labelFor(l10n, id),
                  selected: selectedId == id,
                  colorScheme: previewColorScheme(
                    catalog: catalog,
                    schemeId: id,
                    brightness: brightness,
                    availability: availability,
                  ),
                  onTap: () {
                    ref
                        .read(appThemeSchemeIdControllerProvider.notifier)
                        .setSchemeId(id);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  static String _labelFor(AppLocalizations l10n, String schemeId) {
    return switch (schemeId) {
      ThemeCatalog.electricBlueSchemeId => l10n.settingsSchemeElectricBlue,
      ThemeCatalog.emberSignalSchemeId => l10n.settingsSchemeEmberSignal,
      ThemeCatalog.highContrastSchemeId => l10n.settingsSchemeHighContrast,
      ThemeCatalog.dynamicSchemeId => l10n.settingsSchemeDynamic,
      _ => l10n.settingsSchemeDefault,
    };
  }

  static Brightness _effectiveBrightness(
    BuildContext context,
    AppThemeMode mode,
  ) {
    return switch (mode) {
      AppThemeMode.light => Brightness.light,
      AppThemeMode.dark => Brightness.dark,
      AppThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
  }
}

/// Single scheme chip: three preview dots + label.
class _SchemePreviewChip extends StatelessWidget {
  const _SchemePreviewChip({
    required this.schemeId,
    required this.label,
    required this.selected,
    required this.colorScheme,
    required this.onTap,
  });

  final String schemeId;
  final String label;
  final bool selected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor =
        selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: selected ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SwatchDot(color: colorScheme.primary),
                      const SizedBox(width: 6),
                      _SwatchDot(color: colorScheme.secondary),
                      const SizedBox(width: 6),
                      _SwatchDot(color: colorScheme.surface),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwatchDot extends StatelessWidget {
  const _SwatchDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

/// Shows the Dynamic scheme explanation dialog.
///
/// Purpose: Explain Material You without stealing the chip select gesture.
/// Usage Context: Info icon on the Color scheme section header when Dynamic
/// is available.
Future<void> showDynamicSchemeInfoDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.settingsSchemeDynamicInfoTitle),
      content: Text(l10n.settingsSchemeDynamicInfoBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.settingsSchemeDynamicInfoClose),
        ),
      ],
    ),
  );
}
