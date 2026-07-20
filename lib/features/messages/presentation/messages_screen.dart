import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/core/messages/session_message.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Session message center showing human-readable session log rows.
///
/// Purpose: List in-memory session messages with severity and time; mark read
/// on open. Machine codes stay in the model but are not shown in the UI.
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messages = ref.watch(sessionMessagesNewestFirstProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.messagesTitle)),
      body: messages.isEmpty
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
                  trailing: Text(
                    TimeOfDay.fromDateTime(message.createdAt).format(context),
                  ),
                );
              },
            ),
    );
  }
}
