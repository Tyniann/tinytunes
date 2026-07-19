// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Production [LocalLibrarySource] (Android SAF). Tests must override.
///
/// Purpose: Inject the platform library adapter without leaking MethodChannel
/// types into features.

@ProviderFor(localLibrarySource)
final localLibrarySourceProvider = LocalLibrarySourceProvider._();

/// Production [LocalLibrarySource] (Android SAF). Tests must override.
///
/// Purpose: Inject the platform library adapter without leaking MethodChannel
/// types into features.

final class LocalLibrarySourceProvider
    extends
        $FunctionalProvider<
          LocalLibrarySource,
          LocalLibrarySource,
          LocalLibrarySource
        >
    with $Provider<LocalLibrarySource> {
  /// Production [LocalLibrarySource] (Android SAF). Tests must override.
  ///
  /// Purpose: Inject the platform library adapter without leaking MethodChannel
  /// types into features.
  LocalLibrarySourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localLibrarySourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localLibrarySourceHash();

  @$internal
  @override
  $ProviderElement<LocalLibrarySource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalLibrarySource create(Ref ref) {
    return localLibrarySource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalLibrarySource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalLibrarySource>(value),
    );
  }
}

String _$localLibrarySourceHash() =>
    r'48612bc3f2fbe4ef6b79022a7c27cc9eff560d68';

/// Production [TrackMetadataReader]. Tests may override with a fake.

@ProviderFor(trackMetadataReader)
final trackMetadataReaderProvider = TrackMetadataReaderProvider._();

/// Production [TrackMetadataReader]. Tests may override with a fake.

final class TrackMetadataReaderProvider
    extends
        $FunctionalProvider<
          TrackMetadataReader,
          TrackMetadataReader,
          TrackMetadataReader
        >
    with $Provider<TrackMetadataReader> {
  /// Production [TrackMetadataReader]. Tests may override with a fake.
  TrackMetadataReaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackMetadataReaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackMetadataReaderHash();

  @$internal
  @override
  $ProviderElement<TrackMetadataReader> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TrackMetadataReader create(Ref ref) {
    return trackMetadataReader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackMetadataReader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackMetadataReader>(value),
    );
  }
}

String _$trackMetadataReaderHash() =>
    r'86de5a0eb196b4584203bf9fff047246915274d2';
