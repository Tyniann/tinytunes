import 'dart:async';

import 'package:tinytunes/features/player/application/system_volume_source.dart';

/// In-memory [SystemVolumeSource] for widget and controller tests.
///
/// Purpose: Avoid platform channels when [TransportChrome] watches volume.
class FakeSystemVolumeSource implements SystemVolumeSource {
  /// Creates a fake starting at [initialVolume] (`0.0`–`1.0`).
  FakeSystemVolumeSource({double initialVolume = 0.5})
    : _volume = initialVolume.clamp(0.0, 1.0).toDouble();

  double _volume;
  final StreamController<double> _controller =
      StreamController<double>.broadcast();

  @override
  Future<double> getVolume() async => _volume;

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0).toDouble();
    _controller.add(_volume);
  }

  @override
  Stream<double> get volumeChanges => _controller.stream;

  @override
  void dispose() {
    _controller.close();
  }
}
