import 'package:tinytunes/core/cloud/cloud_media_locator.dart';
import 'package:tinytunes/core/cloud/cloud_provider_id.dart';
import 'package:tinytunes/core/library/media_locator.dart';

/// Encodes and decodes personal OneDrive drive/item ids as [MediaLocator]s.
///
/// Purpose: Opaque durable ids (`onedrive:<drive>/<item>`) with escaped
/// components; keep a non-persisted personal-root sentinel for browsing only.
/// Usage Context: Later Graph [CloudLibrarySource]; Phase 2 locator tests.
abstract final class OneDriveMediaLocator {
  /// Prefix stored in [MediaLocator.value] (`onedrive:`).
  static const prefix = 'onedrive:';

  /// Non-persisted folder-browser sentinel for the signed-in user's My files.
  ///
  /// Never upsert roots/tracks with this value — use [encode] with real ids.
  static final personalRoot = MediaLocator('${prefix}me');

  /// Whether [locator] uses the OneDrive prefix.
  static bool isOneDriveLocator(MediaLocator locator) =>
      locator.value.startsWith(prefix);

  /// Whether [locator] is the personal-root browser sentinel.
  static bool isPersonalRoot(MediaLocator locator) =>
      locator.value == personalRoot.value;

  /// Builds a durable locator from non-empty Graph [driveId] and [itemId].
  static MediaLocator encode({
    required String driveId,
    required String itemId,
  }) {
    final drive = driveId.trim();
    final item = itemId.trim();
    if (drive.isEmpty) {
      throw ArgumentError.value(driveId, 'driveId', 'must be non-empty');
    }
    if (item.isEmpty) {
      throw ArgumentError.value(itemId, 'itemId', 'must be non-empty');
    }
    return MediaLocator(
      '$prefix${CloudLocatorCodec.escape(drive)}/'
      '${CloudLocatorCodec.escape(item)}',
    );
  }

  /// Extracts Graph drive and item ids from a durable OneDrive locator.
  ///
  /// Throws [FormatException] for wrong prefix, the personal-root sentinel,
  /// or malformed payloads.
  static ({String driveId, String itemId}) decode(MediaLocator locator) {
    if (!isOneDriveLocator(locator)) {
      throw FormatException(
        'Expected $prefix… MediaLocator, got ${locator.value}',
      );
    }
    if (isPersonalRoot(locator)) {
      throw FormatException(
        'Personal-root sentinel is not a durable OneDrive MediaLocator',
      );
    }
    final rest = locator.value.substring(prefix.length);
    final slash = rest.indexOf('/');
    if (slash <= 0 || slash == rest.length - 1) {
      throw FormatException('OneDrive MediaLocator must be driveId/itemId');
    }
    final driveEsc = rest.substring(0, slash);
    final itemEsc = rest.substring(slash + 1);
    if (itemEsc.contains('/')) {
      throw FormatException('OneDrive MediaLocator has extra path segments');
    }
    final driveId = CloudLocatorCodec.unescape(driveEsc).trim();
    final itemId = CloudLocatorCodec.unescape(itemEsc).trim();
    if (driveId.isEmpty || itemId.isEmpty) {
      throw FormatException('OneDrive MediaLocator has empty drive or item id');
    }
    return (driveId: driveId, itemId: itemId);
  }

  /// Provider id for OneDrive locators.
  static CloudProviderId get providerId => CloudProviderId.oneDrive;
}
