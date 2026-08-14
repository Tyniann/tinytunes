# Legal docs

## Contents

| File | Purpose |
| --- | --- |
| [`privacy-policy.md`](privacy-policy.md) | Privacy policy **draft** (English, GDPR-oriented) — placeholders only |
| [`privacy-policy.de.md`](privacy-policy.de.md) | German **draft** — placeholders only |
| [`android-signing-and-oauth.md`](android-signing-and-oauth.md) | Official APK OAuth (Google Drive + OneDrive) vs **BYO for forks**; optional release signing (no Play) |
| [`microsoft-brand-assets.md`](microsoft-brand-assets.md) | Official OneDrive / Sign in with Microsoft asset inventory + source notes |

## Privacy drafts vs live policy

The Markdown files above are **templates**. They intentionally use placeholders
(`[CONTROLLER LEGAL NAME]`, `[PRIVACY CONTACT EMAIL]`, …) so a fork does **not**
inherit another publisher’s identity as data controller.

- **Forks / redistributors:** fill the placeholders, host your **own** HTTPS policy,
  wire that URL in OAuth consoles and in `lib/core/legal/legal_urls.dart` (or your
  equivalent). Do not point users at someone else’s privacy page while shipping your build.
- **Official TinyTunes builds:** the live HTML used in-app and on consent screens is
  published separately (see root [`README.md`](../../README.md) Privacy links). That
  hosted copy is what users of the official APK see — not the placeholder drafts.

## In-app

Settings → **About TinyTunes** opens a dialog with logo, version, bundled
changelog preview, **Check for updates**, and buttons for:

- Full changelog on GitHub
- Privacy policy (locale-aware EN/DE URL)

Startup also checks GitHub for a newer release (see
[`docs/features/update-check.md`](../features/update-check.md)).

Constants: `lib/core/legal/legal_urls.dart`.
