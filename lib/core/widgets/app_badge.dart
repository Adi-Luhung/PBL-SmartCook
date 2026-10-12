import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Badge pil generik — dipakai untuk "95% Cocok", "Tersedia",
/// "Di Kulkas", "Ideal / Normal", dsb.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.leading,
    this.padding,
    this.textStyle,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 6),
          ] else if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: textStyle ??
                AppTextStyles.caption
                    .copyWith(color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Badge khusus kategori diet, dipakai di kartu resep & detail resep.
class DietBadge extends StatelessWidget {
  const DietBadge({super.key, required this.isDiet});

  final bool isDiet;

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: isDiet ? 'Diet Sehat' : 'Non-Diet',
      backgroundColor: isDiet ? AppColors.primaryLight : AppColors.neutralBadgeBg,
      textColor: isDiet ? AppColors.primaryDark : AppColors.neutralBadgeText,
    );
  }
}
