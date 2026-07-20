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
