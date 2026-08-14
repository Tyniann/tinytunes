import 'package:flutter/material.dart';

/// Named static palette family that supplies light and dark [ThemeData].
///
/// Purpose: Keep brand colors behind a catalog entry so schemes can be added
/// without rewriting feature widgets.
/// Usage Context: [ThemeCatalog] resolution for [MaterialApp.router] when the
/// selected scheme is not Dynamic.
/// Key Params: [id] — stable prefs key; [seedColor] — Material 3 seed;
/// [contrastLevel] — Material contrast (`0.0` normal, `1.0` high);
/// [darkPrimary] / [darkSurface] / [lightPrimary] / [lightSurface] /
/// [lightInverseSurface] — optional palette anchors so catalog hues survive
/// `fromSeed`.
class AppThemeScheme {
  /// Creates a scheme that builds Material 3 themes from [seedColor].
  const AppThemeScheme({
    required this.id,
    required this.seedColor,
    this.contrastLevel = 0.0,
    this.darkPrimary,
    this.darkOnPrimary,
    this.darkSurface,
    this.lightPrimary,
    this.lightOnPrimary,
    this.lightSurface,
    this.lightInverseSurface,
    this.lightOnInverseSurface,
  });

  /// Stable identifier stored in prefs (e.g. `default`).
  final String id;

  /// Seed color for [ColorScheme.fromSeed].
  final Color seedColor;

  /// Contrast between color pairs (`0.0` default, `1.0` Material high).
  final double contrastLevel;

  /// Optional dark-mode primary accent override.
  final Color? darkPrimary;

  /// Optional dark-mode on-primary override (defaults to black when primary set).
  final Color? darkOnPrimary;

  /// Optional darkest dark-mode surface anchor.
  final Color? darkSurface;

  /// Optional light-mode primary (filled buttons, sliders).
  final Color? lightPrimary;

  /// Optional light-mode on-primary.
  final Color? lightOnPrimary;

  /// Optional light-mode surface anchor.
  final Color? lightSurface;

  /// Optional light-mode inverse surface (transport dock, empty cover).
  final Color? lightInverseSurface;

  /// Optional light-mode on-inverse (dock glyphs). Defaults to white.
  final Color? lightOnInverseSurface;

  /// Builds the [ColorScheme] for [brightness].
  ColorScheme colorSchemeFor(Brightness brightness) {
    final generated = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      contrastLevel: contrastLevel,
    );
    if (brightness == Brightness.light) {
      return _applyLightAnchors(generated);
    }
    return _applyDarkAnchors(generated);
  }

  ColorScheme _applyLightAnchors(ColorScheme generated) {
    final surface = lightSurface;
    final primary = lightPrimary;
    final inverse = lightInverseSurface;
    if (surface == null && primary == null && inverse == null) {
      return generated;
    }
    final onPrimary = lightOnPrimary ??
        (primary == null ? null : const Color(0xFFF7FBFC));
    final onInverse = lightOnInverseSurface ??
        (inverse == null ? null : Colors.white);
    return generated.copyWith(
      primary: primary,
      onPrimary: onPrimary,
      surface: surface,
      surfaceTint: primary,
      surfaceContainerLowest: surface == null
          ? null
          : Color.lerp(surface, Colors.white, 0.35),
      surfaceContainerLow: surface == null
          ? null
          : Color.lerp(surface, Colors.black, 0.03),
      surfaceContainer: surface == null
          ? null
          : Color.lerp(surface, Colors.black, 0.05),
      surfaceContainerHigh: surface == null
          ? null
          : Color.lerp(surface, Colors.black, 0.07),
      surfaceContainerHighest: surface == null
          ? null
          : Color.lerp(surface, Colors.black, 0.10),
      inverseSurface: inverse,
      onInverseSurface: onInverse,
    );
  }

  ColorScheme _applyDarkAnchors(ColorScheme generated) {
    final surface = darkSurface;
    final primary = darkPrimary;
    if (surface == null && primary == null) return generated;
    final accentContainer = _liftSurface(surface, 0.13);
    final onPrimary = darkOnPrimary ??
        (primary == null ? null : Colors.black);

    return generated.copyWith(
      primary: primary,
      onPrimary: onPrimary,
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
