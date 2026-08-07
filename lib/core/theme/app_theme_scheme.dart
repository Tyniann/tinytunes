import 'package:flutter/material.dart';

/// Named static palette family that supplies light and dark [ThemeData].
///
/// Purpose: Keep brand colors behind a catalog entry so schemes can be added
/// without rewriting feature widgets.
/// Usage Context: [ThemeCatalog] resolution for [MaterialApp.router] when the
/// selected scheme is not Dynamic.
/// Key Params: [id] — stable prefs key; [seedColor] — Material 3 seed;
/// [contrastLevel] — Material contrast (`0.0` normal, `1.0` high);
/// [darkPrimary] / [darkSurface] — optional dark-only palette anchors.
class AppThemeScheme {
  /// Creates a scheme that builds Material 3 themes from [seedColor].
  const AppThemeScheme({
    required this.id,
    required this.seedColor,
    this.contrastLevel = 0.0,
    this.darkPrimary,
    this.darkSurface,
  });

  /// Stable identifier stored in prefs (e.g. `default`).
  final String id;

  /// Seed color for [ColorScheme.fromSeed].
  final Color seedColor;

  /// Contrast between color pairs (`0.0` default, `1.0` Material high).
  final double contrastLevel;

  /// Optional dark-mode primary accent override.
  final Color? darkPrimary;

  /// Optional darkest dark-mode surface anchor.
  final Color? darkSurface;

  /// Builds the [ColorScheme] for [brightness].
  ColorScheme colorSchemeFor(Brightness brightness) {
    final generated = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      contrastLevel: contrastLevel,
    );
    if (brightness != Brightness.dark) return generated;
    final surface = darkSurface;
    final primary = darkPrimary;
    if (surface == null && primary == null) return generated;
    final accentContainer = _liftSurface(surface, 0.13);

    return generated.copyWith(
      primary: primary,
      onPrimary: primary == null ? null : Colors.black,
      primaryContainer: accentContainer,
      onPrimaryContainer: primary,
      secondaryContainer: accentContainer,
      onSecondaryContainer: primary,
      tertiaryContainer: accentContainer,
      onTertiaryContainer: primary,
      surface: surface,
      surfaceDim: surface,
      surfaceContainerLowest: surface,
      surfaceContainerLow: _liftSurface(surface, 0.03),
      surfaceContainer: _liftSurface(surface, 0.06),
      surfaceContainerHigh: _liftSurface(surface, 0.09),
      surfaceContainerHighest: _liftSurface(surface, 0.13),
      surfaceBright: _liftSurface(surface, 0.18),
      surfaceTint: primary,
    );
  }

  /// Builds the light [ThemeData] for this scheme.
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorSchemeFor(Brightness.light),
  );

  /// Builds the dark [ThemeData] for this scheme.
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorSchemeFor(Brightness.dark),
  );
}

Color? _liftSurface(Color? surface, double amount) =>
    surface == null ? null : Color.lerp(surface, Colors.white, amount);
