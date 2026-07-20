# Message center

## Overview

Bounded in-memory session log for TinyTunes. Controllers report once via a frozen API; the app shows a short toast and appends a row to the Messages screen. Unread badge math uses a monotonic watermark (not timestamps).

## Location

- **Module:** `lib/core/messages/`
- **Main Screen:** `lib/features/messages/presentation/messages_screen.dart`
- **Related Files:**
  - `session_message.dart` / `session_message_store.dart`
  - `message_reporter.dart`
  - `toast_delivery.dart` / `toastification_toast_delivery.dart`
  - `message_providers.dart`
  - Home badge: `lib/features/playlist/presentation/playlist_home_screen.dart`

## Functionality

### Report API

Call sites pass an already-localized `message` and a stable machine `code`:

- `reportInfo({required String code, required String message})`
- `reportError({required String code, required String message})`

Repositories must not call toasts or touch `BuildContext`.

### Toast delivery

`ToastDelivery` is the test seam. Production uses `ToastificationToastDelivery` under a root `ToastificationWrapper`. Tests override with `NoopToastDelivery` and assert store/badge/list only.

### Unread watermark

Each message gets a monotonic `int id`. Unread = `id > lastReadId`. Opening `/messages` marks read once per visit (`MessagesScreen.initState` / post-frame). Reporting while on home updates the badge; opening Messages clears unread.

### Bound

Max **100** entries; oldest-first eviction. UI list is newest-first.

## Data Model

In-memory only for daily driver — no Drift persistence across restarts. Rows keep a machine `code` for stable refs; the UI does not display it.

## User Interface

App-bar notifications icon with unread `Badge` (hidden at 0) → `/messages`. List shows severity icon, localized message text, and time (no code subtitle).

## Dependencies

- `toastification`
- `flutter_riverpod`

## Related Features

- [Theming](theming.md)

---
*Last updated: 2026-07-20*
