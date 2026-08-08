# Cloud library (Google Drive + OneDrive)

## Overview

Android-only **read-only** cloud library behind `CloudLibrarySource`: sign in to
Google Drive and/or personal OneDrive, add a remote folder to the catalog/queue,
download-then-play into a shared local cache, and manage cache budget / clear /
provider-scoped sign-out wipe — never create, rename, overwrite, move, or delete
remote files.

Both providers may be signed in and used **simultaneously**. Catalog rows use
`sourceKind = cloud`; ownership is stamped with `cloud_provider` +
`cloud_account_key` on the library root.

## Location

- **Module:** `lib/core/cloud/`
- **Main Screen:** Settings (per-provider account sections + shared cache);
  home **Add folder** → device / Google Drive / OneDrive
- **Related Files:**
  - Shared: `cloud_library_source.dart`, `delegating_cloud_library_source.dart`,
    `cloud_provider_id.dart`, `cloud_cache_store.dart`, `cloud_cache_budget.dart`,
    `cloud_providers.dart`, `cloud_account_ownership.dart`
  - Google: `google_drive/` (auth, OAuth config, remote, source, locators)
  - OneDrive: `one_drive/` (MSAL auth, OAuth config, Graph remote, source, locators)
  - UI: `drive_folder_browser_dialog.dart`, `library_source_picker_dialog.dart`,
    Settings cloud sections, `microsoft_branding.dart` /
    `microsoft_brand_assets.dart`
  - Ingest: `library_ingest_controller.dart` (`addCloudFolder(provider:)`)
  - Playback: `playback_uri_resolver.dart` (download-then-play)
  - ADRs: [`0002`](../adr/0002-google-drive-cloud-library.md),
    [`0003`](../adr/0003-onedrive-cloud-library.md)
  - Setup: [`android-signing-and-oauth.md`](../legal/android-signing-and-oauth.md)
  - Brand assets: [`microsoft-brand-assets.md`](../legal/microsoft-brand-assets.md)

## Functionality

### Sign in / Sign out (Settings)

- **Google Drive:** `drive.readonly` via `google_sign_in`.
- **OneDrive:** personal Microsoft accounts only; Graph delegated `Files.Read`
  (+ identity scopes MSAL needs) via `msal_auth`. Work/school tenants are out of
  scope. Microsoft consent may show **Unverified** until publisher verification
  (accepted for v1).
- On app start, `main` eagerly builds both session controllers so prior platform
  sessions restore.
- **Normal sign-out** clears that provider’s session and wipes **only that
  provider’s** downloaded audio/artwork. Catalog roots and queue entries remain
  until Forget.
- **Global Clear cloud cache** wipes cache for all providers; catalog/queue stay.

### Account replacement

If the user signs in with a different account than the one that owns existing
roots for that provider, Settings shows confirm/cancel:

- **Confirm:** forget that provider’s old roots, tracks, queue rows, cache, and
  artwork; accept the new account.
- **Cancel:** sign out the newly authenticated session; leave existing library
  data untouched.

Ownership keys are stable provider account ids, never email.

### OAuth distribution

| Distribution | Google Drive | OneDrive |
| --- | --- | --- |
| **Official release APK** | Maintainer GCP clients; end users sign in without setup (unverified-app warning possible while Google review pending). | Maintainer Entra public client + debug/release `msauth://` redirects (Unverified publisher accepted). |
| **Forks / self-built APKs** | BYO GCP clients; replace `serverClientId` in `google_drive_oauth_config.dart`. | BYO Entra app (personal accounts only, no client secret); replace `clientId` + signature hashes in `one_drive_oauth_config.dart`. |

Details: [`docs/legal/android-signing-and-oauth.md`](../legal/android-signing-and-oauth.md).

### Add cloud folder (home)

1. Home **+** → **This device** / **Google Drive** / **OneDrive** (official marks).
2. Cloud path requires that provider’s signed-in session (else toast / message).
3. Folder browser: Google **My Drive** or OneDrive **My files** (virtual root
   itself is not selectable).
4. **Also load subfolders?** yes/no.
5. Walk into catalog + append queue (same single-flight gate as local); stamp
   `cloud_provider` / `cloud_account_key`.
6. Tags stay empty at ingest (`displayName` from remote); filled once on play
   when the file is already local (download or cache hit).

Locators:

- Google: `gdrive:<fileId>`
- OneDrive: `onedrive:<driveId>/<itemId>` (escaped components). Browser-only
  sentinel `onedrive:me` is never persisted as a root/track.

### Playback

- Local tracks: SAF resolve as before.
- Cloud tracks: cache hit → play file; miss → home **Downloading…** + progress
  → download under `cloud_cache/gdrive/…` or `cloud_cache/onedrive/…` → shared
  LRU budget → play.
- After a local file exists, missing tags and/or cover art are read once via
  `audiotags` and written to the track row / artwork cache. No download solely
  for tags or art; remotes are never mutated.
- Cover files under application support (`artwork/<trackId>.jpg`, capped
  ~512px JPEG). Deleted with the same cloud-cache triggers as audio. Art does
  not count toward the GB budget.
- Failures use the existing unplayable / auto-advance path.

### Cache eviction

| Trigger | Behavior |
| --- | --- |
| Remove queue row / Clear queue | Delete that track’s cache file(s) + artwork; **catalog track + tags remain** |
| After download | Enforce shared budget LRU (prefer non-queued; never now-playing) |
| Settings slider lower | Persist prefs + enforce once |
| Clear cloud cache | Wipe all providers’ cache files + Drift rows + artwork for those tracks |
| Forget cloud root | Catalog + queue rows for root + cache/art for those tracks |
| Provider sign-out | Wipe **that** provider’s cache/art only |

### Settings budget

One shared slider **512 MB–32 GB**, step **512 MB**, default **2 GB**; label
`Cloud cache limit: X.X GB`. Enabled independent of either provider’s busy state.

## Data Model

- Roots/tracks: `sourceKind = cloud`.
- `library_roots.cloud_provider` (`gdrive` / `onedrive`) and
  `cloud_account_key` (stable account id).
- Table `cloud_cache_entries`: `trackId`, `remoteLocator`, `localPath`,
  `sizeBytes`, `lastAccessedAt`.

## User Interface

- Home: Add folder source picker, downloading strip with progress.
- Settings: Google + OneDrive account rows (email, Sign in/out, replacement
  dialogs), shared budget slider, Clear cloud cache (confirm).
- Official OneDrive / Microsoft sign-in assets — see brand-assets doc.

## Dependencies

- Google: `google_sign_in`, `googleapis` (Drive v3), `http`
- OneDrive: `msal_auth` (native MSAL bridge), Graph HTTP
- Android free space via `StoragePlugin` / `StatFs`

## Related Features

- [Library ingest](library-ingest.md)
- [Player](player.md)

## End-to-end smoke matrix (device)

1. Keep Google and OneDrive signed in simultaneously.
2. Import flat and recursive folders from both into one queue.
3. Play uncached tracks from each; observe progress, tags/album/artwork; replay from cache.
4. Remove/re-add entries, clear queue, lower shared budget, clear all cloud cache.
5. Remotely add/delete test files → rescan → verify queue/catalog/cache/art.
6. Forget one provider’s root; the other remains intact.
7. Sign each provider out separately; only that provider’s cache clears.
8. Offline / expired or revoked consent / 404 / insufficient space / interrupted download.
9. Confirm remotes remain structurally and byte-wise unchanged (read-only).

Release-APK acceptance (fresh personal Microsoft account, Unverified consent only,
plus Google regression) is tracked in the OneDrive parity plan Phase 7 manual gate.

---
*Last updated: 2026-08-08*
