import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/theme/app_theme_mode.dart';
import 'package:tinytunes/core/theme/theme_catalog.dart';
import 'package:tinytunes/core/theme/theme_preferences.dart';

void main() {
  group('AppThemeModeCodec', () {
    test('fromPrefs falls back to system for null and invalid values', () {
      expect(AppThemeModeCodec.fromPrefs(null), AppThemeMode.system);
      expect(AppThemeModeCodec.fromPrefs(''), AppThemeMode.system);
      expect(AppThemeModeCodec.fromPrefs('nope'), AppThemeMode.system);
    });

    test('fromPrefs parses known tokens', () {
      expect(AppThemeModeCodec.fromPrefs('system'), AppThemeMode.system);
      expect(AppThemeModeCodec.fromPrefs('light'), AppThemeMode.light);
      expect(AppThemeModeCodec.fromPrefs('dark'), AppThemeMode.dark);
    });

    test('materialThemeMode maps to Flutter ThemeMode', () {
      expect(AppThemeMode.system.materialThemeMode, ThemeMode.system);
      expect(AppThemeMode.light.materialThemeMode, ThemeMode.light);
      expect(AppThemeMode.dark.materialThemeMode, ThemeMode.dark);
    });
  });

  group('ThemeCatalog', () {
    test('v1 default scheme builds light and dark ThemeData', () {
      final catalog = ThemeCatalog.v1();
      final scheme = catalog.resolve(ThemeCatalog.defaultSchemeId);

      expect(scheme.id, ThemeCatalog.defaultSchemeId);
      expect(scheme.lightTheme.brightness, Brightness.light);
      expect(scheme.darkTheme.brightness, Brightness.dark);
      expect(scheme.lightTheme.useMaterial3, isTrue);
      expect(scheme.darkTheme.useMaterial3, isTrue);
    });

    test('resolve falls back to default for unknown scheme id', () {
      final catalog = ThemeCatalog.v1();
      final scheme = catalog.resolve('missing');

      expect(scheme.id, ThemeCatalog.defaultSchemeId);
      expect(identical(scheme, catalog.resolve(null)), isTrue);
    });
  });

  group('ThemePreferences', () {
    test('readMode and readSchemeId use fallbacks for missing keys', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = ThemePreferences(await SharedPreferences.getInstance());

      expect(prefs.readMode(), AppThemeMode.system);
      expect(prefs.readSchemeId(), ThemeCatalog.defaultSchemeId);
    });

    test('readMode falls back for invalid stored mode', () async {
      SharedPreferences.setMockInitialValues({
        ThemePreferences.modeKey: 'not-a-mode',
        ThemePreferences.schemeIdKey: 'default',
      });
      final prefs = ThemePreferences(await SharedPreferences.getInstance());

      expect(prefs.readMode(), AppThemeMode.system);
      expect(prefs.readSchemeId(), 'default');
    });

    test('writeMode and writeSchemeId round-trip', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = ThemePreferences(await SharedPreferences.getInstance());

      await prefs.writeMode(AppThemeMode.dark);
      await prefs.writeSchemeId('default');

      expect(prefs.readMode(), AppThemeMode.dark);
      expect(prefs.readSchemeId(), 'default');
    });
  });
}
