# Theming

## Overview

Extensible Material 3 theming with two independent knobs: appearance **mode**
(System / Light / Dark) and named **color scheme** catalog. Shipped schemes:
`default` and `highContrast` (brand seed `#88AA00`), plus optional `dynamic`
(Material You / wallpaper colors) when the platform supplies them.

## Location

- **Module:** `lib/core/theme/`
- **Main Screen:** `lib/features/settings/presentation/settings_screen.dart`
- **Related Files:**
  - `app_theme_mode.dart`
  - `app_theme_scheme.dart`
  - `theme_catalog.dart`
  - `theme_preferences.dart`
  - `theme_providers.dart`
  - `dynamic_color_availability.dart`
  - `dynamic_color_binder.dart`
  - Settings widgets: `theme_mode_segmented_control.dart`, `color_scheme_picker.dart`
  - About version: `lib/core/settings/package_info_provider.dart`
  - Locale fallback: `lib/core/l10n/locale_resolution.dart`
  - Wired in `lib/main.dart` (`TinyTunesApp` + `DynamicColorBinder`)

## Functionality

### Mode

`AppThemeMode` (`system` / `light` / `dark`) maps to Flutter `ThemeMode`.
Persisted under prefs key `theme.mode`. Invalid/missing → `system`.

Settings exposes a horizontal `SegmentedButton` (System / Light / Dark).

### Scheme catalog

Static entries in `ThemeCatalog.standard()`:

| Id | Seed | `contrastLevel` |
| --- | --- | --- |
| `default` | `#88AA00` | `0.0` |
| `highContrast` | `#88AA00` | `1.0` (Material high) |

High contrast dark mode additionally anchors surfaces near black (`#050700`)
and pins `primary` to the brand `#88AA00` so controls retain the intended
green instead of Material's lighter generated dark accent.

Prefs key `theme.schemeId`. Missing/unknown static id resolves themes to
`default`. Fresh install stays on `default`.

`dynamic` is **not** a seed catalog entry. When selected and platform
`ColorScheme`s are present, `MaterialApp` uses those schemes directly. Mode
still chooses light vs dark vs system.

### Dynamic (Material You)

- `DynamicColorBinder` wraps the app with `dynamic_color`’s
  `DynamicColorBuilder` and publishes snapshots to
  `dynamicColorAvailabilityControllerProvider` **after** each frame.
- Picker shows Dynamic only when `resolved && light != null && dark != null`.
- Wallpaper / system color changes rebuild live while Dynamic is selected.
- **Rewrite race:** before the first builder callback, prefs are left alone
  (themes may temporarily show `default`). After a resolved callback with no
  colors, if prefs say `dynamic`, rewrite to `default` (no toast).

### Locale

`localeListResolutionCallback` prefers `de` / `en` from the OS list; otherwise
falls back to **English**.

### Resolution

`MaterialApp.router` receives `theme` / `darkTheme` / `themeMode` from Riverpod
providers. Feature widgets use `Theme.of(context)` tokens — no hard-coded brand
colors.

## Data Model

Settings-only prefs (`shared_preferences`), not Drift.

## User Interface

Settings:

- **Mode** — segmented control
- **Color scheme** — swatch chips (primary / secondary / surface dots + label);
  info icon (when Dynamic is visible) opens a short Material You explainer

## Dependencies

- `shared_preferences`
- `flutter_riverpod`
- `package_info_plus`
- `dynamic_color`

## Related Features

- [Message center](message-center.md)

---
*Last updated: 2026-08-07*
