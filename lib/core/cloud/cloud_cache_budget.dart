/// Default and bounds for the cloud cache size budget (Settings slider).
///
/// Purpose: Shared constants for prefs UI and [CloudCacheStore] eviction.
abstract final class CloudCacheBudget {
  /// Default limit: 2 GiB.
  static const defaultBytes = 2 * 1024 * 1024 * 1024;

  /// Slider minimum: 512 MiB.
  static const minBytes = 512 * 1024 * 1024;

  /// Slider maximum: 32 GiB.
  static const maxBytes = 32 * 1024 * 1024 * 1024;

  /// Slider step: 512 MiB.
  static const stepBytes = 512 * 1024 * 1024;

  /// Clamps [bytes] into range and snaps to [stepBytes].
  static int clampAndSnap(int bytes) {
    final clamped = bytes.clamp(minBytes, maxBytes);
    final steps = ((clamped - minBytes) / stepBytes).round();
    return minBytes + steps * stepBytes;
  }

  /// Formats [bytes] as `X.X GB` for the Settings label.
  static String formatGbLabel(int bytes) {
    final gb = clampAndSnap(bytes) / (1024 * 1024 * 1024);
    return '${gb.toStringAsFixed(1)} GB';
  }

  /// Number of slider steps from [minBytes] to [maxBytes] inclusive.
  static int get sliderDivisions =>
      ((maxBytes - minBytes) / stepBytes).round();
}
