// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App [PackageInfo] for Settings About and similar surfaces.
///
/// Purpose: Load version metadata once and allow tests to override without a
/// live platform channel.
/// Usage Context: Watched by Settings; override in widget tests.

@ProviderFor(packageInfo)
final packageInfoProvider = PackageInfoProvider._();

/// App [PackageInfo] for Settings About and similar surfaces.
///
/// Purpose: Load version metadata once and allow tests to override without a
/// live platform channel.
/// Usage Context: Watched by Settings; override in widget tests.

final class PackageInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<PackageInfo>,
          PackageInfo,
          FutureOr<PackageInfo>
        >
    with $FutureModifier<PackageInfo>, $FutureProvider<PackageInfo> {
  /// App [PackageInfo] for Settings About and similar surfaces.
  ///
  /// Purpose: Load version metadata once and allow tests to override without a
  /// live platform channel.
  /// Usage Context: Watched by Settings; override in widget tests.
  PackageInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packageInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packageInfoHash();

  @$internal
  @override
  $FutureProviderElement<PackageInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PackageInfo> create(Ref ref) {
    return packageInfo(ref);
  }
}

String _$packageInfoHash() => r'854bbb0e381edfdddbd736229351d6cc918a2ad1';
