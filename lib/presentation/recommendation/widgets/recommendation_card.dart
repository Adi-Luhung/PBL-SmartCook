import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_badge.dart';

/// Varian kartu resep untuk Hasil Rekomendasi — mirip RecipeCard tapi
/// dengan jumlah langkah dan tombol "Masak".
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.title,
    required this.matchedWith,
    required this.durationMinutes,
    required this.matchPercent,
    required this.stepsCount,
    this.isDiet = false,
    this.bookmarked = false,
    this.onBookmarkTap,
    this.onCookTap,
  });

  final String title;
  final String matchedWith;
  final int durationMinutes;
  final int matchPercent;
  final int stepsCount;
  final bool isDiet;
  final bool bookmarked;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onCookTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: AppColors.border.withOpacity(0.5),
                  child: const Center(
                    child: Icon(Icons.image_outlined, color: AppColors.textMuted),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$durationMinutes mnt',
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppBadge(
                      label: '$matchPercent% Cocok',
                      backgroundColor: AppColors.primaryLight,
                      textColor: AppColors.primaryDark,
                    ),
                    const SizedBox(width: 6),
                    DietBadge(isDiet: isDiet),
                    const Spacer(),
                    GestureDetector(
                      onTap: onBookmarkTap,
                      child: Icon(
                        bookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: AppTextStyles.h2),
                const SizedBox(height: 4),
                Text('Cocok: $matchedWith', style: AppTextStyles.bodyMuted),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.format_list_numbered, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('$stepsCount Langkah', style: AppTextStyles.caption),
                    const Spacer(),
                    TextButton(
                      onPressed: onCookTap,
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Masak', style: AppTextStyles.button),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
