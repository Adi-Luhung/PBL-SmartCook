import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/app_button.dart';
import '../../providers/app_providers.dart';
import '../common/actions.dart';
import '../recipe/recipe_detail_page.dart';
import 'widgets/recommendation_card.dart';

/// Tab Rekomendasi — resep yang paling cocok dengan bahan yang dipilih
/// (fungsi SQL `match_recipes`, berbobot IDF).
class RecommendationPage extends ConsumerWidget {
  const RecommendationPage({super.key, this.onPickIngredients});

  /// Pindah ke tab Input Bahan.
  final VoidCallback? onPickIngredients;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final recipes = ref.watch(recommendationsProvider);
    final bookmarks = ref.watch(bookmarkProvider).value ?? <int>{};

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Rekomendasi untukmu', style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Text(
            query.names.isEmpty
                ? 'Pilih bahan dapurmu untuk melihat rekomendasi.'
                : 'Berdasarkan ${query.names.length} bahan dapurmu',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 12),
          if (query.names.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: query.names
                  .map((name) => Chip(
                        label: Text(name, style: AppTextStyles.caption),
                        avatar: const Icon(Icons.check,
                            size: 14, color: AppColors.primary),
                        backgroundColor: AppColors.inputFill,
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
          const SizedBox(height: 20),
          if (query.ids.isEmpty)
            _EmptyState(
              icon: Icons.checklist_rtl,
              message: 'Belum ada bahan yang dipilih.',
              actionLabel: 'Pilih Bahan',
              onAction: onPickIngredients,
            )
          else
            recipes.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => _EmptyState(
                icon: Icons.cloud_off_outlined,
                message: 'Gagal memuat resep. Periksa koneksi lalu coba lagi.',
                actionLabel: 'Coba Lagi',
                onAction: () => ref.invalidate(recommendationsProvider),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return _EmptyState(
                    icon: Icons.search_off,
                    message: 'Belum ada resep yang cocok dengan bahan ini.',
                    actionLabel: 'Ubah Bahan',
                    onAction: onPickIngredients,
                  );
                }
                return Column(
                  children: [
                    for (final r in list)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: RecommendationCard(
                          title: r.title,
                          matchedWith: r.matchedNames.map(titleCase).join(', '),
                          overlayLabel: '${r.matched}/${r.total} bahan',
                          matchPercent: r.percent,
                          caloriesLabel: kaloriPer100gLabel(r.kalori, r.beratG),
                          stepsCount: r.totalSteps,
                          bookmarked: bookmarks.contains(r.id),
                          onBookmarkTap: () =>
                              toggleBookmark(context, ref, r.id),
                          onCookTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailPage(recipeId: r.id),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center, style: AppTextStyles.bodyMuted),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            AppButton(
              label: actionLabel!,
              fullWidth: false,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
