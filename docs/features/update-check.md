# Update check

## Overview

TinyTunes is distributed as a GitHub Release APK, not via Google Play. On a
semi-regular interval the app asks GitHub for the latest release and, when that
tag is newer than the installed `PackageInfo.version`, shows a dialog with a
link to the release page. v1 does **not** download or install the APK.

## Location

- **Module:** `lib/core/updates/`
- **UI:** `lib/features/settings/presentation/update_check_binder.dart`,
  `update_available_dialog.dart`, About in `about_app_dialog.dart`
- **Related Files:**
  - `app_semver.dart` — numeric `major.minor.patch` compare (not string order)
  - `github_release_client.dart` — `GET /repos/Tyniann/tinytunes/releases/latest`
  - `update_check.dart` — interval / dismiss / prompt policy
  - `update_preferences.dart` — last-check time + dismissed tag
  - `update_providers.dart` — Riverpod wiring
  - `official_release.dart` — official GitHub repo, application id, release cert hash
  - `installed_signing_hash.dart` — Android MethodChannel for the installed signer

## Functionality

### Scheduled check

After first frame on each cold start, [UpdateCheckBinder] runs a scheduled
check **only if this install is the official GitHub APK** (package
`at.blumenlaube.tinytunes` **and** the official release signing certificate).
Forks, debug builds, and self-signed APKs never contact GitHub. When the
install is official, GitHub is contacted at most once per **24 hours**
(persisted last-check time). The request is not on the critical path of launch.
Offline, timeout, or non-200 responses fail silently — no toast, no
message-center row.

GitHub `/releases/latest` skips drafts and prereleases. Compare `tag_name`
(optional leading `v`) to `pubspec.yaml` / `PackageInfo.version`. Build numbers
(`+12`) are not part of the tag and are ignored.

### Prompt

When a newer tag is found, a dialog offers **View on GitHub** (opens `html_url`
in the browser) and **Later**. Later stores the normalized tag so the same
version is not shown again on scheduled checks. A *newer* tag after that will
prompt again. Opening the release page does not dismiss the tag (the next 24h
window can remind the user if they did not install).

This is a product dialog, not a session message. The message center is
session-only and toasts on report; an update is a durable “there is a new APK”
event.

### Manual check

Settings → About → **Check for updates** (official APK only) always hits GitHub
(ignores the 24h window and a previous Later on the same tag). The button is
hidden on unofficial builds. Up to date / failure use a short SnackBar. A newer
release uses the same dialog as the scheduled path.

### Version source of truth

GitHub release tags must stay aligned with the `version:` name in
`pubspec.yaml` (the `1.2.0` in `1.2.0+12`). That name is what
`PackageInfo.version` reports. The `+build` is Android `versionCode` only.

## Data Model

Prefs (not Drift):

- `updates.lastCheckedAtMs` — UTC millis of last *successful* GitHub fetch
- `updates.dismissedVersion` — normalized core version the user deferred

Failed fetches do not update last-checked, so the next cold start may retry.

## User Interface

- Startup: one `AlertDialog` when a newer official release exists
- About: Check for updates + version line already shown in that dialog

## GitHub API

Unauthenticated `GET https://api.github.com/repos/Tyniann/tinytunes/releases/latest`
with `Accept: application/vnd.github+json`, `X-GitHub-Api-Version: 2022-11-28`,
and a `User-Agent` (GitHub rejects requests without one). Unauthenticated limit
is 60 requests/hour/IP; once per day per device is well under that.

The JSON includes `tag_name`, `html_url`, and APK `assets` (name
`tinytunes-*.apk`, content type `application/vnd.android.package-archive`,
optional `digest: sha256:…`). v1 only uses tag + HTML URL. Asset URL and SHA-256
are parsed so a later in-app install can reuse the same client.

No extra Dart packages for v1: `package_info_plus`, `http`, `url_launcher`, and
`shared_preferences` were already in the app. Store-oriented packages
(`upgrader`, `new_version_plus`, `in_app_update`) assume Play / App Store
listings and do not match GitHub APK distribution.

## Later: in-app download and install (not in v1)

Planned Android-only extension: download the release APK and hand it to the
system installer. iOS cannot sideload an equivalent of a GitHub APK.

### Package choice: `ota_update`

Use **[`ota_update`](https://pub.dev/packages/ota_update)** (7.1.0, MIT,
maintained). It downloads the APK (progress events on Android), stores it in
app-private storage, and fires the install intent. TinyTunes will own the
progress UI (the plugin no longer uses DownloadManager notifications).

Opt into `usePackageInstaller: true` if we want install-progress events; we
still cannot silent-install a normal sideloaded app — the system installer
sheet always appears. Pass GitHub’s asset SHA-256 as `sha256checksum` when
present. Pick the APK asset by `.apk` name / Android package content type, not
“first asset”.

Current official APKs are large (~74 MB). Download must not stall playback and
must not load the whole file into Dart memory.

**Not `r_upgrade`:** last published years ago, fewer adopters, extra surface
(hot/increment upgrade, store jumps, notification XML) we would not use. Revisit
only if it becomes clearly more maintained and more widely used than
`ota_update`.

**Not** Play `in_app_update` (not on Play) and **not** Shorebird (Dart code
push, not a full APK release).

### Official package / signature only

GitHub is contacted (v1 notify **and** later in-app install) only when:

1. `PackageInfo.packageName` is `at.blumenlaube.tinytunes`, and
2. the installed APK is signed with the **official release keystore**
   (`OfficialRelease.androidReleaseSignatureHash`, same public Base64 SHA-1 as
   the Entra Android redirect)

Package name alone is not enough: this repo’s `applicationId` is the same for
forks until they change it. Maintainer `flutter run` debug builds use the debug
keystore and also skip GitHub.

Android needs `REQUEST_INSTALL_PACKAGES` and the user granting “Install unknown
apps” for TinyTunes when in-app install lands. Same release keystore as the
installed APK. Play Protect may still warn on sideload.

## Forks / self-built APKs

| What | What to expect |
| --- | --- |
| Scheduled / manual check | **No GitHub request.** No update dialog. About has no Check for updates |
| Later in-app install | Same gate: official application id **and** official release signature |
| Your own update stream | Point `OfficialRelease` (owner/repo + release cert hash) at your fork. Bring your own OAuth clients as already documented |

Do not expect the official APK to overlay a fork that kept the same application
id but uses a different signing key.

## Privacy

Startup and manual checks on the **official release APK** contact
`api.github.com`. GitHub sees the device IP and a TinyTunes `User-Agent`.
Forks and debug builds do not make this request. No library, account, or
listening data is sent. Hosted privacy policy covers this; see Settings → About.

## Dependencies

- `package_info_plus`, `http`, `url_launcher`, `shared_preferences` (existing)
- Later: `ota_update` (not added in v1)

## Related Features

- [Theming](theming.md) — About lives on Settings with theme controls
- [Message center](message-center.md) — not used for update prompts

---
*Last updated: 2026-08-14*
