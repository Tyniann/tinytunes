# Feature documentation

Index of TinyTunes feature docs. Each major product module gets a kebab-case file in this folder (see `.cursor/rules/01-dokumentation.mdc`).

## Documented features

- [Theming](theming.md) — Settings theme mode + scheme catalog (`default` seed `#88AA00`)
- [Library ingest](library-ingest.md) — local + cloud catalog, single queue, SAF / Drive scan / forget
- [Cloud library](cloud-library.md) — Google Drive read-only (Android), download-then-play cache
- [Player](player.md) — playback + background, Shuffle × Repeat matrix transport, expandable system volume
- [Message center](message-center.md) — session log, toast pipeline, unread badge

## Later / candidates (not implemented)

- [Online cover fetch](online-cover-fetch.md) — opt-in MusicBrainz / Cover Art Archive fill when `artworkCacheRef` is null at play time

Architecture decisions live in [`docs/adr/`](../adr/). Domain glossary: [`CONTEXT.md`](../../CONTEXT.md).

## Changelog

Notable changes: [`docs/CHANGELOG.md`](../CHANGELOG.md).
