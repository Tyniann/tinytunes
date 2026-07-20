import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/features/messages/presentation/messages_screen.dart';
import 'package:tinytunes/features/playlist/presentation/playlist_home_screen.dart';
import 'package:tinytunes/features/settings/presentation/settings_screen.dart';
import 'package:tinytunes/l10n/app_localizations.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('settings and messages routes open; back returns home', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    final settingsL10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(settingsL10n.settingsAppearanceSection), findsOneWidget);
    expect(find.text('TinyTunes'), findsWidgets);
    expect(
      find.text(settingsL10n.settingsAboutVersion('0.6.0')),
      findsOneWidget,
    );

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(PlaylistHomeScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Messages'));
    await tester.pumpAndSettle();
    expect(find.byType(MessagesScreen), findsOneWidget);
    expect(find.text('No messages yet.'), findsOneWidget);
    await endPumpApp(tester);
  });

  testWidgets('reported messages update list; badge hidden at zero and shows count', (
    tester,
  ) async {
    await pumpApp(tester);

    final badgeAtStart = tester.widget<Badge>(find.byType(Badge));
    expect(badgeAtStart.isLabelVisible, isFalse);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(PlaylistHomeScreen)),
    );
    container.read(messageReporterProvider).reportInfo(
          code: 'test.info',
          message: 'Info body',
        );
    container.read(messageReporterProvider).reportError(
          code: 'test.error',
          message: 'Error body',
        );
    await tester.pump();

    final badgeAfterReport = tester.widget<Badge>(find.byType(Badge));
    expect(badgeAfterReport.isLabelVisible, isTrue);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byTooltip('Messages'));
    await tester.pumpAndSettle();

    expect(find.text('Info body'), findsOneWidget);
    expect(find.text('Error body'), findsOneWidget);
    expect(find.text('test.info'), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    final badgeAfterLeave = tester.widget<Badge>(find.byType(Badge));
    expect(badgeAfterLeave.isLabelVisible, isFalse);
    await endPumpApp(tester);
  });

  testWidgets('reporting a message on home does not reset the router stack', (
    tester,
  ) async {
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(PlaylistHomeScreen)),
    );
    container.read(messageReporterProvider).reportInfo(
          code: 'home.info',
          message: 'Still on home',
        );
    await tester.pump();

    expect(find.byType(PlaylistHomeScreen), findsOneWidget);
    expect(find.text('Queue is empty.'), findsOneWidget);
    expect(find.text('Add folder'), findsWidgets);
    await endPumpApp(tester);
  });
}
