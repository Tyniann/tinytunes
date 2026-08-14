# Android signing + cloud OAuth

TinyTunes is **not** on Google Play. Distribution is via GitHub (source +
optional release APKs).

## Policy (read this first)

| Distribution | Google Drive OAuth | OneDrive (Microsoft) OAuth |
| --- | --- | --- |
| **Official release APK** (GitHub Releases) | Preconfigured Google Cloud OAuth clients (`serverClientId` in [`google_drive_oauth_config.dart`](../../lib/core/cloud/google_drive/google_drive_oauth_config.dart) + Android clients for release SHA-1). Google’s sensitive-scope / brand **verification may still be pending** — users can see an “unverified app” warning until review completes. | Preconfigured Entra **public** client ID + Android `msauth://` redirect URIs for debug **and** release signature hashes. Microsoft consent may show **“Unverified”** until publisher verification (deferred — not a release gate). |
| **Forks / self-built APKs** | **Bring your own** GCP project + OAuth clients. Replace `serverClientId`. Register **your** debug and (if applicable) release SHA-1s. | **Bring your own** Entra app registration (personal accounts only). Replace the public client ID and register **your** debug/release signature hashes. |
| **Local library (SAF)** | Needs **zero** Google / Microsoft setup. | Same. |

Privacy policy:

- **Official APK** consent / in-app link: live HTML on the publisher’s host (see root README).
- **In-repo** [`privacy-policy.md`](privacy-policy.md) / [`.de.md`](privacy-policy.de.md): **drafts with placeholders** — forks must fill controller identity, host their **own** HTTPS policy, and must not reuse another publisher’s URL or name as controller.

Related ADRs: [0002 Google Drive](../adr/0002-google-drive-cloud-library.md),
[0003 OneDrive](../adr/0003-onedrive-cloud-library.md).  
OAuth effort research: [onedrive-oauth-public-effort.md](../research/onedrive-oauth-public-effort.md).

## Update check (forks)

The app contacts GitHub for updates **only** when the installed APK is the
official GitHub build: package `at.blumenlaube.tinytunes` **and** the official
**release** signing certificate. Forks, self-built APKs, and debug/`flutter run`
builds do not ping GitHub and do not show Check for updates.

To check *your* releases instead, change `OfficialRelease` in
`lib/core/updates/official_release.dart` (repo + your release cert hash).
Full behavior: [`docs/features/update-check.md`](../features/update-check.md).

---

## Google Drive OAuth (forks)

1. [Google Cloud Console](https://console.cloud.google.com/) → new or existing project.
2. Enable **Google Drive API**.
3. **OAuth consent screen** (External). Testing + yourself as test user is enough for personal builds.
4. **Credentials** → Create credentials → OAuth client ID:
   - **Android (debug):** package `at.blumenlaube.tinytunes` + **debug** SHA-1.
   - **Android (release), if you ship signed APKs:** create a **second** Android
     client — same package name, **release** SHA-1. Console allows **one SHA-1
     per Android client** (no “add another fingerprint” on the same client).
   - **Web application:** copy the Client ID into `serverClientId` (one Web
     client is enough for all Android clients in the project).
5. Paste the Web Client ID into `GoogleOAuthConfig.serverClientId`.
6. Scope: `https://www.googleapis.com/auth/drive.readonly`.

### Google SHA-1 (hex, colon-separated)

Debug:

```bash
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Release (when `android/tinytunes-release.jks` + `android/key.properties` exist):

```bash
keytool -list -v -keystore android/tinytunes-release.jks -alias tinytunes
```

Register that SHA-1 by creating a **second Android OAuth client** (same package,
release SHA). Do not replace the debug client’s SHA unless you no longer need
debug Drive sign-in.

---

## OneDrive / Microsoft Entra OAuth (maintainer + forks)

### Portal checklist

1. [Microsoft Entra admin center](https://entra.microsoft.com/) → **App registrations** → **New registration**.
2. **Supported account types:** **Personal Microsoft accounts only**
   (`PersonalMicrosoftAccount` / consumers). Do **not** select work/school
   multi-tenant for this product decision.
3. Record **Application (client) ID** (public).
4. Treat the app as a **public client**. Do **not** create a client secret or
   certificate for the mobile APK.
5. **API permissions** → Microsoft Graph → Delegated → **`Files.Read`**.
   Add `openid` / `profile` / `User.Read` as required by MSAL. Do **not**
   request `offline_access` explicitly for personal accounts — the token
   endpoint may decline it and `msal_auth` fails the whole acquire (MSAL still
   caches tokens for silent renew after a successful grant). Never
   `Files.Read.All` or write scopes.
6. **Authentication** → **Add a platform** → **Android**:
   - Package name: `at.blumenlaube.tinytunes`
   - Signature hash: **debug** base64 hash (see below)
   - Add a **second** Android platform entry for the **release** signature hash
     (do not overwrite debug).
7. Copy the generated redirect URIs (shape
   `msauth://at.blumenlaube.tinytunes/<URL_ENCODED_SIGNATURE_HASH>`).
8. Branding: display name, logo, privacy URL above (+ ToS URL if available).
9. Paste the client ID + signature hashes into
   `lib/core/cloud/one_drive/one_drive_oauth_config.dart` (public config only).

Publisher verification and Partner Program setup are **out of scope** for v1
personal OneDrive. Expect the consent UI **“Unverified”** label.

### Microsoft Android signature hash (base64 of cert SHA-1)

MSAL / Entra Android platform registration needs the **Base64** encoding of the
signing certificate’s **SHA-1** bytes (not the colon-hex Google form). The
redirect URI uses the **URL-encoded** form of that Base64 string.

#### Debug (PowerShell)

```powershell
$keytool = "C:\Program Files\Java\jdk-11.0.14\bin\keytool.exe"  # adjust to your JDK
$tmp = Join-Path $env:TEMP "tinytunes-debug.cer"
& $keytool -exportcert -alias androiddebugkey `
  -keystore "$env:USERPROFILE\.android\debug.keystore" `
  -storepass android -keypass android -file $tmp
$sha1 = [System.Security.Cryptography.SHA1]::Create().ComputeHash(
  [System.IO.File]::ReadAllBytes($tmp))
$b64 = [Convert]::ToBase64String($sha1)
$enc = [Uri]::EscapeDataString($b64)
Write-Host "signatureHash=$b64"
Write-Host "redirectUri=msauth://at.blumenlaube.tinytunes/$enc"
Remove-Item $tmp
```

#### Release (PowerShell; uses local gitignored keystore)

```powershell
$keytool = "C:\Program Files\Java\jdk-11.0.14\bin\keytool.exe"  # adjust to your JDK
# Load android/key.properties yourself — never commit passwords.
$tmp = Join-Path $env:TEMP "tinytunes-release.cer"
& $keytool -exportcert -alias tinytunes `
  -keystore android/tinytunes-release.jks `
  -storepass "<STORE_PASSWORD>" -keypass "<KEY_PASSWORD>" -file $tmp
$sha1 = [System.Security.Cryptography.SHA1]::Create().ComputeHash(
  [System.IO.File]::ReadAllBytes($tmp))
$b64 = [Convert]::ToBase64String($sha1)
$enc = [Uri]::EscapeDataString($b64)
Write-Host "signatureHash=$b64"
Write-Host "redirectUri=msauth://at.blumenlaube.tinytunes/$enc"
Remove-Item $tmp
```

#### Maintainer values recorded at Phase 0 (package `at.blumenlaube.tinytunes`)

These are **public** binding values (same class as Google SHA-1), not secrets:

| Item | Value |
| --- | --- |
| Application (client) ID | `c2ed77e3-5443-4251-94c2-b6e1916d084d` |
| Audience | Personal Microsoft accounts only (`PersonalMicrosoftAccount` / `consumers`) |
| Graph delegated permissions | `Files.Read`, `User.Read` (no write / no `Files.Read.All`) |

| Build | Signature hash (Base64) | Redirect URI |
| --- | --- | --- |
| Debug | `kNrKEKVATPOALWoi2IiGqfnphGM=` | `msauth://at.blumenlaube.tinytunes/kNrKEKVATPOALWoi2IiGqfnphGM%3D` |
| Release | `yA+8T1x4a9pYEu1mYe58Quq7f5Y=` | `msauth://at.blumenlaube.tinytunes/yA%2B8T1x4a9pYEu1mYe58Quq7f5Y%3D` |

**Entra registration recorded (2026-08-08):** branding, both Android platforms, and
Graph permissions confirmed by maintainer. Publisher domain remains
`*.onmicrosoft.com` → consent shows **Unverified** (accepted). Live privacy +
ToS URLs on blumenlaube.at are configured. Public client ID + signature hashes
live in `lib/core/cloud/one_drive/one_drive_oauth_config.dart`.

### Manifest / MSAL notes

- Intent-filter / `BrowserTabActivity` host = package name; path = `/` + Base64
  signature hash (not URL-encoded in the manifest path).
- MSAL JSON `redirect_uri` uses the **URL-encoded** Base64 form.
- Never enable confidential-client secret flows for the APK.

---

## Release keystore (optional, maintainer / APK distributors)

- `android/tinytunes-release.jks` + `android/key.properties` — **gitignored**
- Template: `android/key.properties.example`
- Release builds use the release keystore when `key.properties` exists; otherwise debug

Back up the `.jks` and passwords offline. Losing them means a new signing key
(and new Google SHA-1 **and** Microsoft signature hash registrations).

## What we deliberately skip

| Step | TinyTunes stance |
| --- | --- |
| Play Console / Play App Signing | Not distributing on Play |
| Google sensitive-scope wait before shipping APKs | Official APKs may ship while verification is **pending** |
| Microsoft publisher verification | Deferred; accept “Unverified” for personal MSA |
| Work/school / multi-tenant Entra audience | Out of scope (personal OneDrive only) |
| Client secrets in the APK or repo | Forbidden |

Brand assets for OneDrive / Sign in with Microsoft:
[`microsoft-brand-assets.md`](microsoft-brand-assets.md).
