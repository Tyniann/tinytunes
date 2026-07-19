import 'package:flutter/material.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

/// Settings stub until Phase 5 fills theme mode and other daily-driver prefs.
///
/// Purpose: Hold the `/settings` destination so IA navigation works in Phase 1.
/// Usage Context: [SettingsRoute]; no theme picker UI yet.
class SettingsScreen extends StatelessWidget {
  /// Creates the Settings stub screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Center(child: Text(l10n.settingsStubBody)),
    );
  }
}
