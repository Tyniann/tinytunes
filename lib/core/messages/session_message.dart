import 'package:flutter/foundation.dart';

/// Severity for a session message center entry.
enum SessionMessageSeverity {
  /// Informational feedback (non-fatal).
  info,

  /// Error feedback that should also surface via toast.
  error,
}

/// One in-memory session log entry for the message center.
///
/// Purpose: Carry a stable [code], localized [message], and monotonic [id] for
/// unread watermarking without persisting across restarts.
/// Usage Context: [SessionMessageStore] and the Messages screen list.
@immutable
class SessionMessage {
  /// Creates a session message with the given fields.
  const SessionMessage({
    required this.id,
    required this.severity,
    required this.code,
    required this.message,
    required this.createdAt,
  });

  /// Monotonic id used for list keys and unread watermarking.
  final int id;

  /// Info vs error presentation.
  final SessionMessageSeverity severity;

  /// Stable machine-oriented code (e.g. `library.scan.failed`); not unique per instance.
  final String code;

  /// Already-localized user-facing text.
  final String message;

  /// Creation timestamp for display only (not used for unread math).
  final DateTime createdAt;
}
