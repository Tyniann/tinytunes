import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tinytunes/core/messages/message_reporter.dart';
import 'package:tinytunes/core/messages/session_message.dart';
import 'package:tinytunes/core/messages/session_message_store.dart';
import 'package:tinytunes/core/messages/toast_delivery.dart';
import 'package:tinytunes/core/messages/toastification_toast_delivery.dart';

part 'message_providers.g.dart';

/// Production [ToastDelivery]; override with [NoopToastDelivery] in tests.
@Riverpod(keepAlive: true)
ToastDelivery toastDelivery(Ref ref) => const ToastificationToastDelivery();

/// Session message mutations; state is a monotonic revision for listeners.
///
/// Purpose: Bump revision on add/mark-read so unread badge updates even when
/// the message list contents are unchanged (watermark-only updates).
@Riverpod(keepAlive: true)
class SessionMessages extends _$SessionMessages {
  final SessionMessageStore _store = SessionMessageStore();

  @override
  int build() => 0;

  /// Underlying store for lists and unread math.
  SessionMessageStore get store => _store;

  /// Appends a message and notifies listeners.
  SessionMessage add({
    required SessionMessageSeverity severity,
    required String code,
    required String message,
  }) {
    final entry = _store.add(
      severity: severity,
      code: code,
      message: message,
    );
    state++;
    return entry;
  }

  /// Sets the unread watermark to the current max id (once per Messages visit).
  void markAllRead() {
    _store.markAllRead();
    state++;
  }
}

/// Derived unread count for the home app-bar badge.
@Riverpod(keepAlive: true)
int unreadMessageCount(Ref ref) {
  ref.watch(sessionMessagesProvider);
  return ref.read(sessionMessagesProvider.notifier).store.unreadCount;
}

/// Newest-first messages for the Messages screen.
@Riverpod(keepAlive: true)
List<SessionMessage> sessionMessagesNewestFirst(Ref ref) {
  ref.watch(sessionMessagesProvider);
  return ref.read(sessionMessagesProvider.notifier).store.messagesNewestFirst;
}

/// Context-free [MessageReporter] for UI and controllers.
@Riverpod(keepAlive: true)
MessageReporter messageReporter(Ref ref) {
  final toasts = ref.watch(toastDeliveryProvider);
  final notifier = ref.read(sessionMessagesProvider.notifier);
  return MessageReporter(
    onAdd: ({
      required SessionMessageSeverity severity,
      required String code,
      required String message,
    }) {
      notifier.add(severity: severity, code: code, message: message);
    },
    toasts: toasts,
  );
}
