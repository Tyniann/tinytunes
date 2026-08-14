// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// GitHub latest-release client. Tests override with a fake implementation.

@ProviderFor(githubReleaseClient)
final githubReleaseClientProvider = GithubReleaseClientProvider._();

/// GitHub latest-release client. Tests override with a fake implementation.

final class GithubReleaseClientProvider
    extends
        $FunctionalProvider<
          GithubReleaseClient,
          GithubReleaseClient,
          GithubReleaseClient
        >
    with $Provider<GithubReleaseClient> {
  /// GitHub latest-release client. Tests override with a fake implementation.
  GithubReleaseClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'githubReleaseClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$githubReleaseClientHash();

  @$internal
  @override
  $ProviderElement<GithubReleaseClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GithubReleaseClient create(Ref ref) {
    return githubReleaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GithubReleaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GithubReleaseClient>(value),
    );
  }
}

String _$githubReleaseClientHash() =>
    r'cf3856c8c278b4c1940fad96df518d41cc4a95ba';

/// Prefs wrapper for last-check time and dismissed tag.

@ProviderFor(updatePreferences)
final updatePreferencesProvider = UpdatePreferencesProvider._();

/// Prefs wrapper for last-check time and dismissed tag.

final class UpdatePreferencesProvider
    extends
        $FunctionalProvider<
          UpdatePreferences,
          UpdatePreferences,
          UpdatePreferences
        >
    with $Provider<UpdatePreferences> {
  /// Prefs wrapper for last-check time and dismissed tag.
  UpdatePreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updatePreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updatePreferencesHash();

  @$internal
  @override
  $ProviderElement<UpdatePreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdatePreferences create(Ref ref) {
    return updatePreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdatePreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdatePreferences>(value),
    );
  }
}

String _$updatePreferencesHash() => r'6835926dffd7184aafec6bd346ae812a71281729';

/// Installed APK signing hash. Tests override [isOfficialApkProvider] instead.

@ProviderFor(installedSigningHashSource)
final installedSigningHashSourceProvider =
    InstalledSigningHashSourceProvider._();

/// Installed APK signing hash. Tests override [isOfficialApkProvider] instead.

final class InstalledSigningHashSourceProvider
    extends
        $FunctionalProvider<
          InstalledSigningHashSource,
          InstalledSigningHashSource,
          InstalledSigningHashSource
        >
    with $Provider<InstalledSigningHashSource> {
  /// Installed APK signing hash. Tests override [isOfficialApkProvider] instead.
  InstalledSigningHashSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installedSigningHashSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installedSigningHashSourceHash();

  @$internal
  @override
  $ProviderElement<InstalledSigningHashSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InstalledSigningHashSource create(Ref ref) {
    return installedSigningHashSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstalledSigningHashSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstalledSigningHashSource>(value),
    );
  }
}

String _$installedSigningHashSourceHash() =>
    r'e13531b14328c2a61b42d9d62a674eae08303ef1';

/// Whether this install is the official GitHub APK (package + release cert).
///
/// Purpose: Skip GitHub entirely for forks, debug builds, and unsigned hosts.
/// Usage Context: [UpdateCheckController] and About's Check for updates button.

@ProviderFor(isOfficialApk)
final isOfficialApkProvider = IsOfficialApkProvider._();

/// Whether this install is the official GitHub APK (package + release cert).
///
/// Purpose: Skip GitHub entirely for forks, debug builds, and unsigned hosts.
/// Usage Context: [UpdateCheckController] and About's Check for updates button.

final class IsOfficialApkProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether this install is the official GitHub APK (package + release cert).
  ///
  /// Purpose: Skip GitHub entirely for forks, debug builds, and unsigned hosts.
  /// Usage Context: [UpdateCheckController] and About's Check for updates button.
  IsOfficialApkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOfficialApkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOfficialApkHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isOfficialApk(ref);
  }
}

String _$isOfficialApkHash() => r'd1cf5b393ba5e1aa47a6d976846553f5f0fd3854';

/// Clock for interval math. Tests override with a frozen instant.

@ProviderFor(updateClock)
final updateClockProvider = UpdateClockProvider._();

/// Clock for interval math. Tests override with a frozen instant.

final class UpdateClockProvider
    extends
        $FunctionalProvider<
          DateTime Function(),
          DateTime Function(),
          DateTime Function()
        >
    with $Provider<DateTime Function()> {
  /// Clock for interval math. Tests override with a frozen instant.
  UpdateClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateClockHash();

  @$internal
  @override
  $ProviderElement<DateTime Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTime Function() create(Ref ref) {
    return updateClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime Function()>(value),
    );
  }
}

String _$updateClockHash() => r'ac0e13abc5435626ba8a23eb109da2bb0befe624';

/// Runs scheduled and manual GitHub latest-release checks.
///
/// Purpose: Apply [UpdateCheck] policy with injected client, clock, prefs, and
/// [packageInfoProvider]. Failures never go to the message center.
/// Usage Context: [UpdateCheckBinder] on start; About manual check.

@ProviderFor(UpdateCheckController)
final updateCheckControllerProvider = UpdateCheckControllerProvider._();

/// Runs scheduled and manual GitHub latest-release checks.
///
/// Purpose: Apply [UpdateCheck] policy with injected client, clock, prefs, and
/// [packageInfoProvider]. Failures never go to the message center.
/// Usage Context: [UpdateCheckBinder] on start; About manual check.
final class UpdateCheckControllerProvider
    extends $NotifierProvider<UpdateCheckController, UpdateCheckSnapshot> {
  /// Runs scheduled and manual GitHub latest-release checks.
  ///
  /// Purpose: Apply [UpdateCheck] policy with injected client, clock, prefs, and
  /// [packageInfoProvider]. Failures never go to the message center.
  /// Usage Context: [UpdateCheckBinder] on start; About manual check.
  UpdateCheckControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateCheckControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateCheckControllerHash();

  @$internal
  @override
  UpdateCheckController create() => UpdateCheckController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateCheckSnapshot value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateCheckSnapshot>(value),
    );
  }
}

String _$updateCheckControllerHash() =>
    r'5c0e3924ab681a0886e872564d1011c883a17ea0';

/// Runs scheduled and manual GitHub latest-release checks.
///
/// Purpose: Apply [UpdateCheck] policy with injected client, clock, prefs, and
/// [packageInfoProvider]. Failures never go to the message center.
/// Usage Context: [UpdateCheckBinder] on start; About manual check.

abstract class _$UpdateCheckController extends $Notifier<UpdateCheckSnapshot> {
  UpdateCheckSnapshot build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UpdateCheckSnapshot, UpdateCheckSnapshot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UpdateCheckSnapshot, UpdateCheckSnapshot>,
              UpdateCheckSnapshot,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
