# Changelog

All notable changes to the TinyTunes project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

### Changed

### Fixed

### Removed

### Security

---

## [1.2.0] - 2026-08-14

### Added

- Add Electric Blue and Ember Signal color schemes (light + dark) in Settings
- Add cover-carousel home stage with a compressed queue ledger and floating transport dock
- Add sticky containing-folder headers on the queue (compact folder icon + last folder name)

### Changed

- Bump app version to `1.2.0+12`
- Rename the Default color scheme label to Lucky Lime (prefs id `default` unchanged)
- Use ice cyan (not navy) for Electric Blue light; pin Ember Signal light dock/cover ink to Variant D black
- Replace personal controller identity in in-repo privacy drafts (EN/DE) with placeholders so forks do not inherit another publisher as data controller

### Fixed

- Keep High contrast light transport controls visible: pin dock inverse to near-black so lime accents do not vanish

### Removed

### Security

---

## [1.1.0] - 2026-08-08

### Added

- Add personal OneDrive as a second read-only cloud library (Android): MSAL sign-in, Graph list/download, folder browser, ingest, download-then-play, shared cache with Google Drive
- Add ADR 0003 for personal OneDrive cloud library decisions
- Add Microsoft / OneDrive OAuth setup, signature-hash commands, and official brand asset inventory under `docs/legal/`
- Add multi-provider cloud foundation: `CloudProviderId`, locator router, OneDrive locator codec, `clearForProvider`
- Add cloud root ownership (`cloud_provider` / `cloud_account_key`) with account-replacement confirm/cancel for Google and OneDrive
- Add parameterized Google/OneDrive parity tests (ingest, rescan/forget, queue cache, scoped sign-out, shared LRU)

### Changed

- Bump app version to `1.1.0+11`
- Extend privacy policy drafts (EN/DE) to cover optional personal OneDrive / Microsoft sign-in
- Move Google Drive cloud modules under `lib/core/cloud/google_drive/` (mirrored tests)
- Google / OneDrive sign-out each wipe only that provider’s cache; new downloads use `cloud_cache/gdrive/…` or `cloud_cache/onedrive/…`
- Cloud rescan prune deletes indexed audio cache before removing catalog tracks
- Settings “Clear cloud cache” is provider-neutral (`CloudCacheStore.clearAll`)
- Document multi-provider cloud behavior in `docs/features/cloud-library.md` and README

### Fixed

### Removed

- Remove OneDrive / Google Drive spike-only Settings probes (production browsing is the folder dialog)

### Security

---

## [1.0.0] - 2026-08-08

### Added

- Add color scheme picker in Settings: Default, High contrast, and Dynamic (Material You when available)
- Add aggressive high-contrast scheme (`contrastLevel` 1.0, brand seed `#88AA00`)
- Add live wallpaper-derived Dynamic themes via `dynamic_color`, with prefs rewrite to Default when unavailable
- Rework Appearance into Mode (`SegmentedButton`) and Color scheme (swatch chips + Dynamic info dialog)

### Changed

- Bump app version to `1.0.0+10`
- Clarify Google OAuth docs: official release APK is preconfigured; forks must BYO GCP clients (verification may still be pending)

### Fixed

- Restore Google Drive sign-in at app start (not only when opening Settings)

### Removed

### Security

---

## [0.8.0] - 2026-08-06

### Added

- Settings About dialog (logo, version, changelog preview, privacy policy link)
- Embedded album covers: capped JPEG cache, queue trailing thumbs, lock-screen / notification `MediaItem.artUri` (local at ingest; cloud on play-path)
- Playlist menu **Forget all folders** (clears every library root + queue songs; files untouched)
- Document online cover fetch (MusicBrainz / Cover Art Archive) as a later opt-in candidate

### Changed

- Bump app version to `0.8.0+9`

### Fixed

- Cap queue title to 2 lines and artist to 1 (ellipsis) so long filenames no longer overlap other rows

### Removed

### Security

---

## [0.7.1] - 2026-08-06

### Added

- Add Google Drive read-only cloud library (Android): OAuth, folder ingest, download-then-play cache, Settings budget / Clear / sign-out wipe (ADR 0002)
- Add library source picker (This device / Google Drive) with official Drive brand mark
- Fill cloud track tags on play-path download / cache hit (list-only ingest; no tag-only downloads)
- Add GDPR-oriented privacy policy under `docs/legal/` + live URL on blumenlaube.at
- Add public README (BYO Google OAuth), MIT license, signing/OAuth docs
- Set TinyTunes TT logo as Android launcher icon (`flutter_launcher_icons`)
- Expandable system-volume slider on transport chrome (speaker toggle; OS media volume)
- Auto-center the current queue row when playback jumps outside the viewport

### Changed

- Bump app version to `0.7.1+8`
- Drive folder browser shows audio files (not only subfolders); empty state only when truly empty

### Removed

- Remove temporary download-for-tags during cloud folder ingest

---

## [0.6.0] - 2026-07-20

### Added

- Fill Settings with theme mode (System / Light / Dark) and About (app name + version)
- Add empty-queue **Add folder** CTA and per-root revoked-access home strips
- Add `IngestPhase.picking` so folder pick is single-flight busy without a scan toast
- Add forgetting progress strip and Cancel on multi-root folder picker
- Add English locale fallback when the OS language is not `en`/`de`

### Changed

- Harden scan/cancel flow: defer `scanStarted` until after a successful SAF pick
- Show human-readable Messages only (machine codes remain in the model)
- Keep scan on the app isolate (measure-first); document device smoke checklist

### Removed

- Remove Messages demo button and Settings stub copy

---

## [0.5.0] - 2026-07-20

### Added

- Add Shuffle × Repeat matrix (`QueueNavigator`) with transport toggles on home chrome
- Add in-memory shuffle session (permutation for Shuffle+Off; history for Shuffle+All/One)
- Persist `shuffleEnabled` / `repeatMode` via `CatalogDao.updatePlaybackModes`

### Changed

- Extend `PlaybackController` so complete / next / previous / remove / unplayable all use the matrix
- Restore applies modes even when there is no current track; clear/stop preserve modes
- Document intentional modes-only cold start (shuffle order/history reset on process death)

### Fixed

- Prevent duplicate `just_audio` completion events from creating a Repeat One
  seek/play storm that exhausts the Android heap
- Serialize rapid shuffle/repeat persistence and align unplayable end-of-queue
  handling with the Phase 4 navigation contract

### Removed

### Security

---

## [0.4.0] - 2026-07-19

### Added

- Add playback + background via `just_audio` + `audio_service` (`TinyTunesAudioHandler`, `PlaybackController`)
- Add home transport seek bar, row tap to play, current-row highlight, Drift resume paused
- Add Off/Off navigation with shared `AdvanceReason` skip path (remove→autoplay, clear→stop, N=5 unplayable bound)
- Add `docs/features/player.md`

### Changed

- Replace `just_audio_background` with direct `audio_service`; `MainActivity` extends `AudioServiceActivity`
- Bootstrap uses `UncontrolledProviderScope` + `audioHandlerProvider` override before eager controller attach
- Extend `pumpApp` with fake `PlaybackEngine` + detached handler (no `AudioService.init` in tests)

### Fixed

- Stop playback and dismiss the media notification promptly on swipe-away / task removed (`onTaskRemoved` → `super.stop()`)
- Publish playing state immediately by not awaiting `just_audio` track completion, keeping the media notification and foreground service alive in the background

### Removed

- Remove `just_audio_background` dependency

### Security

---

## [0.3.0] - 2026-07-19

### Added

- Add Drift schema v1: `library_roots`, `tracks`, `queue_entries`, singleton `playback_state` (FK `ON DELETE SET NULL`)
- Add single-flight library ingest (add folder, re-scan, forget) with safe prune and no queue resurrection
- Add playlist home queue chrome: list, add folder, remove, clear, re-scan, forget, scan progress
- Add `docs/features/library-ingest.md` and root `CONTEXT.md` glossary

### Changed

- Extend `pumpApp` with in-memory Drift + fake `LocalLibrarySource` overrides for widget tests
- Distinguish Add folder (refill missing queue rows) from explicit Re-scan (append only newly discovered catalog tracks)

### Fixed

- Bundle `libsqlite3.so` via `sqlite3_flutter_libs` 0.5.39 (override empty `0.6.0+eol`) so Drift can open on Android; load via sqlite3 hooks `source: system` (`name_windows: winsqlite3` for host tests)
- Enable Drift `shareAcrossIsolates` so hot restart cannot leave a background isolate locking the DB during schema create
- Prevent startup SAF access checks from escaping as unhandled plugin errors
- Make Add folder refill missing queue entries without duplicates while explicit Re-scan preserves manual removals
- Delete a forgotten root's queue and catalog rows explicitly in one transaction

---

## [0.2.0] - 2026-07-19

### Added

- Add opaque local-library contracts (`MediaLocator`, `LocalLibrarySource`, `TrackMetadataReader`) and a read-only `CloudLibrarySource` stub for later cloud sync
- Add Android SAF MethodChannel adapter (`AndroidLocalLibrarySource`) for durable folder pick, persistable read access, recursive listing, tag materialization, and `content://` playback resolution
- Add path-based `AudiotagsTrackMetadataReader` for title, artist, album, and embedded artwork
- Document Android library-access decision and device proof in ADR 0001
- Add typed app shell routes (`/`, `/settings`, `/messages`) with playlist home, Settings stub, and message center
- Add Material 3 theme catalog (`default` seed `#88AA00`) with prefs-backed System/Light/Dark mode plumbing
- Add bounded in-memory session message center with `reportInfo`/`reportError`, toast delivery seam, and unread badge
- Add widget test harness (`pumpApp`) sharing `TinyTunesApp` with production

### Changed

- Pin the Riverpod / Freezed / analyzer / mockito codegen stack so `build_runner` completes cleanly on Flutter 3.41 / Dart 3.11
