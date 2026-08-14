import 'dart:io';

import 'package:flutter/material.dart';

/// Square cover tile for the home stage carousel.
///
/// Purpose: Show album art for the focused (and peeking) queue pages without
/// a full-bleed immersive treatment.
/// Usage Context: [HomeStageCarousel] pages.
/// Key Params: [path] optional `artworkCacheRef`; [focused] enlarges the frame;
/// [size] base side length before focus scale. Empty art uses
/// [ColorScheme.inverseSurface] so the tile reads as poster ink, not a grey
/// chip.
class HomeStageCover extends StatelessWidget {
  /// Creates a carousel cover for [path].
  const HomeStageCover({
    super.key,
    this.path,
    this.focused = false,
    this.size = 240,
  });

  /// Absolute path to capped cover JPEG, when available.
  final String? path;

  /// Whether this page is the focused carousel item.
  final bool focused;

  /// Base square side length before focus scaling.
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final side = size * (focused ? 1.0 : 0.9);
    final trimmed = path?.trim();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        border: Border.all(
          color: focused
              ? scheme.primary
              : scheme.onInverseSurface.withValues(alpha: 0.22),
          width: focused ? 3 : 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: trimmed == null || trimmed.isEmpty
          ? Icon(
              Icons.album_outlined,
              size: side * 0.22,
              color: scheme.onInverseSurface.withValues(alpha: 0.45),
            )
          : Image.file(
              File(trimmed),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => Icon(
                Icons.album_outlined,
                size: side * 0.22,
                color: scheme.onInverseSurface.withValues(alpha: 0.45),
              ),
            ),
    );
  }
}
