import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/features/player/application/playback_controller.dart';
import 'package:tinytunes/features/player/application/player_l10n_mapper.dart';
import 'package:tinytunes/features/player/application/repeat_mode.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Home transport: shuffle / prev / play-pause / next / repeat + seek bar.
///
/// Purpose: Expose the Shuffle × Repeat matrix on playlist home chrome.
/// Usage Context: [PlaylistHomeScreen] bottom bar; watches
/// [playbackControllerProvider].
/// Key Params: none — reads controller from Riverpod.
class TransportChrome extends ConsumerStatefulWidget {
  /// Creates the transport chrome.
  const TransportChrome({super.key});

  @override
  ConsumerState<TransportChrome> createState() => _TransportChromeState();
}

class _TransportChromeState extends ConsumerState<TransportChrome> {
  bool _seeking = false;
  double? _seekValue;

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
    final hasCurrent = playback.currentQueueEntryId != null;
    final duration = playback.duration;
    final maxMs = (duration != null && duration.inMilliseconds > 0)
        ? duration.inMilliseconds.toDouble()
        : 0.0;
    final positionMs = _seeking
        ? (_seekValue ?? playback.position.inMilliseconds.toDouble())
        : playback.position.inMilliseconds.toDouble().clamp(0, maxMs > 0 ? maxMs : 0);
    final scheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 3,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
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
                    onPressed: () => controller.setShuffleEnabled(
                      !playback.shuffleEnabled,
                    ),
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
                    onPressed:
                        hasCurrent ? () => controller.togglePlayPause() : null,
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

  String _format(Duration d) {
    final total = d.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
