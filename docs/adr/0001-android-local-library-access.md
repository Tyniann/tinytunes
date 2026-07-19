# ADR 0001: Android local library access via SAF MethodChannel

- **Status:** Accepted
- **Date:** 2026-07-19
- **Phase:** 0 (feasibility gate)

## Context

TinyTunes must index user-picked folders with durable access across process death and reboot, without baking filesystem paths into the domain model. Locked `file_picker` **11.0.2** returns a path/URI string from directory pick but does **not** call `takePersistableUriPermission` / expose durable tree listing. `audiotags` **1.4.5** is path-only. Playback via `just_audio` can consume `content://` URIs directly on Android.

## Decision

Ship a **narrow MethodChannel SAF adapter** (`AndroidLocalLibrarySource` + `SafLibraryPlugin`) as the Android `LocalLibrarySource` implementation:

| Channel method | Role |
| --- | --- |
| `pickAndPersistTree` | `ACTION_OPEN_DOCUMENT_TREE` + persistable **READ** grant |
| `listChildren` | One-level listing via `DocumentsContract` (not `DocumentFile.listFiles` for recursion) |
| `copyToCache` | Stream copy to a temp path for path-only tag readers (size budget) |
| `hasPersisted` / `listPersisted` / `release` | Grant diagnostics and forget-folder hygiene |

Opaque identity is `MediaLocator.value` = exact Android `Uri.toString()`:

- **Root:** tree URI (`content://…/tree/…`)
- **Item:** document-under-tree URI (`…/tree/…/document/…`) — do not intermix kinds

### Contract mapping

| Need | API |
| --- | --- |
| Playback URI | `LocalLibrarySource.resolvePlaybackUri` → `Uri.parse(locator.value)` (`content://`) |
| Tag/artwork path | `materializeReadablePath(item, fileNameHint: displayName)` → temp file with real extension; caller deletes in `finally` |
| Tags | `TrackMetadataReader.read(path)` (`AudiotagsTrackMetadataReader`) |

Temp materialize budget: **100 MiB** hard max. Temp files must keep the source extension (e.g. `.mp3` / `.flac`); extension-less temps cause `AudioTagsError.openFile` (“No format could be determined”).

Do **not** add `READ_EXTERNAL_STORAGE` / `READ_MEDIA_*` / `MANAGE_EXTERNAL_STORAGE` for this path.

## Device proof matrix

- **Device:** Nothing A065 (Pong), Android API 36
- **Trees exercised:** `Music/mix` (nested), `Music/The Offspring - Americana (1998)` (FLAC >20 MiB)

| # | Check | Result |
| --- | --- | --- |
| 1 | Select folder | Pass |
| 1b | Locator is `content://…/tree/…` | Pass (`primary%3AMusic…`) |
| 2 | Persist after process kill | Pass |
| 2b | URI in persisted permissions (read) | Pass |
| 3 | Survive reboot | Pass |
| 4 | Recursive enumerate (≥2 levels, DocumentsContract) | Pass |
| 5 | Metadata title/artist + artwork bytes | Pass |
| 5b | Temp >20 MiB within budget (`Pay The Man.flac` ~67 MiB) | Pass |
| 6 | Playback prefers direct `content://` | Pass (no temp required for play) |
| 7 | Optional external SD tree | Skipped |

## Dependencies / pin set (codegen proof)

Proven clean `build_runner` (Riverpod, Freezed, Drift, JSON, go_router_builder) with:

| Package | Pin / note |
| --- | --- |
| `flutter_riverpod` | `3.3.1` |
| `riverpod_annotation` | `4.0.2` |
| `riverpod_generator` | `4.0.3` (4.0.4 needs analyzer ^12) |
| `freezed` | `3.2.5` (analyzer ≥9 \<11) |
| `analyzer` | override `10.0.1` |
| `freezed_annotation` | override `^3.1.0` (audiotags wants ^2) |
| `mockito` | override `5.6.3` (5.7 needs analyzer ^13) |
| `drift` / `drift_dev` | `2.34.0` |
| `file_picker` | `^11.0.2` (not used for durable roots) |

Gradle: `kotlin.incremental=false` on this machine (pub cache on `C:` + project on `D:` breaks Kotlin incremental caches).

## Consequences

- Phase 2 Drift schema stores opaque `MediaLocator` strings, never absolute paths as identity.
- iOS bookmarks are Phase 6 adapter work behind the same contracts.
- Cloud remains `UnimplementedCloudLibrarySource` until Phase 7.
- `file_picker` 12.x beta may assist picker UX later but must not leak into domain types; listing/open stay on this channel (or equivalent).

## Non-goals

- iOS security-scoped bookmarks (Phase 6)
- Cloud provider SDK (Phase 7)
- Drift catalog/queue schema (Phase 2)
- Background playback / lock-screen controls via `audio_service` + `TinyTunesAudioHandler` (Phase 3; not `just_audio_background`)
