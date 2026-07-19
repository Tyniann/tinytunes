# Theming

## Overview

Extensible Material 3 theming with two independent knobs: appearance **mode** (System / Light / Dark) and named **scheme** catalog. v1 ships only the `default` scheme with brand seed `#88AA00`.

## Location

- **Module:** `lib/core/theme/`
- **Main Screen:** Settings picker deferred to Phase 5 (`lib/features/settings/presentation/settings_screen.dart` is a stub)
- **Related Files:**
  - `app_theme_mode.dart`
  - `app_theme_scheme.dart`
  - `theme_catalog.dart`
  - `theme_preferences.dart`
  - `theme_providers.dart`
  - Wired in `lib/main.dart` (`TinyTunesApp`)

## Functionality

### Mode

`AppThemeMode` (`system` / `light` / `dark`) maps to Flutter `ThemeMode`. Persisted under prefs key `theme.mode`. Invalid/missing → `system`.

Phase 1 UI stays on System by default; Light/Dark are verified via provider overrides and device system theme.

### Scheme catalog

`ThemeCatalog` maps `schemeId` → light/dark `ThemeData` via `ColorScheme.fromSeed`. Prefs key `theme.schemeId`. Missing/unknown id resolves to `default`.

v1 entry: `default` with seed `Color(0xFF88AA00)`.

### Resolution

`MaterialApp.router` receives `theme` / `darkTheme` / `themeMode` from Riverpod providers. Feature widgets use `Theme.of(context)` tokens — no hard-coded brand colors.

## Data Model

Settings-only prefs (`shared_preferences`), not Drift.

## User Interface

Settings stub copy only in Phase 1. Mode picker lands in Phase 5. Extra schemes / Dynamic (Material You) later (Phase 8).

## Dependencies

- `shared_preferences`
- `flutter_riverpod`

## Related Features

- [Message center](message-center.md)

---
*Last updated: 2026-07-19*
