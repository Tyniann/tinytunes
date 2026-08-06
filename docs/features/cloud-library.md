# Cloud library (Google Drive)

## Overview

Android-only read-only Google Drive library behind `CloudLibrarySource`: sign in,
add a Drive folder to the catalog/queue, download-then-play into a local cache,
and manage cache budget / clear / sign-out wipe — never mutate remote files.

## Location

- **Module:** `lib/core/cloud/`
- **Main Screen:** Settings Google Drive section; home **Add cloud folder**
- **Related Files:**
  - `cloud_library_source.dart` / `google_drive_cloud_library_source.dart`
  - `cloud_cache_store.dart` / `cloud_cache_budget.dart` / prefs
  - `google_drive_auth.dart` / `google_oauth_config.dart`
  - `library_ingest_controller.dart` (`addCloudFolder`, cloud rescan/forget)
  - `playback_uri_resolver.dart` (download-then-play)
  - `drive_folder_browser_dialog.dart`
  - ADR: [`docs/adr/0002-google-drive-cloud-library.md`](../adr/0002-google-drive-cloud-library.md)

## Functionality

### Sign in / Sign out (Settings)

- Sign in with Google (`drive.readonly`).
- Sign out clears the Google session and **wipes all cloud cache** (catalog roots stay until Forget).

### Add cloud folder (home)

1. Home **+** → choose **This device** or **Google Drive**.
2. Drive path requires signed-in account (else toast / message).
3. Drive folder browser (My Drive root itself is not selectable).
4. **Also load subfolders?** yes/no.
5. Walk into catalog + append queue (same single-flight gate as local).
6. Tags stay empty at ingest (`displayName` from Drive); filled once on play when the file is already local (download or cache hit).

### Playback

- Local tracks: SAF resolve as before.
- Cloud tracks: cache hit → play file; miss → home **Downloading…** + progress bar → download → LRU budget → play.
- After a local file is available, missing tags and/or cover art are read once via
  `audiotags` and written to the track row / artwork cache (queue UI updates via
  watch). No download solely for tags or art; remote files are never mutated.
- Cover files live under application support (`artwork/<trackId>.jpg`, capped
  ~512px JPEG). They are deleted with the same cloud-cache triggers as audio
  (queue remove / clear, budget eviction, Clear cache, sign-out) and on Forget /
  prune. Art does not count toward the GB budget.
- Failures use the existing unplayable / auto-advance path.

### Cache eviction

| Trigger | Behavior |
| --- | --- |
| Remove queue row / Clear queue | Delete that track’s cache file(s) + artwork |
| After download | Enforce budget LRU (prefer non-queued; never now-playing); eviction drops art with audio |
| Settings slider lower | Persist prefs + enforce once |
| Clear cloud cache | Wipe all cache files + Drift rows + artwork for those tracks |
| Forget cloud root / Sign out | Wipe relevant / all cache (+ Forget also wipes art for the root) |

### Settings budget

Slider **512 MB–32 GB**, step **512 MB**, default **2 GB**; label `Cloud cache limit: X.X GB`.

## Data Model

- Roots/tracks: `sourceKind = cloud`; locator `gdrive:<fileId>`.
- Table `cloud_cache_entries` (schema v2): `trackId`, `remoteLocator`, `localPath`, `sizeBytes`, `lastAccessedAt`.

## User Interface

- Home: cloud app-bar action, downloading strip with progress.
- Settings: account email, Sign in/out, budget slider, Clear cloud cache (confirm).

## Dependencies

- `google_sign_in`, `googleapis` (Drive v3), `http`
- Android free space via `StoragePlugin` / `StatFs`

## Related Features

- [Library ingest](library-ingest.md)
- [Player](player.md)

## Android device smoke checklist

1. Sign in (Settings) → email shown.
2. Add cloud folder (flat + recursive) → tracks in queue (display-name order).
3. Tap track → Downloading progress → plays; second tap from cache (no re-download).
4. Remove from queue → cache gone; play again → new download.
5. Lower cache slider → eviction when over budget.
6. Clear cloud cache → files gone; catalog/queue remain.
7. Forget cloud root → catalog gone + cache wipe.
8. Sign out → session cleared + cache wipe; confirm Drive unchanged remotely.

---
*Last updated: 2026-08-06*
