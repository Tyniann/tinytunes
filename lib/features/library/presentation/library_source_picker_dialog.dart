import 'package:flutter/material.dart';
import 'package:tinytunes/l10n/app_localizations.dart';
import 'package:tinytunes/shared/widgets/google_branding.dart';

/// Which library backend the user picked for Add folder.
enum LibrarySourceChoice {
  /// Local SAF / device folders.
  local,

  /// Google Drive cloud folder.
  googleDrive,
}

/// Shows a picker: This device vs Google Drive.
///
/// Purpose: One home "+" entry point that branches to local or cloud ingest.
/// Usage Context: Playlist home Add folder action.
Future<LibrarySourceChoice?> showLibrarySourcePicker({
  required BuildContext context,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<LibrarySourceChoice>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(l10n.addLibrarySourceTitle),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop(LibrarySourceChoice.local),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.folder_outlined),
            title: Text(l10n.addLibrarySourceLocal),
          ),
        ),
        SimpleDialogOption(
          onPressed: () =>
              Navigator.of(context).pop(LibrarySourceChoice.googleDrive),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const GoogleDriveMark(size: 28),
            title: Text(l10n.addLibrarySourceGoogleDrive),
          ),
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
