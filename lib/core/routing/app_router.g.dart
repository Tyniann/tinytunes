// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Long-lived app [GoRouter] — routes only, no theme/message watches.
///
/// Purpose: Keep a single router instance so reporting messages cannot rebuild
/// navigation and reset the stack.
/// Usage Context: [MaterialApp.router] `routerConfig` via [TinyTunesApp].

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Long-lived app [GoRouter] — routes only, no theme/message watches.
///
/// Purpose: Keep a single router instance so reporting messages cannot rebuild
/// navigation and reset the stack.
/// Usage Context: [MaterialApp.router] `routerConfig` via [TinyTunesApp].

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Long-lived app [GoRouter] — routes only, no theme/message watches.
  ///
  /// Purpose: Keep a single router instance so reporting messages cannot rebuild
  /// navigation and reset the stack.
  /// Usage Context: [MaterialApp.router] `routerConfig` via [TinyTunesApp].
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'b509ad6b26900a290ef81e2a0c0a711cc3827d54';
