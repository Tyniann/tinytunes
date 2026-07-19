import 'package:tinytunes/core/messages/session_message.dart';

/// Bounded in-memory store for session messages and unread watermark.
///
/// Purpose: Keep a Winamp-style session log without Drift; support badge unread
/// via monotonic [lastReadId] instead of fragile timestamps.
/// Usage Context: [MessageReporter] and Messages / home badge providers.
class SessionMessageStore {
  /// Maximum retained messages before oldest-first eviction.
  static const int maxEntries = 100;

  final List<SessionMessage> _messages = <SessionMessage>[];
  int _nextId = 1;
  int _lastReadId = 0;

  /// Chronological messages (oldest first). UI reverses for newest-first.
  List<SessionMessage> get messages => List.unmodifiable(_messages);

  /// Newest-first view for the Messages screen.
  List<SessionMessage> get messagesNewestFirst =>
      List<SessionMessage>.unmodifiable(_messages.reversed);

  /// Watermark: messages with `id > lastReadId` are unread.
  int get lastReadId => _lastReadId;

  /// Count of messages newer than [lastReadId].
  int get unreadCount {
    var count = 0;
    for (final message in _messages) {
      if (message.id > _lastReadId) {
        count++;
      }
    }
    return count;
  }

  /// Highest id currently stored, or `0` when empty.
  int get maxId => _messages.isEmpty ? 0 : _messages.last.id;

  /// Appends a message, assigning the next monotonic id; evicts oldest if full.
  SessionMessage add({
    required SessionMessageSeverity severity,
    required String code,
    required String message,
    DateTime? createdAt,
  }) {
    final entry = SessionMessage(
      id: _nextId++,
      severity: severity,
      code: code,
      message: message,
      createdAt: createdAt ?? DateTime.now(),
    );
    _messages.add(entry);
    while (_messages.length > maxEntries) {
      _messages.removeAt(0);
    }
    return entry;
  }

  /// Marks all current messages read by setting the watermark to [maxId].
  void markAllRead() {
    _lastReadId = maxId;
  }
}
