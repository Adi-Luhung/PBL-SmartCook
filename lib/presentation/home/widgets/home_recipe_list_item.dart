import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Item resep horizontal untuk daftar "Rekomendasi Masakan" di Beranda.
class HomeRecipeListItem extends StatelessWidget {
  const HomeRecipeListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stepsCount,
    required this.ingredientsLabel,
    this.bookmarked = false,
    this.onBookmarkTap,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final int stepsCount;
  final String ingredientsLabel;
  final bool bookmarked;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 64,
                height: 64,
                color: AppColors.border.withOpacity(0.5),
                child: const Icon(Icons.image_outlined, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.label.copyWith(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onBookmarkTap,
                        child: Icon(
                          bookmarked ? Icons.bookmark : Icons.bookmark_border,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMuted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.format_list_numbered,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('$stepsCount langkah', style: AppTextStyles.caption),
                      const SizedBox(width: 10),
                      const Icon(Icons.kitchen_outlined,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(ingredientsLabel, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
