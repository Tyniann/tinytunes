# TinyTunes

Simple, no-nonsense, local-first Android music player. Add folders, queue tracks, play in the
background. Optional **Google Drive** support is read-only (list / download /
cache — never write to Drive).

**Not on Google Play.** Source and (optional) self-built APKs via GitHub only.

| | |
| --- | --- |
| Package | `at.blumenlaube.tinytunes` |
| License | [MIT](LICENSE) |
| Privacy | https://blumenlaube.at/apps/tinytunes/privacy-policy.html |
| Platforms | Android first (iOS later) |
| Latest release | [v0.8.0](https://github.com/Tyniann/tinytunes/releases/tag/v0.8.0) |

## Google Drive = bring your own OAuth (BYO)

TinyTunes does **not** ship a verified, public Google OAuth app for every
GitHub user. Google’s Drive (`drive.readonly`) verification circus (including
demo videos) is intentionally **out of scope**.

| You | What to do |
| --- | --- |
| **Maintainer builds** | May use the Client ID in `lib/core/cloud/google_oauth_config.dart` with SHA-1s registered on that GCP project |
| **Forks / your own APK** | **Create your own** Google Cloud OAuth clients and replace `serverClientId` |
| **Contributors** | Local music works with zero Google setup; Drive needs your own clients |

Local folders (SAF) never need Google.

Step-by-step: [docs/legal/android-signing-and-oauth.md](docs/legal/android-signing-and-oauth.md).

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
- For Drive only: a Google Cloud project you control (see OAuth doc)

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

### Drive setup (forks / own builds)

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
a PR. Drive OAuth for your machine is **your** GCP project (BYO).

## License

[MIT](LICENSE) © Mario Angerer
