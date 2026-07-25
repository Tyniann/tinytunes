import 'dart:async';

/// Testable seam over the device media / system volume.
///
/// Purpose: Let transport chrome drive OS volume without binding tests to
/// platform channels.
/// Usage Context: Production [DeviceSystemVolumeSource]; fakes in widget tests.
abstract class SystemVolumeSource {
  /// Current system volume in the range `0.0`–`1.0`.
  Future<double> getVolume();

  /// Sets system volume; [volume] should be in the range `0.0`–`1.0`.
  Future<void> setVolume(double volume);

  /// Emits whenever system volume changes (slider, hardware buttons, OS UI).
  Stream<double> get volumeChanges;

  /// Releases native listeners.
  void dispose();
}
