import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, outline, text }

/// A single reusable button widget covering every button style in the app.
/// Never build ad-hoc ElevatedButton/OutlinedButton instances elsewhere —
/// route everything through this widget for visual consistency.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.pureWhite),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label, style: AppTextStyles.button),
            ],
          );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(onPressed: isLoading ? null : onPressed, child: child),
      AppButtonVariant.outline => OutlinedButton(onPressed: isLoading ? null : onPressed, child: child),
      AppButtonVariant.text => TextButton(onPressed: isLoading ? null : onPressed, child: child),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
