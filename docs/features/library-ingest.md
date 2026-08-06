# Library ingest

## Overview

Indexes user-picked local music folders into a durable **catalog** and a single Winamp-style **queue**. Folder access uses the Phase 0 SAF adapter (`LocalLibrarySource`). Playback is documented in [player.md](player.md).

## Location

- **Module:** `lib/features/library/application/`, `lib/core/database/`
- **Main Screen:** `lib/features/playlist/presentation/playlist_home_screen.dart`
- **Related Files:**
  - `library_ingest_controller.dart` — single-flight add / re-scan / forget
  - `catalog_dao.dart` — thin Drift accessors
  - `app_database.dart` / `tables.dart` — schema v2 (`cloud_cache_entries`)
  - Android adapter: `lib/core/library/android/android_local_library_source.dart`
  - Cloud: [`docs/features/cloud-library.md`](cloud-library.md)
  - ADR: [`docs/adr/0001-android-local-library-access.md`](../adr/0001-android-local-library-access.md)

## Functionality

### Add folder

1. Enter `picking` (busy, no scan banner / no `scanStarted` toast).
2. Pick + retain a SAF tree root. System **Back** cancels → idle, silent.
3. On non-null pick → `scanning` + `library.scan.started`.
4. If the root locator already exists → refresh its catalog and append every
   discovered track that is not already queued. This makes Add folder the
   explicit way to refill a cleared queue without creating duplicates.
5. Otherwise insert `library_roots`, walk the tree (recurse **all** directories; match audio **files** only by extension).
6. Upsert catalog in batches while walking (partial catalog may remain on failure).
7. **Append to queue only after a full successful walk** (all batches OK, not cancelled).

### Re-scan

- Upsert by `(rootId, sourceItemId)`.
- **Append only newly inserted** catalog tracks (never resurrect queue rows the user removed).
- Hard-delete missing catalog tracks + prune queue **only when**: walk completed, not cancelled, and every upsert batch succeeded.

Add folder and Re-scan intentionally differ: Add folder restores existing
catalog tracks missing from the queue; Re-scan only discovers new files.

### Forget folder

1. Transactionally delete related queue rows, tracks, then the root in Drift.
2. Best-effort `releaseRoot`; on release failure report `library.forget.failed` without restoring rows.
3. Clears that root from the revoked UI list.

### Single-flight

Only one Add / Re-scan / Forget / pick at a time (`IngestPhase.picking|scanning|forgetting`). Home disables those actions while busy. Cancel stops scheduling new scan work, awaits in-flight materialize, never prunes. Cancel is scan-only (not available while picking/forgetting).

### Progress

Home strips (stacked: revoked above progress):

- `Scanning… n` + Cancel while scanning
- `Forgetting folder…` while forgetting (no Cancel)

No mandatory two-pass total count. Scan runs on the **app isolate** (KISS). Worker/Drift isolates are **not** in Phase 5 — measure-first; file a follow-up only if large-library smoke shows sustained UI freezes.

### Cold start / revoked roots

No auto re-scan. On home open, `checkRevokedRoots` (cold-start / explicit path only — no live grant watcher):

- Recomputes a watchable revoked UI list (per-root home strip + Forget)
- Reports each newly revoked locator once per session (`library.root.revoked`)
- Continues after per-root plugin errors (does not abort the whole check)
- Clears a strip on Forget or when access is restored (successful re-Add / re-scan)

Catalog is kept until Forget or a successful Re-scan/Add with access.

### Queue behavior

- Remove and Clear affect only `queue_entries`; catalog tracks remain indexed.
- Add folder is the explicit refill action after Remove or Clear.
- Empty queue shows title + **Add folder** CTA.
- Adding the same root repeatedly cannot duplicate queue entries.
- Re-scan synchronizes the catalog without restoring manually removed rows.
- Forget followed by Add is a fresh import and refills the queue.

## Data Model

| Table | Role |
| --- | --- |
| `library_roots` | Opaque root locator + display name |
| `tracks` | Catalog identity `(rootId, sourceItemId)`; tags; nullable reserved `artworkCacheRef` / `sizeBytes` / `modifiedAt` (always null until cover cache) |
| `queue_entries` | Ordered unique `trackId` links |
| `playback_state` | Singleton `id=1`; `currentQueueEntryId` ON DELETE SET NULL; driven by [player](player.md) |

Identity: `sourceItemId` == item `MediaLocator.value`. `PRAGMA foreign_keys = ON`.

### Audio extensions

`.mp3`, `.flac`, `.m4a`, `.aac`, `.ogg`, `.opus`, `.wav` (case-insensitive).

### Message codes

`library.scan.started` | `library.scan.complete` | `library.scan.cancelled` | `library.scan.failed` | `library.root.revoked` | `library.forget.complete` | `library.forget.failed`

(Machine codes stay in the message model; Messages UI shows localized text only.)

## User Interface

Playlist home: queue list, Add folder, remove row, overflow Clear / Re-scan / Forget (confirms for Clear and Forget; multi-root picker has Cancel), revoked strips, scan/forget banners, live transport (see [player](player.md)).

## Device smoke checklist (Phase 5)

Run on a physical Android device (ideally one API 29–33 and one current):

- [ ] Large Add folder → progress strip updates; Cancel mid-scan → no prune
- [ ] SAF **Back** cancels Add; no scan toast/message; UI not stuck busy
- [ ] Theme mode (Settings) persists across process death
- [ ] Revoked grant → home strip; Forget recovers; re-grant / re-Add clears strip
- [ ] Background play + Shuffle×Repeat spot-check still OK
- [ ] If large-lib scan freezes the UI for sustained periods → file follow-up (do not add isolates ad hoc)

## Dependencies

- `drift` / `drift_flutter` — persistence
- `LocalLibrarySource` / `TrackMetadataReader` — SAF + tags
- `MessageReporter` / `toastification` — user feedback

Android MethodChannel changes require a full app rebuild; hot reload does not
replace `SafLibraryPlugin.kt`.

## Related Features

- [Message center](message-center.md)
- [Theming](theming.md)

---
*Last updated: 2026-07-20*
