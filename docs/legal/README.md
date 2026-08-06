# Legal docs

## Contents

| File | Purpose |
| --- | --- |
| [`privacy-policy.md`](privacy-policy.md) | Privacy policy (English, GDPR-oriented) |
| [`privacy-policy.de.md`](privacy-policy.de.md) | German summary / user-facing translation |
| [`android-signing-and-oauth.md`](android-signing-and-oauth.md) | **BYO OAuth** + optional release signing (no Play / no Google verification) |

Live HTML (authoritative for users):  
https://blumenlaube.at/apps/tinytunes/privacy-policy.html

## Hosting / OAuth consent (your GCP project)

TinyTunes uses **bring-your-own OAuth**. If you enable Drive on a fork, point
*your* consent screen at a privacy URL you control (you may link the live
Blumenlaube policy if it still matches your build’s behavior).

## In-app display (recommended)

**Yes — a small link under Settings → About** is the right place.

Suggested UX (keep it light):

1. **Settings → About** section, below version: list row **Privacy policy**.
2. On tap: open https://blumenlaube.at/apps/tinytunes/privacy-policy.html
   (or your fork’s URL) with `url_launcher`.

Do **not** block first launch behind a forced privacy wall for this local-first
app; Google consent already covers Drive when the user signs in.
