import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/features/library/application/library_ingest_controller.dart';
import 'package:tinytunes/features/player/application/playback_controller.dart';
import 'package:tinytunes/features/playlist/presentation/playlist_library_actions.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Compact status strips for ingest, revoke, and cloud download.
///
/// Purpose: Keep operational state visible above the stage without a dense
/// console banner stack.
/// Usage Context: Below chrome on [PlaylistHomeBaseline].
class HomeStatusBanners extends ConsumerWidget {
  /// Creates the home status strip stack.
  const HomeStatusBanners({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(libraryIngestControllerProvider);
    final downloading = ref.watch(
      playbackControllerProvider.select((s) => s.downloading),
    );
    final downloadProgress = ref.watch(
      playbackControllerProvider.select((s) => s.downloadProgress),
    );
    final busy = progress.isBusy;
    final actions = PlaylistLibraryActions(ref);
    final scheme = Theme.of(context).colorScheme;

    final strips = <Widget>[
      for (final revoked in progress.revokedRoots)
        _Strip(
          child: Row(
            children: [
              Expanded(child: Text(l10n.revokedRootBanner(revoked.displayName))),
              TextButton(
                onPressed: busy
                    ? null
                    : () => actions.forgetRevokedRoot(
                        context,
                        revoked.id,
                        l10n,
                      ),
                child: Text(l10n.forgetRevokedRootAction),
              ),
            ],
          ),
        ),
      if (progress.phase == IngestPhase.scanning)
        _Strip(
          child: Row(
            children: [
              Expanded(child: Text(l10n.scanningProgress(progress.processedCount))),
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
        _Strip(child: Text(l10n.forgettingProgress)),
      if (downloading)
        _Strip(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.cloudDownloading),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: downloadProgress,
                minHeight: 2,
                color: scheme.primary,
              ),
            ],
          ),
        ),
    ];

    if (strips.isEmpty) return const SizedBox.shrink();
    return Column(children: strips);
  }
}

class _Strip extends StatelessWidget {
  const _Strip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.bodySmall,
          child: child,
        ),
      ),
    );
  }
}
