import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/messages/message_reporter.dart';
import 'package:tinytunes/core/messages/session_message.dart';
import 'package:tinytunes/core/messages/session_message_store.dart';
import 'package:tinytunes/core/messages/toast_delivery.dart';

void main() {
  group('SessionMessageStore', () {
    test('assigns monotonic ids and reports unread via watermark', () {
      final store = SessionMessageStore();

      store.add(
        severity: SessionMessageSeverity.info,
        code: 'a',
        message: 'one',
      );
      store.add(
        severity: SessionMessageSeverity.error,
        code: 'b',
        message: 'two',
      );

      expect(store.unreadCount, 2);
      store.markAllRead();
      expect(store.unreadCount, 0);
      expect(store.lastReadId, 2);

      store.add(
        severity: SessionMessageSeverity.info,
        code: 'c',
        message: 'three',
      );
      expect(store.unreadCount, 1);
      expect(store.messagesNewestFirst.first.code, 'c');
    });

    test('evicts oldest when exceeding maxEntries and keeps unread consistent', () {
      final store = SessionMessageStore();

      for (var i = 0; i < SessionMessageStore.maxEntries; i++) {
        store.add(
          severity: SessionMessageSeverity.info,
          code: 'n$i',
          message: 'm$i',
        );
      }
      expect(store.messages, hasLength(SessionMessageStore.maxEntries));
      expect(store.messages.first.id, 1);
      expect(store.unreadCount, SessionMessageStore.maxEntries);

      store.add(
        severity: SessionMessageSeverity.error,
        code: 'overflow',
        message: '101',
      );

      expect(store.messages, hasLength(SessionMessageStore.maxEntries));
      expect(store.messages.first.id, 2);
      expect(store.messages.last.id, SessionMessageStore.maxEntries + 1);
      // Evicted id 1; remaining 100 messages are still unread vs lastReadId 0.
      expect(store.unreadCount, SessionMessageStore.maxEntries);
    });

    test('open marks read; demos while open become unread until next visit', () {
      final store = SessionMessageStore();
      store.add(
        severity: SessionMessageSeverity.info,
        code: 'seed',
        message: 'seed',
      );
      // Visit Messages: mark read once.
      store.markAllRead();
      expect(store.unreadCount, 0);

      // Demo while still on Messages — rows appear; home badge is not visible.
      store.add(
        severity: SessionMessageSeverity.info,
        code: 'demo.info',
        message: 'demo info',
      );
      store.add(
        severity: SessionMessageSeverity.error,
        code: 'demo.error',
        message: 'demo error',
      );
      expect(store.unreadCount, 2);

      // Leave then re-enter: mark read clears the badge.
      store.markAllRead();
      expect(store.unreadCount, 0);
    });
  });

  group('MessageReporter', () {
    test('noop ToastDelivery still mutates the store', () {
      final store = SessionMessageStore();
      final reporter = messageReporterForStore(store, const NoopToastDelivery());

      reporter.reportInfo(code: 'demo.info', message: 'Hello');
      reporter.reportError(code: 'demo.error', message: 'Boom');

      expect(store.messages, hasLength(2));
      expect(store.messages.first.severity, SessionMessageSeverity.info);
      expect(store.messages.last.severity, SessionMessageSeverity.error);
      expect(store.unreadCount, 2);
    });
  });
}
