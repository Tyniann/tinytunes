import 'package:flutter/material.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/drive_media_locator.dart';
import 'package:tinytunes/core/cloud/google_drive_cloud_library_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/features/library/application/cloud_folder_pick.dart';
import 'package:tinytunes/features/library/application/library_entry_order.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Modal Drive folder browser + subfolders confirm for Add cloud folder.
///
/// Purpose: Let the user pick a Drive folder and whether to recurse, without
/// putting dialog code inside [LibraryIngestController].
/// Usage Context: Playlist home Add-cloud action after Google sign-in.
Future<CloudFolderPick?> showDriveFolderPicker({
  required BuildContext context,
  required CloudLibrarySource cloud,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final folder = await showDialog<_BrowsedFolder>(
    context: context,
    builder: (context) => _DriveFolderBrowserDialog(cloud: cloud, l10n: l10n),
  );
  if (folder == null || !context.mounted) return null;

  final include = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.driveIncludeSubfoldersTitle),
      content: Text(l10n.driveIncludeSubfoldersBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.driveIncludeSubfoldersNo),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.driveIncludeSubfoldersYes),
        ),
      ],
    ),
  );
  if (include == null) return null;

  return CloudFolderPick(
    locator: folder.locator,
    displayName: folder.name,
    includeSubfolders: include,
  );
}

class _BrowsedFolder {
  const _BrowsedFolder({required this.locator, required this.name});

  final MediaLocator locator;
  final String name;
}

class _DriveFolderBrowserDialog extends StatefulWidget {
  const _DriveFolderBrowserDialog({required this.cloud, required this.l10n});

  final CloudLibrarySource cloud;
  final AppLocalizations l10n;

  @override
  State<_DriveFolderBrowserDialog> createState() =>
      _DriveFolderBrowserDialogState();
}

class _DriveFolderBrowserDialogState extends State<_DriveFolderBrowserDialog> {
  final List<_BrowsedFolder> _stack = [
    _BrowsedFolder(
      locator: DriveMediaLocator.encode(
        GoogleDriveCloudLibrarySource.myDriveRootFileId,
      ),
      name: 'My Drive',
    ),
  ];

  /// Folders and audio files under [_current] (folders first for navigation).
  List<CloudLibraryEntry> _children = const [];
  bool _loading = true;
  String? _error;

  _BrowsedFolder get _current => _stack.last;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final children = List<CloudLibraryEntry>.of(
        await widget.cloud.list(_current.locator),
      )..sort(_compareBrowserEntries);
      if (!mounted) return;
      setState(() {
        _children = children;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  /// Folders before files; then display-name order within each group.
  static int _compareBrowserEntries(CloudLibraryEntry a, CloudLibraryEntry b) {
    if (a.isDirectory != b.isDirectory) {
      return a.isDirectory ? -1 : 1;
    }
    return compareDisplayNames(a.name, b.name);
  }

  void _open(CloudLibraryEntry folder) {
    _stack.add(_BrowsedFolder(locator: folder.locator, name: folder.name));
    _load();
  }

  void _goUp() {
    if (_stack.length <= 1) return;
    _stack.removeLast();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.driveFolderBrowserTitle),
      content: SizedBox(
        width: double.maxFinite,
        height: 360,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: IconButton(
                onPressed: _stack.length > 1 ? _goUp : null,
                icon: const Icon(Icons.arrow_upward),
              ),
              title: Text(_current.name),
              subtitle: Text(_current.locator.value),
            ),
            const Divider(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!))
                  : _children.isEmpty
                  ? Center(child: Text(l10n.driveFolderBrowserEmpty))
                  : ListView.builder(
                      itemCount: _children.length,
                      itemBuilder: (context, index) {
                        final entry = _children[index];
                        if (entry.isDirectory) {
                          return ListTile(
                            leading: const Icon(Icons.folder_outlined),
                            title: Text(entry.name),
                            onTap: () => _open(entry),
                          );
                        }
                        return ListTile(
                          leading: const Icon(Icons.audiotrack_outlined),
                          title: Text(entry.name),
                          // Files are preview-only; selection is the current folder.
                          enabled: false,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          onPressed:
              _current.locator.value ==
                  DriveMediaLocator.encode(
                    GoogleDriveCloudLibrarySource.myDriveRootFileId,
                  ).value
              ? null
              : () => Navigator.of(context).pop(_current),
          child: Text(l10n.driveFolderBrowserSelect),
        ),
      ],
    );
  }
}
