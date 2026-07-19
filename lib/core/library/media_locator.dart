import 'package:flutter/foundation.dart';

/// Opaque, serializable identity for a library root or media item.
///
/// Purpose: Persist and compare locators without baking filesystem paths into
/// the domain. Equality uses the exact stored token.
/// Usage Context: Catalog/queue identity and [LocalLibrarySource] APIs.
/// Key Params: [value] — platform token (Android: exact `Uri.toString()`).
@immutable
class MediaLocator {
  /// Creates a locator from a normalized opaque [value].
  ///
  /// Callers must normalize once at write time (e.g. Android `Uri.toString()`).
  /// Root locators are tree URIs; item locators are document-under-tree URIs —
  /// do not intermix the two kinds.
  const MediaLocator(this.value);

  /// Opaque platform token used as the durable identity.
  final String value;

  @override
  bool operator ==(Object other) =>
      other is MediaLocator && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'MediaLocator($value)';
}
