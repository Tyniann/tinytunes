import 'package:flutter/material.dart';

/// Resolves the app locale from the device preferred list.
///
/// Purpose: Prefer German or English when the OS offers them; otherwise fall
/// back to English so unsupported locales never land on the first generated
/// [supportedLocales] entry (today German).
/// Usage Context: Pass to [MaterialApp.localeListResolutionCallback].
Locale resolveAppLocale(
  List<Locale>? locales,
  Iterable<Locale> supportedLocales,
) {
  const english = Locale('en');
  final supported = supportedLocales.toList(growable: false);
  if (locales == null || locales.isEmpty) {
    return english;
  }

  for (final preferred in locales) {
    for (final candidate in supported) {
      if (candidate.languageCode == preferred.languageCode) {
        return candidate;
      }
    }
  }

  return english;
}
