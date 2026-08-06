# Player

## Overview

Foreground and background playback for the single Winamp-style queue. Uses
`just_audio` for decoding and a thin `audio_service` handler for lock-screen /
notification controls. Navigation implements the full Shuffle × Repeat matrix
via pure `QueueNavigator`; the handler stays a thin façade.

## Location

- **Module:** `lib/features/player/`
- **Main Screen:** Transport chrome on `lib/features/playlist/presentation/playlist_home_screen.dart`
- **Related Files:**
  - `lib/features/player/application/playback_controller.dart`
  - `lib/features/player/application/queue_navigator.dart`
  - `lib/features/player/application/shuffle_session.dart`
  - `lib/features/player/application/repeat_mode.dart`
  - `lib/features/player/application/tinytunes_audio_handler.dart`
  - `lib/features/player/application/playback_engine.dart`
  - `lib/features/player/application/just_audio_playback_engine.dart`
  - `lib/features/player/presentation/transport_chrome.dart`
  - `lib/features/player/application/system_volume_source.dart`
  - `lib/features/player/application/device_system_volume_source.dart`
  - `lib/features/player/application/player_providers.dart`
  - `lib/core/library/artwork_cache_store.dart` (capped cover JPEG cache)
  - `lib/main.dart` (bootstrap: `AudioService.init` → handler override → eager controller)

## Functionality

### Bootstrap

1. `AudioService.init` creates a thin `TinyTunesAudioHandler` (no `AudioPlayer`).
2. `ProviderContainer` overrides `audioHandlerProvider` with that instance.
3. Eager `playbackControllerProvider` attach owns the single engine + `audio_session`.
4. Pre-attach OS media intents are no-ops. Tests never call `AudioService.init`.

Activity story: `MainActivity` extends `AudioServiceActivity` so SAF plugin
registration and media-session wiring coexist.

### Transport / home

- Row tap plays an entry; tap current toggles pause.
- Transport: **Shuffle | Prev | Play/Pause | Next | Repeat** + seek bar +
  expandable system-volume slider (speaker toggle left of seek).
- Shuffle and Repeat are always enabled (never greyed); Prev/Play/Next need a current track.
- Queue list stays **canonical** `sortIndex` order (shuffle never reorders the list).
- Current row highlight via `ColorScheme`.
- When `currentQueueEntryId` changes and the row is outside the viewport, the
  list animates to center that row (next / previous / shuffle / natural advance).
- Queue trailing cover thumb (left of remove) when `artworkCacheRef` is set;
  no placeholder — title/artist expand toward remove when art is missing.
- `MediaItem.artUri` set from the capped cover file for notification / lock screen.
- Cloud tracks resolve via `PlaybackUriResolver` (download-then-play + cache); see [cloud-library.md](cloud-library.md).

### Shuffle × Repeat matrix

| Shuffle | Repeat | Complete | Next | Previous (after 3s rule) |
| --- | --- | --- | --- | --- |
| Off | Off | next canonical / stop@last | same; no-op@last | prev canonical; seek0@first |
| Off | All | next; wrap to first | same | prev; wrap to last |
| Off | One | seek0 + replay | advance canonical; wrap at end | prev canonical; seek0 at first |
| On | Off | next in perm / stop@last | same; no-op@last | prev in perm; seek0@first |
| On | All | random excl. current (`len>1`); push history | same | pop history; else seek0 |
| On | One | seek0 + replay | random + push history | pop history; else seek0 |

**Session model (in-memory only):**

- Shuffle+Off: permutation + index (`rebuildFromHead` = current/tap as head + shuffled rest).
- Shuffle+All / One: history stack only (no permutation); empty history when entering those modes.
- Modes (`shuffleEnabled`, `repeatMode`) persist in Drift; **order/history intentionally reset** on process death.

**Row tap:**

- Shuffle Off: play tapped.
- Shuffle+Off: play tapped; rebuild perm with tapped as head.
- Shuffle+All / One: play tapped; push prior current onto history.

**Queue edits:**

- Always prune removed ids from session; append new ids to perm when Shuffle+Off.
- Remove current / unplayable go through `QueueNavigator` (not canonical-only shortcuts).
- Clear / stop clear now-playing but **keep modes**.

| Reason | Shuffle Off | Shuffle+Off | Shuffle+All / One |
| --- | --- | --- | --- |
| Current removed | Canonical suffix; Repeat All wraps; Repeat One cannot loop a removed row | Next living entry after the removed slot in the old permutation | Random living entry excluding the removed row |
| Unplayable | Same successor as Next from the failed row; Repeat All/One wrap | Next living permutation entry; never retry the failed row | Random living entry excluding the failed row |

When no successor exists, playback stops and now-playing/checkpoint are cleared;
shuffle and repeat modes remain unchanged.

Shared seam: `advanceAfterCurrentGone` with `completed` / `manualNext` /
`currentRemoved` / `unplayable`. Proposed session commits only after successful
`setUri`.

### Persist / resume

- Drift `playback_state` singleton: `checkpoint({entryId, positionMs})` and
  `updatePlaybackModes({shuffleEnabled, repeatMode})`.
- Cold start: load queue → apply modes (even if no current) → rebuild/clear
  session → load paused track if still present.
- Throttled position writes (~2s); flush on pause/seek/noisy/interrupt and app
  paused/detached.

### Session policy

- Headset becoming-noisy → pause + checkpoint.
- Interruption begin → pause + checkpoint; **no auto-resume**.
- Swipe-away / task removed → `AudioHandler.onTaskRemoved` → `stop()` (engine +
  `super.stop()`) so the foreground service and notification dismiss promptly.
  Background playback continues while the app is only minimized.
- `just_audio` `play()` is started without awaiting track completion so
  `audio_service` publishes `playing=true` immediately.

### Identity

- Drift/UI: `queueEntryId`
- `MediaItem.id`: `trackId` (string)

## Data Model

`playback_state` (schema v1, no migration): `currentQueueEntryId`, `positionMs`,
`shuffleEnabled`, `repeatMode`. No permutation/history blobs.

## User Interface

Playlist home list + bottom `TransportChrome`. Speaker icon left of the seek bar
expands/collapses a system-volume slider row (OS media volume via
`volume_controller`; hardware buttons stay in sync). Lock-screen / notification
expose play, pause, seek, skip previous/next via the handler façade.

## Dependencies

- `just_audio`
- `audio_service` (direct; **not** `just_audio_background`)
- `audio_session`
- `volume_controller` (system / media volume for transport chrome)
- `image` (cap/encode embedded covers to JPEG)

## Related Features

- [Library ingest](library-ingest.md) — catalog/queue and SAF locators
- [Cloud library](cloud-library.md) — play-path cover enrich + cache wipe of art
- [Online cover fetch](online-cover-fetch.md) — candidate later (opt-in; not shipped)
- [Message center](message-center.md) — player error/info codes

---
*Last updated: 2026-08-06*
