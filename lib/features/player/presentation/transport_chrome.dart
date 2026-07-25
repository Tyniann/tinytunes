import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/features/player/application/playback_controller.dart';
import 'package:tinytunes/features/player/application/player_l10n_mapper.dart';
import 'package:tinytunes/features/player/application/player_providers.dart';
import 'package:tinytunes/features/player/application/repeat_mode.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Home transport: shuffle / prev / play-pause / next / repeat + seek + volume.
///
/// Purpose: Expose the Shuffle × Repeat matrix and expandable system volume on
/// playlist home chrome.
/// Usage Context: [PlaylistHomeScreen] bottom bar; watches
/// [playbackControllerProvider] and [systemVolumeProvider].
/// Key Params: none — reads controllers from Riverpod.
class TransportChrome extends ConsumerStatefulWidget {
  /// Creates the transport chrome.
  const TransportChrome({super.key});

  @override
  ConsumerState<TransportChrome> createState() => _TransportChromeState();
}

class _TransportChromeState extends ConsumerState<TransportChrome> {
  bool _seeking = false;
  double? _seekValue;
  bool _volumeExpanded = false;
  bool _volumeDragging = false;
  double? _volumeDragValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final controller = ref.read(playbackControllerProvider.notifier);
      controller.updateL10n(playerL10nFrom(l10n));
      controller.markToastsReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playback = ref.watch(playbackControllerProvider);
    final controller = ref.read(playbackControllerProvider.notifier);
    final volumeAsync = ref.watch(systemVolumeProvider);
    final hasCurrent = playback.currentQueueEntryId != null;
    final duration = playback.duration;
    final maxMs = (duration != null && duration.inMilliseconds > 0)
        ? duration.inMilliseconds.toDouble()
        : 0.0;
    final positionMs = _seeking
        ? (_seekValue ?? playback.position.inMilliseconds.toDouble())
        : playback.position.inMilliseconds.toDouble().clamp(
            0,
            maxMs > 0 ? maxMs : 0,
          );
    final scheme = Theme.of(context).colorScheme;
    final volume = _volumeDragging
        ? (_volumeDragValue ?? volumeAsync.value ?? 0.0)
        : (volumeAsync.value ?? 0.0);

    return Material(
      elevation: 3,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _volumeExpanded
                    ? Row(
                        children: [
                          Icon(
                            _volumeIcon(volume),
                            size: 20,
                            color: scheme.onSurfaceVariant,
                          ),
                          Expanded(
                            child: Slider(
                              value: volume.clamp(0.0, 1.0),
                              onChanged: (value) async {
                                setState(() {
                                  _volumeDragging = true;
                                  _volumeDragValue = value;
                                });
                                try {
                                  await ref
                                      .read(systemVolumeProvider.notifier)
                                      .setVolume(value);
                                } catch (_) {
                                  // Native failure already logged; keep last known UI.
                                }
                              },
                              onChangeEnd: (value) {
                                setState(() {
                                  _volumeDragging = false;
                                  _volumeDragValue = null;
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    isSelected: _volumeExpanded,
                    onPressed: () {
                      setState(() => _volumeExpanded = !_volumeExpanded);
                    },
                    tooltip: _volumeExpanded
                        ? l10n.transportVolumeCollapse
                        : l10n.transportVolumeExpand,
                    icon: Icon(
                      _volumeIcon(volume),
                      color: _volumeExpanded ? scheme.primary : null,
                    ),
                  ),
                  Text(
                    _format(Duration(milliseconds: positionMs.round())),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Expanded(
                    child: Slider(
                      value: maxMs <= 0
                          ? 0.0
                          : positionMs.clamp(0.0, maxMs).toDouble(),
                      max: maxMs <= 0 ? 1.0 : maxMs,
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
                  Text(
                    duration == null ? '--:--' : _format(duration),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    isSelected: playback.shuffleEnabled,
                    onPressed: () =>
                        controller.setShuffleEnabled(!playback.shuffleEnabled),
                    tooltip: l10n.transportShuffle,
                    icon: Icon(
                      Icons.shuffle,
                      color: playback.shuffleEnabled ? scheme.primary : null,
                    ),
                  ),
                  IconButton(
                    onPressed: hasCurrent ? () => controller.previous() : null,
                    tooltip: l10n.transportPrevious,
                    icon: const Icon(Icons.skip_previous),
                  ),
                  IconButton(
                    onPressed: hasCurrent
                        ? () => controller.togglePlayPause()
                        : null,
                    tooltip: l10n.transportPlayPause,
                    icon: Icon(
                      playback.playing ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                  IconButton(
                    onPressed: hasCurrent ? () => controller.next() : null,
                    tooltip: l10n.transportNext,
                    icon: const Icon(Icons.skip_next),
                  ),
                  IconButton(
                    isSelected: playback.repeatMode != RepeatMode.off,
                    onPressed: () => controller.cycleRepeatMode(),
                    tooltip: switch (playback.repeatMode) {
                      RepeatMode.off => l10n.transportRepeatOff,
                      RepeatMode.one => l10n.transportRepeatOne,
                      RepeatMode.all => l10n.transportRepeatAll,
                    },
                    icon: Icon(
                      playback.repeatMode == RepeatMode.one
                          ? Icons.repeat_one
                          : Icons.repeat,
                      color: playback.repeatMode == RepeatMode.off
                          ? null
                          : scheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Picks a speaker glyph that reflects the current [volume] level.
  IconData _volumeIcon(double volume) {
    if (volume <= 0) return Icons.volume_off;
    if (volume < 0.34) return Icons.volume_mute;
    if (volume < 0.67) return Icons.volume_down;
    return Icons.volume_up;
  }

  String _format(Duration d) {
    final total = d.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
