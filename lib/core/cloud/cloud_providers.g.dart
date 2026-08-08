// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Production [GoogleDriveAuth]. Tests override [googleDriveAuthProvider].

@ProviderFor(googleDriveAuth)
final googleDriveAuthProvider = GoogleDriveAuthProvider._();

/// Production [GoogleDriveAuth]. Tests override [googleDriveAuthProvider].

final class GoogleDriveAuthProvider
    extends
        $FunctionalProvider<GoogleDriveAuth, GoogleDriveAuth, GoogleDriveAuth>
    with $Provider<GoogleDriveAuth> {
  /// Production [GoogleDriveAuth]. Tests override [googleDriveAuthProvider].
  GoogleDriveAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleDriveAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleDriveAuthHash();

  @$internal
  @override
  $ProviderElement<GoogleDriveAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoogleDriveAuth create(Ref ref) {
    return googleDriveAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleDriveAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleDriveAuth>(value),
    );
  }
}

String _$googleDriveAuthHash() => r'06094ce8ccf1da72a5bb11d6315b1b6981b9db4e';

/// Production [DriveRemote]. Tests override with a fake.

@ProviderFor(driveRemote)
final driveRemoteProvider = DriveRemoteProvider._();

/// Production [DriveRemote]. Tests override with a fake.

final class DriveRemoteProvider
    extends $FunctionalProvider<DriveRemote, DriveRemote, DriveRemote>
    with $Provider<DriveRemote> {
  /// Production [DriveRemote]. Tests override with a fake.
  DriveRemoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driveRemoteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driveRemoteHash();

  @$internal
  @override
  $ProviderElement<DriveRemote> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DriveRemote create(Ref ref) {
    return driveRemote(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriveRemote value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriveRemote>(value),
    );
  }
}

String _$driveRemoteHash() => r'314a3fae81e0ac2286b13869799c16a8e9447437';

/// Free-space checks for cloud downloads (Android StatFs; unlimited elsewhere).

@ProviderFor(freeSpaceSource)
final freeSpaceSourceProvider = FreeSpaceSourceProvider._();

/// Free-space checks for cloud downloads (Android StatFs; unlimited elsewhere).

final class FreeSpaceSourceProvider
    extends
        $FunctionalProvider<FreeSpaceSource, FreeSpaceSource, FreeSpaceSource>
    with $Provider<FreeSpaceSource> {
  /// Free-space checks for cloud downloads (Android StatFs; unlimited elsewhere).
  FreeSpaceSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'freeSpaceSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$freeSpaceSourceHash();

  @$internal
  @override
  $ProviderElement<FreeSpaceSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FreeSpaceSource create(Ref ref) {
    return freeSpaceSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FreeSpaceSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FreeSpaceSource>(value),
    );
  }
}

String _$freeSpaceSourceHash() => r'5fa615fd2adf07feebef0aade5e7a9ef7b748967';

/// Root directory for Drive cache files under application support.

@ProviderFor(cloudCacheDirectory)
final cloudCacheDirectoryProvider = CloudCacheDirectoryProvider._();

/// Root directory for Drive cache files under application support.

final class CloudCacheDirectoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<Directory>,
          Directory,
          FutureOr<Directory>
        >
    with $FutureModifier<Directory>, $FutureProvider<Directory> {
  /// Root directory for Drive cache files under application support.
  CloudCacheDirectoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudCacheDirectoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudCacheDirectoryHash();

  @$internal
  @override
  $FutureProviderElement<Directory> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Directory> create(Ref ref) {
    return cloudCacheDirectory(ref);
  }
}

String _$cloudCacheDirectoryHash() =>
    r'74b11b107a644ea3e3ebd2074354394cea060ace';

/// Production Google Drive [CloudLibrarySource] (provider subdirectory layout).

@ProviderFor(googleDriveCloudLibrarySource)
final googleDriveCloudLibrarySourceProvider =
    GoogleDriveCloudLibrarySourceProvider._();

/// Production Google Drive [CloudLibrarySource] (provider subdirectory layout).

final class GoogleDriveCloudLibrarySourceProvider
    extends
        $FunctionalProvider<
          AsyncValue<CloudLibrarySource>,
          CloudLibrarySource,
          FutureOr<CloudLibrarySource>
        >
    with
        $FutureModifier<CloudLibrarySource>,
        $FutureProvider<CloudLibrarySource> {
  /// Production Google Drive [CloudLibrarySource] (provider subdirectory layout).
  GoogleDriveCloudLibrarySourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleDriveCloudLibrarySourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleDriveCloudLibrarySourceHash();

  @$internal
  @override
  $FutureProviderElement<CloudLibrarySource> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CloudLibrarySource> create(Ref ref) {
    return googleDriveCloudLibrarySource(ref);
  }
}

String _$googleDriveCloudLibrarySourceHash() =>
    r'e3fcdafcd306cf3087dfb1795a32dd86c151c561';

/// Production OneDrive [OneDriveRemote] (Graph HTTP).

@ProviderFor(oneDriveRemote)
final oneDriveRemoteProvider = OneDriveRemoteProvider._();

/// Production OneDrive [OneDriveRemote] (Graph HTTP).

final class OneDriveRemoteProvider
    extends $FunctionalProvider<OneDriveRemote, OneDriveRemote, OneDriveRemote>
    with $Provider<OneDriveRemote> {
  /// Production OneDrive [OneDriveRemote] (Graph HTTP).
  OneDriveRemoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oneDriveRemoteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oneDriveRemoteHash();

  @$internal
  @override
  $ProviderElement<OneDriveRemote> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OneDriveRemote create(Ref ref) {
    return oneDriveRemote(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OneDriveRemote value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OneDriveRemote>(value),
    );
  }
}

String _$oneDriveRemoteHash() => r'e95e52428effbeccbe1f02bb09542176d67c6ad3';

/// Production OneDrive [CloudLibrarySource] (provider subdirectory layout).

@ProviderFor(oneDriveCloudLibrarySource)
final oneDriveCloudLibrarySourceProvider =
    OneDriveCloudLibrarySourceProvider._();

/// Production OneDrive [CloudLibrarySource] (provider subdirectory layout).

final class OneDriveCloudLibrarySourceProvider
    extends
        $FunctionalProvider<
          AsyncValue<CloudLibrarySource>,
          CloudLibrarySource,
          FutureOr<CloudLibrarySource>
        >
    with
        $FutureModifier<CloudLibrarySource>,
        $FutureProvider<CloudLibrarySource> {
  /// Production OneDrive [CloudLibrarySource] (provider subdirectory layout).
  OneDriveCloudLibrarySourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oneDriveCloudLibrarySourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oneDriveCloudLibrarySourceHash();

  @$internal
  @override
  $FutureProviderElement<CloudLibrarySource> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CloudLibrarySource> create(Ref ref) {
    return oneDriveCloudLibrarySource(ref);
  }
}

String _$oneDriveCloudLibrarySourceHash() =>
    r'7cd5857ca524cf45b6417e1ad2de3df8a9d16db7';

/// Delegating [CloudLibrarySource] routing by locator prefix.

@ProviderFor(cloudLibrarySource)
final cloudLibrarySourceProvider = CloudLibrarySourceProvider._();

/// Delegating [CloudLibrarySource] routing by locator prefix.

final class CloudLibrarySourceProvider
    extends
        $FunctionalProvider<
          AsyncValue<CloudLibrarySource>,
          CloudLibrarySource,
          FutureOr<CloudLibrarySource>
        >
    with
        $FutureModifier<CloudLibrarySource>,
        $FutureProvider<CloudLibrarySource> {
  /// Delegating [CloudLibrarySource] routing by locator prefix.
  CloudLibrarySourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudLibrarySourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudLibrarySourceHash();

  @$internal
  @override
  $FutureProviderElement<CloudLibrarySource> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CloudLibrarySource> create(Ref ref) {
    return cloudLibrarySource(ref);
  }
}

String _$cloudLibrarySourceHash() =>
    r'e248d95e336fe03f7f175acf9138f644bdf18d5e';

/// [CloudCacheStore] bound to the app database (deletes artwork with audio).

@ProviderFor(cloudCacheStore)
final cloudCacheStoreProvider = CloudCacheStoreProvider._();

/// [CloudCacheStore] bound to the app database (deletes artwork with audio).

final class CloudCacheStoreProvider
    extends
        $FunctionalProvider<CloudCacheStore, CloudCacheStore, CloudCacheStore>
    with $Provider<CloudCacheStore> {
  /// [CloudCacheStore] bound to the app database (deletes artwork with audio).
  CloudCacheStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudCacheStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudCacheStoreHash();

  @$internal
  @override
  $ProviderElement<CloudCacheStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CloudCacheStore create(Ref ref) {
    return cloudCacheStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudCacheStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudCacheStore>(value),
    );
  }
}

String _$cloudCacheStoreHash() => r'e5b15eb27d63774768046be043df78dcfd0fa289';

/// Prefs wrapper for the cloud cache budget.

@ProviderFor(cloudCacheBudgetPreferences)
final cloudCacheBudgetPreferencesProvider =
    CloudCacheBudgetPreferencesProvider._();

/// Prefs wrapper for the cloud cache budget.

final class CloudCacheBudgetPreferencesProvider
    extends
        $FunctionalProvider<
          CloudCacheBudgetPreferences,
          CloudCacheBudgetPreferences,
          CloudCacheBudgetPreferences
        >
    with $Provider<CloudCacheBudgetPreferences> {
  /// Prefs wrapper for the cloud cache budget.
  CloudCacheBudgetPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudCacheBudgetPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudCacheBudgetPreferencesHash();

  @$internal
  @override
  $ProviderElement<CloudCacheBudgetPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CloudCacheBudgetPreferences create(Ref ref) {
    return cloudCacheBudgetPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudCacheBudgetPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudCacheBudgetPreferences>(value),
    );
  }
}

String _$cloudCacheBudgetPreferencesHash() =>
    r'2656d0498b31cf1a04cb8a81f6219302f4e7c007';

/// Persisted cloud cache budget with write + eviction on lower limits.
///
/// Purpose: Settings slider and playback download path share one budget value.
/// Usage Context: Settings Cloud cache limit; [PlaybackUriResolver] budget.

@ProviderFor(CloudCacheBudgetController)
final cloudCacheBudgetControllerProvider =
    CloudCacheBudgetControllerProvider._();

/// Persisted cloud cache budget with write + eviction on lower limits.
///
/// Purpose: Settings slider and playback download path share one budget value.
/// Usage Context: Settings Cloud cache limit; [PlaybackUriResolver] budget.
final class CloudCacheBudgetControllerProvider
    extends $NotifierProvider<CloudCacheBudgetController, int> {
  /// Persisted cloud cache budget with write + eviction on lower limits.
  ///
  /// Purpose: Settings slider and playback download path share one budget value.
  /// Usage Context: Settings Cloud cache limit; [PlaybackUriResolver] budget.
  CloudCacheBudgetControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudCacheBudgetControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudCacheBudgetControllerHash();

  @$internal
  @override
  CloudCacheBudgetController create() => CloudCacheBudgetController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$cloudCacheBudgetControllerHash() =>
    r'af30ac438fb8ab3e3523e48a6867389a350b78d3';

/// Persisted cloud cache budget with write + eviction on lower limits.
///
/// Purpose: Settings slider and playback download path share one budget value.
/// Usage Context: Settings Cloud cache limit; [PlaybackUriResolver] budget.

abstract class _$CloudCacheBudgetController extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Controllers Google Drive sign-in / sign-out for Settings.
///
/// Purpose: Drive Settings through a testable seam; bind/replace root ownership;
/// wipe **Google** cache on normal sign-out; restore on first build.
/// Usage Context: Eagerly read from `main`; Settings Google Drive section.

@ProviderFor(GoogleDriveSessionController)
final googleDriveSessionControllerProvider =
    GoogleDriveSessionControllerProvider._();

/// Controllers Google Drive sign-in / sign-out for Settings.
///
/// Purpose: Drive Settings through a testable seam; bind/replace root ownership;
/// wipe **Google** cache on normal sign-out; restore on first build.
/// Usage Context: Eagerly read from `main`; Settings Google Drive section.
final class GoogleDriveSessionControllerProvider
    extends
        $NotifierProvider<
          GoogleDriveSessionController,
          GoogleDriveSessionState
        > {
  /// Controllers Google Drive sign-in / sign-out for Settings.
  ///
  /// Purpose: Drive Settings through a testable seam; bind/replace root ownership;
  /// wipe **Google** cache on normal sign-out; restore on first build.
  /// Usage Context: Eagerly read from `main`; Settings Google Drive section.
  GoogleDriveSessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleDriveSessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleDriveSessionControllerHash();

  @$internal
  @override
  GoogleDriveSessionController create() => GoogleDriveSessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleDriveSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleDriveSessionState>(value),
    );
  }
}

String _$googleDriveSessionControllerHash() =>
    r'07b5d1e73029edc49f189ea687f0bcac884e5c5a';

/// Controllers Google Drive sign-in / sign-out for Settings.
///
/// Purpose: Drive Settings through a testable seam; bind/replace root ownership;
/// wipe **Google** cache on normal sign-out; restore on first build.
/// Usage Context: Eagerly read from `main`; Settings Google Drive section.

abstract class _$GoogleDriveSessionController
    extends $Notifier<GoogleDriveSessionState> {
  GoogleDriveSessionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<GoogleDriveSessionState, GoogleDriveSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GoogleDriveSessionState, GoogleDriveSessionState>,
              GoogleDriveSessionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Production [OneDriveAuth]. Tests override [oneDriveAuthProvider].

@ProviderFor(oneDriveAuth)
final oneDriveAuthProvider = OneDriveAuthProvider._();

/// Production [OneDriveAuth]. Tests override [oneDriveAuthProvider].

final class OneDriveAuthProvider
    extends $FunctionalProvider<OneDriveAuth, OneDriveAuth, OneDriveAuth>
    with $Provider<OneDriveAuth> {
  /// Production [OneDriveAuth]. Tests override [oneDriveAuthProvider].
  OneDriveAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oneDriveAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oneDriveAuthHash();

  @$internal
  @override
  $ProviderElement<OneDriveAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OneDriveAuth create(Ref ref) {
    return oneDriveAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OneDriveAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OneDriveAuth>(value),
    );
  }
}

String _$oneDriveAuthHash() => r'306d9b13c2f46682dc2055e86e8ed1188690c61b';

/// Controllers OneDrive sign-in / sign-out for Settings.
///
/// Purpose: Drive Settings through a testable seam; bind/replace root ownership;
/// wipe **OneDrive** cache on normal sign-out; restore on first build.
/// Usage Context: Eagerly read from `main`; Settings OneDrive section.

@ProviderFor(OneDriveSessionController)
final oneDriveSessionControllerProvider = OneDriveSessionControllerProvider._();

/// Controllers OneDrive sign-in / sign-out for Settings.
///
/// Purpose: Drive Settings through a testable seam; bind/replace root ownership;
/// wipe **OneDrive** cache on normal sign-out; restore on first build.
/// Usage Context: Eagerly read from `main`; Settings OneDrive section.
final class OneDriveSessionControllerProvider
    extends $NotifierProvider<OneDriveSessionController, OneDriveSessionState> {
  /// Controllers OneDrive sign-in / sign-out for Settings.
  ///
  /// Purpose: Drive Settings through a testable seam; bind/replace root ownership;
  /// wipe **OneDrive** cache on normal sign-out; restore on first build.
  /// Usage Context: Eagerly read from `main`; Settings OneDrive section.
  OneDriveSessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oneDriveSessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oneDriveSessionControllerHash();

  @$internal
  @override
  OneDriveSessionController create() => OneDriveSessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OneDriveSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OneDriveSessionState>(value),
    );
  }
}

String _$oneDriveSessionControllerHash() =>
    r'47a185380a0afd79b36e1e59ea287c18cd4ebf70';

/// Controllers OneDrive sign-in / sign-out for Settings.
///
/// Purpose: Drive Settings through a testable seam; bind/replace root ownership;
/// wipe **OneDrive** cache on normal sign-out; restore on first build.
/// Usage Context: Eagerly read from `main`; Settings OneDrive section.

abstract class _$OneDriveSessionController
    extends $Notifier<OneDriveSessionState> {
  OneDriveSessionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OneDriveSessionState, OneDriveSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OneDriveSessionState, OneDriveSessionState>,
              OneDriveSessionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
