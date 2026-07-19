import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/features/playlist/presentation/playlist_home_screen.dart';
import 'package:tinytunes/features/settings/presentation/settings_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('settings and messages routes open; back returns home', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Theme mode comes in a later phase.'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(PlaylistHomeScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Messages'));
    await tester.pumpAndSettle();
    expect(find.text('Add demo message'), findsOneWidget);
  });

  testWidgets('demo messages update list; badge hidden at zero and shows count', (
    tester,
  ) async {
    await pumpApp(tester);

    final badgeAtStart = tester.widget<Badge>(find.byType(Badge));
    expect(badgeAtStart.isLabelVisible, isFalse);

    await tester.tap(find.byTooltip('Messages'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add demo message'));
    await tester.pumpAndSettle();

    expect(find.text('Demo info message'), findsOneWidget);
    expect(find.text('Demo error message'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    final badgeAfterLeave = tester.widget<Badge>(find.byType(Badge));
    expect(badgeAfterLeave.isLabelVisible, isTrue);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byTooltip('Messages'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    final badgeAfterReenter = tester.widget<Badge>(find.byType(Badge));
    expect(badgeAfterReenter.isLabelVisible, isFalse);
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
    expect(find.text('Queue'), findsOneWidget);
  });
}
