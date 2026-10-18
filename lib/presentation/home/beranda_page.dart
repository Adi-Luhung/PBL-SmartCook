import 'package:flutter/material.dart';

import '../../core/services/bookmark_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/profile_avatar.dart';
import '../explore/detail_resep_page.dart';
import 'widgets/home_recipe_list_item.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({
    super.key,
    required this.onNavigate,
    required this.onSearchRecipes,
  });

  final ValueChanged<int> onNavigate;
  final ValueChanged<String> onSearchRecipes;

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  static const _recommended = [
    (
      title: 'Sup Ayam Jahe Hangat',
      subtitle: 'Cocok untuk dada ayam & daun bawang',
      duration: 25,
      calories: 320,
      portions: 2,
      isDiet: true,
      rating: 4.9,
      reviewCount: 148,
      reviews: [
        RecipeReview(
          userName: 'Dian Permata',
          rating: 5.0,
          comment:
              'Kuahnya sangat menghangatkan tubuh dan aromanya jahenya pas.',
          date: '1 hari lalu',
        ),
        RecipeReview(
          userName: 'Rian Pratama',
          rating: 4.8,
          comment: 'Daging ayamnya empuk dan bumbu jahenya meresap.',
          date: '3 hari lalu',
        ),
      ],
      imageAsset: 'assets/images/recipes/sup_ayam_jahe.jpg',
      ingredientList: [
        '300g Dada Ayam Fillet',
        '2 ruas Jahe Segar',
        '3 siung Bawang Putih',
        '1 batang Daun Bawang',
        '1 sdt Minyak Wijen',
        '1 sdt Garam & Merica',
      ],
      stepList: [
        {
          'title': 'Persiapan Bahan',
          'description':
              'Potong dadu dada ayam dan memarkan jahe segar serta bawang putih.',
        },
        {
          'title': 'Merebus Kaldu Gurih',
          'description':
              'Didihkan air, masukkan potongan ayam, jahe, dan bawang putih hingga kaldu harum dan bening.',
        },
        {
          'title': 'Penyajian Hangat',
          'description':
              'Bumbui garam, merica, dan sedikit minyak wijen. Sajikan hangat dengan irisan daun bawang segar.',
        },
      ],
    ),
    (
      title: 'Tumis Tahu Telur Saus Tiram',
      subtitle: 'Gunakan stok tahu dan telur ayam',
      duration: 15,
      calories: 240,
      portions: 2,
      isDiet: false,
      rating: 4.8,
      reviewCount: 95,
      reviews: [
        RecipeReview(
          userName: 'Maya Anggraini',
          rating: 5.0,
          comment:
              'Sangat praktis buat sarapan cepat dan rasanya gurih manis lezat!',
          date: '2 hari lalu',
        ),
      ],
      imageAsset: 'assets/images/recipes/tumis_tahu_telur.jpg',
      ingredientList: [
        '3 buah Tahu Putih',
        '2 butir Telur Ayam',
        '2 siung Bawang Putih',
        '2 sdm Saus Tiram',
        '1 sdm Kecap Manis',
        '1 batang Daun Bawang',
      ],
      stepList: [
        {
          'title': 'Menggoreng Tahu',
          'description':
              'Potong kotak tahu putih lalu goreng setengah matang hingga berkulit keemasan.',
        },
        {
          'title': 'Menumis & Orak-Arik',
          'description':
              'Tumis bawang putih hingga harum, masukkan telur lalu orak-arik cepat.',
        },
        {
          'title': 'Membumbui & Penyelesaian',
          'description':
              'Masukkan tahu goreng, saus tiram, kecap manis, dan sedikit air. Masak hingga meresap dan taburi daun bawang.',
        },
      ],
    ),
  ];

  void _openRecipeDetail((
    {int calories,
    int duration,
    String imageAsset,
    List<String> ingredientList,
    bool isDiet,
    int portions,
    double rating,
    int reviewCount,
    List<RecipeReview> reviews,
    List<Map<String, String>> stepList,
    String subtitle,
    String title}
  ) item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailResepPage(
          title: item.title,
          imageAsset: item.imageAsset,
          calories: item.calories,
          portions: item.portions,
          isDiet: item.isDiet,
          rating: item.rating,
          reviewCount: item.reviewCount,
          reviews: item.reviews,
          ingredientList: item.ingredientList,
          stepList: item.stepList,
        ),
      ),
    );
  }

  void _toggleBookmark((
    {int calories,
    int duration,
    String imageAsset,
    List<String> ingredientList,
    bool isDiet,
    int portions,
    double rating,
    int reviewCount,
    List<RecipeReview> reviews,
    List<Map<String, String>> stepList,
    String subtitle,
    String title}
  ) item) {
    BookmarkService.instance.toggleBookmark(
      SavedRecipe(
        name: item.title,
        time: '${item.duration} Menit',
        ingredients: '${item.ingredientList.length} Bahan',
        imageAsset: item.imageAsset,
        calories: item.calories,
        portions: item.portions,
        isDiet: item.isDiet,
        ingredientList: item.ingredientList,
        stepList: item.stepList,
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
            onTap: () => widget.onNavigate(3),
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
  Widget build(BuildContext context) {
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
              _SearchCard(onSearch: widget.onSearchRecipes),
              const SizedBox(height: 12),
              _HighlightCard(onTap: () => widget.onNavigate(2)),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text('Rekomendasi Masakan', style: AppTextStyles.h2),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => widget.onNavigate(1),
                    child: Row(
                      children: [
                        Text(
                          'Lihat Semua (24)',
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
              ...List.generate(_recommended.length, (i) {
                final item = _recommended[i];
                final isBookmarked =
                    BookmarkService.instance.isBookmarked(item.title);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HomeRecipeListItem(
                    title: item.title,
                    subtitle: item.subtitle,
                    durationMinutes: item.duration,
                    calories: item.calories,
                    imageAsset: item.imageAsset,
                    bookmarked: isBookmarked,
                    onBookmarkTap: () => _toggleBookmark(item),
                    onTap: () => _openRecipeDetail(item),
                  ),
                );
              }),
              const SizedBox(height: 8),
              AppButton(
                label: 'Jelajahi Semua Resep Masakan',
                onPressed: () => widget.onNavigate(1),
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
