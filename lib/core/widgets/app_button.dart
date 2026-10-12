import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, outline, text }

/// Tombol standar SmartCook. Dipakai untuk "Masuk", "Daftar Sekarang",
/// "Cari & Masukkan Bahan", "Jelajahi Semua Resep Masakan", "Simpan Profil", "Reset", dst.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.fullWidth = true,
    this.loading = false,
    this.backgroundColor,
    this.textColor,
    this.borderSide,
    this.borderRadius,
    this.iconLeading = false,
    this.boxShadow,
    this.height,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;
  final bool loading;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderSide? borderSide;
  final double? borderRadius;
  final bool iconLeading;
  final List<BoxShadow>? boxShadow;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final labelColor = textColor ??
        (variant == AppButtonVariant.primary ? Colors.white : AppColors.primary);

    final child = loading
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null && iconLeading) ...[
                Icon(icon, size: 20, color: labelColor),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTextStyles.button.copyWith(color: labelColor)),
              if (icon != null && !iconLeading) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 18, color: labelColor),
              ],
            ],
          );

    final radius = BorderRadius.circular(borderRadius ?? 12);

    final Widget buttonWidget = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            disabledBackgroundColor:
                (backgroundColor ?? AppColors.primary).withValues(alpha: 0.6),
            padding: EdgeInsets.symmetric(vertical: height != null ? 0 : 14),
            minimumSize: height != null ? Size(0, height!) : null,
            shape: RoundedRectangleBorder(borderRadius: radius),
            elevation: 0,
          ),
          child: child,
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor,
            side: borderSide ?? const BorderSide(color: AppColors.primary),
            padding: EdgeInsets.symmetric(vertical: height != null ? 0 : 14),
            minimumSize: height != null ? Size(0, height!) : null,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: onPressed,
          child: child,
        ),
    };

    Widget result = buttonWidget;

    if (boxShadow != null) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: boxShadow,
        ),
        child: result,
      );
    }

    return fullWidth ? SizedBox(width: double.infinity, child: result) : result;
  }
}
