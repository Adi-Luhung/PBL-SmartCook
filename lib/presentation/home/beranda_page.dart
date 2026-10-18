import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models.dart';
import '../../providers/app_providers.dart';
import '../common/actions.dart';
import '../recipe/recipe_detail_page.dart';
import 'widgets/home_recipe_list_item.dart';

class _HomeItem {
  const _HomeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.steps,
    required this.ingredientsLabel,
    this.caloriesLabel,
  });

  final int id;
  final String title;
  final String subtitle;
  final int steps;
  final String ingredientsLabel;
  final String? caloriesLabel;
}

/// Tab Beranda — kalau pengguna sudah memilih bahan, tampilkan resep paling
/// cocok; kalau belum, tampilkan beberapa resep dari katalog.
class BerandaPage extends ConsumerWidget {
  const BerandaPage({super.key, required this.onNavigate});

  /// Dipanggil saat user mau pindah tab: 0=Beranda, 1=Rekomendasi,
  /// 2=Input, 3=Profil.
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<RecipeMatch> matches =
        ref.watch(recommendationsProvider).value ?? const <RecipeMatch>[];
    final featured = ref.watch(featuredRecipesProvider);
    final bookmarks = ref.watch(bookmarkProvider).value ?? <int>{};

    final List<_HomeItem> items;
    if (matches.isNotEmpty) {
      items = matches
          .take(5)
          .map((r) => _HomeItem(
                id: r.id,
                title: r.title,
                subtitle:
                    'Cocok untuk ${r.matchedNames.take(3).map(titleCase).join(', ')}',
                steps: r.totalSteps,
                ingredientsLabel: '${r.matched}/${r.total} bahan',
                caloriesLabel: kaloriPer100gLabel(r.kalori, r.beratG),
              ))
          .toList();
    } else {
      items = (featured.value ?? const <RecipeSummary>[])
          .map((r) => _HomeItem(
                id: r.id,
                title: r.title,
                subtitle: r.category == null ? '' : 'Kategori ${titleCase(r.category!)}',
                steps: r.totalSteps,
                ingredientsLabel: '${r.totalIngredients} bahan',
                caloriesLabel: kaloriPer100gLabel(r.kalori, r.beratG),
              ))
          .toList();
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Halo, Mau Masak Apa?', style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Text(
            'Pilih bahan yang ada, kami temukan resepnya, atau cari resep makanan favoritmu.',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 20),
          _SearchCard(onSearchTap: () => onNavigate(1)),
          const SizedBox(height: 12),
          _HighlightCard(onTap: () => onNavigate(2)),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Rekomendasi Masakan', style: AppTextStyles.h2),
              const Spacer(),
              GestureDetector(
                onTap: () => onNavigate(1),
                child: Row(
                  children: [
                    Text(
                      'Lihat Semua',
                      style: AppTextStyles.label.copyWith(color: AppColors.primary),
                    ),
                    const Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty && featured.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Belum ada resep yang bisa ditampilkan. Periksa koneksi internetmu.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HomeRecipeListItem(
                  title: item.title,
                  subtitle: item.subtitle,
                  stepsCount: item.steps,
                  ingredientsLabel: item.ingredientsLabel,
                  caloriesLabel: item.caloriesLabel,
                  bookmarked: bookmarks.contains(item.id),
                  onBookmarkTap: () => toggleBookmark(context, ref, item.id),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailPage(recipeId: item.id),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Jelajahi Semua Resep Masakan',
            onPressed: () => onNavigate(1),
          ),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Cari Resep Masakan', style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text('Misal: Soto Ayam, Rendang', style: AppTextStyles.bodyMuted),
                ),
                GestureDetector(
                  onTap: onSearchTap,
                  child: Row(
                    children: [
                      Text('Cari', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                      const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rtl, size: 18, color: AppColors.primaryDark),
              const SizedBox(width: 8),
              Text(
                'Masukkan Bahan Masakan',
                style: AppTextStyles.label.copyWith(color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppButton(label: 'Cari & Masukkan Bahan', onPressed: onTap),
        ],
      ),
    );
  }
}
