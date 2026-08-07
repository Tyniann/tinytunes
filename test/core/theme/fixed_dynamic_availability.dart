import 'package:flutter/material.dart';
import 'package:tinytunes/core/theme/dynamic_color_availability.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';

/// Test notifier that exposes a fixed [DynamicColorAvailability].
///
/// Ignores [apply] so [DynamicColorBinder] post-frame updates cannot overwrite
/// the fixture during widget tests.
class FixedDynamicAvailability extends DynamicColorAvailabilityController {
  /// Creates a controller that always returns [availability].
  FixedDynamicAvailability(this._availability);

  final DynamicColorAvailability _availability;

  @override
  DynamicColorAvailability build() => _availability;

  @override
  void apply(ColorScheme? light, ColorScheme? dark) {
    // Keep the fixture stable under DynamicColorBinder.
  }
}
