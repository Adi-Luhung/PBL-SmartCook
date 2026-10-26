import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/nutrition.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models.dart';
import '../../providers/app_providers.dart';
import '../explore/detail_resep_page.dart';

/// Memuat resep dari database lalu menampilkannya dengan [DetailResepPage].
class RecipeDetailLoader extends ConsumerWidget {
  const RecipeDetailLoader({super.key, required this.recipeId});

  final int recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(recipeDetailProvider(recipeId));
    final budget = ref.watch(mealBudgetProvider);

    return detail.when(
      loading: () => Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Gagal memuat resep.', style: AppTextStyles.bodyMuted),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Coba Lagi',
                  fullWidth: false,
                  onPressed: () => ref.invalidate(recipeDetailProvider(recipeId)),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (r) {
        final calories = caloriesPerPortion(r.kalori, r.beratG);
        final reviews =
            ref.watch(recipeReviewsProvider(recipeId)).value ?? const [];
        final rating = reviews.isNotEmpty
            ? (reviews.map((e) => e.rating).reduce((a, b) => a + b) /
                reviews.length)
            : 5.0;
        return DetailResepPage(
          title: r.title,
          calories: calories,
          portions: estimatePortions(r.beratG),
          isDiet: isDietPortion(calories, budget) ?? false,
          showReviews: true,
          reviews: reviews,
          rating: rating,
          reviewCount: reviews.length,
          recipeId: recipeId,
          ingredientList: r.ingredients.map(titleCase).toList(),
          ingredientQuantities: {
            for (final e in r.quantities.entries) titleCase(e.key): e.value,
          },
          stepList: [
            for (final step in r.steps) {'title': '', 'description': step},
          ],
          extraContent: _DbExtras(detail: r),
        );
      },
    );
  }
}

/// Kartu perkiraan gizi di bawah langkah pembuatan.
class _DbExtras extends StatelessWidget {
  const _DbExtras({required this.detail});

  final RecipeDetail detail;

  @override
  Widget build(BuildContext context) {
    if (detail.kalori == null) return const SizedBox.shrink();
    return _NutritionCard(detail: detail);
  }
}

class _NutritionCard extends StatelessWidget {
  const _NutritionCard({required this.detail});

  final RecipeDetail detail;

  static String _n(double v) => v
      .round()
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  @override
  Widget build(BuildContext context) {
    final kalori = detail.kalori!;
    final berat = detail.beratG;
    final portions = estimatePortions(berat);

    Widget tile(String value, String label) => Expanded(
          child: Column(
            children: [
              Text(value,
                  style: AppTextStyles.h2.copyWith(color: AppColors.primaryDark)),
              const SizedBox(height: 2),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Perkiraan Gizi', style: AppTextStyles.label),
          const SizedBox(height: 2),
          Text('Total seluruh bahan resep', style: AppTextStyles.caption),
          const SizedBox(height: 12),
          Row(
            children: [
              tile(_n(kalori), 'kkal'),
              if (detail.proteinG != null) tile('${_n(detail.proteinG!)} g', 'protein'),
              if (detail.lemakG != null) tile('${_n(detail.lemakG!)} g', 'lemak'),
              if (detail.karboG != null) tile('${_n(detail.karboG!)} g', 'karbo'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            [
              if (berat != null) 'berat bahan ≈ ${_n(berat)} g',
              'kalori per porsi = total ÷ $portions porsi (porsi diperkirakan dari berat bahan)',
            ].join(' • '),
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
