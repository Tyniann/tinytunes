# Theming

## Overview

Extensible Material 3 theming with two independent knobs: appearance **mode** (System / Light / Dark) and named **scheme** catalog. v1 ships only the `default` scheme with brand seed `#88AA00`.

## Location

- **Module:** `lib/core/theme/`
- **Main Screen:** `lib/features/settings/presentation/settings_screen.dart`
- **Related Files:**
  - `app_theme_mode.dart`
  - `app_theme_scheme.dart`
  - `theme_catalog.dart`
  - `theme_preferences.dart`
  - `theme_providers.dart`
  - About version: `lib/core/settings/package_info_provider.dart`
  - Locale fallback: `lib/core/l10n/locale_resolution.dart`
  - Wired in `lib/main.dart` (`TinyTunesApp`)

## Functionality

### Mode

`AppThemeMode` (`system` / `light` / `dark`) maps to Flutter `ThemeMode`. Persisted under prefs key `theme.mode`. Invalid/missing → `system`.

Settings exposes a System / Light / Dark picker that writes via `AppThemeModeController`.

### Scheme catalog

`ThemeCatalog` maps `schemeId` → light/dark `ThemeData` via `ColorScheme.fromSeed`. Prefs key `theme.schemeId`. Missing/unknown id resolves to `default`.

v1 entry: `default` with seed `Color(0xFF88AA00)`. No scheme picker until more than one scheme ships (Dynamic → Phase 8).

### Locale

`localeListResolutionCallback` prefers `de` / `en` from the OS list; otherwise falls back to **English** (does not trust generated `supportedLocales` order).

### Resolution

`MaterialApp.router` receives `theme` / `darkTheme` / `themeMode` from Riverpod providers. Feature widgets use `Theme.of(context)` tokens — no hard-coded brand colors.

## Data Model

Settings-only prefs (`shared_preferences`), not Drift.

## User Interface

Settings: Appearance radios + About (app name + version from `package_info_plus`). Extra schemes / Dynamic (Material You) later (Phase 8).

## Dependencies

- `shared_preferences`
- `flutter_riverpod`
- `package_info_plus`

## Related Features

- [Message center](message-center.md)

---
*Last updated: 2026-07-20*
