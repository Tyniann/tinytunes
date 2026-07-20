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

/// v1 [ThemeCatalog] (single `default` scheme).

@ProviderFor(themeCatalog)
final themeCatalogProvider = ThemeCatalogProvider._();

/// v1 [ThemeCatalog] (single `default` scheme).

final class ThemeCatalogProvider
    extends $FunctionalProvider<ThemeCatalog, ThemeCatalog, ThemeCatalog>
    with $Provider<ThemeCatalog> {
  /// v1 [ThemeCatalog] (single `default` scheme).
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

String _$themeCatalogHash() => r'857c7bcc85f3119f98e6ffaf2d2781c38e7da3e1';

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

/// Persisted scheme id with write API for later scheme pickers.

@ProviderFor(AppThemeSchemeIdController)
final appThemeSchemeIdControllerProvider =
    AppThemeSchemeIdControllerProvider._();

/// Persisted scheme id with write API for later scheme pickers.
final class AppThemeSchemeIdControllerProvider
    extends $NotifierProvider<AppThemeSchemeIdController, String> {
  /// Persisted scheme id with write API for later scheme pickers.
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

/// Persisted scheme id with write API for later scheme pickers.

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

/// Active [AppThemeScheme] resolved from catalog + scheme id.

@ProviderFor(activeThemeScheme)
final activeThemeSchemeProvider = ActiveThemeSchemeProvider._();

/// Active [AppThemeScheme] resolved from catalog + scheme id.

final class ActiveThemeSchemeProvider
    extends $FunctionalProvider<AppThemeScheme, AppThemeScheme, AppThemeScheme>
    with $Provider<AppThemeScheme> {
  /// Active [AppThemeScheme] resolved from catalog + scheme id.
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

String _$activeThemeSchemeHash() => r'54fc30bb69c1fa929acf314bddbcb4e4369313b6';

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

String _$lightThemeDataHash() => r'8a49641dff910d9dca7855e43cfc2f79aad98768';

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

String _$darkThemeDataHash() => r'4e681530f8815cc83e0958691a3a3098ed2ea784';

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
