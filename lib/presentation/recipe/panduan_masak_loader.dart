import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/utils/nutrition.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/app_button.dart';
import '../../providers/app_providers.dart';
import '../recommendation/detail_panduan_masak_page.dart';

/// Memuat resep dari database lalu menampilkannya dengan [DetailPanduanMasakPage]
/// (panduan memasak + perbandingan dengan bahan yang dimiliki pengguna).
class PanduanMasakLoader extends ConsumerWidget {
  const PanduanMasakLoader({super.key, required this.recipeId});

  final int recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(recipeDetailProvider(recipeId));
    final query = ref.watch(searchQueryProvider);
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
        final portions = estimatePortions(r.beratG);
        int perPortion(double? v) => v == null ? 0 : (v / portions).round();
        final calories = caloriesPerPortion(r.kalori, r.beratG);
        final berat = r.beratG;
        return DetailPanduanMasakPage(
          title: r.title,
          calories: calories,
          portions: portions,
          isDiet: isDietPortion(calories, budget) ?? false,
          showReviews: false,
          recipeId: recipeId,
          ingredientList: r.ingredients.map(titleCase).toList(),
          ingredientQuantities: {
            for (final e in r.quantities.entries) titleCase(e.key): e.value,
          },
          stepList: [
            for (final step in r.steps) {'title': '', 'description': step},
          ],
          // Nama baku bahan pengguna -> dicocokkan persis dengan bahan resep.
          userIngredients: query.canonical.map(titleCase).toList(),
          proteinGrams: perPortion(r.proteinG),
          carbsGrams: perPortion(r.karboG),
          fatGrams: perPortion(r.lemakG),
          weightPerPortionGrams:
              (berat != null && berat > 0) ? (berat / portions).round() : null,
          caloriesPer100g: (r.kalori != null && berat != null && berat > 0)
              ? (r.kalori! / berat * 100).round()
              : null,
        );
      },
    );
  }
}
