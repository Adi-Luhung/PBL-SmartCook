import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
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
  });

  final String title;
  final String matchedWith;
  final int calories;
  final int matchPercent;
  final String imageAsset;
  final bool isDiet;
  final int stepsCount;
}

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({
    super.key,
    this.selectedIngredients,
    this.onAddIngredients,
  });

  final List<String>? selectedIngredients;
  final VoidCallback? onAddIngredients;

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  final Set<String> _bookmarked = {};

  static const _defaultIngredients = ['Tahu', 'Telur', 'Bawang', 'Cabai'];

  static const _recipes = [
    _RecipeData(
      title: 'Tahu Telur Bumbu Kecap Pedas',
      matchedWith: 'Tahu, Telur, Bawang, Cabai',
      calories: 320,
      matchPercent: 95,
      imageAsset: 'assets/images/recipes/tahu_telur_kecap.jpg',
      isDiet: false,
      stepsCount: 3,
    ),
    _RecipeData(
      title: 'Orak-Arik Telur Tahu Sehat',
      matchedWith: 'Tahu, Telur, Bawang',
      calories: 220,
      matchPercent: 85,
      imageAsset: 'assets/images/recipes/orak_arik_telur_tahu.jpeg',
      isDiet: true,
      stepsCount: 2,
    ),
    _RecipeData(
      title: 'Sambal Goreng Tahu Telur',
      matchedWith: 'Tahu, Telur, Cabai',
      calories: 350,
      matchPercent: 75,
      imageAsset: 'assets/images/recipes/sambal_goreng.jpg',
      isDiet: false,
      stepsCount: 4,
    ),
  ];

  List<String> get _activeIngredients {
    if (widget.selectedIngredients != null && widget.selectedIngredients!.isNotEmpty) {
      return widget.selectedIngredients!;
    }
    return _defaultIngredients;
  }

  void _showCookingModal(String title) {
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
                            title,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Memulai panduan memasak untuk $title!'),
                          backgroundColor: const Color(0xFF084E38),
                        ),
                      );
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
                        onCookTap: () => _showCookingModal(r.title),
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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
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
