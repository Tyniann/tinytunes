---
name: TinyTunes Roadmap
overview: "Hardened phased roadmap for TinyTunes: Android daily driver first, URI-first local library, separate catalog vs Winamp queue, playback+background as one slice, Shuffle×Repeat matrix, extensible theme catalog (seed #88aa00), cloud late."
todos:
  - id: phase-0
    content: "Phase 0: Feasibility gate — codegen proof + Android device spike; MethodChannel SAF adapter selected"
    status: completed
  - id: phase-1
    content: "Phase 1: App shell — routes, messages/toasts, theme plumbing (mode + scheme catalog, seed #88aa00), test harness, docs index, CloudLibrarySource stub"
    status: completed
  - id: phase-2
    content: "Phase 2: Local catalog + single queue — Drift schema, URI-first scan, forget-root, docs"
    status: completed
  - id: phase-3
    content: "Phase 3: Playback + background — PlaybackController, direct audio_service handler, persist/resume paused"
    status: completed
  - id: phase-4
    content: "Phase 4: Shuffle + Repeat matrix (Off/One/All), transport toggles, queue manage polish"
    status: completed
  - id: phase-5
    content: "Phase 5: Android daily-driver hardening — Settings theme mode UI, progress, empty states, scale, tests"
    status: completed
  - id: phase-6
    content: "Phase 6: iOS adapter + playback parity (security-scoped bookmarks; no Drift model rewrite)"
    status: pending
  - id: phase-7
    content: "Phase 7: One read-only cloud provider behind CloudLibrarySource"
    status: pending
  - id: phase-8
    content: "Phase 8: Store readiness — including optional Dynamic (Material You) scheme"
    status: pending
isProject: false
---

# TinyTunes high-level roadmap (hardened)

**Current state (v0.6.0):** Phases 0–5 are implemented and device-verified on
Android. Phase 6 (iOS storage and playback parity) is next.

## Goals and constraints

- **First milestone:** Personal Android daily driver (local folders + background + shuffle), not store-ready.
- **Playlist model:** One Winamp-inspired **queue** — tap title to play; manage actions on the home screen; not named multi-playlists.
- **Catalog vs queue:** Separate Drift entities — indexed library roots/tracks vs ordered queue entries (locked).
- **Platforms:** Android first; iOS implements the same locator/source contracts later (not “path assumptions + late fixes”).
- **Cloud:** Minimal `CloudLibrarySource` **contract stub early**; one provider + implementation only in the cloud phase. Read-only forever (list/download/cache; never remote delete/write/rename).
- **Stack:** Follow `[.cursor/rules/00-allgemeine-projektregeln.mdc](.cursor/rules/00-allgemeine-projektregeln.mdc)`. `[pubspec.yaml](pubspec.yaml)` pins deps. `[lib/main.dart](lib/main.dart)` now bootstraps `AudioService`, Drift-backed providers, eager playback attachment, and the routed app shell.
- **Navigation:** No drawer / bottom nav — playlist home + app-bar Settings and Messages (see IA).

```mermaid
flowchart LR
  P0[P0 Feasibility] --> P1[P1 App shell]
  P1 --> P2[P2 Catalog and queue]
  P2 --> P3[P3 Play plus background]
  P3 --> P4[P4 Shuffle and Repeat]
  P4 --> P5[P5 Android harden]
  P5 --> P6[P6 iOS parity]
  P6 --> P7[P7 Cloud read-only]
  P7 --> P8[P8 Store readiness]
```



---

## Locked product decisions


| Topic                        | Decision                                                                                                                                                                 |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Adding a folder              | Scan into **catalog** and **append all discovered tracks to the queue**                                                                                                  |
| Clear playlist               | Empties the **queue only** — catalog/roots untouched                                                                                                                     |
| Remove track                 | Removes **queue entry only** — catalog row stays                                                                                                                         |
| Forget folder                | Explicit action: drop root + its catalog tracks + related queue entries                                                                                                  |
| Cold-start resume            | Restore track + position; start **paused**                                                                                                                               |
| Messages                     | Bounded **in-memory session** store (no Drift persistence for v1)                                                                                                        |
| Playback phases              | **One slice:** `just_audio` + `audio_session` + direct `audio_service` with custom `TinyTunesAudioHandler`                                                              |
| Shuffle / Repeat             | Two transport controls — see **Playback modes** below (full matrix in Phase 4)                                                                                           |
| Android folder access        | Narrow MethodChannel SAF adapter (`AndroidLocalLibrarySource` + `SafLibraryPlugin`); `file_picker` is not used for durable roots                                      |
| Re-scan missing files        | After a **complete successful** re-scan: **hard-delete** missing catalog tracks and prune related queue entries. Partial/failed/cancelled scans must **not** mass-delete |
| Theme mode (v1)              | **System / Light / Dark** in Settings                                                                                                                                    |
| Theme schemes                | **Catalog** of named schemes; each scheme supplies light + dark `ThemeData`. v1 ships only `default`                                                                     |
| Brand seed                   | `#88aa00` for the `default` scheme                                                                                                                                       |
| Dynamic color (Material You) | **Not** in daily driver; add optional **Dynamic** scheme at **store readiness** (Phase 8)                                                                                |


**Why hard-delete (not “unavailable”):** Dead queue rows are worse UX for a Winamp-style list. The safety net is scan completeness: only prune after a full successful walk so a cancelled or permission-lost scan cannot wipe the library.

**Playback / settings persistence:** Queue + playback state live in **Drift**. `shared_preferences` is settings-only (theme mode/scheme id). Locale follows the OS with an English fallback for unsupported languages (no in-app language prefs in v1).

---

## Playback modes (locked) — Shuffle × Repeat

Two independent transport controls (icons on playlist/transport chrome; **not** Settings):


| Control     | Values                  |
| ----------- | ----------------------- |
| **Shuffle** | Off / On                |
| **Repeat**  | Off → One → All (cycle) |


No greying out — every combination has defined behavior.


| Shuffle | Repeat | Behavior                                                                                                         |
| ------- | ------ | ---------------------------------------------------------------------------------------------------------------- |
| Off     | Off    | Canonical queue order; **stop** at end                                                                           |
| Off     | All    | Canonical order; **loop** whole queue                                                                            |
| Off     | One    | Loop **current** track                                                                                           |
| On      | Off    | Random **permutation**; each track **exactly once**; **stop** at end                                             |
| On      | All    | **With-replacement** random next; continues **indefinitely**                                                     |
| On      | One    | Loop **current** track; on **Next**, advance (random pick if Shuffle on, else next in order) and loop that track |


**Other locked rules:**

- Turning **Shuffle off** restores **canonical** queue order; keep current track if still in the queue.
- **Previous:** walk permutation / history stack (Shuffle+All uses play history — not a new random jump).
- Queue edits: append new imports at end of canonical order (and of permutation when Shuffle+Off); Shuffle+All uses the updated set for the next pick.
- Persist `currentQueueEntryId`, `positionMs`, `shuffleEnabled`, and `repeatMode`
  in Drift `playback_state`. Shuffle permutation/history are session-only and
  intentionally reset on process death.

```mermaid
flowchart TB
  subgraph controls [Transport toggles]
    ShuffleBtn[Shuffle Off or On]
    RepeatBtn[Repeat Off One All]
  end
  controls --> Matrix[Combination matrix]
  Matrix --> Player[PlaybackController plus QueueNavigator]
```



---

## Theming architecture (locked — extensible without rewrite)

Two independent knobs:


| Knob       | Controls                                                             | Persistence          | v1 UI                                                                   |
| ---------- | -------------------------------------------------------------------- | -------------------- | ----------------------------------------------------------------------- |
| **Mode**   | System / Light / Dark                                                | `shared_preferences` | Settings control (wired when Settings is filled; plumbing earlier)      |
| **Scheme** | Named palette family (`default`, later `highContrast`, `dynamic`, …) | `shared_preferences` | Hidden or single-scheme until more exist; Dynamic only at store release |


```mermaid
flowchart LR
  Prefs[shared_preferences]
  Mode[AppThemeMode]
  SchemeId[schemeId]
  Catalog[ThemeCatalog]
  Prefs --> Mode
  Prefs --> SchemeId
  Mode --> Resolve[resolveThemeData]
  SchemeId --> Catalog
  Catalog --> Resolve
  Resolve --> MaterialApp[MaterialApp.router theme]
```



**Code shape (Phase 1):**

- `AppThemeMode` enum + prefs read/write (Riverpod).
- `ThemeCatalog` / `AppThemeScheme` — maps `schemeId` → factory that builds light and dark `ThemeData` from a seed (Material 3 `ColorScheme.fromSeed`).
- v1: one entry `default` with seed `Color(0xFF88AA00)`.
- `MaterialApp.router` uses `theme` / `darkTheme` / `themeMode` from the resolver — **never** hard-code colors in feature widgets; use `Theme.of(context)` / color scheme tokens.
- Later schemes = new catalog entries (no feature rewrite). Full Winamp-style **skins** (alternate layouts) stay out of scope; this architecture does not block adding a separate skin layer later if ever needed.

**Phase mapping:** plumbing + default scheme in **Phase 1**; Settings mode picker in **Phase 5** (Settings fill); optional Dynamic scheme in **Phase 8**.

---

## Information architecture (locked)


| Element                  | Choice                                                      |
| ------------------------ | ----------------------------------------------------------- |
| Primary screen           | Queue list + transport chrome (home)                        |
| Side drawer / bottom nav | No                                                          |
| Settings                 | App-bar gear → `/settings`                                  |
| Message center           | App-bar icon + unread badge → `/messages`                   |
| Playlist actions         | On home (add folder, clear, remove, shuffle, forget folder) |


```mermaid
flowchart TB
  Home[PlaylistHome]
  Settings[SettingsRoute]
  Messages[MessageCenterRoute]
  Home -->|"app bar gear"| Settings
  Home -->|"app bar messages + badge"| Messages
```



---

## Message center + toasts (locked)


| Channel          | Role                                                         |
| ---------------- | ------------------------------------------------------------ |
| `toastification` | Short ephemeral feedback                                     |
| Message center   | Session log: severity + stable **ref** + message + timestamp |


- **API frozen in Phase 1:** e.g. `reportError` / `reportInfo` (controllers map failures once → message + toast). No `BuildContext` / toast calls inside repositories.
- **Unread:** created since Messages was last opened; mark read on open.
- **Bound:** max entries + eviction (oldest first) so large scans cannot grow forever.
- **Storage:** in-memory for daily driver; no cross-restart persistence unless revisited later.

---

## Cross-phase acceptance rules

- Every phase ends with codegen (when touched), analyze, tests, and an Android run; platform behavior needs a **physical-device** check where relevant.
- Public Flutter APIs get `///` intent docs immediately.
- Feature modules update `docs/features/`, `docs/features/README.md`, and `docs/CHANGELOG.md` **in the same phase** they land (not batched into Phase 5).
- Localize user-visible strings in the phase that introduces them (ARB incremental).
- Failures reported once with a stable ref.
- No scan deletion after cancel, permission loss, or partial traversal.
- No remote write/delete/rename at the cloud boundary.

---

## Phase 0 — Feasibility and dependency gate

**Status: Completed. Outcome:** The stack and durable Android folder access
were proven before product UI work.

- Prove `build_runner` generates Riverpod, Freezed, Drift, JSON, and typed routes in one clean run; analyze + tests. Prefer a disposable smoke fixture over an empty production DB. **Repin packages** if analyzer overrides cannot produce clean codegen.
- **Android device spike:** select folder → retain access after process death/reboot → recursive enumerate → read tags/artwork for one file → play that file.
- Storage decision: the spike showed `file_picker` 11.x cannot retain/list
  durable trees, so TinyTunes ships a **narrow native MethodChannel SAF
  adapter** (ADR 0001). Domain identity remains opaque `MediaLocator` values,
  never plain filesystem paths.
- Define contracts (no heavy UI): `MediaLocator`, `LocalLibrarySource`, `TrackMetadataReader`, and minimal read-only `CloudLibrarySource` stub. Local adapter resolves opaque items to a playback URI and, if needed, a temporary readable path/stream for tag extraction (bounded, deleted after use).

**Exit:** Clean codegen/analyze/test + documented Android device proof for durable access, metadata, and playback. Storage adapter direction chosen.

---

## Phase 1 — App shell and shared infrastructure

**Status: Completed. Outcome:** Locked IA shell + frozen message/toast pipeline
with theme plumbing + test harness.

- Feature-first folders: `lib/features/...`, `lib/shared/...`, `lib/core/...`.
- `MaterialApp.router` + typed `go_router_builder` routes: `/`, `/settings`, `/messages`.
- Playlist home shell established the app-bar routes; its body and transport
  were subsequently filled by Phases 2–4. Settings theme/About UI landed in Phase 5.
- Material 3 + **theme architecture**: `AppThemeMode`, `ThemeCatalog` with `default` scheme seed `#88aa00`, prefs-backed providers; `theme` / `darkTheme` / `themeMode` wired.
- Localization-aware shell.
- Bounded in-memory message store + toast helper; badge/read behavior (Phase 1 demo report path removed in Phase 5).
- `test/helpers/pump_app.dart` with `ProviderScope` + router overrides; fix scaffold widget test.
- Bootstrap `docs/features/README.md` and `docs/CHANGELOG.md`.
- Keep `CloudLibrarySource` as contract-only (no provider).

**Exit:** Navigate Settings/Messages on Android; toast + message + badge work; light/dark/system resolve correctly with green seed; tests use the harness.

---

## Phase 2 — Local catalog and single queue

**Status: Completed. Outcome:** Folders form a durable catalog and Winamp queue
that survive restart.

### Schema v1 (Drift)

- `library_roots` — opaque root locator, display name, `sourceKind`, `addedAt`
- `tracks` — `(rootId, sourceItemId)` unique; opaque locator, display name,
  nullable title/artist/album; `sizeBytes`, `modifiedAt`, and `artworkCacheRef`
  are reserved and currently null
- `queue_entries` — ordered links to `tracks` (order lives here, not on tracks)
- `playback_state` — singleton: `currentQueueEntryId`, `positionMs`,
  `shuffleEnabled`, `repeatMode`; no permutation/history columns

`sourceKind` shipped on roots and tracks so later cloud entries do not require
reworking local identity.

### Semantics

- Add folder: upsert catalog and append every discovered track not currently
  queued. Selecting an existing root refills missing queue rows without
  creating duplicates.
- Re-scan: upsert by identity and append only newly discovered catalog tracks;
  manually removed queue rows stay removed. After a **complete successful**
  scan, **hard-delete** missing tracks and prune queue; partial failure → no
  mass-delete.
- Remove queue row ≠ delete catalog. Clear queue ≠ forget roots. **Forget folder** removes root + catalog + related queue rows.
- SAF-first: no broad storage permission unless a concrete API requires it.
- Scan on the app isolate (KISS) with bounded metadata concurrency and batched
  Drift writes; progress is “Scanning… n”. Worker/isolate optimization deferred
  until measure-first smoke proves jank (not required for Phase 5 exit).
- Manual re-scan (not every cold start) unless later product change.
- Feature docs for library ingest in this phase.

**Exit:** Nested folder survives restart/reboot; Add refills without duplicates;
explicit Re-scan preserves manual removals; Forget → Add is a fresh import;
revoked access is reported; queue order persists.

---

## Phase 3 — Playback + background (one vertical slice)

**Status: Completed. Outcome:** Foreground/background playback shipped without
a later `main()` rewrite.

- `AudioService.init` creates a thin `TinyTunesAudioHandler` before `runApp`;
  the provider container overrides the handler and eagerly attaches
  `PlaybackController`. `just_audio_background` is not used.
- One application-lifetime `PlaybackController` owns
  `JustAudioPlaybackEngine` and `audio_session`; every source carries stable
  track id + `MediaItem` metadata.
- UI: row tap to play, play/pause, prev/next, seek, current-row highlight.
  Cover UI/cache is not implemented; `artworkCacheRef` remains unused.
- Lock-screen / notification controls; headset noisy + interruption policy.
- Persist playback state in Drift on track change / seek / pause (throttled position); cold start restores **paused** if item still available.
- Missing/unplayable tracks report through toast + message center and advance
  through the bounded `AdvanceReason.unplayable` path; Phase 5 owns further UX
  polish.
- Feature docs for player in this phase.

**Exit:** Foreground + background, controls, interruptions, and process recreation pass on a physical Android device.

---

## Phase 4 — Shuffle, Repeat, and queue management polish

**Status: Completed and Android device-verified. Outcome:** Full Shuffle ×
Repeat matrix on the single queue with reliable prev/next.

- Transport chrome: **Shuffle** toggle + **Repeat** cycle (Off / One / All) — see [Playback modes](#playback-modes-locked--shuffle--repeat).
- Implement matrix behaviors exactly (permutation + stop; with-replacement infinite; Repeat One + Next advances then loops).
- Keep **canonical** queue order separate from shuffle permutation / play history.
- Persist `shuffleEnabled` + `repeatMode` in Drift `playback_state`; restore toggles on cold start.
  Shuffle permutation / play history are **in-memory only** (intentionally reset on process death).
- Clear queue and Forget folder have destructive confirmations. No drag-reorder.

**Exit:** All six Shuffle×Repeat combinations match the matrix; prev/next and queue edits behave as locked;
**toggles + checkpoint survive process death; shuffle order/history intentionally reset.**

---

## Phase 5 — Android daily-driver hardening

**Status: Completed and Android device-verified. Outcome:** Reliable personal
use on a documented device smoke checklist.

- Harden the existing scan banner/cancellation and single-flight flow
  (`IngestPhase.picking`); improve queue-empty, revoked-root, and message UX.
- Artwork cache cleanup begins only when cover caching is implemented. Message
  history is already bounded; clear-all / severity filter deferred.
- Settings filled for daily use: **theme mode** (System / Light / Dark) + About;
  queue actions stay on home. No scheme picker (only `default`).
- Extended ingest / home / settings / shell tests; large-library device smoke
  passed. Schema stays v1 (no migration suite). Scan remains app-isolate
  (measure-first; isolates only as a follow-up if jank appears).
- Feature docs/changelog updated with the harden.

**Exit:** Day-to-day Android daily driver — met.

---

## Phase 6 — iOS storage and playback parity

**Outcome:** Same catalog/queue/player contracts on iOS — adapter work, not schema rewrite.

- Implement iOS `LocalLibrarySource` with **security-scoped access/bookmarks** (or explicitly document import-to-sandbox only if bookmarks prove impossible — prefer bookmarks).
- Background audio mode; metadata, interruptions, lock screen, relaunch, revoked folder access on a **real device**.
- Changing Drift domain semantics here means Phase 0–2 failed the locator gate.

**Exit:** Same contracts pass on iOS without redesigning persistence.

---

## Phase 7 — Read-only cloud sync

**Outcome:** One provider behind the existing `CloudLibrarySource` contract.

- List / download / cache only; playback uses validated local cache locators.
- Stable remote source IDs; eviction never mutates remote content.
- Provider SDK chosen in this phase only.

**Exit:** Cloud folder → cached tracks play offline; read-only scope verified.

---

## Phase 8 — Store readiness

**Outcome:** Public release quality after personal use is proven.

- Privacy, listings, icons, splash, accessibility, permission copy.
- Performance on large libraries; signing, versioning, changelog discipline.
- Migration tests before treating daily-driver data as durable release data.
- **Theming:** add optional **Dynamic** scheme (Material You / wallpaper-derived colors on supported Android); keep `default` (`#88aa00`) as the brand fallback. Expose scheme picker in Settings once more than one scheme ships.

---

## What we deliberately defer

- Named multi-playlists / smart playlists / drag-reorder (unless needed)
- Drawer / bottom navigation (revisit if destinations multiply after cloud)
- Extra color schemes beyond `default` until wanted; **Dynamic** until Phase 8
- Full visual **skins** (custom layouts) — separate from the scheme catalog
- Equalizer, lyrics, social, writing tags back to files
- Message persistence across restarts
- Cloud provider choice until Phase 7

## Suggested build rhythm

Vertical slices: prove access → shell → catalog/queue → play+background → shuffle/repeat → harden. Each phase leaves Android runnable; docs and i18n travel with the feature.