# Android signing + Google OAuth (BYO — GitHub only)

TinyTunes is **not** on Google Play and does **not** pursue Google’s public
OAuth verification for Drive. **Bring your own OAuth client.**

## Policy (read this first)

- **Forks / self-built APKs:** create your own GCP project + OAuth clients.
  Replace `serverClientId` in
  [`lib/core/cloud/google_oauth_config.dart`](../../lib/core/cloud/google_oauth_config.dart).
- **Maintainer machine only:** the committed Web Client ID may be used together
  with SHA-1s registered on that private GCP project. It is **not** a public
  multi-user OAuth app.
- **No verification video, no “publish for everyone” requirement** for this
  project’s intended distribution model.
- Local library (SAF) needs **zero** Google setup.

## Create your own Drive OAuth (forks)

1. [Google Cloud Console](https://console.cloud.google.com/) → new or existing project.
2. Enable **Google Drive API**.
3. **OAuth consent screen** (External). Testing + yourself as test user is enough.
4. **Credentials** → Create credentials → OAuth client ID:
   - **Android (debug):** package `at.blumenlaube.tinytunes` + **debug** SHA-1.
   - **Android (release), if you ship signed APKs:** create a **second** Android
     client — same package name, **release** SHA-1. Console allows **one SHA-1
     per Android client** (no “add another fingerprint” on the same client).
   - **Web application:** copy the Client ID into `serverClientId` (one Web
     client is enough for all Android clients in the project).
5. Paste the Web Client ID into `GoogleOAuthConfig.serverClientId`.
6. Scope: `https://www.googleapis.com/auth/drive.readonly`.

Get debug SHA-1:

```bash
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## Release keystore (optional, maintainer / APK distributors)

- `android/tinytunes-release.jks` + `android/key.properties` — **gitignored**
- Template: `android/key.properties.example`
- Release builds use the release keystore when `key.properties` exists; otherwise debug

```bash
keytool -list -v -keystore android/tinytunes-release.jks -alias tinytunes
```

Register that SHA-1 by creating a **second Android OAuth client** (same package,
release SHA). Do not replace the debug client’s SHA unless you no longer need
debug Drive sign-in.

Back up the `.jks` and passwords offline. Losing them means a new signing key
(and a new SHA-1 to register).

## What we deliberately skip

| Google step | TinyTunes stance |
| --- | --- |
| OAuth brand / sensitive-scope verification | Not doing it |
| Demo YouTube video for Drive | Not doing it |
| Play Console / Play App Signing | Not distributing on Play |

Privacy policy (for your own consent screen if you want one):  
https://blumenlaube.at/apps/tinytunes/privacy-policy.html  
In-repo drafts: [docs/legal/](.).
