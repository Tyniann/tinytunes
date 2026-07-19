import 'package:flutter/material.dart';

/// Named palette family that supplies light and dark [ThemeData].
///
/// Purpose: Keep brand colors behind a catalog entry so later schemes can be
/// added without rewriting feature widgets.
/// Usage Context: [ThemeCatalog] resolution for [MaterialApp.router].
/// Key Params: [id] — stable prefs key; [seedColor] — Material 3 seed.
class AppThemeScheme {
  /// Creates a scheme that builds Material 3 themes from [seedColor].
  const AppThemeScheme({
    required this.id,
    required this.seedColor,
  });

  /// Stable identifier stored in prefs (e.g. `default`).
  final String id;

  /// Seed color for [ColorScheme.fromSeed].
  final Color seedColor;

  /// Builds the light [ThemeData] for this scheme.
  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
      );

  /// Builds the dark [ThemeData] for this scheme.
  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      );
}
