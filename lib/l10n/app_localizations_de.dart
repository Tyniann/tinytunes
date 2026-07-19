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
  String get queueEmpty =>
      'Warteschlange ist leer. Ordner hinzufügen, um zu starten.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsStubBody =>
      'Der Designmodus kommt in einer späteren Phase.';

  @override
  String get messagesTitle => 'Nachrichten';

  @override
  String get messagesEmpty => 'Noch keine Nachrichten.';

  @override
  String get addDemoMessage => 'Demo-Nachricht hinzufügen';

  @override
  String get demoInfoMessage => 'Demo-Info-Nachricht';

  @override
  String get demoErrorMessage => 'Demo-Fehler-Nachricht';

  @override
  String get transportPrevious => 'Zurück';

  @override
  String get transportPlayPause => 'Wiedergeben oder pausieren';

  @override
  String get transportNext => 'Weiter';

  @override
  String get addFolderTooltip => 'Ordner hinzufügen';

  @override
  String get playlistMenuTooltip => 'Playlist-Aktionen';

  @override
  String get clearQueue => 'Warteschlange leeren';

  @override
  String get rescanFolder => 'Ordner erneut scannen';

  @override
  String get forgetFolder => 'Ordner vergessen';

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
  String get unknownArtist => 'Unbekannter Künstler';
}
