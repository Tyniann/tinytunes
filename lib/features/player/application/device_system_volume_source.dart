import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:tinytunes/features/player/application/system_volume_source.dart';

/// [SystemVolumeSource] backed by the platform media volume.
///
/// Purpose: Bridge [VolumeController] into the app volume seam.
/// Usage Context: Injected via [systemVolumeSourceProvider] for transport chrome.
class DeviceSystemVolumeSource implements SystemVolumeSource {
  /// Creates a source over [VolumeController.instance].
  ///
  /// Hides the OS volume HUD while the in-app slider drives changes so the
  /// chrome does not fight the system overlay.
  DeviceSystemVolumeSource() {
    _controller.showSystemUI = false;
    _subscription = _controller.addListener(
      _controllerStream.add,
      fetchInitialVolume: true,
    );
  }

  final VolumeController _controller = VolumeController.instance;
  final StreamController<double> _controllerStream =
      StreamController<double>.broadcast();
  late final StreamSubscription<double> _subscription;

  @override
  Future<double> getVolume() => _controller.getVolume();

  @override
  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0).toDouble();
    try {
      await _controller.setVolume(clamped);
    } catch (error, stack) {
      debugPrint('DeviceSystemVolumeSource.setVolume failed: $error\n$stack');
      rethrow;
    }
  }

  @override
  Stream<double> get volumeChanges => _controllerStream.stream;

  @override
  void dispose() {
    _subscription.cancel();
    _controller.removeListener();
    _controllerStream.close();
  }
}
