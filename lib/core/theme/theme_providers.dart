import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/theme/app_theme_mode.dart';
import 'package:tinytunes/core/theme/app_theme_scheme.dart';
import 'package:tinytunes/core/theme/dynamic_color_availability.dart';
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

/// Shipped [ThemeCatalog] (Lucky Lime, Electric Blue, Ember Signal, High contrast).
@Riverpod(keepAlive: true)
ThemeCatalog themeCatalog(Ref ref) => ThemeCatalog.standard();

/// Platform Material You colors bridged from [DynamicColorBinder].
@Riverpod(keepAlive: true)
class DynamicColorAvailabilityController
    extends _$DynamicColorAvailabilityController {
  @override
  DynamicColorAvailability build() => DynamicColorAvailability.unresolved;

  /// Applies a [DynamicColorBuilder] snapshot after the frame (never during build).
  void apply(ColorScheme? light, ColorScheme? dark) {
    final next = DynamicColorAvailability(
      resolved: true,
      light: light,
      dark: dark,
    );
    if (state == next) return;
    state = next;
  }
}

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

/// Persisted scheme id with write API for Settings and tests.
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

/// Rewrites prefs from `dynamic` to `default` once Dynamic is known unavailable.
///
/// Purpose: Keep Settings honest when the Dynamic chip is hidden, without the
/// scheme controller depending on itself during [build].
/// Usage Context: Watched from theme data providers so the guard stays alive.
@Riverpod(keepAlive: true)
int dynamicSchemeGuard(Ref ref) {
  final schemeId = ref.watch(appThemeSchemeIdControllerProvider);
  final availability = ref.watch(dynamicColorAvailabilityControllerProvider);
  if (schemeId != ThemeCatalog.dynamicSchemeId) return 0;
  if (!availability.resolved || availability.isAvailable) return 0;

  Future.microtask(() async {
    final current = ref.read(appThemeSchemeIdControllerProvider);
    if (current != ThemeCatalog.dynamicSchemeId) return;
    final still = ref.read(dynamicColorAvailabilityControllerProvider);
    if (!still.resolved || still.isAvailable) return;
    await ref
        .read(appThemeSchemeIdControllerProvider.notifier)
        .setSchemeId(ThemeCatalog.defaultSchemeId);
  });
  return 0;
}

/// Active static [AppThemeScheme] for non-dynamic scheme ids.
///
/// When prefs say Dynamic, returns the catalog `default` seed scheme for
/// callers that need a static entry; prefer theme data / [previewColorScheme].
@Riverpod(keepAlive: true)
AppThemeScheme activeThemeScheme(Ref ref) {
  final catalog = ref.watch(themeCatalogProvider);
  final schemeId = ref.watch(appThemeSchemeIdControllerProvider);
  if (schemeId == ThemeCatalog.dynamicSchemeId) {
    return catalog.resolve(ThemeCatalog.defaultSchemeId);
  }
  return catalog.resolve(schemeId);
}

/// Light [ThemeData] for [MaterialApp.router].
@Riverpod(keepAlive: true)
ThemeData lightThemeData(Ref ref) {
  ref.watch(dynamicSchemeGuardProvider);
  return _themeDataFor(ref, brightness: Brightness.light);
}

/// Dark [ThemeData] for [MaterialApp.router].
@Riverpod(keepAlive: true)
ThemeData darkThemeData(Ref ref) {
  ref.watch(dynamicSchemeGuardProvider);
  return _themeDataFor(ref, brightness: Brightness.dark);
}

/// Flutter [ThemeMode] derived from [AppThemeModeController].
@Riverpod(keepAlive: true)
ThemeMode materialThemeMode(Ref ref) =>
    ref.watch(appThemeModeControllerProvider).materialThemeMode;

/// Preview [ColorScheme] for a scheme chip at [brightness].
ColorScheme previewColorScheme({
  required ThemeCatalog catalog,
  required String schemeId,
  required Brightness brightness,
  required DynamicColorAvailability availability,
}) {
  if (schemeId == ThemeCatalog.dynamicSchemeId) {
    final dynamicScheme =
        brightness == Brightness.light ? availability.light : availability.dark;
    if (dynamicScheme != null) return dynamicScheme;
    return catalog
        .resolve(ThemeCatalog.defaultSchemeId)
        .colorSchemeFor(brightness);
  }
  return catalog.resolve(schemeId).colorSchemeFor(brightness);
}

ThemeData _themeDataFor(Ref ref, {required Brightness brightness}) {
  final catalog = ref.watch(themeCatalogProvider);
  final schemeId = ref.watch(appThemeSchemeIdControllerProvider);
  final availability = ref.watch(dynamicColorAvailabilityControllerProvider);

  if (schemeId == ThemeCatalog.dynamicSchemeId) {
    final dynamicScheme =
        brightness == Brightness.light ? availability.light : availability.dark;
    if (availability.resolved && dynamicScheme != null) {
      return ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: dynamicScheme,
      );
    }
    return _staticTheme(
      catalog.resolve(ThemeCatalog.defaultSchemeId),
      brightness,
    );
  }

  return _staticTheme(catalog.resolve(schemeId), brightness);
}

ThemeData _staticTheme(AppThemeScheme scheme, Brightness brightness) =>
    brightness == Brightness.light ? scheme.lightTheme : scheme.darkTheme;
