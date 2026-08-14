import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/core/routing/app_routes.dart';
import 'package:tinytunes/features/library/application/library_ingest_controller.dart';
import 'package:tinytunes/features/player/application/playback_controller.dart';
import 'package:tinytunes/features/player/presentation/transport_chrome.dart';
import 'package:tinytunes/features/playlist/application/playlist_providers.dart';
import 'package:tinytunes/features/playlist/presentation/home_queue_list.dart';
import 'package:tinytunes/features/playlist/presentation/home_stage_carousel.dart';
import 'package:tinytunes/features/playlist/presentation/home_status_banners.dart';
import 'package:tinytunes/features/playlist/presentation/playlist_library_actions.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Production playlist home: cover carousel, ledger queue, floating transport.
///
/// Purpose: Primary listening surface — swipe covers to browse, tap a queue
/// row (or the focused cover / dock play) to start, remove with a visible
/// close control. Theme tokens only so catalog schemes restyle it.
/// Usage Context: Body of [PlaylistHomeScreen].
class PlaylistHomeBaseline extends ConsumerStatefulWidget {
  /// Creates the production home.
  const PlaylistHomeBaseline({super.key});

  @override
  ConsumerState<PlaylistHomeBaseline> createState() =>
      _PlaylistHomeBaselineState();
}

class _PlaylistHomeBaselineState extends ConsumerState<PlaylistHomeBaseline> {
  int _focusedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unread = ref.watch(unreadMessageCountProvider);
    final ingest = ref.watch(libraryIngestControllerProvider);
    final queueAsync = ref.watch(orderedQueueProvider);
    final actions = PlaylistLibraryActions(ref);
    final busy = ingest.isBusy;
    final scheme = Theme.of(context).colorScheme;

    ref.listen(
      playbackControllerProvider.select((s) => s.currentQueueEntryId),
      (previous, next) {
        final queue = ref.read(orderedQueueProvider).asData?.value;
        if (queue == null || next == null) return;
        final index = queue.indexWhere((row) => row.queueEntryId == next);
        if (index >= 0 && index != _focusedIndex) {
          setState(() => _focusedIndex = index);
        }
      },
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _HomeChrome(
              l10n: l10n,
              unread: unread,
              busy: busy,
              actions: actions,
            ),
            const HomeStatusBanners(),
            Expanded(
              child: queueAsync.when(
                data: (queue) {
                  if (queue.isEmpty) {
                    return _EmptyQueue(
                      busy: busy,
                      onAdd: () => actions.onAddFolder(context, l10n),
                      emptyLabel: l10n.queueEmpty,
                      addLabel: l10n.addFolderAction,
                    );
                  }

                  final focused = _focusedIndex.clamp(0, queue.length - 1);
                  if (focused != _focusedIndex) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _focusedIndex = focused);
                    });
                  }

                  void playFocused() {
                    ref
                        .read(playbackControllerProvider.notifier)
                        .playEntry(queue[focused].queueEntryId);
                  }

                  return Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: HomeStageCarousel(
                          queue: queue,
                          focusedIndex: focused,
                          onFocusedIndexChanged: (index) {
                            setState(() => _focusedIndex = index);
                          },
                          onPlayFocused: playFocused,
                        ),
                      ),
                      Divider(height: 1, color: scheme.outlineVariant),
                      Expanded(
                        flex: 4,
                        child: HomeQueueList(
                          queue: queue,
                          busy: busy,
                          focusedIndex: focused,
                          onFocusIndex: (index) {
                            setState(() => _focusedIndex = index);
                          },
                        ),
                      ),
                      TransportChrome(onPlayWhenIdle: playFocused),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (error, _) => Center(child: Text('$error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact home chrome: title plus library / messages / settings.
class _HomeChrome extends StatelessWidget {
  const _HomeChrome({
    required this.l10n,
    required this.unread,
    required this.busy,
    required this.actions,
  });

  final AppLocalizations l10n;
  final int unread;
  final bool busy;
  final PlaylistLibraryActions actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
      child: Row(
        children: [
          Container(width: 4, height: 22, color: scheme.primary),
          const SizedBox(width: 10),
          Text(
            l10n.appTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            tooltip: l10n.addFolderTooltip,
            onPressed: busy ? null : () => actions.onAddFolder(context, l10n),
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
          PopupMenuButton<PlaylistMenuAction>(
            tooltip: l10n.playlistMenuTooltip,
            enabled: !busy,
            onSelected: (action) => actions.onMenuAction(context, action, l10n),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: PlaylistMenuAction.clearQueue,
                child: Text(l10n.clearQueue),
              ),
              PopupMenuItem(
                value: PlaylistMenuAction.rescan,
                child: Text(l10n.rescanFolder),
              ),
              PopupMenuItem(
                value: PlaylistMenuAction.forget,
                child: Text(l10n.forgetFolder),
              ),
              PopupMenuItem(
                value: PlaylistMenuAction.forgetAll,
                child: Text(l10n.forgetAllFolders),
              ),
            ],
          ),
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
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue({
    required this.busy,
    required this.onAdd,
    required this.emptyLabel,
    required this.addLabel,
  });

  final bool busy;
  final VoidCallback onAdd;
  final String emptyLabel;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.album_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              emptyLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: busy ? null : onAdd,
              child: Text(addLabel),
            ),
          ],
        ),
      ),
    );
  }
}
