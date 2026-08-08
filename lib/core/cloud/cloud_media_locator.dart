import 'package:tinytunes/core/cloud/cloud_provider_id.dart';
import 'package:tinytunes/core/library/media_locator.dart';

/// Shared escape helpers for multi-segment cloud locator payloads.
///
/// Purpose: Percent-encode drive/item ids so separators stay unambiguous.
/// Usage Context: OneDrive (and any future multi-id) locator codecs.
abstract final class CloudLocatorCodec {
  /// Encodes [raw] for embedding in a locator segment.
  static String escape(String raw) => Uri.encodeComponent(raw);

  /// Decodes a segment produced by [escape].
  static String unescape(String escaped) => Uri.decodeComponent(escaped);
}

/// Routes opaque [MediaLocator] values to a [CloudProviderId].
///
/// Purpose: Prefix-based provider detection for the delegating cloud source.
/// Usage Context: [DelegatingCloudLibrarySource] and shared locator tests.
abstract final class CloudMediaLocator {
  /// Provider for [locator], or throws [FormatException] when unknown/malformed.
  static CloudProviderId providerOf(MediaLocator locator) {
    final value = locator.value;
    for (final id in CloudProviderId.values) {
      if (value.startsWith(id.locatorPrefix)) {
        final rest = value.substring(id.locatorPrefix.length);
        if (rest.isEmpty) {
          throw FormatException(
            'Cloud MediaLocator is missing a payload after ${id.locatorPrefix}',
          );
        }
        return id;
      }
    }
    throw FormatException('Unknown cloud MediaLocator prefix: $value');
  }

  /// Whether [locator] uses a known cloud provider prefix.
  static bool isCloudLocator(MediaLocator locator) {
    try {
      providerOf(locator);
      return true;
    } on FormatException {
      return false;
    }
  }
}
