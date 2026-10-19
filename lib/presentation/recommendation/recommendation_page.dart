import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/profile_avatar.dart';
import '../profile/profile_page.dart';
import 'detail_panduan_masak_page.dart';
import 'widgets/recommendation_card.dart';

class _RecipeData {
  const _RecipeData({
    required this.title,
    required this.matchedWith,
    required this.calories,
    required this.matchPercent,
    required this.imageAsset,
    this.isDiet = false,
    this.stepsCount = 3,
    this.portions = 2,
    this.rating = 4.8,
    this.reviewCount = 142,
    this.proteinGrams = 30,
    this.carbsGrams = 14,
    this.fatGrams = 12,
    this.fiberGrams = 4,
    this.sugarGrams = 3,
    this.ingredientList = const [],
    this.stepList = const [],
  });

  final String title;
  final String matchedWith;
  final int calories;
  final int matchPercent;
  final String imageAsset;
  final bool isDiet;
  final int stepsCount;
  final int portions;
  final double rating;
  final int reviewCount;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final int fiberGrams;
  final int sugarGrams;
  final List<String> ingredientList;
  final List<Map<String, String>> stepList;
}

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({
    super.key,
    this.selectedIngredients,
    this.onAddIngredients,
    this.onProfileTap,
  });

  final List<String>? selectedIngredients;
  final VoidCallback? onAddIngredients;
  final VoidCallback? onProfileTap;

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  final Set<String> _bookmarked = {};

  void _openProfile() {
    if (widget.onProfileTap != null) {
      widget.onProfileTap!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }

  static const _defaultIngredients = ['Tahu', 'Telur', 'Bawang', 'Cabai'];

  static const _recipes = [
    _RecipeData(
      title: 'Ayam Tumis Kecap Bawang Daun',
      matchedWith: 'Daging Ayam, Bawang Putih, Daun Bawang, Kecap Manis',
      calories: 380,
      matchPercent: 75,
      imageAsset: 'assets/images/recipes/tumis_tahu_telur.jpg',
      isDiet: false,
      stepsCount: 5,
      portions: 2,
      rating: 4.8,
      reviewCount: 142,
      proteinGrams: 30,
      carbsGrams: 14,
      fatGrams: 12,
      fiberGrams: 4,
      sugarGrams: 3,
      ingredientList: [
        '250g Dada Ayam Fillet',
        '3 siung Bawang Putih',
        '2 batang Daun Bawang',
        '1 buah Tomat Segar',
        '2 sdm Kecap Manis Kental',
        '1 sdm Kecap Asin Rendah Natrium',
        '1 sdt Minyak Wijen Murni',
        '1/2 sdt Merica & Garam Halus',
      ],
      stepList: [
        {
          'title': 'Persiapan & Marinasi',
          'description':
              'Potong dadu dada ayam, lumuri dengan 1 sdm kecap asin, merica, dan sesendok teh minyak wijen. Diamkan 5 menit agar serat daging empuk dan bumbu meresap sempurna.',
        },
        {
          'title': 'Tumis Bumbu Aromatik',
          'description':
              'Panaskan 1 sdm minyak di wajan anti lengket. Masukkan bawang putih cincang, tumis dengan api sedang hingga harum kekuningan dan tidak gosong.',
        },
        {
          'title': 'Pematangan Daging Ayam',
          'description':
              'Masukkan potongan ayam yang telah dimarinasi ke wajan. Aduk cepat hingga seluruh permukaan ayam berubah warna pucat keemasan dan matang gurih merata.',
        },
        {
          'title': 'Karamelisasi Kecap & Daun Bawang',
          'description':
              'Tuangkan kecap manis, irisan daun bawang, dan potongan tomat. Aduk merata di atas api sedang hingga saus mengental mengkilap melapisi setiap potongan ayam.',
        },
        {
          'title': 'Penyajian Hangat',
          'description':
              'Angkat dari wajan dan sajikan selagi hangat mengepul bersama nasi putih pulen hangat atau quinoa sehat favorit keluarga. Selamat menikmati santapan buatan sendiri!',
        },
      ],
    ),
    _RecipeData(
      title: 'Tahu Telur Bumbu Kecap Pedas',
      matchedWith: 'Tahu, Telur, Bawang, Cabai',
      calories: 320,
      matchPercent: 95,
      imageAsset: 'assets/images/recipes/tahu_telur_kecap.jpg',
      isDiet: false,
      stepsCount: 3,
      portions: 2,
      rating: 4.7,
      reviewCount: 98,
      proteinGrams: 18,
      carbsGrams: 16,
      fatGrams: 14,
      fiberGrams: 3,
      sugarGrams: 4,
      ingredientList: [
        '300g Tahu Putih',
        '2 butir Telur Ayam',
        '3 siung Bawang Merah',
        '2 siung Bawang Putih',
        '5 buah Cabai Rawit Merah',
        '2 batang Daun Bawang',
        '3 sdm Kecap Manis',
        '1/2 sdt Garam & Merica',
      ],
      stepList: [
        {
          'title': 'Goreng Tahu',
          'description':
              'Potong dadu tahu putih lalu goreng dalam minyak panas hingga berkulit keemasan, angkat dan tiriskan.',
        },
        {
          'title': 'Tumis Bumbu',
          'description':
              'Tumis irisan bawang merah, bawang putih, dan cabai rawit hingga harum semerbak.',
        },
        {
          'title': 'Karamelisasi Kecap',
          'description':
              'Masukkan tahu goreng, tuang kecap manis, bumbui garam dan merica, aduk rata hingga meresap sempurna.',
        },
      ],
    ),
    _RecipeData(
      title: 'Orak-Arik Telur Tahu Sehat',
      matchedWith: 'Tahu, Telur, Bawang',
      calories: 220,
      matchPercent: 85,
      imageAsset: 'assets/images/recipes/orak_arik_telur_tahu.jpeg',
      isDiet: true,
      stepsCount: 2,
      portions: 2,
      rating: 4.6,
      reviewCount: 84,
      proteinGrams: 20,
      carbsGrams: 8,
      fatGrams: 10,
      fiberGrams: 3,
      sugarGrams: 2,
      ingredientList: [
        '200g Tahu Putih Sutra',
        '2 butir Telur Ayam',
        '2 siung Bawang Putih',
        '1 batang Daun Bawang',
        '1/2 sdt Merica & Garam',
      ],
      stepList: [
        {
          'title': 'Tumis Aromatik',
          'description':
              'Tumis bawang putih halus dengan 1 sendok teh minyak sehat hingga wangi lembut.',
        },
        {
          'title': 'Orak-Arik Lembut',
          'description':
              'Masukkan hancuran tahu dan telur kocok, masak dengan api kecil sambil diaduk perlahan hingga matang empuk.',
        },
      ],
    ),
    _RecipeData(
      title: 'Sambal Goreng Tahu Telur',
      matchedWith: 'Tahu, Telur, Cabai',
      calories: 350,
      matchPercent: 75,
      imageAsset: 'assets/images/recipes/sambal_goreng.jpg',
      isDiet: false,
      stepsCount: 4,
      portions: 2,
      rating: 4.8,
      reviewCount: 110,
      proteinGrams: 22,
      carbsGrams: 12,
      fatGrams: 15,
      fiberGrams: 4,
      sugarGrams: 3,
      ingredientList: [
        '250g Tahu Kuning',
        '3 butir Telur Rebus',
        '6 buah Cabai Merah',
        '4 siung Bawang Merah',
        '2 siung Bawang Putih',
        '2 sdm Kecap Manis',
        '1/2 sdt Garam & Gula',
      ],
      stepList: [
        {
          'title': 'Goreng Tahu & Telur',
          'description':
              'Goreng tahu dan telur rebus sebentar hingga berkulit tipis.',
        },
        {
          'title': 'Tumis Bumbu Sambal',
          'description':
              'Haluskan cabai dan bawang, tumis hingga minyak kemerahan keluar dan matang.',
        },
        {
          'title': 'Pematangan Sambal Goreng',
          'description':
              'Masukkan tahu dan telur ke dalam sambal, tambahkan kecap manis dan garam, masak hingga bumbu meresap.',
        },
        {
          'title': 'Penyajian Hangat',
          'description':
              'Angkat dan sajikan bersama taburan bawang goreng selagi hangat.',
        },
      ],
    ),
  ];

  List<String> get _activeIngredients {
    if (widget.selectedIngredients != null && widget.selectedIngredients!.isNotEmpty) {
      return widget.selectedIngredients!;
    }
    return _defaultIngredients;
  }

  void _openRecipeDetail(_RecipeData recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailPanduanMasakPage(
          title: recipe.title,
          imageAsset: recipe.imageAsset,
          calories: recipe.calories,
          portions: recipe.portions,
          isDiet: recipe.isDiet,
          rating: recipe.rating,
          reviewCount: recipe.reviewCount,
          ingredientList: recipe.ingredientList,
          stepList: recipe.stepList,
          userIngredients: _activeIngredients,
          proteinGrams: recipe.proteinGrams,
          carbsGrams: recipe.carbsGrams,
          fatGrams: recipe.fatGrams,
          fiberGrams: recipe.fiberGrams,
          sugarGrams: recipe.sugarGrams,
        ),
      ),
    );
  }

  void _showCookingModal(_RecipeData recipe) {
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
                      _openRecipeDetail(recipe);
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

  @override
  Widget build(BuildContext context) {
    final ingredients = _activeIngredients;

    return Scaffold(
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
                  ...List.generate(_recipes.length, (i) {
                    final r = _recipes[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => _openRecipeDetail(r),
                        child: RecommendationCard(
                          title: r.title,
                          matchedWith: r.matchedWith,
                          calories: r.calories,
                          matchPercent: r.matchPercent,
                          stepsCount: r.stepsCount,
                          isDiet: r.isDiet,
                          imageAsset: r.imageAsset,
                          bookmarked: _bookmarked.contains(r.title),
                          onBookmarkTap: () => setState(() {
                            if (_bookmarked.contains(r.title)) {
                              _bookmarked.remove(r.title);
                            } else {
                              _bookmarked.add(r.title);
                            }
                          }),
                          onCookTap: () => _showCookingModal(r),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
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
