import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/core/routing/app_routes.dart';
import 'package:tinytunes/features/library/application/library_ingest_controller.dart';
import 'package:tinytunes/features/library/application/library_ingest_l10n_mapper.dart';
import 'package:tinytunes/features/player/application/playback_controller.dart';
import 'package:tinytunes/features/player/presentation/transport_chrome.dart';
import 'package:tinytunes/features/playlist/application/playlist_providers.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Playlist home: queue list, library actions, live transport.
///
/// Purpose: Primary IA surface for the single Winamp-style queue, folder
/// ingest, and Phase 3 playback controls.
/// Usage Context: Route `/` via [PlaylistHomeRoute].
class PlaylistHomeScreen extends ConsumerStatefulWidget {
  /// Creates the playlist home screen.
  const PlaylistHomeScreen({super.key});

  @override
  ConsumerState<PlaylistHomeScreen> createState() => _PlaylistHomeScreenState();
}

class _PlaylistHomeScreenState extends ConsumerState<PlaylistHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ref.read(libraryIngestControllerProvider.notifier).checkRevokedRoots(
            l10n: libraryIngestL10nFrom(l10n),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unread = ref.watch(unreadMessageCountProvider);
    final progress = ref.watch(libraryIngestControllerProvider);
    final queueAsync = ref.watch(orderedQueueProvider);
    final playback = ref.watch(playbackControllerProvider);
    final busy = progress.isBusy;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.addFolderTooltip,
            onPressed: busy
                ? null
                : () {
                    ref.read(libraryIngestControllerProvider.notifier).addFolder(
                          l10n: libraryIngestL10nFrom(l10n),
                        );
                  },
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
          PopupMenuButton<_PlaylistMenuAction>(
            tooltip: l10n.playlistMenuTooltip,
            enabled: !busy,
            onSelected: (action) => _onMenuAction(action, l10n),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _PlaylistMenuAction.clearQueue,
                child: Text(l10n.clearQueue),
              ),
              PopupMenuItem(
                value: _PlaylistMenuAction.rescan,
                child: Text(l10n.rescanFolder),
              ),
              PopupMenuItem(
                value: _PlaylistMenuAction.forget,
                child: Text(l10n.forgetFolder),
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
      body: Column(
        children: [
          for (final revoked in progress.revokedRoots)
            _HomeStrip(
              child: Row(
                children: [
                  Expanded(
                    child: Text(l10n.revokedRootBanner(revoked.displayName)),
                  ),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => _forgetRevokedRoot(revoked.id, l10n),
                    child: Text(l10n.forgetRevokedRootAction),
                  ),
                ],
              ),
            ),
          if (progress.phase == IngestPhase.scanning)
            _HomeStrip(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.scanningProgress(progress.processedCount),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(libraryIngestControllerProvider.notifier)
                        .cancelScan(),
                    child: Text(l10n.cancelScan),
                  ),
                ],
              ),
            ),
          if (progress.phase == IngestPhase.forgetting)
            _HomeStrip(
              child: Text(l10n.forgettingProgress),
            ),
          Expanded(
            child: queueAsync.when(
              data: (queue) {
                if (queue.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.queueEmpty,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: busy
                                ? null
                                : () {
                                    ref
                                        .read(
                                          libraryIngestControllerProvider
                                              .notifier,
                                        )
                                        .addFolder(
                                          l10n: libraryIngestL10nFrom(l10n),
                                        );
                                  },
                            child: Text(l10n.addFolderAction),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: queue.length,
                  itemBuilder: (context, index) {
                    final row = queue[index];
                    final isCurrent =
                        row.queueEntryId == playback.currentQueueEntryId;
                    return ListTile(
                      selected: isCurrent,
                      selectedTileColor: scheme.secondaryContainer,
                      title: Text(row.listTitle),
                      subtitle: Text(
                        (row.artist != null && row.artist!.trim().isNotEmpty)
                            ? row.artist!
                            : l10n.unknownArtist,
                      ),
                      onTap: () => ref
                          .read(playbackControllerProvider.notifier)
                          .playEntry(row.queueEntryId),
                      trailing: IconButton(
                        tooltip: l10n.removeFromQueueTooltip,
                        onPressed: busy
                            ? null
                            : () => ref
                                .read(queueActionsProvider)
                                .removeEntry(row.queueEntryId),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                    );
                  },
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, _) => Center(child: Text('$error')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const TransportChrome(),
    );
  }

  Future<void> _forgetRevokedRoot(int rootId, AppLocalizations l10n) async {
    final ok = await _confirm(
      title: l10n.forgetFolderTitle,
      body: l10n.forgetFolderBody,
      l10n: l10n,
    );
    if (ok && mounted) {
      await ref.read(libraryIngestControllerProvider.notifier).forgetRoot(
            rootId: rootId,
            l10n: libraryIngestL10nFrom(l10n),
          );
    }
  }

  Future<void> _onMenuAction(
    _PlaylistMenuAction action,
    AppLocalizations l10n,
  ) async {
    switch (action) {
      case _PlaylistMenuAction.clearQueue:
        final ok = await _confirm(
          title: l10n.clearQueueTitle,
          body: l10n.clearQueueBody,
          l10n: l10n,
        );
        if (ok && mounted) {
          await ref.read(queueActionsProvider).clearQueue();
        }
      case _PlaylistMenuAction.rescan:
        final root = await _pickRoot(l10n);
        if (root != null && mounted) {
          await ref.read(libraryIngestControllerProvider.notifier).rescanRoot(
                rootId: root.id,
                l10n: libraryIngestL10nFrom(l10n),
              );
        }
      case _PlaylistMenuAction.forget:
        final root = await _pickRoot(l10n);
        if (root == null || !mounted) return;
        final ok = await _confirm(
          title: l10n.forgetFolderTitle,
          body: l10n.forgetFolderBody,
          l10n: l10n,
        );
        if (ok && mounted) {
          await ref.read(libraryIngestControllerProvider.notifier).forgetRoot(
                rootId: root.id,
                l10n: libraryIngestL10nFrom(l10n),
              );
        }
    }
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required AppLocalizations l10n,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirmAction),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<LibraryRoot?> _pickRoot(AppLocalizations l10n) async {
    final db = ref.read(appDatabaseProvider);
    final roots = await db.select(db.libraryRoots).get();
    if (!mounted) return null;
    if (roots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noLibraryFolders)),
      );
      return null;
    }
    if (roots.length == 1) return roots.single;

    return showDialog<LibraryRoot>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.pickFolderTitle),
        children: [
          for (final root in roots)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(root),
              child: Text(root.displayName),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancelAction),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared Material strip for revoked / scan / forget home chrome.
///
/// Purpose: Keep banner styling consistent without MaterialBanner.
class _HomeStrip extends StatelessWidget {
  const _HomeStrip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: child,
      ),
    );
  }
}

enum _PlaylistMenuAction { clearQueue, rescan, forget }
