# Library ingest

## Overview

Indexes user-picked local music folders into a durable **catalog** and a single Winamp-style **queue**. Folder access uses the Phase 0 SAF adapter (`LocalLibrarySource`); playback is out of scope until Phase 3.

## Location

- **Module:** `lib/features/library/application/`, `lib/core/database/`
- **Main Screen:** `lib/features/playlist/presentation/playlist_home_screen.dart`
- **Related Files:**
  - `library_ingest_controller.dart` — single-flight add / re-scan / forget
  - `catalog_dao.dart` — thin Drift accessors
  - `app_database.dart` / `tables.dart` — schema v1
  - Android adapter: `lib/core/library/android/android_local_library_source.dart`
  - ADR: [`docs/adr/0001-android-local-library-access.md`](../adr/0001-android-local-library-access.md)

## Functionality

### Add folder

1. Pick + retain a SAF tree root.
2. If the root locator already exists → refresh its catalog and append every
   discovered track that is not already queued. This makes Add folder the
   explicit way to refill a cleared queue without creating duplicates.
3. Otherwise insert `library_roots`, walk the tree (recurse **all** directories; match audio **files** only by extension).
4. Upsert catalog in batches while walking (partial catalog may remain on failure).
5. **Append to queue only after a full successful walk** (all batches OK, not cancelled).

### Re-scan

- Upsert by `(rootId, sourceItemId)`.
- **Append only newly inserted** catalog tracks (never resurrect queue rows the user removed).
- Hard-delete missing catalog tracks + prune queue **only when**: walk completed, not cancelled, and every upsert batch succeeded.

Add folder and Re-scan intentionally differ: Add folder restores existing
catalog tracks missing from the queue; Re-scan only discovers new files.

### Forget folder

1. Transactionally delete related queue rows, tracks, then the root in Drift.
2. Best-effort `releaseRoot`; on release failure report `library.forget.failed` without restoring rows.

### Single-flight

Only one Add / Re-scan / Forget at a time. Home disables those actions while busy. Cancel stops scheduling new work, awaits in-flight materialize, never prunes.

### Progress

Banner shows `Scanning… n` (files processed). No mandatory two-pass total count. Scan runs on the app isolate (KISS); worker/Drift isolates deferred to Phase 5 perf work.

### Cold start

No auto re-scan. Known roots with missing persisted grants are reported once
per session (`library.root.revoked`); catalog is kept until Forget or a
successful Re-scan. A failed native access check is logged and contained so a
stale plugin cannot escape the post-frame startup callback.

### Queue behavior

- Remove and Clear affect only `queue_entries`; catalog tracks remain indexed.
- Add folder is the explicit refill action after Remove or Clear.
- Adding the same root repeatedly cannot duplicate queue entries.
- Re-scan synchronizes the catalog without restoring manually removed rows.
- Forget followed by Add is a fresh import and refills the queue.

## Data Model

| Table | Role |
| --- | --- |
| `library_roots` | Opaque root locator + display name |
| `tracks` | Catalog identity `(rootId, sourceItemId)`; tags; nullable reserved `artworkCacheRef` / `sizeBytes` / `modifiedAt` (always null in Phase 2) |
| `queue_entries` | Ordered unique `trackId` links |
| `playback_state` | Singleton `id=1`; `currentQueueEntryId` ON DELETE SET NULL; unused for UX until Phase 3–4 |

Identity: `sourceItemId` == item `MediaLocator.value`. `PRAGMA foreign_keys = ON`.

### Audio extensions

`.mp3`, `.flac`, `.m4a`, `.aac`, `.ogg`, `.opus`, `.wav` (case-insensitive).

### Message codes

`library.scan.started` | `library.scan.complete` | `library.scan.cancelled` | `library.scan.failed` | `library.root.revoked` | `library.forget.complete` | `library.forget.failed`

## User Interface

Playlist home: queue list, Add folder, remove row, overflow Clear / Re-scan / Forget (confirms for Clear and Forget), scan banner + Cancel. Transport chrome stays inert until Phase 3.

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
*Last updated: 2026-07-19*
