# ADR 0002: Google Drive as read-only cloud library (Android)

- **Status:** Accepted
- **Date:** 2026-08-06
- **Phase:** 7 Step 0 (OAuth / listing gate)

## Context

TinyTunes Phase 7 adds one read-only cloud provider behind `CloudLibrarySource`
(list / download / cache only — never remote write/delete/rename). Product
locked **Google Drive** with user OAuth, Android-only for this phase (iOS
storage parity remains Phase 6 and is skipped for now).

Local catalog identity already uses opaque `MediaLocator` strings and a
`sourceKind` column so cloud roots/tracks can coexist without rewriting Drift
domain semantics.

## Decision

### Provider and scopes

- Use **Google Drive API v3** with scope
  `https://www.googleapis.com/auth/drive.readonly`.
- Authenticate via `google_sign_in` **7.x**:
  - **Android OAuth client** in Google Cloud Console (package
    `at.blumenlaube.tinytunes` + signing SHA-1) — Console-only; not embedded in
    the app.
  - **Web application OAuth client ID** passed as `serverClientId` on
    `GoogleSignIn.initialize` (required on Android without Firebase /
    `google-services.json`).
- Do **not** add Firebase or ship OAuth `client_secret` / credential JSON in the
  repo.

### Locator identity

Cloud roots and items use:

```text
MediaLocator.value = gdrive:<driveFileId>
```

Helpers live in `DriveMediaLocator` (`lib/core/cloud/drive_media_locator.dart`).
Never use filesystem paths as durable cloud identity.

### Auth → API bridge

Obtain a Drive access token from
`GoogleSignInAccount.authorizationClient` (`authorizationForScopes` then
`authorizeScopes` if needed). Call `googleapis` Drive with a thin
`GoogleAccessTokenClient` (Bearer header). Prefer this over
`extension_google_sign_in_as_googleapis_auth` until proven necessary — keeps the
dependency surface small for `google_sign_in` 7.x.

### Step 0 spike surface

Settings hosts a temporary Google Drive section: Sign in → List My Drive →
Sign out. Listing proves OAuth + Drive API before ingest/cache/playback land in
later Phase 7 steps. Step 4 will expand this into account + cache budget UI.

### Device proof matrix (Step 0)

| # | Check | Result |
| --- | --- | --- |
| 1 | Settings → Sign in with Google (test user on OAuth consent) | **Pass** on A065 |
| 2 | Authorize `drive.readonly` when prompted | **Pass** |
| 3 | List My Drive shows folders/files with `gdrive:` locators | **Pass** (e.g. `Musik`, `backups`, files) |
| 4 | Sign out returns to Sign in | Spot-check optional (button present; not blocking) |
| 5 | No remote create/delete/rename performed by the app | Pass by design (list-only spike) |

**Device:** Nothing A065 (`a0cc96e2`), debug APK.  
**Debug SHA-1:** registered on the Android OAuth client (Console-only; not required in-repo).

### Implementation findings (Step 0)

- `google_sign_in` **7.2**: use `initialize(serverClientId:)`, then `authenticate(scopeHint:)`, then
  `GoogleSignInAccount.authorizationClient.authorizationForScopes` /
  `authorizeScopes` — not the 6.x `GoogleSignIn(scopes: …)` constructor.
- Bridged Drive with a thin Bearer `http.BaseClient` (`GoogleAccessTokenClient`); did **not** add
  `extension_google_sign_in_as_googleapis_auth` (keeps surface small with 7.x).
- Web Client ID is required as `serverClientId` without Firebase; Android client stays Console-only
  (package `at.blumenlaube.tinytunes` + SHA-1 above).
- Settings hosts a temporary Drive spike section (Sign in / List My Drive / Sign out); Step 4 will
  replace/extend it with cache budget UI.

## Consequences

- Phase 7 Steps 1+ implement `GoogleDriveCloudLibrarySource` and cache on top of
  the same auth + locator conventions.
- Catalog rows for cloud use `sourceKind = cloud`.
- Sign-out (later) wipes local cloud cache only; Drive content is never mutated.
- Adding another cloud provider later means a new `CloudLibrarySource` impl +
  locator scheme — not a rewrite of local SAF.

## Non-goals

- iOS Google Sign-In / Drive (deferred with Phase 6)
- Progressive play-while-download
- Firebase / `google-services.json`
- Shared-drive-specific UX beyond default Drive API visibility for the user
- Writing, renaming, or deleting remote Drive files
