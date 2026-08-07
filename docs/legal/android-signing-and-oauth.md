# Android signing + Google OAuth

TinyTunes is **not** on Google Play. Distribution is via GitHub (source +
optional release APKs).

## Policy (read this first)

| Distribution | OAuth |
| --- | --- |
| **Official release APK** (GitHub Releases) | Preconfigured with the maintainer’s Google Cloud OAuth clients (`serverClientId` in [`google_oauth_config.dart`](../../lib/core/cloud/google_oauth_config.dart) + Android clients registered for the release signing SHA-1). Install, sign in, use Drive. Google’s sensitive-scope / brand **verification may still be pending** — users can see an “unverified app” warning until review completes. |
| **Forks / self-built APKs** | **Bring your own** GCP project + OAuth clients. Replace `serverClientId`. Register **your** debug and (if applicable) release SHA-1s. The committed Client ID will not work for builds signed with your keystore. |
| **Local library (SAF)** | Needs **zero** Google setup. |

## Create your own Drive OAuth (forks)

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
| Play Console / Play App Signing | Not distributing on Play |
| Waiting on verification before shipping APKs | Official APKs may ship while verification is **pending**; expect Google’s unverified-app warning until approved |

Forks that only need Drive for themselves can stay on OAuth **Testing** + test users and skip brand verification entirely.

Privacy policy (for consent screen / users):  
https://blumenlaube.at/apps/tinytunes/privacy-policy.html  
In-repo drafts: [docs/legal/](.).
