import 'package:flutter/material.dart';
import 'package:tinytunes/shared/widgets/microsoft_brand_assets.dart';

/// OneDrive product mark for list tiles and pickers.
///
/// Purpose: Show the official OneDrive icon without altering brand colors.
/// Usage Context: Settings OneDrive section and library source picker.
/// Key Params: [size] logical width/height of the square mark.
class OneDriveMark extends StatelessWidget {
  /// Creates a OneDrive mark of [size] logical pixels.
  const OneDriveMark({super.key, this.size = 24});

  /// Logical width and height.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      MicrosoftBrandAssets.oneDriveIcon,
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'OneDrive',
    );
  }
}

/// Light "Sign in with Microsoft" button using the official symbol + label.
///
/// Purpose: Familiar Microsoft auth CTA in Settings (symbol + localized text).
/// Usage Context: Settings when signed out of OneDrive.
/// Key Params: [label], [onPressed], [enabled].
class SignInWithMicrosoftButton extends StatelessWidget {
  /// Creates a Sign in with Microsoft button.
  const SignInWithMicrosoftButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  /// Localized button label (e.g. Sign in with Microsoft).
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
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(color: Color(0xFF8C8C8C)),
        ),
        child: InkWell(
          onTap: effectiveOnPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  MicrosoftBrandAssets.microsoftSymbol,
                  width: 21,
                  height: 21,
                  filterQuality: FilterQuality.medium,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: enabled
                          ? const Color(0xFF5E5E5E)
                          : const Color(0xFF5E5E5E).withValues(alpha: 0.38),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      height: 20 / 15,
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
