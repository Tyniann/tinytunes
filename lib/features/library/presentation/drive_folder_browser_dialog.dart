import 'package:flutter/material.dart';
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/features/library/application/cloud_folder_pick.dart';
import 'package:tinytunes/features/library/application/library_entry_order.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Provider-specific virtual root for the cloud folder browser.
///
/// Purpose: Google starts at My Drive; OneDrive at My files — neither is
/// selectable as an import root.
class CloudFolderBrowserConfig {
  /// Creates a browser config for [rootLocator] labeled [rootDisplayName].
  const CloudFolderBrowserConfig({
    required this.rootLocator,
    required this.rootDisplayName,
  });

  /// Non-persisted browse root (`gdrive:root` or `onedrive:me`).
  final MediaLocator rootLocator;

  /// Localized label for the virtual root.
  final String rootDisplayName;

  /// Whether [locator] is the non-selectable virtual root.
  bool isVirtualRoot(MediaLocator locator) =>
      locator.value == rootLocator.value;
}

/// Modal cloud folder browser + subfolders confirm for Add cloud folder.
///
/// Purpose: Let the user pick a provider folder and whether to recurse, without
/// putting dialog code inside [LibraryIngestController].
/// Usage Context: Playlist home Add-cloud action after provider sign-in.
Future<CloudFolderPick?> showCloudFolderPicker({
  required BuildContext context,
  required CloudLibrarySource cloud,
  required CloudFolderBrowserConfig config,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final folder = await showDialog<_BrowsedFolder>(
    context: context,
    builder: (context) => _CloudFolderBrowserDialog(
      cloud: cloud,
      config: config,
      l10n: l10n,
    ),
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

class _CloudFolderBrowserDialog extends StatefulWidget {
  const _CloudFolderBrowserDialog({
    required this.cloud,
    required this.config,
    required this.l10n,
  });

  final CloudLibrarySource cloud;
  final CloudFolderBrowserConfig config;
  final AppLocalizations l10n;

  @override
  State<_CloudFolderBrowserDialog> createState() =>
      _CloudFolderBrowserDialogState();
}

class _CloudFolderBrowserDialogState extends State<_CloudFolderBrowserDialog> {
  late final List<_BrowsedFolder> _stack = [
    _BrowsedFolder(
      locator: widget.config.rootLocator,
      name: widget.config.rootDisplayName,
    ),
  ];

  final ScrollController _scrollController = ScrollController();

  /// Folders and audio files under [_current] (folders first for navigation).
  List<CloudLibraryEntry> _children = const [];
  bool _loading = true;
  String? _error;

  /// Whether the folder list has more content below the viewport.
  bool _canScrollDown = false;

  _BrowsedFolder get _current => _stack.last;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollAffordances);
    _load();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollAffordances);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollAffordances() {
    if (!_scrollController.hasClients) {
      if (_canScrollDown) {
        setState(() => _canScrollDown = false);
      }
      return;
    }
    final position = _scrollController.position;
    final canDown =
        position.maxScrollExtent > 0 &&
        position.pixels < position.maxScrollExtent - 24;
    if (canDown != _canScrollDown) {
      setState(() => _canScrollDown = canDown);
    }
  }

  void _scheduleScrollAffordances() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateScrollAffordances();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _canScrollDown = false;
    });
    try {
      final children = List<CloudLibraryEntry>.of(
        await widget.cloud.list(_current.locator),
      )..sort(_compareBrowserEntries);
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      setState(() {
        _children = children;
        _loading = false;
      });
      _scheduleScrollAffordances();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
        _canScrollDown = false;
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
    final theme = Theme.of(context);
    final atVirtualRoot = widget.config.isVirtualRoot(_current.locator);
    return AlertDialog(
      title: Text(l10n.cloudFolderBrowserTitle),
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
                  ? Center(child: Text(l10n.cloudFolderBrowserEmpty))
                  : Stack(
                      children: [
                        Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: ListView.builder(
                            controller: _scrollController,
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
                        if (_canScrollDown)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 36,
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      theme.colorScheme.surface.withValues(
                                        alpha: 0,
                                      ),
                                      theme.colorScheme.surface,
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  key: const Key('cloudFolderBrowserScrollHint'),
                                  color: theme.colorScheme.onSurfaceVariant,
                                  semanticLabel:
                                      l10n.cloudFolderBrowserScrollMore,
                                ),
                              ),
                            ),
                          ),
                      ],
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
          onPressed: atVirtualRoot
              ? null
              : () => Navigator.of(context).pop(_current),
          child: Text(l10n.cloudFolderBrowserSelect),
        ),
      ],
    );
  }
}
