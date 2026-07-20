// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TinyTunes';

  @override
  String get messagesTooltip => 'Messages';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get queueEmpty => 'Queue is empty. Add a folder to get started.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsStubBody => 'Theme mode comes in a later phase.';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesEmpty => 'No messages yet.';

  @override
  String get addDemoMessage => 'Add demo message';

  @override
  String get demoInfoMessage => 'Demo info message';

  @override
  String get demoErrorMessage => 'Demo error message';

  @override
  String get transportPrevious => 'Previous';

  @override
  String get transportPlayPause => 'Play or pause';

  @override
  String get transportNext => 'Next';

  @override
  String get transportShuffle => 'Shuffle';

  @override
  String get transportRepeatOff => 'Repeat off';

  @override
  String get transportRepeatOne => 'Repeat one';

  @override
  String get transportRepeatAll => 'Repeat all';

  @override
  String get addFolderTooltip => 'Add folder';

  @override
  String get playlistMenuTooltip => 'Playlist actions';

  @override
  String get clearQueue => 'Clear queue';

  @override
  String get rescanFolder => 'Re-scan folder';

  @override
  String get forgetFolder => 'Forget folder';

  @override
  String get removeFromQueueTooltip => 'Remove from queue';

  @override
  String get cancelScan => 'Cancel';

  @override
  String scanningProgress(int count) {
    return 'Scanning… $count';
  }

  @override
  String get clearQueueTitle => 'Clear queue?';

  @override
  String get clearQueueBody =>
      'Removes all songs from the queue. Your library folders stay.';

  @override
  String get forgetFolderTitle => 'Forget folder?';

  @override
  String get forgetFolderBody =>
      'Removes this folder from the library and its songs from the queue.';

  @override
  String get confirmAction => 'Confirm';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get pickFolderTitle => 'Choose folder';

  @override
  String get noLibraryFolders => 'No library folders yet.';

  @override
  String get libraryScanStarted => 'Scanning library…';

  @override
  String get libraryScanComplete => 'Library scan complete.';

  @override
  String get libraryScanCancelled => 'Library scan cancelled.';

  @override
  String get libraryScanFailed => 'Library scan failed.';

  @override
  String get libraryRootRevoked => 'Folder access was revoked.';

  @override
  String get libraryForgetComplete => 'Folder forgotten.';

  @override
  String get libraryForgetFailed =>
      'Folder removed locally, but access release failed.';

  @override
  String get unknownArtist => 'Unknown artist';

  @override
  String get playerFileMissing => 'Track file is missing or inaccessible.';

  @override
  String get playerLoadFailed => 'Could not load track for playback.';

  @override
  String get playerRestoreSkipped =>
      'Previous track is no longer in the queue.';

  @override
  String get playerSkipBoundReached =>
      'Stopped after several unplayable tracks in a row.';
}
