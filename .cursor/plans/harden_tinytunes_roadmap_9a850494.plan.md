---
name: Harden TinyTunes Roadmap
overview: The roadmap has the right product sequence, but Phase 1 is currently blocked by mobile folder-access assumptions and several persistence boundaries are ambiguous. This hardened version adds a feasibility gate, separates catalog/queue/playback state, integrates background concerns with the first player slice, and moves tests/docs into each phase.
todos:
  - id: phase-0
    content: Prove compatible codegen and durable Android folder access before schema work.
    status: pending
  - id: phase-1
    content: Build the typed app shell, bounded message/toast pipeline, test harness, and documentation index.
    status: pending
  - id: phase-2
    content: Implement separate local catalog and ordered queue persistence with safe idempotent scanning.
    status: pending
  - id: phase-3
    content: Deliver one application-lifetime player with foreground and background playback together.
    status: pending
  - id: phase-4
    content: Define and implement deterministic shuffle and queue-management semantics.
    status: pending
  - id: phase-5
    content: Harden Android daily use with failure states, scale checks, tests, and current docs.
    status: pending
  - id: phase-6
    content: Implement persistent iOS folder access and complete real-device playback parity.
    status: pending
  - id: phase-7
    content: Add one read-only cloud provider behind the predeclared contract.
    status: pending
  - id: phase-8
    content: Complete store, privacy, accessibility, migration, and release readiness.
    status: pending
isProject: false
---

# Hardened TinyTunes roadmap

## Assessment

The product direction in [`.cursor/plans/tinytunes_roadmap_d322b16d.plan.md`](.cursor/plans/tinytunes_roadmap_d322b16d.plan.md) is sound: Android-first, one Winamp-style queue, local before cloud, and vertical slices. The plan should not be implemented unchanged.

### Blocking issues

- **Durable folder access is not designed.** Phase 1 assumes `file_picker` directory selection produces a reusable recursive path. The installed `file_picker` 11.0.2 only returns a resolved path and does not retain Android SAF tree access; its own implementation can return `/` or `null` for protected locations. `audiotags` 1.4.5 accepts a filesystem path only. Add a device-backed storage spike before defining Drift locators or scan code.
- **The code-generation stack is outside declared compatibility.** [`pubspec.yaml`](pubspec.yaml) forces analyzer 10.0.1, while the resolved `riverpod_generator` 4.0.4 declares analyzer 12.x, `freezed` 3.2.5 declares analyzer below 11, and `drift_dev` accepts 10–12. Phase 0 must prove all generators together or repin packages before feature work.
- **Catalog and playlist are conflated.** “Tracks in Drift,” “playlist order,” remove, clear, and rescan do not define whether a track is indexed content or a queue entry. Use separate source roots, catalog tracks, and ordered queue entries even though only one queue is exposed.
- **Storage locators cannot be plain paths.** Persist an opaque source locator plus a stable source item ID/relative path. This prevents the Android-first schema from baking in assumptions that fail for SAF, iOS security-scoped URLs, and later cloud cache entries.

### High-priority corrections

- Reword “project already scaffolded”: [`pubspec.yaml`](pubspec.yaml) declares the stack, but [`lib/main.dart`](lib/main.dart) contains only a minimal `ProviderScope` + gen-l10n shell. Routing, Drift, feature folders, messages, toasts, audio, and file access are all still unimplemented.
- Build background metadata, one long-lived `AudioPlayer`, and `just_audio_background` initialization into the first playback architecture. The current [`AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml) and [`Info.plist`](ios/Runner/Info.plist) contain none of the required service, foreground-service, wake-lock, or background-audio configuration.
- Treat iOS storage as an adapter implementation, not late “permission fixes.” Persistent external-folder access requires security-scoped access/bookmarks; the project currently targets iOS 13 in [`ios/Runner.xcodeproj/project.pbxproj`](ios/Runner.xcodeproj/project.pbxproj).
- Resolve the rule conflict around cloud: the workspace rule requires the `CloudLibrarySource` architecture to be locked in v1, while the roadmap defers the interface to Phase 7. Add only the minimal read-only contract early; keep all provider code in the cloud phase.
- Persist queue and playback state in Drift. The “Drift (or prefs)” wording is incompatible with the rule that `shared_preferences` is settings-only.
- Create/update feature docs, [`docs/features/README.md`](docs/features/README.md), and [`docs/CHANGELOG.md`](docs/CHANGELOG.md) in the phase that introduces each module. Do not defer documentation to Phase 5.
- Add tests with each phase. The existing [`test/widget_test.dart`](test/widget_test.dart) is only a scaffold test and will need a `ProviderScope`-based app harness once providers/routes are introduced.

## Revised phases

### Phase 0 — Feasibility and dependency gate

- Prove `build_runner` can generate Riverpod, Freezed, Drift, JSON, and typed routes in one clean run; then run analyze/tests. Use a disposable smoke fixture if necessary rather than committing an empty production database solely for this proof. Repin instead of relying on incompatible overrides if the proof fails.
- On a representative Android device, prove: select a folder, retain access after process death/reboot, recursively enumerate nested files, read one track’s metadata/artwork, and play it.
- Choose the storage adapter only after the spike. Acceptable directions are a narrowly scoped native SAF adapter or a deliberately accepted prerelease package; do not silently rely on `File`/`Directory` paths.
- Define `MediaLocator`, `LocalLibrarySource`, `TrackMetadataReader`, and the minimal read-only `CloudLibrarySource` contract. The local adapter must resolve one opaque item to a playback URI and, separately, a temporary readable path/stream when metadata extraction requires it. Keep provider/platform details behind these contracts.

**Exit:** clean codegen/analyze/test plus an Android device proof for durable folder access, metadata, and playback.

### Phase 1 — App shell and shared infrastructure

- Add typed routes for `/`, `/settings`, and `/messages`; retain the one-screen IA.
- Add Material 3, localization-aware route/widget tests, toast presentation, and a bounded in-memory session message store.
- Keep UI concerns out of repositories: controllers map a failure once to a message-center entry and a toast event. Define unread as “created since Messages was last opened” and mark entries read on opening.
- Bootstrap `docs/features/README.md` and `docs/CHANGELOG.md`. Avoid an empty Drift schema solely to demonstrate codegen.

**Exit:** navigation, localized shell, message badge/read behavior, toast presentation, and tests work on Android.

### Phase 2 — Local catalog and single queue

- Introduce Drift schema version 1 with `library_roots`, `tracks`, `queue_entries`, and singleton `playback_state` (plus artwork-cache references if needed).
- Give tracks a unique `(rootId, sourceItemId)` identity and retain source locator, relative path/display name, size/modified metadata, availability, and tag fields. Queue entries own order; tracks do not.
- Define user semantics: first root import appends discovered tracks; rescan updates the catalog and appends only genuinely new tracks; removing a queue entry does not delete the catalog; clear empties the queue; forgetting a root removes its catalog and related queue entries.
- Scan off the UI path with bounded metadata concurrency and batched Drift writes. Reconcile missing files only after a complete successful scan; a partial/failed scan must not mass-delete tracks.
- Under SAF, avoid broad storage permission. If `audiotags` needs a temporary materialized file, bound disk use and delete it after extraction; benchmark this during the Phase 0 spike.
- Localize user-visible scan/player errors from their first phase; do not postpone localization until the Settings phase.

**Exit:** a folder with nested audio survives restart/reboot, idempotent rescans do not duplicate tracks, revoked access is reported, and queue order persists.

### Phase 3 — Playback and background as one vertical slice

- Initialize `just_audio_background` before `runApp`, configure `audio_session`, and own exactly one non-`autoDispose` player through an application-lifetime provider/controller.
- Build every audio source with stable track ID and `MediaItem` metadata from the start. Keep queue mutations synchronized with the player while preserving the current track when possible.
- Deliver row-to-play, play/pause, previous/next, seek, notification/lock-screen controls, headset/noisy handling, and interruption policy.
- Persist current queue entry/track and a throttled position checkpoint in Drift; restore only if the item is still available. Resume playback paused unless an explicit product decision says otherwise.

**Exit:** foreground and background playback, controls, interruptions, process recreation, and missing-current-file behavior pass on an Android device.

### Phase 4 — Shuffle and queue management

- Preserve canonical queue order separately from effective shuffled order.
- Define toggle behavior, previous-track history, newly appended items, current-track stability, and cold-start restoration. Persist a seed/order when exact restoration is required.
- Add remove/clear confirmations where destructive; defer drag reorder unless it is needed for daily use.

**Exit:** shuffle never loses or duplicates entries, previous/next semantics are repeatable, and toggling off restores canonical order.

### Phase 5 — Android daily-driver hardening

- Add scan progress/cancellation, empty/revoked/missing-file states, artwork-cache cleanup, and bounded message history.
- Add DAO/migration tests, scanner tests with fake sources/metadata, player-controller tests with a fake adapter, widget tests with provider overrides, and physical-device smoke tests.
- Fill only useful settings (locale/theme/about). Keep queue actions on home.
- Maintain feature docs and changelog throughout Phases 2–5.

**Exit:** the Android daily-driver flow is reliable on a documented device/API matrix and representative large library.

### Phase 6 — iOS storage and playback parity

- Implement/validate the iOS local-source adapter using security-scoped access/bookmarks or explicitly choose import-to-sandbox semantics.
- Add background audio mode and validate metadata, interruptions, lock-screen controls, relaunch, and revoked folder access on a real device.
- Do not claim parity from simulator smoke tests alone.
- Treat Phase 6 as the platform implementation of the locator/source contracts already fixed in Phase 0–2; changing the Drift model here is a failed earlier gate.

**Exit:** the same catalog/queue contracts pass on iOS without changing domain persistence semantics.

### Phase 7 — Read-only cloud source

- Implement one provider behind the already locked `CloudLibrarySource`; scopes remain list/download/cache only.
- Give remote items stable source IDs and explicit cache state. Playback consumes only validated local cache locators; eviction never mutates remote content.

**Exit:** remote listing, download, offline playback, cache eviction, and read-only scope verification pass.

### Phase 8 — Store readiness

- Keep the existing privacy, accessibility, permission-copy, performance, signing, versioning, and listing work.
- Add migration tests before treating existing daily-driver data as durable release data, despite pre-production backward compatibility being a non-goal.

## Cross-phase acceptance rules

- Every phase ends with codegen, format, analyze, unit/widget tests, and an Android run; platform behavior gets a physical-device test.
- Every new/modified public Flutter API receives the required `///` intent documentation.
- Every feature module/screen updates feature documentation, index, and changelog in the same phase.
- Failures are reported once with a stable reference; services do not directly require `BuildContext` or invoke toast UI.
- No scan deletion occurs after cancellation, permission loss, or partial traversal.
- No remote write/delete/rename API enters the cloud boundary.