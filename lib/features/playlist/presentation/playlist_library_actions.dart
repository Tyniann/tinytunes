import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/cloud/cloud_provider_id.dart';
import 'package:tinytunes/core/cloud/cloud_providers.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_cloud_library_source.dart';
import 'package:tinytunes/core/cloud/google_drive/google_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_media_locator.dart';
import 'package:tinytunes/core/database/app_database.dart';
import 'package:tinytunes/core/database/database_providers.dart';
import 'package:tinytunes/features/library/application/library_ingest_controller.dart';
import 'package:tinytunes/features/library/application/library_ingest_l10n_mapper.dart';
import 'package:tinytunes/features/library/presentation/drive_folder_browser_dialog.dart';
import 'package:tinytunes/features/library/presentation/library_source_picker_dialog.dart';
import 'package:tinytunes/features/playlist/application/playlist_providers.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Shared library / queue management actions for playlist home.
///
/// Purpose: Keep ingest and folder dialogs out of the home layout widgets so
/// chrome can change without duplicating business wiring.
/// Usage Context: [PlaylistHomeBaseline] app bar and empty-state CTAs.
class PlaylistLibraryActions {
  /// Creates actions bound to [ref].
  PlaylistLibraryActions(this.ref);

  /// Riverpod handle for ingest / queue / database providers.
  final WidgetRef ref;

  /// Opens the source picker then adds a local or cloud folder.
  Future<void> onAddFolder(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final choice = await showLibrarySourcePicker(context: context);
    if (!context.mounted || choice == null) return;
    switch (choice) {
      case LibrarySourceChoice.local:
        await ref
            .read(libraryIngestControllerProvider.notifier)
            .addFolder(l10n: libraryIngestL10nFrom(l10n));
      case LibrarySourceChoice.googleDrive:
        await _addCloudFolder(context, l10n, CloudProviderId.googleDrive);
      case LibrarySourceChoice.oneDrive:
        await _addCloudFolder(context, l10n, CloudProviderId.oneDrive);
    }
  }

  /// Handles clear / rescan / forget menu actions.
  Future<void> onMenuAction(
    BuildContext context,
    PlaylistMenuAction action,
    AppLocalizations l10n,
  ) async {
    switch (action) {
      case PlaylistMenuAction.clearQueue:
        final ok = await confirm(
          context: context,
          title: l10n.clearQueueTitle,
          body: l10n.clearQueueBody,
          l10n: l10n,
        );
        if (ok && context.mounted) {
          await ref.read(queueActionsProvider).clearQueue();
        }
      case PlaylistMenuAction.rescan:
        final root = await pickRoot(context, l10n);
        if (root != null && context.mounted) {
          await ref
              .read(libraryIngestControllerProvider.notifier)
              .rescanRoot(rootId: root.id, l10n: libraryIngestL10nFrom(l10n));
        }
      case PlaylistMenuAction.forget:
        final root = await pickRoot(context, l10n);
        if (root == null || !context.mounted) return;
        final ok = await confirm(
          context: context,
          title: l10n.forgetFolderTitle,
          body: l10n.forgetFolderBody,
          l10n: l10n,
        );
        if (ok && context.mounted) {
          await ref
              .read(libraryIngestControllerProvider.notifier)
              .forgetRoot(rootId: root.id, l10n: libraryIngestL10nFrom(l10n));
        }
      case PlaylistMenuAction.forgetAll:
        final db = ref.read(appDatabaseProvider);
        final roots = await db.select(db.libraryRoots).get();
        if (!context.mounted) return;
        if (roots.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.noLibraryFolders)));
          return;
        }
        final ok = await confirm(
          context: context,
          title: l10n.forgetAllFoldersTitle,
          body: l10n.forgetAllFoldersBody,
          l10n: l10n,
        );
        if (ok && context.mounted) {
          await ref
              .read(libraryIngestControllerProvider.notifier)
              .forgetAllRoots(l10n: libraryIngestL10nFrom(l10n));
        }
    }
  }

  /// Confirms and forgets a revoked library root.
  Future<void> forgetRevokedRoot(
    BuildContext context,
    int rootId,
    AppLocalizations l10n,
  ) async {
    final ok = await confirm(
      context: context,
      title: l10n.forgetFolderTitle,
      body: l10n.forgetFolderBody,
      l10n: l10n,
    );
    if (ok && context.mounted) {
      await ref
          .read(libraryIngestControllerProvider.notifier)
          .forgetRoot(rootId: rootId, l10n: libraryIngestL10nFrom(l10n));
    }
  }

  /// Standard confirm dialog used by library destructive actions.
  Future<bool> confirm({
    required BuildContext context,
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

  /// Picks a library root when more than one exists.
  Future<LibraryRoot?> pickRoot(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final db = ref.read(appDatabaseProvider);
    final roots = await db.select(db.libraryRoots).get();
    if (!context.mounted) return null;
    if (roots.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noLibraryFolders)));
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

  Future<void> _addCloudFolder(
    BuildContext context,
    AppLocalizations l10n,
    CloudProviderId provider,
  ) async {
    final cloud = await ref.read(cloudLibrarySourceProvider.future);
    if (!context.mounted) return;
    final config = switch (provider) {
      CloudProviderId.googleDrive => CloudFolderBrowserConfig(
        rootLocator: DriveMediaLocator.encode(
          GoogleDriveCloudLibrarySource.myDriveRootFileId,
        ),
        rootDisplayName: l10n.cloudFolderBrowserMyDrive,
      ),
      CloudProviderId.oneDrive => CloudFolderBrowserConfig(
        rootLocator: OneDriveMediaLocator.personalRoot,
        rootDisplayName: l10n.cloudFolderBrowserMyFiles,
      ),
    };
    final signInMessage = switch (provider) {
      CloudProviderId.googleDrive => l10n.libraryCloudSignInRequiredGoogleDrive,
      CloudProviderId.oneDrive => l10n.libraryCloudSignInRequiredOneDrive,
    };
    final ingestL10n = libraryIngestL10nFrom(
      l10n,
    ).withCloudSignInRequired(signInMessage);
    await ref
        .read(libraryIngestControllerProvider.notifier)
        .addCloudFolder(
          l10n: ingestL10n,
          provider: provider,
          pick: () => showCloudFolderPicker(
            context: context,
            cloud: cloud,
            config: config,
          ),
        );
  }
}

/// Playlist overflow menu actions shared by home surfaces.
enum PlaylistMenuAction { clearQueue, rescan, forget, forgetAll }
