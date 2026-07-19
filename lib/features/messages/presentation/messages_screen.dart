import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/core/messages/session_message.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Session message center with demo report path.
///
/// Purpose: Show the in-memory session log and prove toast + badge via the
/// demo button. Marks messages read once per visit in [initState].
/// Usage Context: Route `/messages` via [MessagesRoute].
class MessagesScreen extends ConsumerStatefulWidget {
  /// Creates the message center screen.
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(sessionMessagesProvider.notifier).markAllRead();
    });
  }

  void _addDemoMessages() {
    final l10n = AppLocalizations.of(context)!;
    final reporter = ref.read(messageReporterProvider);
    reporter.reportInfo(code: 'demo.info', message: l10n.demoInfoMessage);
    reporter.reportError(code: 'demo.error', message: l10n.demoErrorMessage);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messages = ref.watch(sessionMessagesNewestFirstProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.messagesTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _addDemoMessages,
              child: Text(l10n.addDemoMessage),
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? Center(child: Text(l10n.messagesEmpty))
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ListTile(
                        leading: Icon(
                          message.severity == SessionMessageSeverity.error
                              ? Icons.error_outline
                              : Icons.info_outline,
                        ),
                        title: Text(message.message),
                        subtitle: Text(message.code),
                        trailing: Text(
                          TimeOfDay.fromDateTime(message.createdAt)
                              .format(context),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
