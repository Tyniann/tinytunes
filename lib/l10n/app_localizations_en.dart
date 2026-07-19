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
  String get queuePlaceholder => 'Queue';

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
}
