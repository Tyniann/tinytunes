import 'package:flutter/material.dart';
import 'package:tinytunes/core/theme/app_theme_scheme.dart';

/// Catalog of named static [AppThemeScheme] entries available to the app.
///
/// Purpose: Resolve a static scheme id to light/dark themes without hard-coding
/// colors in feature widgets. Dynamic (Material You) is handled separately via
/// platform [ColorScheme]s — it is not a seed entry here.
/// Usage Context: Theme providers and Settings scheme pickers.
class ThemeCatalog {
  /// Creates a catalog from the given [schemes] (must include [defaultSchemeId]).
  ThemeCatalog(List<AppThemeScheme> schemes)
    : _byId = {for (final scheme in schemes) scheme.id: scheme};

  /// Prefs / catalog id for Lucky Lime (brand seed). Kept as `default` so
  /// existing installs do not jump scheme.
  static const String defaultSchemeId = 'default';

  /// Prefs / catalog id for Electric Blue (console cyan).
  static const String electricBlueSchemeId = 'electricBlue';

  /// Prefs / catalog id for Ember Signal (night oxblood / paper vermillion).
  static const String emberSignalSchemeId = 'emberSignal';

  /// Prefs / catalog id for the aggressive high-contrast scheme.
  static const String highContrastSchemeId = 'highContrast';

  /// Prefs id for Material You / wallpaper-derived colors (not a seed entry).
  static const String dynamicSchemeId = 'dynamic';

  /// Brand seed for Lucky Lime (`#88AA00`).
  static const Color luckyLimeSeed = Color(0xFF88AA00);

  /// Alias kept for older call sites/tests.
  static const Color defaultSeedColor = luckyLimeSeed;

  /// Near-black surface anchor for High contrast dark mode.
  static const Color highContrastDarkSurface = Color(0xFF050700);

  /// Electric Blue dark void (Variant B).
  static const Color electricBlueDarkSurface = Color(0xFF071016);

  /// Electric Blue cyan signal (Variant B) — used in dark and light.
  static const Color electricBlueSignal = Color(0xFF70D9E8);

  /// Electric Blue light paper (cool ice off-white).
  static const Color electricBlueLightSurface = Color(0xFFF7FBFC);

  /// Electric Blue dock / empty-cover ink in light mode (same void as dark).
  static const Color electricBlueLightInverse = electricBlueDarkSurface;

  /// Ember Signal dark night (Variant C).
  static const Color emberSignalDarkSurface = Color(0xFF0E0D11);

  /// Ember Signal dark oxblood (Variant C).
  static const Color emberSignalDarkPrimary = Color(0xFFC45B4A);

  /// Ember Signal light paper (Variant D).
  static const Color emberSignalLightSurface = Color(0xFFF0EBE1);

  /// Ember Signal light vermillion (Variant D).
  static const Color emberSignalLightPrimary = Color(0xFFE63B2E);

  /// Ember Signal poster ink (Variant D cover / dock).
  static const Color emberSignalLightInverse = Color(0xFF0A0A0A);

  /// Ember Signal dock glyphs on poster ink.
  static const Color emberSignalLightOnInverse = Color(0xFFF5F0E8);

  /// Shipped static catalog.
  factory ThemeCatalog.standard() => ThemeCatalog([
    const AppThemeScheme(id: defaultSchemeId, seedColor: luckyLimeSeed),
    const AppThemeScheme(
      id: electricBlueSchemeId,
      seedColor: electricBlueSignal,
      darkPrimary: electricBlueSignal,
      darkOnPrimary: electricBlueDarkSurface,
      darkSurface: electricBlueDarkSurface,
      lightPrimary: electricBlueSignal,
      lightOnPrimary: electricBlueDarkSurface,
      lightSurface: electricBlueLightSurface,
      lightInverseSurface: electricBlueLightInverse,
      lightOnInverseSurface: Color(0xFFF1F6F7),
    ),
    const AppThemeScheme(
      id: emberSignalSchemeId,
      seedColor: emberSignalDarkPrimary,
      darkPrimary: emberSignalDarkPrimary,
      darkOnPrimary: Color(0xFFF3EDE0),
      darkSurface: emberSignalDarkSurface,
      lightPrimary: emberSignalLightPrimary,
      lightOnPrimary: Color(0xFFF5F0E8),
      lightSurface: emberSignalLightSurface,
      lightInverseSurface: emberSignalLightInverse,
      lightOnInverseSurface: emberSignalLightOnInverse,
    ),
    const AppThemeScheme(
      id: highContrastSchemeId,
      seedColor: luckyLimeSeed,
      contrastLevel: 1.0,
      darkPrimary: luckyLimeSeed,
      darkSurface: highContrastDarkSurface,
    ),
  ]);

  /// Alias for [ThemeCatalog.standard] kept for older call sites/tests.
  factory ThemeCatalog.v1() => ThemeCatalog.standard();

  final Map<String, AppThemeScheme> _byId;

  /// Returns the static scheme for [schemeId], or `default` when unknown.
  ///
  /// [dynamicSchemeId] is not a static entry — callers must treat it specially.
  AppThemeScheme resolve(String? schemeId) {
    if (schemeId != null && _byId.containsKey(schemeId)) {
      return _byId[schemeId]!;
    }
    return _byId[defaultSchemeId]!;
  }

  /// Scheme ids shown in Settings, optionally including [dynamicSchemeId].
  List<String> pickerSchemeIds({required bool dynamicAvailable}) {
    return [
      defaultSchemeId,
      electricBlueSchemeId,
      emberSignalSchemeId,
      highContrastSchemeId,
      if (dynamicAvailable) dynamicSchemeId,
    ];
  }
}
