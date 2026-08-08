# ADR 0003: Personal OneDrive as second read-only cloud library (Android)

- **Status:** Accepted
- **Date:** 2026-08-08
- **Phase:** OneDrive Cloud Parity — Phase 0 (contract + Entra setup)

## Context

TinyTunes already ships a complete read-only Google Drive library behind
`CloudLibrarySource` ([ADR 0002](0002-google-drive-cloud-library.md)). Product
now wants the **same feature surface** for personal OneDrive while keeping
Google Drive available at the same time.

Research on public Microsoft OAuth effort (vs Google’s sensitive-scope path)
lives in [`docs/research/onedrive-oauth-public-effort.md`](../research/onedrive-oauth-public-effort.md).
Verdict for personal MSA + sideloaded GitHub APKs: Microsoft is slightly
easier than Google (no Testing→Production gate, no Files.Read scope-review
queue), with similar Android package + signature-hash binding.

## Decision

### Audience and scopes

- **Android only** for this rollout (iOS deferred).
- **Personal Microsoft accounts only** (Entra “PersonalMicrosoftAccount” /
  consumers authority). No work/school / multi-tenant org audience.
- Root browsing is the user’s own OneDrive **My files** only — no separate
  Shared / Recent / Photos / SharePoint / Teams surface.
- Delegated Microsoft Graph **`Files.Read`** plus MSAL identity scopes
  (`User.Read`, `openid`, `profile`). Do **not** request `offline_access`
  explicitly — personal MSA token responses decline it and `msal_auth` treats
  declined scopes as hard failure; MSAL still caches tokens for silent renew
  after a successful grant. Never `Files.Read.All` or any write scope.
- Read-only forever: list / download / cache only — never create, rename,
  overwrite, move, or delete remote OneDrive content.

### Auth bridge

- Prefer **`msal_auth`** (third-party Flutter wrapper around native MSAL) with
  `SingleAccountPca`, public client (no secret), authorization code + PKCE,
  system browser.
- If the Phase 1 device spike fails hard gates (redirect, silent restore,
  release signature hash, personal-account consent), **keep the Dart
  `OneDriveAuth` interface** and replace only the bridge with a custom
  MethodChannel around official MSAL Android. Do **not** fall back to generic
  AppAuth without a new decision.
- Accept Microsoft’s **“Unverified”** publisher label for the first public
  GitHub APK. Publisher verification is **not** a release gate.

### Multi-provider catalog model

- Keep catalog `sourceKind = cloud` for both providers (do **not** invent
  `cloud_gdrive` / `cloud_onedrive` kinds).
- Provider identity tokens: `gdrive` and `onedrive` (`CloudProviderId`).
- Preserve existing locators: `gdrive:<driveFileId>`.
- OneDrive locators are opaque canonical values containing **both** Graph
  **drive ID** and **item ID**, each component escaped by one shared codec.
  Folder browser may use a non-persisted personal-root sentinel; persisted
  roots and tracks always use stable drive/item IDs.
- Route every `CloudLibrarySource` call by locator prefix through a
  **delegating registry**.
- Add nullable `cloud_provider` + `cloud_account_key` on `library_roots`
  (tracks inherit via `rootId`). Ownership key is the provider’s **stable
  account id**, never mutable email.

### Cache and sessions

- Google Drive and OneDrive may be signed in and used **simultaneously**.
- **One shared** cloud-cache budget and one global “Clear cloud cache”.
- Normal provider **sign-out** clears **only that provider’s** downloaded
  audio/artwork; catalog roots and queue entries remain.
- New downloads land under `cloud_cache/gdrive/...` and
  `cloud_cache/onedrive/...`. Legacy indexed Google paths may age out via
  ordinary deletion/eviction (rows store absolute paths).

### Account replacement (both providers)

- A newly authenticated account cannot silently take ownership of another
  account’s roots for that provider.
- UI confirms replacement: forget that provider’s old roots, tracks, queue
  rows, cache, and artwork; then accept the new account.
- Cancel: auth-only sign-out of the newly authenticated session; retain all
  existing library data.
- Same rules apply to **Google Drive and OneDrive**.

### Code layout

Shared contracts, routing, cache, free-space, and Riverpod composition stay
under `lib/core/cloud/`. Provider-specific auth, locators, remotes, sources,
probes, and OAuth config live under `lib/core/cloud/google_drive/` and
`lib/core/cloud/one_drive/` (mirrored under `test/core/cloud/`). Keep
descriptive provider-prefixed filenames; no ambiguous `auth.dart` barrels.

### Branding

- Use **official** Microsoft OneDrive / Sign in with Microsoft assets and
  brand rules. Do not redraw, recolor, or generate substitutes.
- Asset inventory and source notes:
  [`docs/legal/microsoft-brand-assets.md`](../legal/microsoft-brand-assets.md).

### OAuth distribution

- Official release APK: maintainer’s Entra public client ID + Android redirect
  URIs for debug **and** release signature hashes.
- Forks / self-built APKs: bring your own Entra registration — see
  [`docs/legal/android-signing-and-oauth.md`](../legal/android-signing-and-oauth.md).
- Sideloaded GitHub APKs are supported; no Microsoft Store / Play requirement
  for OAuth binding.
- Never ship a client secret, refresh token, or portal credential JSON.

## Consequences

- Phase 1 proves MSAL sign-in / silent restore / root listing on device before
  feature wiring.
- Phase 2 relocates Google files into `google_drive/` and makes routing +
  scoped cache wipe multi-provider-safe (including Google regression).
- Phases 3–7 add ownership schema, Graph source, UI parity, and public APK
  gates.
- ADR 0002 remains the Google Drive decision; this ADR extends the cloud
  architecture without rewriting local SAF.

## Non-goals

- Work/school / business tenants, tenant-admin consent, publisher verification
- iOS OneDrive in this rollout
- Shared-with-me / Recent / Photos / SharePoint / Teams surfaces
- Multiple simultaneous signed-in OneDrive accounts
- `Files.Read.All`, write scopes, remote mutation
- Per-provider cache budgets, progressive play-while-download
- Changing `sourceKind` away from generic `cloud`

## Phase 0 setup checklist (maintainer)

Manual Entra portal steps (must pass before Phase 1 device spike):

1. Create Entra app registration → **Personal Microsoft accounts only**.
2. Treat as **public client** — do **not** create a client secret.
3. Add Microsoft Graph delegated permission **`Files.Read`** only (plus
   `User.Read` / `openid` / `profile` for MSAL). Do **not** request
   `offline_access` explicitly (personal MSA declines it).
4. Authentication → Add Android platform for package
   `at.blumenlaube.tinytunes` with **debug** signature hash and **release**
   signature hash (two platform entries / redirect URIs).
5. Branding: app name, logo, privacy URL
   `https://blumenlaube.at/apps/tinytunes/privacy-policy.html` (+ ToS if
   available).
6. Record Application (client) ID and `msauth://…` redirect URIs as **public**
   config for Phase 1 (`one_drive_oauth_config.dart`) — never secrets.

Reproducible hash / redirect commands:
[`docs/legal/android-signing-and-oauth.md`](../legal/android-signing-and-oauth.md)
(Microsoft section).

### Phase 0 gate result

**Pass (2026-08-08).** Maintainer Entra registration confirmed:

- Client ID `c2ed77e3-5443-4251-94c2-b6e1916d084d`
- Personal Microsoft accounts only; Android debug + release platforms
- Graph delegated `Files.Read` + `User.Read`; no client secret
- Branding + live privacy/ToS URLs; publisher **Unverified** accepted

---
*Accepted: 2026-08-08*
