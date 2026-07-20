import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:tinytunes/core/l10n/locale_resolution.dart';
import 'package:tinytunes/core/routing/app_router.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';
import 'package:tinytunes/features/player/application/playback_controller.dart';
import 'package:tinytunes/features/player/application/player_providers.dart';
import 'package:tinytunes/features/player/application/tinytunes_audio_handler.dart';
import 'package:tinytunes/l10n/app_localizations.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Needed so path_provider / MethodChannels work before runApp; also primes
  // libsqlite3.so on older Android (no-op when already loadable).
  await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();

  final handler = await AudioService.init(
    builder: TinyTunesAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'at.blumenlaube.tinytunes.audio',
      androidNotificationChannelName: 'TinyTunes',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      audioHandlerProvider.overrideWithValue(handler),
    ],
  );

  // Eager attach: controller owns engine + session; handler receives remote.
  container.read(playbackControllerProvider);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TinyTunesApp(),
    ),
  );
}

/// Root TinyTunes application widget shared by production and tests.
///
/// Purpose: Compose Material 3 themes, l10n, typed router, and toast overlay
/// in one place so [pumpApp] cannot drift from `main`.
/// Usage Context: Passed to [runApp] after prefs bootstrap; also used by the
/// widget test harness.
class TinyTunesApp extends ConsumerWidget {
  /// Creates the TinyTunes root widget.
  const TinyTunesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final light = ref.watch(lightThemeDataProvider);
    final dark = ref.watch(darkThemeDataProvider);
    final themeMode = ref.watch(materialThemeModeProvider);

    return ToastificationWrapper(
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: light,
        darkTheme: dark,
        themeMode: themeMode,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        localeListResolutionCallback: resolveAppLocale,
        routerConfig: router,
      ),
    );
  }
}
