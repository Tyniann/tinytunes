/// Repeat transport cycle: Off → One → All → Off.
///
/// Purpose: Encode Drift `repeat_mode` values and UI cycle without stringly
/// typed branches across [PlaybackController] and [QueueNavigator].
enum RepeatMode {
  /// Stop or no-op at queue/permutation end (no wrap; no single-track loop).
  off,

  /// Loop the current track until Next/Previous leaves it.
  one,

  /// Loop the whole queue (canonical or with-replacement when shuffle is on).
  all;

  /// Next value in the Off → One → All cycle.
  RepeatMode cycle() {
    return switch (this) {
      RepeatMode.off => RepeatMode.one,
      RepeatMode.one => RepeatMode.all,
      RepeatMode.all => RepeatMode.off,
    };
  }

  /// Drift / prefs wire value (`off` / `one` / `all`).
  String get storageValue => name;

  /// Parses a stored value; unknown input falls back to [RepeatMode.off].
  static RepeatMode fromStorage(String value) {
    return switch (value) {
      'one' => RepeatMode.one,
      'all' => RepeatMode.all,
      _ => RepeatMode.off,
    };
  }
}
