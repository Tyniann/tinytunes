// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'TinyTunes';

  @override
  String get messagesTooltip => 'Nachrichten';

  @override
  String get settingsTooltip => 'Einstellungen';

  @override
  String get queueEmpty => 'Warteschlange ist leer.';

  @override
  String get addFolderAction => 'Ordner hinzufügen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsModeSection => 'Modus';

  @override
  String get settingsColorSchemeSection => 'Farbschema';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsSchemeDefault => 'Standard';

  @override
  String get settingsSchemeHighContrast => 'Hoher Kontrast';

  @override
  String get settingsSchemeDynamic => 'Dynamisch';

  @override
  String get settingsSchemeDynamicInfoTitle => 'Dynamisch';

  @override
  String get settingsSchemeDynamicInfoBody =>
      'Verwendet Farben von deinem Hintergrundbild (Material You). Hell und Dunkel folgen weiterhin dem Modus.';

  @override
  String get settingsSchemeDynamicInfoClose => 'OK';

  @override
  String get settingsAboutSection => 'Über';

  @override
  String get settingsAboutOpen => 'Über TinyTunes';

  @override
  String settingsAboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsAboutChangelogHeading => 'Änderungsprotokoll';

  @override
  String get settingsAboutChangelogLoadFailed =>
      'Änderungsprotokoll konnte nicht geladen werden.';

  @override
  String get settingsAboutOpenChangelogOnline =>
      'Vollständiges Changelog online öffnen';

  @override
  String get settingsAboutPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get settingsAboutGitHub => 'GitHub-Repository';

  @override
  String get settingsAboutOpenLinkFailed =>
      'Link konnte nicht geöffnet werden.';

  @override
  String get settingsAboutClose => 'Schließen';

  @override
  String get settingsGoogleDriveSection => 'Google Drive';

  @override
  String get settingsGoogleDriveSignIn => 'Mit Google anmelden';

  @override
  String get settingsGoogleDriveSignOut => 'Abmelden';

  @override
  String settingsGoogleDriveSignedInAs(String email) {
    return 'Angemeldet als $email';
  }

  @override
  String get settingsCloudAccountReplaceTitle => 'Cloud-Konto ersetzen?';

  @override
  String settingsCloudAccountReplaceBody(
    String previousEmail,
    String newEmail,
  ) {
    return 'Bibliotheksordner von $previousEmail werden von diesem Gerät entfernt (einschließlich Playlist-Einträgen und Cache-Dateien dieses Kontos). $newEmail wird das aktive Konto.';
  }

  @override
  String get settingsCloudAccountReplaceConfirm => 'Ersetzen';

  @override
  String get settingsCloudAccountReplaceCancel => 'Abbrechen';

  @override
  String get settingsOneDriveSection => 'OneDrive';

  @override
  String get settingsOneDriveSignIn => 'Mit Microsoft anmelden';

  @override
  String get settingsOneDriveSignOut => 'Abmelden';

  @override
  String settingsOneDriveSignedInAs(String email) {
    return 'Angemeldet als $email';
  }

  @override
  String settingsCloudCacheLimit(String size) {
    return 'Cloud-Cache-Limit: $size';
  }

  @override
  String get settingsCloudCacheClear => 'Cloud-Cache leeren';

  @override
  String get settingsCloudCacheClearTitle => 'Cloud-Cache leeren?';

  @override
  String get settingsCloudCacheClearBody =>
      'Löscht heruntergeladene Cloud-Dateien auf diesem Gerät. Bibliotheksordner und Playlist bleiben erhalten.';

  @override
  String get settingsCloudCacheCleared => 'Cloud-Cache geleert.';

  @override
  String get messagesTitle => 'Nachrichten';

  @override
  String get messagesEmpty => 'Noch keine Nachrichten.';

  @override
  String get forgettingProgress => 'Ordner wird vergessen…';

  @override
  String revokedRootBanner(String folderName) {
    return 'Zugriff verloren: $folderName';
  }

  @override
  String get forgetRevokedRootAction => 'Vergessen';

  @override
  String get transportPrevious => 'Zurück';

  @override
  String get transportPlayPause => 'Wiedergeben oder pausieren';

  @override
  String get transportNext => 'Weiter';

  @override
  String get transportShuffle => 'Zufallswiedergabe';

  @override
  String get transportRepeatOff => 'Wiederholung aus';

  @override
  String get transportRepeatOne => 'Titel wiederholen';

  @override
  String get transportRepeatAll => 'Alle wiederholen';

  @override
  String get transportVolumeExpand => 'Lautstärke anzeigen';

  @override
  String get transportVolumeCollapse => 'Lautstärke ausblenden';

  @override
  String get addFolderTooltip => 'Ordner hinzufügen';

  @override
  String get addLibrarySourceTitle => 'Musik hinzufügen von';

  @override
  String get addLibrarySourceLocal => 'Dieses Gerät';

  @override
  String get addLibrarySourceGoogleDrive => 'Google Drive';

  @override
  String get addLibrarySourceOneDrive => 'OneDrive';

  @override
  String get playlistMenuTooltip => 'Playlist-Aktionen';

  @override
  String get clearQueue => 'Warteschlange leeren';

  @override
  String get rescanFolder => 'Ordner erneut scannen';

  @override
  String get forgetFolder => 'Ordner vergessen';

  @override
  String get forgetAllFolders => 'Alle Ordner vergessen';

  @override
  String get removeFromQueueTooltip => 'Aus Warteschlange entfernen';

  @override
  String get cancelScan => 'Abbrechen';

  @override
  String scanningProgress(int count) {
    return 'Scannen… $count';
  }

  @override
  String get clearQueueTitle => 'Warteschlange leeren?';

  @override
  String get clearQueueBody =>
      'Entfernt alle Titel aus der Warteschlange. Bibliotheksordner bleiben erhalten.';

  @override
  String get forgetFolderTitle => 'Ordner vergessen?';

  @override
  String get forgetFolderBody =>
      'Entfernt diesen Ordner aus der Bibliothek und seine Titel aus der Warteschlange.';

  @override
  String get forgetAllFoldersTitle => 'Alle Ordner vergessen?';

  @override
  String get forgetAllFoldersBody =>
      'Entfernt jeden Bibliotheksordner (dieses Gerät und Cloud-Konten) und ihre Titel aus der Warteschlange. Dateien auf dem Gerät und in der Cloud werden nicht gelöscht.';

  @override
  String get confirmAction => 'Bestätigen';

  @override
  String get cancelAction => 'Abbrechen';

  @override
  String get pickFolderTitle => 'Ordner wählen';

  @override
  String get noLibraryFolders => 'Noch keine Bibliotheksordner.';

  @override
  String get libraryScanStarted => 'Bibliothek wird gescannt…';

  @override
  String get libraryScanComplete => 'Bibliotheksscan abgeschlossen.';

  @override
  String get libraryScanCancelled => 'Bibliotheksscan abgebrochen.';

  @override
  String get libraryScanFailed => 'Bibliotheksscan fehlgeschlagen.';

  @override
  String get libraryRootRevoked => 'Ordnerzugriff wurde widerrufen.';

  @override
  String get libraryForgetComplete => 'Ordner vergessen.';

  @override
  String get libraryForgetFailed =>
      'Ordner lokal entfernt, aber Freigabe fehlgeschlagen.';

  @override
  String get libraryForgetAllComplete => 'Alle Ordner vergessen.';

  @override
  String get libraryForgetAllFailed =>
      'Ordner lokal entfernt, aber einige Freigaben fehlgeschlagen.';

  @override
  String get libraryCloudSignInRequired =>
      'Melde dich zuerst in den Einstellungen bei einem Cloud-Konto an.';

  @override
  String get libraryCloudSignInRequiredGoogleDrive =>
      'Melde dich zuerst in den Einstellungen bei Google Drive an.';

  @override
  String get libraryCloudSignInRequiredOneDrive =>
      'Melde dich zuerst in den Einstellungen bei OneDrive an.';

  @override
  String get addCloudFolderTooltip => 'Cloud-Ordner hinzufügen';

  @override
  String get cloudFolderBrowserTitle => 'Ordner wählen';

  @override
  String get cloudFolderBrowserSelect => 'Diesen Ordner wählen';

  @override
  String get cloudFolderBrowserEmpty => 'Dieser Ordner ist leer.';

  @override
  String get cloudFolderBrowserMyDrive => 'Meine Ablage';

  @override
  String get cloudFolderBrowserMyFiles => 'Meine Dateien';

  @override
  String get cloudFolderBrowserScrollMore => 'Weitere Ordner darunter';

  @override
  String get driveIncludeSubfoldersTitle => 'Auch Unterordner laden?';

  @override
  String get driveIncludeSubfoldersBody =>
      'Verschachtelte Ordner wie beim lokalen Hinzufügen einbeziehen, oder nur Dateien in diesem Ordner.';

  @override
  String get driveIncludeSubfoldersYes => 'Unterordner einbeziehen';

  @override
  String get driveIncludeSubfoldersNo => 'Nur dieser Ordner';

  @override
  String get unknownArtist => 'Unbekannter Künstler';

  @override
  String get playerFileMissing => 'Titeldatei fehlt oder ist nicht zugänglich.';

  @override
  String get cloudDownloading => 'Wird heruntergeladen…';

  @override
  String get playerLoadFailed => 'Titel konnte nicht geladen werden.';

  @override
  String get playerRestoreSkipped =>
      'Vorheriger Titel ist nicht mehr in der Warteschlange.';

  @override
  String get playerSkipBoundReached =>
      'Gestoppt nach mehreren nicht abspielbaren Titeln.';
}
