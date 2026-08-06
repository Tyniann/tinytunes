import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tinytunes/core/cloud/free_space_source.dart';

/// Android [FreeSpaceSource] via a narrow StatFs MethodChannel.
///
/// Purpose: Enforce per-download free-space checks without a heavyweight plugin.
/// Usage Context: Production DI on Android only.
class AndroidFreeSpaceSource implements FreeSpaceSource {
  /// Creates a source using the default storage channel.
  AndroidFreeSpaceSource({MethodChannel? channel})
    : _channel =
          channel ?? const MethodChannel('at.blumenlaube.tinytunes/storage');

  final MethodChannel _channel;

  @override
  Future<int> availableBytesFor(String directoryPath) async {
    try {
      final raw = await _channel.invokeMethod<dynamic>(
        'availableBytes',
        <String, Object?>{'path': directoryPath},
      );
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      throw StateError('availableBytes returned unexpected type: $raw');
    } on Object catch (error, stack) {
      debugPrint('AndroidFreeSpaceSource failed: $error\n$stack');
      rethrow;
    }
  }
}
