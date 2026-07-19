# Player

## Overview

Foreground and background playback for the single Winamp-style queue. Uses
`just_audio` for decoding and a thin `audio_service` handler for lock-screen /
notification controls. Phase 3 hardcodes Shuffle Off / Repeat Off; Phase 4 will
extend navigation behind the same handler.

## Location

- **Module:** `lib/features/player/`
- **Main Screen:** Transport chrome on `lib/features/playlist/presentation/playlist_home_screen.dart`
- **Related Files:**
  - `lib/features/player/application/playback_controller.dart`
  - `lib/features/player/application/tinytunes_audio_handler.dart`
  - `lib/features/player/application/playback_engine.dart`
  - `lib/features/player/application/just_audio_playback_engine.dart`
  - `lib/features/player/presentation/transport_chrome.dart`
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
- Transport: previous / play-pause / next + seek bar (position/duration).
- Current row highlight via `ColorScheme`.
- No cover art (`artworkCacheRef` unused).

### Off/Off navigation (Phase 3)

| Event | Behavior |
| --- | --- |
| Complete (not last) | Autoplay next by `sortIndex` |
| Complete (last) | Keep entry, position ≈ end, paused |
| Next at last | No-op |
| Prev | If position > 3s → seek 0; else previous; no wrap |
| Remove / forget current | Successor = old suffix ∩ new queue; **autoplay** |
| Clear queue | Stop; clear checkpoint; no autoplay |
| Unplayable | Report + skip to next after candidate; bound N=5 |

Shared seam: `advanceAfterCurrentGone({required AdvanceReason reason})` with
`completed` / `manualNext` / `currentRemoved` / `unplayable`.

### Persist / resume

- Drift `playback_state` singleton via atomic `checkpoint({entryId, positionMs})`.
- Commit in-memory current / `MediaItem` / checkpoint **only after successful `setUri`**.
- Cold start: restore paused from controller `build` (once-flag); session-only
  messages until toasts are ready.
- Throttled position writes (~2s); flush on pause/seek/noisy/interrupt and app
  paused/detached.

### Session policy

- Headset becoming-noisy → pause + checkpoint.
- Interruption begin → pause + checkpoint; **no auto-resume**.
- Swipe-away / task removed → `AudioHandler.onTaskRemoved` → `stop()` (engine +
  `super.stop()`) so the foreground service and notification dismiss promptly.
  Background playback continues while the app is only minimized.
- `just_audio` `play()` is started without awaiting track completion so
  `audio_service` publishes `playing=true` immediately (keeps the media
  session / silent media notification alive under background).

### Identity

- Drift/UI: `queueEntryId`
- `MediaItem.id`: `trackId` (string)

## Data Model

Uses existing `playback_state` (no migration): `currentQueueEntryId`, `positionMs`,
plus unused Phase 4 placeholders `shuffleEnabled` / `repeatMode`.

## User Interface

Playlist home list + bottom `TransportChrome`. Lock-screen / notification expose
play, pause, seek, skip previous/next via the handler façade.

## Dependencies

- `just_audio`
- `audio_service` (direct; **not** `just_audio_background`)
- `audio_session`

## Related Features

- [Library ingest](library-ingest.md) — catalog/queue and SAF locators
- [Message center](message-center.md) — player error/info codes

---
*Last updated: 2026-07-19*
