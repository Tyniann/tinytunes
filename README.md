# TinyTunes

Simple, no-nonsense, local-first Android music player. Add folders, queue tracks, play in the
background. Optional **Google Drive** support is read-only (list / download /
cache — never write to Drive).

**Not on Google Play.** Source and release APKs via GitHub.

| | |
| --- | --- |
| Package | `at.blumenlaube.tinytunes` |
| License | [MIT](LICENSE) |
| Privacy | https://blumenlaube.at/apps/tinytunes/privacy-policy.html |
| Platforms | Android first (iOS later) |
| Latest release | [v1.0.0](https://github.com/Tyniann/tinytunes/releases/tag/v1.0.0) |

## Google Drive / OAuth

| You | What to do |
| --- | --- |
| **Official release APK** (GitHub Releases) | Already wired to the maintainer’s OAuth clients. Install and sign in — Drive works. Google’s verification for `drive.readonly` may still be **pending**, so you might see an “unverified app” warning; that is expected until Google finishes review. |
| **Forks / self-built APKs** | **Bring your own** Google Cloud project + OAuth clients. Replace `serverClientId` in `lib/core/cloud/google_oauth_config.dart`. The committed Client ID is for the official signed APK only — your debug/release SHA-1s will not match. |
| **Contributors (local library only)** | No Google setup needed. SAF local folders never need OAuth. |

Step-by-step for forks: [docs/legal/android-signing-and-oauth.md](docs/legal/android-signing-and-oauth.md).

## Features

- Winamp-style single queue (play / pause / prev / next)
- Shuffle × repeat, background playback / lock screen controls
- Expandable system-volume slider on transport chrome
- Add local folders (including subfolders) via Android SAF
- Optional Google Drive folder ingest + download-then-play cache + cache budget
- Material 3 themes, EN / DE
- In-app About dialog (logo, version, changelog, privacy policy link)

## Requirements

- Flutter **3.41+** / Dart **3.11+** (see `pubspec.yaml`)
- Android device or emulator
- For Drive on **your own** builds/forks only: a Google Cloud project you control (see OAuth doc). Not needed if you only install the official APK.

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

### Drive setup (forks / own builds only)

Skip this if you install the official release APK — OAuth is already configured.

1. Google Cloud Console → enable **Google Drive API**.
2. OAuth consent screen (External, Testing is fine for yourself).
3. Create **Android** OAuth client(s): package `at.blumenlaube.tinytunes` +
   SHA-1 (**one SHA per Android client** — use a second Android client for
   release if needed).
4. Create **Web** OAuth client; copy its Client ID.
5. Set it in `lib/core/cloud/google_oauth_config.dart` (`serverClientId`).
6. Scope used: `https://www.googleapis.com/auth/drive.readonly`.

Do **not** commit client secrets. Android client ID stays Console-only.

### Release signing (optional)

See [docs/legal/android-signing-and-oauth.md](docs/legal/android-signing-and-oauth.md).
`android/key.properties` and `*.jks` are gitignored — never commit them.

## Project layout

Feature-first Flutter app (`lib/features/…`, `lib/core/…`). Domain terms:
[CONTEXT.md](CONTEXT.md). Feature docs: [docs/features/](docs/features/).
ADRs: [docs/adr/](docs/adr/). Changelog: [docs/CHANGELOG.md](docs/CHANGELOG.md).

## Privacy

- [English](https://blumenlaube.at/apps/tinytunes/privacy-policy.html)
- [Deutsch](https://blumenlaube.at/apps/tinytunes/privacy-policy.de.html)
- Also linked from **Settings → About** in the app
- Sources in-repo: [docs/legal/](docs/legal/)

## Contributing

PRs welcome. Keep changes focused; prefer the existing Riverpod / Drift /
`just_audio` + custom `audio_service` stack. Run analyzer/tests before opening
a PR. If you build your own APK and want Drive, use **your** GCP OAuth clients
(see above) — do not rely on the committed maintainer Client ID.

## License

[MIT](LICENSE) © Mario Angerer
