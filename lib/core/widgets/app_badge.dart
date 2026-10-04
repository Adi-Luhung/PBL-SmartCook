import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Badge pil generik — dipakai untuk "95% Cocok", "Tersedia",
/// "Di Kulkas", dsb.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.caption
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
