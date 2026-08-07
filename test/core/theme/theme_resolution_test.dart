import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/theme/dynamic_color_availability.dart';
import 'package:tinytunes/core/theme/theme_catalog.dart';
import 'package:tinytunes/core/theme/theme_preferences.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';

import 'fixed_dynamic_availability.dart';

void main() {
  group('ThemeCatalog', () {
    test('resolve falls back to default for null and unknown ids', () {
      final catalog = ThemeCatalog.standard();
      expect(catalog.resolve(null).id, ThemeCatalog.defaultSchemeId);
      expect(catalog.resolve('missing').id, ThemeCatalog.defaultSchemeId);
    });

    test('highContrast uses contrastLevel 1.0 and differs from default', () {
      final catalog = ThemeCatalog.standard();
      final normal = catalog.resolve(ThemeCatalog.defaultSchemeId);
      final high = catalog.resolve(ThemeCatalog.highContrastSchemeId);

      expect(normal.contrastLevel, 0.0);
      expect(high.contrastLevel, 1.0);
      expect(
        high.colorSchemeFor(Brightness.light).onSurface,
        isNot(normal.colorSchemeFor(Brightness.light).onSurface),
      );
      final normalDark = normal.colorSchemeFor(Brightness.dark);
      final highDark = high.colorSchemeFor(Brightness.dark);
      expect(highDark.primary, ThemeCatalog.defaultSeedColor);
      expect(highDark.surface, ThemeCatalog.highContrastDarkSurface);
      expect(highDark.onSecondaryContainer, ThemeCatalog.defaultSeedColor);
      expect(
        highDark.surface.computeLuminance(),
        lessThan(normalDark.surface.computeLuminance()),
      );
      expect(
        highDark.secondaryContainer.computeLuminance(),
        lessThan(normalDark.secondaryContainer.computeLuminance()),
      );
    });

    test('pickerSchemeIds includes dynamic only when available', () {
      final catalog = ThemeCatalog.standard();
      expect(catalog.pickerSchemeIds(dynamicAvailable: false), [
        ThemeCatalog.defaultSchemeId,
        ThemeCatalog.highContrastSchemeId,
      ]);
      expect(catalog.pickerSchemeIds(dynamicAvailable: true), [
        ThemeCatalog.defaultSchemeId,
        ThemeCatalog.highContrastSchemeId,
        ThemeCatalog.dynamicSchemeId,
      ]);
    });
  });

  group('theme resolution providers', () {
    test('dynamic unresolved keeps prefs and uses default themes', () async {
      SharedPreferences.setMockInitialValues({
        ThemePreferences.schemeIdKey: ThemeCatalog.dynamicSchemeId,
      });
      final localPrefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(localPrefs),
          dynamicColorAvailabilityControllerProvider.overrideWith(
            () => FixedDynamicAvailability(DynamicColorAvailability.unresolved),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(appThemeSchemeIdControllerProvider),
        ThemeCatalog.dynamicSchemeId,
      );
      expect(
        container.read(lightThemeDataProvider).colorScheme.primary,
        ThemeCatalog.standard()
            .resolve(ThemeCatalog.defaultSchemeId)
            .lightTheme
            .colorScheme
            .primary,
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        localPrefs.getString(ThemePreferences.schemeIdKey),
        ThemeCatalog.dynamicSchemeId,
      );
    });

    test('dynamic resolved unavailable rewrites prefs to default', () async {
      SharedPreferences.setMockInitialValues({
        ThemePreferences.schemeIdKey: ThemeCatalog.dynamicSchemeId,
      });
      final localPrefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(localPrefs),
          dynamicColorAvailabilityControllerProvider.overrideWith(
            () =>
                FixedDynamicAvailability(DynamicColorAvailability.unavailable),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(lightThemeDataProvider);
      container.read(appThemeSchemeIdControllerProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(appThemeSchemeIdControllerProvider),
        ThemeCatalog.defaultSchemeId,
      );
      expect(
        localPrefs.getString(ThemePreferences.schemeIdKey),
        ThemeCatalog.defaultSchemeId,
      );
    });

    test('dynamic resolved with schemes uses platform primary', () async {
      final fakeLight = ColorScheme.fromSeed(
        seedColor: const Color(0xFF1122FF),
        brightness: Brightness.light,
      );
      final fakeDark = ColorScheme.fromSeed(
        seedColor: const Color(0xFF1122FF),
        brightness: Brightness.dark,
      );
      SharedPreferences.setMockInitialValues({
        ThemePreferences.schemeIdKey: ThemeCatalog.dynamicSchemeId,
      });
      final localPrefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(localPrefs),
          dynamicColorAvailabilityControllerProvider.overrideWith(
            () => FixedDynamicAvailability(
              DynamicColorAvailability(
                resolved: true,
                light: fakeLight,
                dark: fakeDark,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(lightThemeDataProvider).colorScheme.primary,
        fakeLight.primary,
      );
      expect(
        container.read(darkThemeDataProvider).colorScheme.primary,
        fakeDark.primary,
      );
    });
  });
}
