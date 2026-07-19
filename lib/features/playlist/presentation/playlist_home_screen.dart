import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/core/routing/app_routes.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Playlist home shell with queue placeholder and inert transport chrome.
///
/// Purpose: Primary IA surface — app-bar access to Messages and Settings until
/// catalog/playback land in later phases.
/// Usage Context: Route `/` via [PlaylistHomeRoute].
class PlaylistHomeScreen extends ConsumerWidget {
  /// Creates the playlist home shell.
  const PlaylistHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final unread = ref.watch(unreadMessageCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.messagesTooltip,
            onPressed: () => const MessagesRoute().push<void>(context),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          IconButton(
            tooltip: l10n.settingsTooltip,
            onPressed: () => const SettingsRoute().push<void>(context),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Center(child: Text(l10n.queuePlaceholder)),
      bottomNavigationBar: const _InertTransportChrome(),
    );
  }
}

/// Explicitly inert play/pause/prev/next row — no audio wiring in Phase 1.
class _InertTransportChrome extends StatelessWidget {
  const _InertTransportChrome();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      elevation: 3,
      child: SafeArea(
        child: IgnorePointer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: null,
                tooltip: l10n.transportPrevious,
                icon: const Icon(Icons.skip_previous),
              ),
              IconButton(
                onPressed: null,
                tooltip: l10n.transportPlayPause,
                icon: const Icon(Icons.play_arrow),
              ),
              IconButton(
                onPressed: null,
                tooltip: l10n.transportNext,
                icon: const Icon(Icons.skip_next),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
