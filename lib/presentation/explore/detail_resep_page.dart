import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../auth/auth_page.dart';
import '../recommendation/rating_hasil_masakan_page.dart';

class RecipeReview {
  const RecipeReview({
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
  });

  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final String date;
}

class DetailResepPage extends StatelessWidget {
  const DetailResepPage({
    super.key,
    required this.title,
    this.imageUrl,
    this.imageAsset,
    this.calories = 350,
    this.portions = 2,
    this.isDiet = false,
    this.rating = 4.8,
    this.reviewCount = 120,
    this.reviews = const [],
    this.ingredientList = const [],
    this.stepList = const [],
  });

  final String title;
  final String? imageUrl;
  final String? imageAsset;
  final int calories;
  final int portions;
  final bool isDiet;
  final double rating;
  final int reviewCount;
  final List<RecipeReview> reviews;
  final List<String> ingredientList;
  final List<Map<String, String>> stepList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Detail Resep',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 20),
                  const Text(
                    'Bahan Masakan & Takaran',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Daftar takaran bahan yang dibutuhkan',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildIngredientsCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Langkah Pembuatan Masakan',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tahapan memasak berurutan',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildStepsCard(),
                  const SizedBox(height: 24),
                  _buildReviewsSection(context),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RatingHasilMasakanPage(
                              title: title,
                              isDiet: isDiet,
                              calories: calories,
                              portions: portions,
                              imageAsset: imageAsset,
                              imageUrl: imageUrl,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF084E38),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Selesai Memasak',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF0A2218)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  imageAsset != null
                      ? Image.asset(imageAsset!, fit: BoxFit.cover)
                      : const SizedBox.shrink(),
            )
          else if (imageAsset != null)
            Image.asset(imageAsset!, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.65),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.soup_kitchen_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$portions Porsi',
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 14,
                            color: Color(0xFFF97316),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$calories kkal',
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDiet) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Diet Sehat',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: const [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 16,
                  color: Color(0xFF084E38),
                ),
                SizedBox(width: 8),
                Text(
                  'BAHAN & BUMBU',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Color(0xFF084E38),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          ...List.generate(ingredientList.length, (index) {
            final ingredient = ingredientList[index];
            final isLast = index == ingredientList.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ingredient,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF8FAFC),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: List.generate(stepList.length, (index) {
          final step = stepList[index];
          final isLast = index == stepList.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1FAE5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'] ?? '',
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step['description'] ?? '',
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF475569),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Penilaian Resep Masakan',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pendapat pengguna yang telah memasak resep ini',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$rating ($reviewCount)',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Berdasarkan $reviewCount ulasan pengguna',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (reviews.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 16),
                ...List.generate(reviews.length, (index) {
                  final review = reviews[index];
                  final initial = review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U';

                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: index < reviews.length - 1 ? 16 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF084E38),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.userName,
                                    style: const TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    review.date,
                                    style: const TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                5,
                                (starIndex) => Icon(
                                  starIndex < review.rating.floor()
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 14,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          review.comment,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF334155),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: () => _showLoginPrompt(context),
                  icon: const Icon(
                    Icons.rate_review_outlined,
                    size: 16,
                    color: Color(0xFF084E38),
                  ),
                  label: const Text(
                    'Tambah Ulasan & Penilaian',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF084E38),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF084E38),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF084E38),
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Masuk Akun Diperlukan',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: const Text(
          'Silakan masuk atau daftar akun terlebih dahulu untuk memberikan ulasan dan rating pada resep masakan ini.',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF475569),
            height: 1.45,
          ),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF084E38),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Masuk Sekarang',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
