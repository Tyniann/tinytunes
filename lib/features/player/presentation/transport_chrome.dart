import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/features/player/application/playback_controller.dart';
import 'package:tinytunes/features/player/application/player_providers.dart';
import 'package:tinytunes/features/player/application/repeat_mode.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Floating transport dock: seek, shuffle / prev / play / next / repeat, volume.
///
/// Purpose: Keep playback controls visually separate from the queue while
/// staying on [ColorScheme] tokens so Lucky Lime / Electric Blue / Ember
/// Signal all theme it.
/// Usage Context: Bottom of [PlaylistHomeBaseline].
/// Key Params: [onPlayWhenIdle] starts the staged carousel track when nothing
/// is current.
class TransportChrome extends ConsumerStatefulWidget {
  /// Creates the home transport dock.
  const TransportChrome({super.key, this.onPlayWhenIdle});

  /// Starts the focused queue entry when play is pressed with no current track.
  final VoidCallback? onPlayWhenIdle;

  @override
  ConsumerState<TransportChrome> createState() => _TransportChromeState();
}

class _TransportChromeState extends ConsumerState<TransportChrome> {
  bool _seeking = false;
  double? _seekValue;
  bool _volumeDragging = false;
  double? _volumeValue;
  bool _volumeOpen = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final currentId = ref.watch(
      playbackControllerProvider.select((s) => s.currentQueueEntryId),
    );
    final playing = ref.watch(
      playbackControllerProvider.select((s) => s.playing),
    );
    final duration = ref.watch(
      playbackControllerProvider.select((s) => s.duration),
    );
    final shuffleEnabled = ref.watch(
      playbackControllerProvider.select((s) => s.shuffleEnabled),
    );
    final repeatMode = ref.watch(
      playbackControllerProvider.select((s) => s.repeatMode),
    );
    final position = ref.watch(
      playbackControllerProvider.select((s) => s.position),
    );
    final controller = ref.read(playbackControllerProvider.notifier);
    final volumeAsync = ref.watch(systemVolumeProvider);
    final hasCurrent = currentId != null;
    final canPlay = hasCurrent || widget.onPlayWhenIdle != null;
    final maxMs = duration != null && duration.inMilliseconds > 0
        ? duration.inMilliseconds.toDouble()
        : 0.0;
    final positionMs = _seeking
        ? (_seekValue ?? position.inMilliseconds.toDouble())
        : position.inMilliseconds.toDouble().clamp(
            0.0,
            maxMs > 0 ? maxMs : 0.0,
          );
    final volume = _volumeDragging
        ? (_volumeValue ?? volumeAsync.value ?? 0)
        : (volumeAsync.value ?? 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Material(
        elevation: 8,
        color: scheme.inverseSurface,
        shadowColor: scheme.shadow.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: scheme.primary.withValues(alpha: 0.55),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    _format(Duration(milliseconds: positionMs.round())),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onInverseSurface.withValues(alpha: 0.7),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: scheme.primary,
                        inactiveTrackColor: scheme.onInverseSurface.withValues(
                          alpha: 0.18,
                        ),
                        thumbColor: scheme.onInverseSurface,
                        overlayColor: scheme.primary.withValues(alpha: 0.16),
                        trackHeight: 2.5,
                      ),
                      child: Slider(
                        value: maxMs <= 0 ? 0 : positionMs.clamp(0.0, maxMs),
                        max: maxMs <= 0 ? 1 : maxMs,
                        onChanged: !hasCurrent || maxMs <= 0
                            ? null
                            : (value) {
                                setState(() {
                                  _seeking = true;
                                  _seekValue = value;
                                });
                              },
                        onChangeEnd: !hasCurrent || maxMs <= 0
                            ? null
                            : (value) async {
                                setState(() {
                                  _seeking = false;
                                  _seekValue = null;
                                });
                                await controller.seekTo(
                                  Duration(milliseconds: value.round()),
                                );
                              },
                      ),
                    ),
                  ),
                  Text(
                    duration == null ? '--:--' : _format(duration),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onInverseSurface.withValues(alpha: 0.7),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _DockIcon(
                    tooltip: l10n.transportShuffle,
                    icon: Icons.shuffle,
                    selected: shuffleEnabled,
                    onPressed: () =>
                        controller.setShuffleEnabled(!shuffleEnabled),
                    color: scheme.onInverseSurface,
                    selectedColor: scheme.primary,
                  ),
                  const Spacer(),
                  _DockIcon(
                    tooltip: l10n.transportPrevious,
                    icon: Icons.skip_previous,
                    onPressed: hasCurrent ? controller.previous : null,
                    color: scheme.onInverseSurface,
                    selectedColor: scheme.primary,
                    size: 30,
                  ),
                  _PlayButton(
                    playing: playing,
                    enabled: canPlay,
                    tooltip: l10n.transportPlayPause,
                    onPressed: hasCurrent
                        ? controller.togglePlayPause
                        : widget.onPlayWhenIdle,
                    fill: scheme.primary,
                    glyph: scheme.onPrimary,
                    disabledFill: scheme.onInverseSurface.withValues(
                      alpha: 0.12,
                    ),
                  ),
                  _DockIcon(
                    tooltip: l10n.transportNext,
                    icon: Icons.skip_next,
                    onPressed: hasCurrent ? controller.next : null,
                    color: scheme.onInverseSurface,
                    selectedColor: scheme.primary,
                    size: 30,
                  ),
                  const Spacer(),
                  _DockIcon(
                    tooltip: switch (repeatMode) {
                      RepeatMode.off => l10n.transportRepeatOff,
                      RepeatMode.one => l10n.transportRepeatOne,
                      RepeatMode.all => l10n.transportRepeatAll,
                    },
                    icon: repeatMode == RepeatMode.one
                        ? Icons.repeat_one
                        : Icons.repeat,
                    selected: repeatMode != RepeatMode.off,
                    onPressed: controller.cycleRepeatMode,
                    color: scheme.onInverseSurface,
                    selectedColor: scheme.primary,
                  ),
                  _DockIcon(
                    tooltip: _volumeOpen
                        ? l10n.transportVolumeCollapse
                        : l10n.transportVolumeExpand,
                    icon: _volumeIcon(volume),
                    selected: _volumeOpen,
                    onPressed: () => setState(() => _volumeOpen = !_volumeOpen),
                    color: scheme.onInverseSurface,
                    selectedColor: scheme.primary,
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _volumeOpen
                    ? Row(
                        children: [
                          Icon(
                            _volumeIcon(volume),
                            size: 16,
                            color: scheme.onInverseSurface.withValues(
                              alpha: 0.65,
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: scheme.primary,
                                inactiveTrackColor: scheme.onInverseSurface
                                    .withValues(alpha: 0.18),
                                thumbColor: scheme.onInverseSurface,
                                trackHeight: 2.5,
                              ),
                              child: Slider(
                                value: volume.clamp(0.0, 1.0),
                                onChanged: (value) async {
                                  setState(() {
                                    _volumeDragging = true;
                                    _volumeValue = value;
                                  });
                                  try {
                                    await ref
                                        .read(systemVolumeProvider.notifier)
                                        .setVolume(value);
                                  } on Object {
                                    // Native seam retains last known value.
                                  }
                                },
                                onChangeEnd: (_) {
                                  setState(() {
                                    _volumeDragging = false;
                                    _volumeValue = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _volumeIcon(double volume) {
    if (volume <= 0) return Icons.volume_off;
    if (volume < 0.34) return Icons.volume_mute;
    if (volume < 0.67) return Icons.volume_down;
    return Icons.volume_up;
  }

  String _format(Duration duration) {
    final total = duration.inSeconds;
    final hours = total ~/ 3600;
    final minutes = ((total % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (total % 60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }
}

class _DockIcon extends StatelessWidget {
  const _DockIcon({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.selectedColor,
    this.selected = false,
    this.size = 22,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final Color selectedColor;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: size, color: selected ? selectedColor : color),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.playing,
    required this.enabled,
    required this.tooltip,
    required this.onPressed,
    required this.fill,
    required this.glyph,
    required this.disabledFill,
  });

  final bool playing;
  final bool enabled;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color fill;
  final Color glyph;
  final Color disabledFill;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled ? fill : disabledFill,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(
              playing ? Icons.pause : Icons.play_arrow,
              size: 28,
              color: enabled ? glyph : glyph.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
