import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/l10n/locale_resolution.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

void main() {
  const supported = AppLocalizations.supportedLocales;

  test('prefers German when the OS offers de', () {
    expect(
      resolveAppLocale(const [Locale('de'), Locale('fr')], supported),
      const Locale('de'),
    );
  });

  test('prefers English when the OS offers en', () {
    expect(
      resolveAppLocale(const [Locale('en_US')], supported),
      const Locale('en'),
    );
  });

  test('falls back to English when OS locale is unsupported', () {
    // Generated supportedLocales is [de, en]; without the callback Flutter
    // would pick German as the first entry.
    expect(
      resolveAppLocale(const [Locale('fr')], supported),
      const Locale('en'),
    );
  });

  test('falls back to English when preferred list is empty', () {
    expect(resolveAppLocale(const [], supported), const Locale('en'));
    expect(resolveAppLocale(null, supported), const Locale('en'));
  });
}
