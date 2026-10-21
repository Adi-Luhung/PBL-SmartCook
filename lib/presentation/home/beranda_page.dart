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
import '../recipe/recipe_detail_loader.dart';
import 'widgets/home_recipe_list_item.dart';

class _HomeItem {
  const _HomeItem({
    required this.summary,
    required this.subtitle,
    required this.calories,
  });

  final RecipeSummary summary;
  final String subtitle;
  final int calories;
}

/// Tab Beranda — kalau pengguna sudah memilih bahan, tampilkan resep paling
/// cocok; kalau belum, tampilkan beberapa resep dari katalog database.
class BerandaPage extends ConsumerWidget {
  const BerandaPage({
    super.key,
    required this.onNavigate,
    required this.onSearchRecipes,
  });

  final ValueChanged<int> onNavigate;
  final ValueChanged<String> onSearchRecipes;

  void _openRecipeDetail(BuildContext context, int recipeId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailLoader(recipeId: recipeId)),
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
            onTap: () => onNavigate(3),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<RecipeMatch> matches =
        ref.watch(recommendationsProvider).value ?? const <RecipeMatch>[];
    final featured = ref.watch(featuredRecipesProvider);

    final List<_HomeItem> items;
    if (matches.isNotEmpty) {
      items = matches
          .take(5)
          .map((r) => _HomeItem(
                summary: r.toSummary(),
                subtitle:
                    'Cocok untuk ${r.matchedNames.take(3).map(titleCase).join(', ')}',
                calories: caloriesPerPortion(r.kalori, r.beratG),
              ))
          .toList();
    } else {
      items = (featured.value ?? const <RecipeSummary>[])
          .map((r) => _HomeItem(
                summary: r,
                subtitle: r.category == null
                    ? '${r.totalIngredients} bahan'
                    : 'Kategori ${titleCase(r.category!)}',
                calories: caloriesPerPortion(r.kalori, r.beratG),
              ))
          .toList();
    }

    return ListenableBuilder(
      listenable: BookmarkService.instance,
      builder: (context, _) {
        return SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
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
                    _SearchCard(onSearch: onSearchRecipes),
                    const SizedBox(height: 12),
                    _HighlightCard(onTap: () => onNavigate(2)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Rekomendasi Masakan', style: AppTextStyles.h2),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => onNavigate(1),
                          child: Row(
                            children: [
                              Text(
                                'Lihat Semua',
                                style: AppTextStyles.label
                                    .copyWith(color: AppColors.primary),
                              ),
                              const Icon(Icons.chevron_right,
                                  size: 16, color: AppColors.primary),
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
                            title: item.summary.title,
                            subtitle: item.subtitle,
                            calories: item.calories,
                            bookmarked: BookmarkService.instance
                                .isRecipeBookmarked(item.summary.id),
                            onBookmarkTap: () =>
                                toggleRecipeBookmark(context, item.summary),
                            onTap: () => _openRecipeDetail(context, item.summary.id),
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
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchCard extends StatefulWidget {
  const _SearchCard({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  State<_SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<_SearchCard> {
  final TextEditingController _searchController = TextEditingController();

  void _submitSearch() {
    final searchKeyword = _searchController.text.trim();
    if (searchKeyword.isEmpty) return;
    widget.onSearch(searchKeyword);
    _searchController.clear();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _submitSearch(),
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Misal: Soto Ayam, Rendang',
                      hintStyle: AppTextStyles.bodyMuted,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, _) {
                    final isEnabled = value.text.trim().isNotEmpty;
                    final actionColor =
                        isEnabled ? AppColors.primary : AppColors.textMuted;
                    return GestureDetector(
                      onTap: isEnabled ? _submitSearch : null,
                      child: Row(
                        children: [
                          Text(
                            'Cari',
                            style: AppTextStyles.label
                                .copyWith(color: actionColor),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: actionColor,
                          ),
                        ],
                      ),
                    );
                  },
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
