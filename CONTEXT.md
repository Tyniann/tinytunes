# TinyTunes — domain context

Single-context mobile audio player. Prefer these terms in issues, PRs, tests, and docs.

## Glossary

| Term | Meaning |
| --- | --- |
| **Catalog** | Indexed library of roots and tracks in Drift. Not the play order. |
| **Queue** | Single Winamp-style ordered playlist (`queue_entries`). One track appears at most once. |
| **Library root** | User-picked folder with durable access (Android: SAF tree URI). |
| **Forget folder** | Remove a root + its catalog tracks + related queue rows, then release the grant. |
| **Queue entry** | Ordered row linking to a catalog track. Removing it does not delete the catalog track. |
| **Track** | Catalog row identified by `(rootId, sourceItemId)`. |
| **MediaLocator** | Opaque serializable locator string (exact Android `Uri.toString()` for local; `gdrive:<fileId>` for Drive; OneDrive uses a drive+item opaque form — see ADR 0003). Never a bare filesystem path as identity. |
| **sourceItemId** | Stable id within a root; Phase 2 equals the item locator string. |
| **sourceKind** | Catalog origin: `local` (SAF) or `cloud` (any cloud provider — Google Drive and personal OneDrive share this kind). |
| **Cloud provider** | Google Drive (`gdrive`) or personal OneDrive (`onedrive`); simultaneous sign-in allowed. Provider-specific files live under `lib/core/cloud/google_drive/` and `lib/core/cloud/one_drive/`. |
| **Cloud ownership** | `library_roots.cloud_provider` + `cloud_account_key` (stable account id, never email). Account replacement requires confirm/cancel. |
| **Winamp queue** | One mutable queue on the home screen — not named multi-playlists. |
| **Single-flight scan** | At most one catalog-mutating Add / Re-scan / Forget at a time. |
| **Add folder** | Import or refill action: refresh the selected root and append its tracks that are not currently queued; never duplicate queue entries. |
| **Re-scan** | Catalog synchronization: append only newly discovered tracks, prune missing files after a safe complete scan, and preserve manual queue removals. |
| **Now playing** | Current queue entry driven by `PlaybackController` / `playback_state`; UI highlight + transport. |
| **Theme catalog** | Named color schemes (unrelated to the music catalog). |

## Avoid

- Named multi-playlists / smart playlists (deferred)
- Plain absolute paths as durable identity
- Confusing **theme catalog** with the **music catalog**

## Key ADRs

- [ADR 0001 — Android local library access via SAF MethodChannel](docs/adr/0001-android-local-library-access.md)
- [ADR 0002 — Google Drive as read-only cloud library (Android)](docs/adr/0002-google-drive-cloud-library.md)
- [ADR 0003 — Personal OneDrive as second read-only cloud library (Android)](docs/adr/0003-onedrive-cloud-library.md)
