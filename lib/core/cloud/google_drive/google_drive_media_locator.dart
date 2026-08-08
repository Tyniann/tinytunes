import 'package:tinytunes/core/library/media_locator.dart';

/// Encodes and decodes Google Drive file ids as opaque [MediaLocator] values.
///
/// Purpose: Keep Drive identity in the same locator type as local SAF URIs
/// without treating paths as durable ids.
/// Usage Context: Cloud catalog roots/tracks and [CloudLibrarySource] calls.
abstract final class DriveMediaLocator {
  /// Prefix stored in [MediaLocator.value] for Drive items (`gdrive:<fileId>`).
  static const prefix = 'gdrive:';

  /// Whether [locator] uses the Drive prefix.
  static bool isDriveLocator(MediaLocator locator) =>
      locator.value.startsWith(prefix);

  /// Builds a [MediaLocator] from a non-empty Drive [fileId].
  static MediaLocator encode(String fileId) {
    final trimmed = fileId.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(fileId, 'fileId', 'must be non-empty');
    }
    return MediaLocator('$prefix$trimmed');
  }

  /// Extracts the Drive file id from a [gdrive:][MediaLocator].
  ///
  /// Throws [FormatException] when [locator] is not a Drive token.
  static String decode(MediaLocator locator) {
    if (!isDriveLocator(locator)) {
      throw FormatException(
        'Expected $prefix… MediaLocator, got ${locator.value}',
      );
    }
    final id = locator.value.substring(prefix.length).trim();
    if (id.isEmpty) {
      throw FormatException('Drive MediaLocator is missing a file id');
    }
    return id;
  }
}
