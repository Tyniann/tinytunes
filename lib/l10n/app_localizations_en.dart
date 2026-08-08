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
  String get queueEmpty => 'Queue is empty.';

  @override
  String get addFolderAction => 'Add folder';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsModeSection => 'Mode';

  @override
  String get settingsColorSchemeSection => 'Color scheme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSchemeDefault => 'Default';

  @override
  String get settingsSchemeHighContrast => 'High contrast';

  @override
  String get settingsSchemeDynamic => 'Dynamic';

  @override
  String get settingsSchemeDynamicInfoTitle => 'Dynamic';

  @override
  String get settingsSchemeDynamicInfoBody =>
      'Uses colors from your wallpaper (Material You). Light and dark still follow Mode.';

  @override
  String get settingsSchemeDynamicInfoClose => 'OK';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsAboutOpen => 'About TinyTunes';

  @override
  String settingsAboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsAboutChangelogHeading => 'Changelog';

  @override
  String get settingsAboutChangelogLoadFailed =>
      'Could not load the changelog.';

  @override
  String get settingsAboutOpenChangelogOnline => 'Open full changelog online';

  @override
  String get settingsAboutPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsAboutGitHub => 'GitHub repository';

  @override
  String get settingsAboutOpenLinkFailed => 'Could not open the link.';

  @override
  String get settingsAboutClose => 'Close';

  @override
  String get settingsGoogleDriveSection => 'Google Drive';

  @override
  String get settingsGoogleDriveSignIn => 'Sign in with Google';

  @override
  String get settingsGoogleDriveSignOut => 'Sign out';

  @override
  String settingsGoogleDriveSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get settingsCloudAccountReplaceTitle => 'Replace cloud account?';

  @override
  String settingsCloudAccountReplaceBody(
    String previousEmail,
    String newEmail,
  ) {
    return 'Library folders from $previousEmail will be removed from this device (including playlist entries and cached files for that account). $newEmail will become the active account.';
  }

  @override
  String get settingsCloudAccountReplaceConfirm => 'Replace';

  @override
  String get settingsCloudAccountReplaceCancel => 'Cancel';

  @override
  String get settingsOneDriveSection => 'OneDrive';

  @override
  String get settingsOneDriveSignIn => 'Sign in with Microsoft';

  @override
  String get settingsOneDriveSignOut => 'Sign out';

  @override
  String settingsOneDriveSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String settingsCloudCacheLimit(String size) {
    return 'Cloud cache limit: $size';
  }

  @override
  String get settingsCloudCacheClear => 'Clear cloud cache';

  @override
  String get settingsCloudCacheClearTitle => 'Clear cloud cache?';

  @override
  String get settingsCloudCacheClearBody =>
      'Deletes downloaded cloud files on this device. Your library roots and playlist stay intact.';

  @override
  String get settingsCloudCacheCleared => 'Cloud cache cleared.';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesEmpty => 'No messages yet.';

  @override
  String get forgettingProgress => 'Forgetting folder…';

  @override
  String revokedRootBanner(String folderName) {
    return 'Access lost: $folderName';
  }

  @override
  String get forgetRevokedRootAction => 'Forget';

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
  String get transportVolumeExpand => 'Show volume';

  @override
  String get transportVolumeCollapse => 'Hide volume';

  @override
  String get addFolderTooltip => 'Add folder';

  @override
  String get addLibrarySourceTitle => 'Add music from';

  @override
  String get addLibrarySourceLocal => 'This device';

  @override
  String get addLibrarySourceGoogleDrive => 'Google Drive';

  @override
  String get addLibrarySourceOneDrive => 'OneDrive';

  @override
  String get playlistMenuTooltip => 'Playlist actions';

  @override
  String get clearQueue => 'Clear queue';

  @override
  String get rescanFolder => 'Re-scan folder';

  @override
  String get forgetFolder => 'Forget folder';

  @override
  String get forgetAllFolders => 'Forget all folders';

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
  String get forgetAllFoldersTitle => 'Forget all folders?';

  @override
  String get forgetAllFoldersBody =>
      'Removes every library folder (this device and cloud accounts) and clears their songs from the queue. Files on disk and in the cloud are not deleted.';

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
  String get libraryForgetAllComplete => 'All folders forgotten.';

  @override
  String get libraryForgetAllFailed =>
      'Folders removed locally, but some access releases failed.';

  @override
  String get libraryCloudSignInRequired =>
      'Sign in to a cloud account in Settings first.';

  @override
  String get libraryCloudSignInRequiredGoogleDrive =>
      'Sign in to Google Drive in Settings first.';

  @override
  String get libraryCloudSignInRequiredOneDrive =>
      'Sign in to OneDrive in Settings first.';

  @override
  String get addCloudFolderTooltip => 'Add cloud folder';

  @override
  String get cloudFolderBrowserTitle => 'Choose folder';

  @override
  String get cloudFolderBrowserSelect => 'Select this folder';

  @override
  String get cloudFolderBrowserEmpty => 'This folder is empty.';

  @override
  String get cloudFolderBrowserMyDrive => 'My Drive';

  @override
  String get cloudFolderBrowserMyFiles => 'My files';

  @override
  String get cloudFolderBrowserScrollMore => 'More folders below';

  @override
  String get driveIncludeSubfoldersTitle => 'Also load subfolders?';

  @override
  String get driveIncludeSubfoldersBody =>
      'Include nested folders like local Add folder, or only files in this folder.';

  @override
  String get driveIncludeSubfoldersYes => 'Include subfolders';

  @override
  String get driveIncludeSubfoldersNo => 'This folder only';

  @override
  String get unknownArtist => 'Unknown artist';

  @override
  String get playerFileMissing => 'Track file is missing or inaccessible.';

  @override
  String get cloudDownloading => 'Downloading…';

  @override
  String get playerLoadFailed => 'Could not load track for playback.';

  @override
  String get playerRestoreSkipped =>
      'Previous track is no longer in the queue.';

  @override
  String get playerSkipBoundReached =>
      'Stopped after several unplayable tracks in a row.';
}
