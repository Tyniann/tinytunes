import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/features/library/application/library_ingest_controller.dart';
import 'package:tinytunes/features/library/application/library_ingest_l10n_mapper.dart';
import 'package:tinytunes/features/player/application/playback_controller.dart';
import 'package:tinytunes/features/player/application/player_l10n_mapper.dart';
import 'package:tinytunes/features/playlist/presentation/playlist_home_baseline.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Playlist home: cover carousel, queue ledger, and transport dock.
///
/// Purpose: Primary IA route (`/`). Owns one-shot player l10n/toast bootstrap
/// so the listening surface stays focused on queue and playback.
/// Usage Context: [PlaylistHomeRoute].
class PlaylistHomeScreen extends ConsumerStatefulWidget {
  /// Creates the playlist home.
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
      final controller = ref.read(playbackControllerProvider.notifier);
      controller.updateL10n(playerL10nFrom(l10n));
      controller.markToastsReady();
      ref
          .read(libraryIngestControllerProvider.notifier)
          .checkRevokedRoots(l10n: libraryIngestL10nFrom(l10n));
    });
  }

  @override
  Widget build(BuildContext context) => const PlaylistHomeBaseline();
}
