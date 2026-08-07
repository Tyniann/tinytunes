import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/theme/theme_providers.dart';

/// Bridges [DynamicColorBuilder] platform colors into Riverpod.
///
/// Purpose: Keep live Material You updates out of [MaterialApp] build while
/// still feeding [dynamicColorAvailabilityControllerProvider] after each frame.
/// Usage Context: Wrap the app shell in [TinyTunesApp] under [ProviderScope].
/// Key Params: [child] — typically the toast wrapper + [MaterialApp.router].
class DynamicColorBinder extends ConsumerWidget {
  /// Creates a binder that publishes dynamic colors then builds [child].
  const DynamicColorBinder({required this.child, super.key});

  /// App content under the binder.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          ref
              .read(dynamicColorAvailabilityControllerProvider.notifier)
              .apply(lightDynamic, darkDynamic);
        });
        return child;
      },
    );
  }
}
