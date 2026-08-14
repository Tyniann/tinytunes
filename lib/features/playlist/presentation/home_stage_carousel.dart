import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/features/player/application/playback_controller.dart';
import 'package:tinytunes/features/playlist/presentation/home_stage_cover.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Horizontal cover carousel for browsing the queue without auto-playing.
///
/// Purpose: Swipe to stage a track; tap the focused cover (or dock play) to
/// start it. Playback-driven jumps animate the page without a feedback loop.
/// Usage Context: Upper stage of [PlaylistHomeBaseline].
/// Key Params: [queue], [focusedIndex], [onFocusedIndexChanged], [onPlayFocused].
class HomeStageCarousel extends ConsumerStatefulWidget {
  /// Creates the home cover carousel.
  const HomeStageCarousel({
    super.key,
    required this.queue,
    required this.focusedIndex,
    required this.onFocusedIndexChanged,
    required this.onPlayFocused,
    this.viewportFraction = 0.72,
  });

  /// Ordered queue projection.
  final List<QueueTrackView> queue;

  /// Currently focused (staged) page index.
  final int focusedIndex;

  /// Called when the user settles on a new carousel page.
  final ValueChanged<int> onFocusedIndexChanged;

  /// Starts playback for the focused page.
  final VoidCallback onPlayFocused;

  /// Fraction of viewport width per carousel page.
  final double viewportFraction;

  @override
  ConsumerState<HomeStageCarousel> createState() => _HomeStageCarouselState();
}

class _HomeStageCarouselState extends ConsumerState<HomeStageCarousel> {
  late PageController _pageController;
  bool _syncingFromPlayback = false;
  bool _acceptUserPageChanges = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.focusedIndex.clamp(0, _maxIndex);
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: initial,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _acceptUserPageChanges = true);
    });
  }

  int get _maxIndex => widget.queue.isEmpty ? 0 : widget.queue.length - 1;

  @override
  void didUpdateWidget(covariant HomeStageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewportFraction != widget.viewportFraction) {
      final page = widget.focusedIndex.clamp(0, _maxIndex);
      _pageController.dispose();
      _pageController = PageController(
        viewportFraction: widget.viewportFraction,
        initialPage: page,
      );
    }
    if (oldWidget.focusedIndex != widget.focusedIndex &&
        !_syncingFromPlayback &&
        _pageController.hasClients) {
      final target = widget.focusedIndex.clamp(0, _maxIndex);
      final visual = _pageController.page?.round() ?? target;
      if (visual != target) {
        _syncingFromPlayback = true;
        _pageController
            .animateToPage(
              target,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
            )
            .whenComplete(() {
              _syncingFromPlayback = false;
            });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (!_acceptUserPageChanges || _syncingFromPlayback) return;
    widget.onFocusedIndexChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final currentId = ref.watch(
      playbackControllerProvider.select((s) => s.currentQueueEntryId),
    );
    if (widget.queue.isEmpty) return const SizedBox.shrink();

    final focused = widget.queue[widget.focusedIndex.clamp(0, _maxIndex)];
    final artist = _present(focused.artist) ?? l10n.unknownArtist;
    final album = _present(focused.album);
    final isCurrent = focused.queueEntryId == currentId;
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w300,
      height: 1.12,
      letterSpacing: -0.7,
      color: scheme.onSurface,
    );

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final coverSize = (constraints.maxWidth * 0.58).clamp(
                160.0,
                260.0,
              );
              return PageView.builder(
                controller: _pageController,
                itemCount: widget.queue.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final row = widget.queue[index];
                  final focusedHere = index == widget.focusedIndex;
                  return Center(
                    child: GestureDetector(
                      onTap: focusedHere ? widget.onPlayFocused : null,
                      child: HomeStageCover(
                        path: row.artworkCacheRef,
                        focused: focusedHere,
                        size: coverSize,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                focused.listTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
              const SizedBox(height: 4),
              Text(
                album == null ? artist : '$artist · $album',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.focusedIndex + 1} / ${widget.queue.length}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isCurrent ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _present(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
