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

  /// Prefs / catalog id for the brand scheme.
  static const String defaultSchemeId = 'default';

  /// Prefs / catalog id for the aggressive high-contrast scheme.
  static const String highContrastSchemeId = 'highContrast';

  /// Prefs id for Material You / wallpaper-derived colors (not a seed entry).
  static const String dynamicSchemeId = 'dynamic';

  /// Brand seed for static schemes (`#88AA00`).
  static const Color defaultSeedColor = Color(0xFF88AA00);

  /// Near-black surface anchor for High contrast dark mode.
  static const Color highContrastDarkSurface = Color(0xFF050700);

  /// Shipped static catalog: [defaultSchemeId] + [highContrastSchemeId].
  factory ThemeCatalog.standard() => ThemeCatalog([
    const AppThemeScheme(id: defaultSchemeId, seedColor: defaultSeedColor),
    const AppThemeScheme(
      id: highContrastSchemeId,
      seedColor: defaultSeedColor,
      contrastLevel: 1.0,
      darkPrimary: defaultSeedColor,
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
      highContrastSchemeId,
      if (dynamicAvailable) dynamicSchemeId,
    ];
  }
}
