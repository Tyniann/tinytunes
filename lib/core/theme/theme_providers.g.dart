// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injected [SharedPreferences] overridden in `main` after bootstrap.
///
/// Purpose: Keep theme reads synchronous; never call `getInstance` from
/// providers. Tests override with [SharedPreferences.setMockInitialValues].

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Injected [SharedPreferences] overridden in `main` after bootstrap.
///
/// Purpose: Keep theme reads synchronous; never call `getInstance` from
/// providers. Tests override with [SharedPreferences.setMockInitialValues].

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// Injected [SharedPreferences] overridden in `main` after bootstrap.
  ///
  /// Purpose: Keep theme reads synchronous; never call `getInstance` from
  /// providers. Tests override with [SharedPreferences.setMockInitialValues].
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'97dfeab6f723774dfa2bb7e903b7bda45a545e51';

/// Theme prefs wrapper around the injected [SharedPreferences].

@ProviderFor(themePreferences)
final themePreferencesProvider = ThemePreferencesProvider._();

/// Theme prefs wrapper around the injected [SharedPreferences].

final class ThemePreferencesProvider
    extends
        $FunctionalProvider<
          ThemePreferences,
          ThemePreferences,
          ThemePreferences
        >
    with $Provider<ThemePreferences> {
  /// Theme prefs wrapper around the injected [SharedPreferences].
  ThemePreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themePreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themePreferencesHash();

  @$internal
  @override
  $ProviderElement<ThemePreferences> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemePreferences create(Ref ref) {
    return themePreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemePreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemePreferences>(value),
    );
  }
}

String _$themePreferencesHash() => r'1bffd8962a6c5909df735d37cfb3b51e19505d4c';

/// Shipped [ThemeCatalog] (`default` + `highContrast`).

@ProviderFor(themeCatalog)
final themeCatalogProvider = ThemeCatalogProvider._();

/// Shipped [ThemeCatalog] (`default` + `highContrast`).

final class ThemeCatalogProvider
    extends $FunctionalProvider<ThemeCatalog, ThemeCatalog, ThemeCatalog>
    with $Provider<ThemeCatalog> {
  /// Shipped [ThemeCatalog] (`default` + `highContrast`).
  ThemeCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeCatalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeCatalogHash();

  @$internal
  @override
  $ProviderElement<ThemeCatalog> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeCatalog create(Ref ref) {
    return themeCatalog(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeCatalog value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeCatalog>(value),
    );
  }
}

String _$themeCatalogHash() => r'068ded7f06bab156324528b9811e4b6f00da44ef';

/// Platform Material You colors bridged from [DynamicColorBinder].

@ProviderFor(DynamicColorAvailabilityController)
final dynamicColorAvailabilityControllerProvider =
    DynamicColorAvailabilityControllerProvider._();

/// Platform Material You colors bridged from [DynamicColorBinder].
final class DynamicColorAvailabilityControllerProvider
    extends
        $NotifierProvider<
          DynamicColorAvailabilityController,
          DynamicColorAvailability
        > {
  /// Platform Material You colors bridged from [DynamicColorBinder].
  DynamicColorAvailabilityControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dynamicColorAvailabilityControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$dynamicColorAvailabilityControllerHash();

  @$internal
  @override
  DynamicColorAvailabilityController create() =>
      DynamicColorAvailabilityController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DynamicColorAvailability value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DynamicColorAvailability>(value),
    );
  }
}

String _$dynamicColorAvailabilityControllerHash() =>
    r'225c9a33cc0522a1c3bec493365426564d40aa1b';

/// Platform Material You colors bridged from [DynamicColorBinder].

abstract class _$DynamicColorAvailabilityController
    extends $Notifier<DynamicColorAvailability> {
  DynamicColorAvailability build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<DynamicColorAvailability, DynamicColorAvailability>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DynamicColorAvailability, DynamicColorAvailability>,
              DynamicColorAvailability,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Persisted appearance mode with write API for Settings and tests.

@ProviderFor(AppThemeModeController)
final appThemeModeControllerProvider = AppThemeModeControllerProvider._();

/// Persisted appearance mode with write API for Settings and tests.
final class AppThemeModeControllerProvider
    extends $NotifierProvider<AppThemeModeController, AppThemeMode> {
  /// Persisted appearance mode with write API for Settings and tests.
  AppThemeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeModeControllerHash();

  @$internal
  @override
  AppThemeModeController create() => AppThemeModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeMode>(value),
    );
  }
}

String _$appThemeModeControllerHash() =>
    r'01e82dced6ab56a9feec8ebad0119213e228c227';

/// Persisted appearance mode with write API for Settings and tests.

abstract class _$AppThemeModeController extends $Notifier<AppThemeMode> {
  AppThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppThemeMode, AppThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppThemeMode, AppThemeMode>,
              AppThemeMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Persisted scheme id with write API for Settings and tests.

@ProviderFor(AppThemeSchemeIdController)
final appThemeSchemeIdControllerProvider =
    AppThemeSchemeIdControllerProvider._();

/// Persisted scheme id with write API for Settings and tests.
final class AppThemeSchemeIdControllerProvider
    extends $NotifierProvider<AppThemeSchemeIdController, String> {
  /// Persisted scheme id with write API for Settings and tests.
  AppThemeSchemeIdControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeSchemeIdControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeSchemeIdControllerHash();

  @$internal
  @override
  AppThemeSchemeIdController create() => AppThemeSchemeIdController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$appThemeSchemeIdControllerHash() =>
    r'3204e0703834b7e9dda687b37d9b4f0c2816608e';

/// Persisted scheme id with write API for Settings and tests.

abstract class _$AppThemeSchemeIdController extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Rewrites prefs from `dynamic` to `default` once Dynamic is known unavailable.
///
/// Purpose: Keep Settings honest when the Dynamic chip is hidden, without the
/// scheme controller depending on itself during [build].
/// Usage Context: Watched from theme data providers so the guard stays alive.

@ProviderFor(dynamicSchemeGuard)
final dynamicSchemeGuardProvider = DynamicSchemeGuardProvider._();

/// Rewrites prefs from `dynamic` to `default` once Dynamic is known unavailable.
///
/// Purpose: Keep Settings honest when the Dynamic chip is hidden, without the
/// scheme controller depending on itself during [build].
/// Usage Context: Watched from theme data providers so the guard stays alive.

final class DynamicSchemeGuardProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Rewrites prefs from `dynamic` to `default` once Dynamic is known unavailable.
  ///
  /// Purpose: Keep Settings honest when the Dynamic chip is hidden, without the
  /// scheme controller depending on itself during [build].
  /// Usage Context: Watched from theme data providers so the guard stays alive.
  DynamicSchemeGuardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dynamicSchemeGuardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dynamicSchemeGuardHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return dynamicSchemeGuard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$dynamicSchemeGuardHash() =>
    r'6ddf4bc6a9d5160c957a25c7be0a3d4bc28bc5c2';

/// Active static [AppThemeScheme] for non-dynamic scheme ids.
///
/// When prefs say Dynamic, returns the catalog `default` seed scheme for
/// callers that need a static entry; prefer theme data / [previewColorScheme].

@ProviderFor(activeThemeScheme)
final activeThemeSchemeProvider = ActiveThemeSchemeProvider._();

/// Active static [AppThemeScheme] for non-dynamic scheme ids.
///
/// When prefs say Dynamic, returns the catalog `default` seed scheme for
/// callers that need a static entry; prefer theme data / [previewColorScheme].

final class ActiveThemeSchemeProvider
    extends $FunctionalProvider<AppThemeScheme, AppThemeScheme, AppThemeScheme>
    with $Provider<AppThemeScheme> {
  /// Active static [AppThemeScheme] for non-dynamic scheme ids.
  ///
  /// When prefs say Dynamic, returns the catalog `default` seed scheme for
  /// callers that need a static entry; prefer theme data / [previewColorScheme].
  ActiveThemeSchemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeThemeSchemeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeThemeSchemeHash();

  @$internal
  @override
  $ProviderElement<AppThemeScheme> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppThemeScheme create(Ref ref) {
    return activeThemeScheme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeScheme value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeScheme>(value),
    );
  }
}

String _$activeThemeSchemeHash() => r'f7992a3dfd07f83f26d4ff8d52f397dbbd96df65';

/// Light [ThemeData] for [MaterialApp.router].

@ProviderFor(lightThemeData)
final lightThemeDataProvider = LightThemeDataProvider._();

/// Light [ThemeData] for [MaterialApp.router].

final class LightThemeDataProvider
    extends $FunctionalProvider<ThemeData, ThemeData, ThemeData>
    with $Provider<ThemeData> {
  /// Light [ThemeData] for [MaterialApp.router].
  LightThemeDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lightThemeDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lightThemeDataHash();

  @$internal
  @override
  $ProviderElement<ThemeData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeData create(Ref ref) {
    return lightThemeData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeData>(value),
    );
  }
}

String _$lightThemeDataHash() => r'4dbc0104b1a6cc2ac75eb49052b1a1a7bf9a9da5';

/// Dark [ThemeData] for [MaterialApp.router].

@ProviderFor(darkThemeData)
final darkThemeDataProvider = DarkThemeDataProvider._();

/// Dark [ThemeData] for [MaterialApp.router].

final class DarkThemeDataProvider
    extends $FunctionalProvider<ThemeData, ThemeData, ThemeData>
    with $Provider<ThemeData> {
  /// Dark [ThemeData] for [MaterialApp.router].
  DarkThemeDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'darkThemeDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$darkThemeDataHash();

  @$internal
  @override
  $ProviderElement<ThemeData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeData create(Ref ref) {
    return darkThemeData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeData>(value),
    );
  }
}

String _$darkThemeDataHash() => r'd770cfb090a24ec1334710cfdc96d6b1d8741207';

/// Flutter [ThemeMode] derived from [AppThemeModeController].

@ProviderFor(materialThemeMode)
final materialThemeModeProvider = MaterialThemeModeProvider._();

/// Flutter [ThemeMode] derived from [AppThemeModeController].

final class MaterialThemeModeProvider
    extends $FunctionalProvider<ThemeMode, ThemeMode, ThemeMode>
    with $Provider<ThemeMode> {
  /// Flutter [ThemeMode] derived from [AppThemeModeController].
  MaterialThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'materialThemeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$materialThemeModeHash();

  @$internal
  @override
  $ProviderElement<ThemeMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeMode create(Ref ref) {
    return materialThemeMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$materialThemeModeHash() => r'd826c852e6f0d2989dded90fa2d81d80008a8468';
