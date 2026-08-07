import 'package:flutter/material.dart';

/// Snapshot of platform Material You colors from [DynamicColorBuilder].
///
/// Purpose: Separate “not yet resolved” from “resolved but unavailable” so
/// prefs are not rewritten while the first builder callback is still pending.
/// Usage Context: Theme providers and Settings scheme picker visibility.
class DynamicColorAvailability {
  /// Creates an availability snapshot.
  const DynamicColorAvailability({
    required this.resolved,
    this.light,
    this.dark,
  });

  /// Before the first [DynamicColorBuilder] callback.
  static const unresolved = DynamicColorAvailability(resolved: false);

  /// After a callback with no platform colors.
  static const unavailable = DynamicColorAvailability(resolved: true);

  /// Whether at least one builder callback has completed.
  final bool resolved;

  /// Light dynamic [ColorScheme], if the platform supplied one.
  final ColorScheme? light;

  /// Dark dynamic [ColorScheme], if the platform supplied one.
  final ColorScheme? dark;

  /// Whether Settings should show the Dynamic scheme option.
  bool get isAvailable => resolved && light != null && dark != null;

  /// Returns a copy with updated fields.
  DynamicColorAvailability copyWith({
    bool? resolved,
    ColorScheme? light,
    ColorScheme? dark,
    bool clearSchemes = false,
  }) {
    return DynamicColorAvailability(
      resolved: resolved ?? this.resolved,
      light: clearSchemes ? null : (light ?? this.light),
      dark: clearSchemes ? null : (dark ?? this.dark),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DynamicColorAvailability &&
        other.resolved == resolved &&
        other.light == light &&
        other.dark == dark;
  }

  @override
  int get hashCode => Object.hash(resolved, light, dark);
}
