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
