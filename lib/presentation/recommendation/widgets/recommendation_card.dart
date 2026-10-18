import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Kartu resep hasil rekomendasi sesuai dengan desain mockup SmartCook.
/// Memuat badge persentase cocok, tombol bookmark, badge kalori,
/// baris bahan yang cocok / kurang, dan tombol "Masak Sekarang ->".
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.title,
    required this.matchedWith,
    this.extraNote,
    this.isMissingNote = false,
    required this.calories,
    required this.matchPercent,
    this.durationMinutes = 15,
    this.stepsCount = 3,
    this.isDiet = false,
    this.imageAsset,
    this.bookmarked = false,
    this.onBookmarkTap,
    this.onCookTap,
  });

  final String title;
  final String matchedWith;
  final String? extraNote;
  final bool isMissingNote;
  final int calories;
  final int matchPercent;
  final int durationMinutes;
  final int stepsCount;
  final bool isDiet;
  final String? imageAsset;
  final bool bookmarked;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onCookTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar dengan Badge-badge di atasnya
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                child: SizedBox(
                  height: 195,
                  width: double.infinity,
                  child: imageAsset != null
                      ? Image.asset(
                          imageAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
              ),

              // Badge Cocok di Kiri Atas
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF094E38),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$matchPercent% Cocok',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol Bookmark di Kanan Atas
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onBookmarkTap,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        bookmarked ? Icons.bookmark : Icons.bookmark_border_rounded,
                        size: 19,
                        color: bookmarked ? AppColors.primary : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
              ),

              // Badge Kalori di Kanan Bawah
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 14,
                        color: Color(0xFFEA580C),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$calories kkal',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          color: Color(0xFF7C2D12),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Detail Resep di Bawah Gambar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul Resep
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Info Bahan Cocok & Kurang
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check,
                        size: 15,
                        color: Color(0xFF0D7C55),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.35,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Cocok: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            TextSpan(
                              text: matchedWith,
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                            if (extraNote != null && extraNote!.isNotEmpty) ...[
                              const TextSpan(
                                text: ' • ',
                                style: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                              TextSpan(
                                text: extraNote,
                                style: TextStyle(
                                  fontWeight: isMissingNote ? FontWeight.w600 : FontWeight.w400,
                                  color: isMissingNote
                                      ? const Color(0xFFC2410C)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tombol "Masak Sekarang ->"
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onCookTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF084E38),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Masak Sekarang',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.restaurant, size: 40, color: Color(0xFF94A3B8)),
      ),
    );
  }
}
