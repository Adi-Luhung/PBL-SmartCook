import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_badge.dart';

/// Kartu resep dipakai di Beranda & Hasil Rekomendasi
/// (mis. "Tahu Telur Bumbu Kecap Pedas — 95% Cocok").
class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    this.matchPercent,
    this.isDiet = false,
    this.imageUrl,
    this.bookmarked = false,
    this.onBookmarkTap,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final int durationMinutes;
  final int? matchPercent;
  final bool isDiet;
  final String? imageUrl;
  final bool bookmarked;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
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
                    child: imageUrl == null
                        ? const Center(
                            child: Icon(Icons.image_outlined, color: AppColors.textMuted),
                          )
                        : Image.network(imageUrl!, fit: BoxFit.cover),
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
                      if (matchPercent != null) ...[
                        AppBadge(
                          label: '$matchPercent% Cocok',
                          backgroundColor: AppColors.primaryLight,
                          textColor: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 6),
                      ],
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
                  Text(
                    title,
                    style: AppTextStyles.h2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMuted,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
