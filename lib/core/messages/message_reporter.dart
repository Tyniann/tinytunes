import 'package:tinytunes/core/messages/session_message.dart';
import 'package:tinytunes/core/messages/session_message_store.dart';
import 'package:tinytunes/core/messages/toast_delivery.dart';

/// Frozen session reporting API: append once + toast, no [BuildContext].
///
/// Purpose: Controllers map failures to a stable [code] and localized message
/// in one place; repositories must not call toasts directly.
/// Usage Context: UI/controllers via Riverpod; tests use [NoopToastDelivery].
class MessageReporter {
  /// Creates a reporter that appends through [onAdd] and shows toasts via [toasts].
  const MessageReporter({
    required void Function({
      required SessionMessageSeverity severity,
      required String code,
      required String message,
    }) onAdd,
    required ToastDelivery toasts,
  })  : _onAdd = onAdd,
        _toasts = toasts;

  final void Function({
    required SessionMessageSeverity severity,
    required String code,
    required String message,
  }) _onAdd;
  final ToastDelivery _toasts;

  /// Records an info message and shows an info toast.
  void reportInfo({required String code, required String message}) {
    _onAdd(
      severity: SessionMessageSeverity.info,
      code: code,
      message: message,
    );
    _toasts.showInfo(message);
  }

  /// Records an error message and shows an error toast.
  void reportError({required String code, required String message}) {
    _onAdd(
      severity: SessionMessageSeverity.error,
      code: code,
      message: message,
    );
    _toasts.showError(message);
  }
}

/// Test helper: [MessageReporter] wired to a plain [SessionMessageStore].
MessageReporter messageReporterForStore(
  SessionMessageStore store,
  ToastDelivery toasts,
) {
  return MessageReporter(
    onAdd: ({
      required SessionMessageSeverity severity,
      required String code,
      required String message,
    }) {
      store.add(severity: severity, code: code, message: message);
    },
    toasts: toasts,
  );
}
