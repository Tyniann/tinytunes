// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_ingest_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Single-flight library ingest: add folder, re-scan, forget.
///
/// Purpose: Mutate catalog/queue safely with prune-after-batches-succeed rules.
/// Usage Context: Playlist home actions; tests override source/reader/DB.

@ProviderFor(LibraryIngestController)
final libraryIngestControllerProvider = LibraryIngestControllerProvider._();

/// Single-flight library ingest: add folder, re-scan, forget.
///
/// Purpose: Mutate catalog/queue safely with prune-after-batches-succeed rules.
/// Usage Context: Playlist home actions; tests override source/reader/DB.
final class LibraryIngestControllerProvider
    extends $NotifierProvider<LibraryIngestController, ScanProgress> {
  /// Single-flight library ingest: add folder, re-scan, forget.
  ///
  /// Purpose: Mutate catalog/queue safely with prune-after-batches-succeed rules.
  /// Usage Context: Playlist home actions; tests override source/reader/DB.
  LibraryIngestControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryIngestControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryIngestControllerHash();

  @$internal
  @override
  LibraryIngestController create() => LibraryIngestController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScanProgress value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScanProgress>(value),
    );
  }
}

String _$libraryIngestControllerHash() =>
    r'7e12a5fee12a69a8f1b42341b82703ead6faf2a0';

/// Single-flight library ingest: add folder, re-scan, forget.
///
/// Purpose: Mutate catalog/queue safely with prune-after-batches-succeed rules.
/// Usage Context: Playlist home actions; tests override source/reader/DB.

abstract class _$LibraryIngestController extends $Notifier<ScanProgress> {
  ScanProgress build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ScanProgress, ScanProgress>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScanProgress, ScanProgress>,
              ScanProgress,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
