import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tinytunes/features/messages/presentation/messages_screen.dart';
import 'package:tinytunes/features/playlist/presentation/playlist_home_screen.dart';
import 'package:tinytunes/features/settings/presentation/settings_screen.dart';

part 'app_routes.g.dart';

/// Typed route for the playlist home shell (`/`).
@TypedGoRoute<PlaylistHomeRoute>(path: '/')
class PlaylistHomeRoute extends GoRouteData with $PlaylistHomeRoute {
  /// Creates the playlist home route.
  const PlaylistHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PlaylistHomeScreen();
  }
}

/// Typed route for the Settings stub (`/settings`).
@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with $SettingsRoute {
  /// Creates the Settings route.
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}

/// Typed route for the message center (`/messages`).
@TypedGoRoute<MessagesRoute>(path: '/messages')
class MessagesRoute extends GoRouteData with $MessagesRoute {
  /// Creates the Messages route.
  const MessagesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const MessagesScreen();
  }
}
