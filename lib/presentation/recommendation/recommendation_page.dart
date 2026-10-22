import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/bookmark_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/nutrition.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../data/models.dart';
import '../../providers/app_providers.dart';
import '../common/actions.dart';
import '../profile/profile_page.dart';
import '../recipe/panduan_masak_loader.dart';
import 'widgets/recommendation_card.dart';

/// Hasil rekomendasi resep dari bahan yang dipilih di tab Input
/// (fungsi SQL `match_recipes`, berbobot IDF).
class RecommendationPage extends ConsumerStatefulWidget {
  const RecommendationPage({
    super.key,
    this.onAddIngredients,
    this.onProfileTap,
  });

  final VoidCallback? onAddIngredients;
  final VoidCallback? onProfileTap;

  @override
  ConsumerState<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends ConsumerState<RecommendationPage> {
  void _openProfile() {
    if (widget.onProfileTap != null) {
      widget.onProfileTap!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }

  void _openGuide(int recipeId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PanduanMasakLoader(recipeId: recipeId)),
    );
  }

  void _showCookingModal(RecipeMatch recipe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F7F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.outdoor_grill_outlined,
                        color: Color(0xFF084E38),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Siap Memasak!',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0D7C55),
                            ),
                          ),
                          Text(
                            recipe.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ikuti panduan langkah demi langkah untuk menyajikan hidangan lezat dan bernutrisi ini.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _openGuide(recipe.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF084E38),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Mulai Panduan Masak',
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
        );
      },
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
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
            AppButton(label: actionLabel, fullWidth: false, onPressed: onAction),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildResults(
      SearchQuery query, AsyncValue<List<RecipeMatch>> recipes, int budget) {
    if (query.ids.isEmpty) {
      return [
        _emptyState(
          icon: Icons.checklist_rtl,
          message: 'Belum ada bahan yang dipilih.',
          actionLabel: 'Pilih Bahan',
          onAction: widget.onAddIngredients,
        ),
      ];
    }
    return recipes.when(
      loading: () => const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (e, _) => [
        _emptyState(
          icon: Icons.cloud_off_outlined,
          message: 'Gagal memuat resep. Periksa koneksi lalu coba lagi.',
          actionLabel: 'Coba Lagi',
          onAction: () => ref.invalidate(recommendationsProvider),
        ),
      ],
      data: (list) {
        if (list.isEmpty) {
          return [
            _emptyState(
              icon: Icons.search_off,
              message: 'Belum ada resep yang cocok dengan bahan ini.',
              actionLabel: 'Ubah Bahan',
              onAction: widget.onAddIngredients,
            ),
          ];
        }
        return [
          for (final r in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => _openGuide(r.id),
                child: RecommendationCard(
                title: r.title,
                matchedWith: r.matchedNames.map(titleCase).join(', '),
                calories: caloriesPerPortion(r.kalori, r.beratG),
                isDiet: isDietPortion(caloriesPerPortion(r.kalori, r.beratG), budget),
                matchPercent: r.percent,
                stepsCount: r.totalSteps,
                bookmarked: BookmarkService.instance.isRecipeBookmarked(r.id),
                onBookmarkTap: () => toggleRecipeBookmark(context, r.toSummary()),
                onCookTap: () => _showCookingModal(r),
              ),
              ),
            ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final recipes = ref.watch(recommendationsProvider);
    final budget = ref.watch(mealBudgetProvider);
    final ingredients = query.names;

    return ListenableBuilder(
      listenable: BookmarkService.instance,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _buildHeadlineRow(ingredients.length),
                    const SizedBox(height: 14),
                    _buildIngredientsChips(ingredients),
                    const SizedBox(height: 20),
                    ..._buildResults(query, recipes, budget),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              children: [
                TextSpan(
                  text: 'Smart',
                  style: TextStyle(color: Color(0xFF0F172A)),
                ),
                TextSpan(
                  text: 'Cook',
                  style: TextStyle(color: Color(0xFF084E38)),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _openProfile,
            borderRadius: BorderRadius.circular(20),
            child: const Tooltip(
              message: 'Profil',
              child: ProfileAvatar(radius: 18, iconSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadlineRow(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rekomendasi untukmu',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Berdasarkan bahan pilihanmu',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF084E38),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$count Bahan',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientsChips(List<String> ingredients) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          GestureDetector(
            key: const ValueKey('add_ingredient_chip_button'),
            onTap: widget.onAddIngredients,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 15,
                    color: Color(0xFF084E38),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Ubah',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF084E38),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 1.5,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: ingredients.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final name = ingredients[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2EBF8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check,
                        size: 14,
                        color: Color(0xFF1E293B),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
