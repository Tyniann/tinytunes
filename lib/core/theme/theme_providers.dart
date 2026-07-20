import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/theme/app_theme_mode.dart';
import 'package:tinytunes/core/theme/app_theme_scheme.dart';
import 'package:tinytunes/core/theme/theme_catalog.dart';
import 'package:tinytunes/core/theme/theme_preferences.dart';

part 'theme_providers.g.dart';

/// Injected [SharedPreferences] overridden in `main` after bootstrap.
///
/// Purpose: Keep theme reads synchronous; never call `getInstance` from
/// providers. Tests override with [SharedPreferences.setMockInitialValues].
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw StateError(
    'sharedPreferencesProvider must be overridden with an instance from main().',
  );
}

/// Theme prefs wrapper around the injected [SharedPreferences].
@Riverpod(keepAlive: true)
ThemePreferences themePreferences(Ref ref) {
  return ThemePreferences(ref.watch(sharedPreferencesProvider));
}

/// v1 [ThemeCatalog] (single `default` scheme).
@Riverpod(keepAlive: true)
ThemeCatalog themeCatalog(Ref ref) => ThemeCatalog.v1();

/// Persisted appearance mode with write API for Settings and tests.
@Riverpod(keepAlive: true)
class AppThemeModeController extends _$AppThemeModeController {
  @override
  AppThemeMode build() => ref.watch(themePreferencesProvider).readMode();

  /// Persists and applies [mode].
  Future<void> setMode(AppThemeMode mode) async {
    await ref.read(themePreferencesProvider).writeMode(mode);
    state = mode;
  }
}

/// Persisted scheme id with write API for later scheme pickers.
@Riverpod(keepAlive: true)
class AppThemeSchemeIdController extends _$AppThemeSchemeIdController {
  @override
  String build() => ref.watch(themePreferencesProvider).readSchemeId();

  /// Persists and applies [schemeId].
  Future<void> setSchemeId(String schemeId) async {
    await ref.read(themePreferencesProvider).writeSchemeId(schemeId);
    state = schemeId;
  }
}

/// Active [AppThemeScheme] resolved from catalog + scheme id.
@Riverpod(keepAlive: true)
AppThemeScheme activeThemeScheme(Ref ref) {
  final catalog = ref.watch(themeCatalogProvider);
  final schemeId = ref.watch(appThemeSchemeIdControllerProvider);
  return catalog.resolve(schemeId);
}

/// Light [ThemeData] for [MaterialApp.router].
@Riverpod(keepAlive: true)
ThemeData lightThemeData(Ref ref) => ref.watch(activeThemeSchemeProvider).lightTheme;

/// Dark [ThemeData] for [MaterialApp.router].
@Riverpod(keepAlive: true)
ThemeData darkThemeData(Ref ref) => ref.watch(activeThemeSchemeProvider).darkTheme;

/// Flutter [ThemeMode] derived from [AppThemeModeController].
@Riverpod(keepAlive: true)
ThemeMode materialThemeMode(Ref ref) =>
    ref.watch(appThemeModeControllerProvider).materialThemeMode;
