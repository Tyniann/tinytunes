import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/theme/app_theme_mode.dart';
import 'package:tinytunes/core/theme/theme_catalog.dart';

/// Thin prefs access for theme mode and scheme id.
///
/// Purpose: Isolate `shared_preferences` keys and fallbacks from Riverpod
/// providers so invalid values never crash theme resolution.
/// Usage Context: Theme providers after prefs are injected at app start.
class ThemePreferences {
  /// Creates prefs helpers backed by [prefs].
  const ThemePreferences(this.prefs);

  /// Prefs key for [AppThemeMode].
  static const String modeKey = 'theme.mode';

  /// Prefs key for the active scheme id.
  static const String schemeIdKey = 'theme.schemeId';

  /// Injected [SharedPreferences] instance (sync after bootstrap).
  final SharedPreferences prefs;

  /// Reads the stored mode; missing/invalid → [AppThemeMode.system].
  AppThemeMode readMode() => AppThemeModeCodec.fromPrefs(prefs.getString(modeKey));

  /// Reads the stored scheme id; missing → [ThemeCatalog.defaultSchemeId].
  String readSchemeId() =>
      prefs.getString(schemeIdKey) ?? ThemeCatalog.defaultSchemeId;

  /// Persists [mode] for the next cold start.
  Future<void> writeMode(AppThemeMode mode) =>
      prefs.setString(modeKey, mode.prefsValue);

  /// Persists [schemeId] for the next cold start.
  Future<void> writeSchemeId(String schemeId) =>
      prefs.setString(schemeIdKey, schemeId);
}
