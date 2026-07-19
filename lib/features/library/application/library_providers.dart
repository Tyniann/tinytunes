import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tinytunes/core/library/android/android_local_library_source.dart';
import 'package:tinytunes/core/library/audiotags_track_metadata_reader.dart';
import 'package:tinytunes/core/library/local_library_source.dart';
import 'package:tinytunes/core/library/track_metadata_reader.dart';

part 'library_providers.g.dart';

/// Production [LocalLibrarySource] (Android SAF). Tests must override.
///
/// Purpose: Inject the platform library adapter without leaking MethodChannel
/// types into features.
@Riverpod(keepAlive: true)
LocalLibrarySource localLibrarySource(Ref ref) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return AndroidLocalLibrarySource();
  }
  throw UnsupportedError(
    'localLibrarySourceProvider requires an override on non-Android platforms.',
  );
}

/// Production [TrackMetadataReader]. Tests may override with a fake.
@Riverpod(keepAlive: true)
TrackMetadataReader trackMetadataReader(Ref ref) {
  return const AudiotagsTrackMetadataReader();
}
