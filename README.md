# TinyTunes

Simple, no-nonsense, local-first Android music player. Add folders, queue tracks, play in the
background. Optional **Google Drive** and personal **OneDrive** support is
read-only (list / download / cache — never write to the cloud).

**Not on Google Play.** Source and release APKs via GitHub.

| | |
| --- | --- |
| Package | `at.blumenlaube.tinytunes` |
| License | [MIT](LICENSE) |
| Privacy | https://blumenlaube.at/apps/tinytunes/privacy-policy.html |
| Platforms | Android first (iOS later) |
| Latest release | [v1.1.0](https://github.com/Tyniann/tinytunes/releases/tag/v1.1.0) |

## Cloud OAuth (Google Drive + OneDrive)

| You | What to do |
| --- | --- |
| **Official release APK** (GitHub Releases) | Already wired to the maintainer’s Google + Microsoft clients. Install and sign in. Google may show an “unverified app” warning while `drive.readonly` review is pending; Microsoft may show **Unverified** publisher — both are expected for v1. |
| **Forks / self-built APKs** | **Bring your own** OAuth. Google: replace `serverClientId` in `lib/core/cloud/google_drive/google_drive_oauth_config.dart`. OneDrive: replace Entra `clientId` + Android signature hashes in `lib/core/cloud/one_drive/one_drive_oauth_config.dart` (personal accounts only, `Files.Read`, **no client secret**). Committed IDs are for the official signed APK only. |
| **Contributors (local library only)** | No Google / Microsoft setup. SAF local folders never need OAuth. |

Step-by-step for forks: [docs/legal/android-signing-and-oauth.md](docs/legal/android-signing-and-oauth.md).

## Features

- Winamp-style single queue (play / pause / prev / next)
- Shuffle × repeat, background playback / lock screen controls
- Expandable system-volume slider on transport chrome
- Add local folders (including subfolders) via Android SAF
- Optional Google Drive + personal OneDrive folder ingest, shared download-then-play cache + budget
- Material 3 themes, EN / DE
- In-app About dialog (logo, version, changelog, privacy policy link)

## Requirements

- Flutter **3.41+** / Dart **3.11+** (see `pubspec.yaml`)
- Android device or emulator
- For cloud on **your own** builds/forks only: GCP and/or Entra projects you control (see OAuth doc). Not needed if you only install the official APK.

## Build & run

```bash
git clone https://github.com/Tyniann/tinytunes.git
cd tinytunes
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Release APK (uses `android/key.properties` + keystore if present; else debug key):

```bash
flutter build apk --release
```

### Cloud setup (forks / own builds only)

Skip this if you install the official release APK — OAuth is already configured.

**Google Drive**

1. Google Cloud Console → enable **Google Drive API**.
2. OAuth consent screen (External, Testing is fine for yourself).
3. Create **Android** OAuth client(s): package `at.blumenlaube.tinytunes` +
   SHA-1 (**one SHA per Android client** — use a second Android client for
   release if needed).
4. Create **Web** OAuth client; copy its Client ID.
5. Set it in `lib/core/cloud/google_drive/google_drive_oauth_config.dart` (`serverClientId`).
6. Scope used: `https://www.googleapis.com/auth/drive.readonly`.

**OneDrive (personal Microsoft accounts)**

1. Entra app registration → **Personal Microsoft accounts only**.
2. Public client only — **no** client secret.
3. Graph delegated `Files.Read` (+ MSAL identity scopes). Never `Files.Read.All` or write scopes.
4. Android platform entries for **debug and release** signature hashes
   (`msauth://at.blumenlaube.tinytunes/…`).
5. Paste client ID + hashes into `lib/core/cloud/one_drive/one_drive_oauth_config.dart`.

Do **not** commit client secrets. Full checklist:
[docs/legal/android-signing-and-oauth.md](docs/legal/android-signing-and-oauth.md).

### Release signing (optional)

See [docs/legal/android-signing-and-oauth.md](docs/legal/android-signing-and-oauth.md).
`android/key.properties` and `*.jks` are gitignored — never commit them.

## Project layout

Feature-first Flutter app (`lib/features/…`, `lib/core/…`). Domain terms:
[CONTEXT.md](CONTEXT.md). Feature docs: [docs/features/](docs/features/).
ADRs: [docs/adr/](docs/adr/). Changelog: [docs/CHANGELOG.md](docs/CHANGELOG.md).

## Privacy

- Official builds: [English](https://blumenlaube.at/apps/tinytunes/privacy-policy.html) · [Deutsch](https://blumenlaube.at/apps/tinytunes/privacy-policy.de.html)
- Also linked from **Settings → About** in the app
- In-repo Markdown under [docs/legal/](docs/legal/) is a **draft with placeholders** (forks must substitute their own controller / contact / hosted URL — do not ship another publisher’s identity)

## Contributing

PRs welcome. Keep changes focused; prefer the existing Riverpod / Drift /
`just_audio` + custom `audio_service` stack. Run analyzer/tests before opening
a PR. If you build your own APK and want Drive, use **your** GCP OAuth clients
(see above) — do not rely on the committed maintainer Client ID.

## License

[MIT](LICENSE) © Mario Angerer
