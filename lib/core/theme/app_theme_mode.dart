import 'package:flutter/material.dart';

/// User-selected appearance mode for Material theme resolution.
///
/// Purpose: Map prefs strings to Flutter [ThemeMode] without coupling UI to
/// persistence details.
/// Usage Context: Theme prefs read/write and [MaterialApp.router] `themeMode`.
enum AppThemeMode {
  /// Follow the platform light/dark setting.
  system,

  /// Always use the light [ThemeData] from the active scheme.
  light,

  /// Always use the dark [ThemeData] from the active scheme.
  dark,
}

/// Prefs / codec helpers for [AppThemeMode].
extension AppThemeModeCodec on AppThemeMode {
  /// Stable prefs token for this mode.
  String get prefsValue => name;

  /// Flutter [ThemeMode] used by [MaterialApp].
  ThemeMode get materialThemeMode => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };

  /// Parses a prefs token; unknown or null values fall back to [AppThemeMode.system].
  static AppThemeMode fromPrefs(String? raw) {
    return switch (raw) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      'system' => AppThemeMode.system,
      _ => AppThemeMode.system,
    };
  }
}
