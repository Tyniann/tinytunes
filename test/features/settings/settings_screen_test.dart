import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/theme/app_theme_mode.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('theme mode radios persist Light selection', (tester) async {
    await pumpApp(
      tester,
      initialLocation: '/settings',
    );

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.settingsAppearanceSection), findsOneWidget);
    expect(find.text('TinyTunes'), findsWidgets);
    expect(find.text(l10n.settingsAboutVersion('0.6.0')), findsOneWidget);

    await tester.tap(find.text(l10n.settingsThemeLight));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(container.read(appThemeModeControllerProvider), AppThemeMode.light);
    expect(
      container.read(themePreferencesProvider).readMode(),
      AppThemeMode.light,
    );

    await endPumpApp(tester);
  });
}
