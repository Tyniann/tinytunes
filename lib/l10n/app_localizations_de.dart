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
  String get queuePlaceholder => 'Warteschlange';

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
}
