import 'package:flutter/material.dart';
import 'package:tinytunes/shared/widgets/google_brand_assets.dart';

/// Google Drive product mark for list tiles and pickers.
///
/// Purpose: Show the official Drive icon without altering brand colors.
/// Usage Context: Library source picker and Settings Google Drive section.
/// Key Params: [size] logical width/height of the square mark.
class GoogleDriveMark extends StatelessWidget {
  /// Creates a Drive mark of [size] logical pixels.
  const GoogleDriveMark({super.key, this.size = 24});

  /// Logical width and height.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      GoogleBrandAssets.driveIcon,
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Google Drive',
    );
  }
}

/// Light "Sign in with Google" button following Google Identity guidelines.
///
/// Purpose: Familiar Google auth CTA in Settings (G on white + action text).
/// Usage Context: Settings when signed out.
/// Key Params: [label], [onPressed], [enabled].
class SignInWithGoogleButton extends StatelessWidget {
  /// Creates a Sign in with Google button.
  const SignInWithGoogleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  /// Localized button label (e.g. Sign in with Google).
  final String label;

  /// Tap handler; ignored when [enabled] is false.
  final VoidCallback? onPressed;

  /// Whether the button accepts presses.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = enabled ? onPressed : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: enabled ? Colors.white : const Color(0xFFF2F2F2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF747775)),
        ),
        child: InkWell(
          onTap: effectiveOnPressed,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  GoogleBrandAssets.googleGLogo,
                  width: 20,
                  height: 20,
                  filterQuality: FilterQuality.medium,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: enabled
                          ? const Color(0xFF1F1F1F)
                          : const Color(0xFF1F1F1F).withValues(alpha: 0.38),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 20 / 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
