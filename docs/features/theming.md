# Theming

## Overview

Extensible Material 3 theming with two independent knobs: appearance **mode**
(System / Light / Dark) and named **color scheme** catalog. Shipped schemes:
Lucky Lime (`default`), Electric Blue, Ember Signal, High contrast, plus
optional `dynamic` (Material You / wallpaper colors) when the platform
supplies them.

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

| Id | Display | Seed / anchors |
| --- | --- | --- |
| `default` | Lucky Lime | seed `#88AA00` |
| `electricBlue` | Electric Blue | cyan `#70D9E8` (dark + light); dark/light inverse `#071016`; light paper `#F7FBFC` |
| `emberSignal` | Ember Signal | dark oxblood `#C45B4A` on `#0E0D11`; light vermillion `#E63B2E` on paper `#F0EBE1`; light inverse poster ink `#0A0A0A` |
| `highContrast` | High contrast | Lucky Lime seed, `contrastLevel` `1.0`; light inverse (dock) `#050700` |

High contrast dark mode additionally anchors surfaces near black (`#050700`)
and pins `primary` to `#88AA00`. High contrast light pins the transport dock
(`inverseSurface`) to the same near-black so lime shuffle / repeat / play stay
visible against it.

Prefs key `theme.schemeId`. Missing/unknown static id resolves themes to
`default` (Lucky Lime). Fresh install stays on `default`. The prefs id is
unchanged so existing installs do not jump scheme when the label became
Lucky Lime.

`dynamic` is **not** a seed catalog entry. When selected and platform
`ColorScheme`s are present, `MaterialApp` uses those schemes directly. Mode
still chooses light vs dark vs system.

Typography is **not** part of the scheme catalog. Now-playing title weight
and tracking live on the home stage widget.

### Dynamic (Material You)

- `DynamicColorBinder` wraps the app with `dynamic_color`’s
  `DynamicColorBuilder` and publishes snapshots to
  `dynamicColorAvailabilityControllerProvider` **after** each frame.
- Picker shows Dynamic only when `resolved && light != null && dark != null`.
- Wallpaper / system color changes rebuild live while Dynamic is selected.
- **Rewrite race:** before the first builder callback, prefs are left alone
  (themes may temporarily show Lucky Lime). After a resolved callback with no
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
- **Color scheme** — wrapping swatch chips (primary / secondary / surface dots
  + label); info icon (when Dynamic is visible) opens a short Material You
  explainer

## Dependencies

- `shared_preferences`
- `flutter_riverpod`
- `package_info_plus`
- `dynamic_color`

## Related Features

- [Message center](message-center.md)
- [Player](player.md)

---
*Last updated: 2026-08-14*
