import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

/// Root widget for TinyTunes.
///
/// Purpose: Hosts Material 3, localization, and Riverpod scope for the app.
/// Usage Context: Passed to [runApp] from [main].
class MainApp extends StatelessWidget {
  /// Creates the TinyTunes root widget.
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => Text(AppLocalizations.of(context)!.appTitle),
          ),
        ),
      ),
    );
  }
}
