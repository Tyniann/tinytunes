import 'package:flutter/material.dart';
import 'package:tinytunes/core/theme/app_theme_scheme.dart';

/// Catalog of named [AppThemeScheme] entries available to the app.
///
/// Purpose: Resolve a scheme id to light/dark themes without hard-coding
/// colors in feature widgets.
/// Usage Context: Theme providers and future Settings scheme pickers.
class ThemeCatalog {
  /// Creates a catalog from the given [schemes] (must include [defaultSchemeId]).
  ThemeCatalog(List<AppThemeScheme> schemes)
      : _byId = {for (final scheme in schemes) scheme.id: scheme};

  /// Prefs / catalog id for the v1 brand scheme.
  static const String defaultSchemeId = 'default';

  /// Brand seed for the v1 [defaultSchemeId] scheme (`#88AA00`).
  static const Color defaultSeedColor = Color(0xFF88AA00);

  /// Catalog shipped in v1 (single `default` entry).
  factory ThemeCatalog.v1() => ThemeCatalog([
        const AppThemeScheme(
          id: defaultSchemeId,
          seedColor: defaultSeedColor,
        ),
      ]);

  final Map<String, AppThemeScheme> _byId;

  /// Returns the scheme for [schemeId], or the `default` entry when unknown.
  AppThemeScheme resolve(String? schemeId) {
    if (schemeId != null && _byId.containsKey(schemeId)) {
      return _byId[schemeId]!;
    }
    return _byId[defaultSchemeId]!;
  }
}
