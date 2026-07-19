import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/theme/app_theme_mode.dart';
import 'package:tinytunes/core/theme/theme_preferences.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('forced light mode resolves light catalog theme', (tester) async {
    await pumpApp(
      tester,
      overrides: [
        appThemeModeControllerProvider.overrideWith(
          () => _FixedThemeMode(AppThemeMode.light),
        ),
      ],
    );

    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.light);
    expect(Theme.of(context).colorScheme.brightness, Brightness.light);
    expect(Theme.of(context).useMaterial3, isTrue);
    await endPumpApp(tester);
  });

  testWidgets('forced dark mode resolves dark catalog theme', (tester) async {
    await pumpApp(
      tester,
      overrides: [
        appThemeModeControllerProvider.overrideWith(
          () => _FixedThemeMode(AppThemeMode.dark),
        ),
      ],
    );

    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(Theme.of(context).colorScheme.brightness, Brightness.dark);
    expect(Theme.of(context).useMaterial3, isTrue);
    await endPumpApp(tester);
  });

  testWidgets('invalid prefs fall back to system mode and default scheme', (
    tester,
  ) async {
    await pumpApp(
      tester,
      prefsValues: {
        ThemePreferences.modeKey: 'not-a-mode',
        ThemePreferences.schemeIdKey: 'missing-scheme',
      },
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(container.read(appThemeModeControllerProvider), AppThemeMode.system);
    expect(
      container.read(appThemeSchemeIdControllerProvider),
      'missing-scheme',
    );
    expect(container.read(activeThemeSchemeProvider).id, 'default');
    await endPumpApp(tester);
  });
}

/// Test notifier that always exposes a fixed [AppThemeMode].
class _FixedThemeMode extends AppThemeModeController {
  _FixedThemeMode(this._mode);

  final AppThemeMode _mode;

  @override
  AppThemeMode build() => _mode;
}
