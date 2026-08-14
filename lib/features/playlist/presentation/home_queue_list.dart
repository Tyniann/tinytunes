import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/features/player/application/playback_controller.dart';
import 'package:tinytunes/features/playlist/application/playlist_providers.dart';
import 'package:tinytunes/features/playlist/presentation/queue_cover_thumb.dart';
import 'package:tinytunes/features/playlist/presentation/queue_folder_sections.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Compressed ledger-style queue: sticky folder headers and scannable rows.
///
/// Purpose: Show CD / chapter folder changes as compact pinned headers, with
/// an obvious delete control on each track row.
/// Usage Context: Lower stage of [PlaylistHomeBaseline].
class HomeQueueList extends ConsumerStatefulWidget {
  /// Creates the home queue ledger.
  const HomeQueueList({
    super.key,
    required this.queue,
    required this.busy,
    required this.focusedIndex,
    required this.onFocusIndex,
  });

  /// Ordered queue rows.
  final List<QueueTrackView> queue;

  /// Disables remove while ingest is busy.
  final bool busy;

  /// Carousel-focused index (may differ from the playing row).
  final int focusedIndex;

  /// Stages a row in the carousel when the user activates it.
  final ValueChanged<int> onFocusIndex;

  @override
  ConsumerState<HomeQueueList> createState() => _HomeQueueListState();
}

class _HomeQueueListState extends ConsumerState<HomeQueueList> {
  static const double _itemExtent = 56;
  static const double _headerExtent = 28;

  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentId = ref.watch(
      playbackControllerProvider.select((s) => s.currentQueueEntryId),
    );
    final playing = ref.watch(
      playbackControllerProvider.select((s) => s.playing),
    );

    ref.listen(
      playbackControllerProvider.select((s) => s.currentQueueEntryId),
      (previous, next) {
        if (next == null || next == previous) return;
        _scheduleReveal(next);
      },
    );

    final sections = groupQueueByContainingFolder(widget.queue);

    return CustomScrollView(
      controller: _scroll,
      slivers: [
        for (final section in sections)
          SliverMainAxisGroup(
            slivers: [
              PinnedHeaderSliver(
                child: _FolderSectionHeader(name: section.folderName),
              ),
              SliverFixedExtentList(
                itemExtent: _itemExtent,
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final row = section.tracks[i];
                    final index = section.firstIndex + i;
                    final isCurrent = row.queueEntryId == currentId;
                    final isFocused = index == widget.focusedIndex;
                    return _QueueRow(
                      index: index,
                      row: row,
                      isCurrent: isCurrent,
                      isPlaying: isCurrent && playing,
                      isFocused: isFocused,
                      busy: widget.busy,
                      unknownArtist: l10n.unknownArtist,
                      removeTooltip: l10n.removeFromQueueTooltip,
                      onPlay: () {
                        widget.onFocusIndex(index);
                        ref
                            .read(playbackControllerProvider.notifier)
                            .playEntry(row.queueEntryId);
                      },
                      onRemove: () => ref
                          .read(queueActionsProvider)
                          .removeEntry(row.queueEntryId),
                    );
                  },
                  childCount: section.tracks.length,
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _scheduleReveal(int entryId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_revealIfNeeded(entryId));
    });
  }

  Future<void> _revealIfNeeded(int entryId) async {
    if (!_scroll.hasClients) return;
    final top = _offsetForEntry(entryId);
    if (top == null) return;
    final position = _scroll.position;
    final bottom = top + _itemExtent;
    final visible =
        bottom > position.pixels &&
        top < position.pixels + position.viewportDimension;
    if (visible) return;
    final target = (top + _itemExtent / 2 - position.viewportDimension / 2)
        .clamp(0.0, position.maxScrollExtent);
    await _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  double? _offsetForEntry(int entryId) {
    var offset = 0.0;
    for (final section in groupQueueByContainingFolder(widget.queue)) {
      offset += _headerExtent;
      for (final row in section.tracks) {
        if (row.queueEntryId == entryId) return offset;
        offset += _itemExtent;
      }
    }
    return null;
  }
}

/// Compact pinned folder change marker: hairline, folder icon, name.
///
/// Purpose: Make CD / chapter boundaries obvious without a tall section bar.
/// Usage Context: [PinnedHeaderSliver] in [HomeQueueList].
class _FolderSectionHeader extends StatelessWidget {
  const _FolderSectionHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: SizedBox(
        height: _HomeQueueListState._headerExtent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Expanded(
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: scheme.outlineVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 14,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: scheme.onSurface,
                                  letterSpacing: 0.2,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.index,
    required this.row,
    required this.isCurrent,
    required this.isPlaying,
    required this.isFocused,
    required this.busy,
    required this.unknownArtist,
    required this.removeTooltip,
    required this.onPlay,
    required this.onRemove,
  });

  final int index;
  final QueueTrackView row;
  final bool isCurrent;
  final bool isPlaying;
  final bool isFocused;
  final bool busy;
  final String unknownArtist;
  final String removeTooltip;
  final VoidCallback onPlay;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final artist = (row.artist != null && row.artist!.trim().isNotEmpty)
        ? row.artist!
        : unknownArtist;
    final artPath = row.artworkCacheRef?.trim();

    return Material(
      color: isCurrent
          ? scheme.primary.withValues(alpha: 0.12)
          : isFocused
          ? scheme.surfaceContainerHighest.withValues(alpha: 0.5)
          : Colors.transparent,
      child: InkWell(
        onTap: onPlay,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isCurrent ? scheme.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 10, end: 0),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Center(
                    child: isCurrent
                        ? Icon(
                            isPlaying ? Icons.graphic_eq : Icons.pause,
                            size: 16,
                            color: scheme.primary,
                          )
                        : Text(
                            (index + 1).toString().padLeft(2, '0'),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                  ),
                ),
                if (artPath != null && artPath.isNotEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: QueueCoverThumb(
                      key: ValueKey('home-q-${row.trackId}'),
                      path: artPath,
                      size: 36,
                    ),
                  ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.listTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                      Text(
                        artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (row.sourceKind == 'cloud')
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 4),
                    child: Icon(
                      Icons.cloud_outlined,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                IconButton(
                  tooltip: removeTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: busy ? null : onRemove,
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
