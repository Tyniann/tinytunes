import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinytunes/core/messages/message_providers.dart';
import 'package:tinytunes/core/messages/toast_delivery.dart';
import 'package:tinytunes/core/routing/app_router.dart';
import 'package:tinytunes/core/routing/app_routes.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:tinytunes/main.dart';

/// Pumps [TinyTunesApp] with mock prefs and a noop [ToastDelivery].
///
/// Purpose: Keep production and tests on the same root widget; suppress toasts
/// so assertions target store/badge/list instead of overlay pixels.
Future<void> pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefsValues = const {},
  List<Override> overrides = const [],
  String initialLocation = '/',
}) async {
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        toastDeliveryProvider.overrideWithValue(const NoopToastDelivery()),
        appRouterProvider.overrideWithValue(
          GoRouter(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'test-root'),
            initialLocation: initialLocation,
            routes: $appRoutes,
          ),
        ),
        ...overrides,
      ],
      child: const TinyTunesApp(),
    ),
  );
  await tester.pumpAndSettle();
}
