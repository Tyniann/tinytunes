import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tinytunes/core/routing/app_routes.dart';

part 'app_router.g.dart';

/// Root navigator key for [GoRouter] and optional overlay delivery.
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Long-lived app [GoRouter] — routes only, no theme/message watches.
///
/// Purpose: Keep a single router instance so reporting messages cannot rebuild
/// navigation and reset the stack.
/// Usage Context: [MaterialApp.router] `routerConfig` via [TinyTunesApp].
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: $appRoutes,
  );
}
