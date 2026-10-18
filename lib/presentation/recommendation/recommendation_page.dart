import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import 'widgets/recommendation_card.dart';

class _RecipeData {
  const _RecipeData({
    required this.title,
    required this.matchedWith,
    this.extraNote,
    this.isMissingNote = false,
    required this.calories,
    required this.matchPercent,
    required this.imageAsset,
  });

  final String title;
  final String matchedWith;
  final String? extraNote;
  final bool isMissingNote;
  final int calories;
  final int matchPercent;
  final String imageAsset;
}

/// Halaman Rekomendasi Resep hasil dari input bahan.
/// Tampilan disesuaikan 100% dengan mockup SmartCook:
/// Header SmartCook + avatar, badge "X Bahan Tersedia", chips bahan,
/// 3 kartu resep dengan badge cocok & kalori, serta card "Punya bahan lain di rumah?".
class RecommendationPage extends StatefulWidget {
  const RecommendationPage({
    super.key,
    this.selectedIngredients,
    this.onAddIngredients,
  });

  /// Daftar bahan terpilih dari halaman input bahan.
  /// Jika kosong/null, akan memakai daftar default sesuai mockup.
  final List<String>? selectedIngredients;

  /// Callback saat user menekan tombol tambah bahan ("+" chip atau card bawah)
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
    ),
    _RecipeData(
      title: 'Orak-Arik Telur Tahu Sehat',
      matchedWith: 'Tahu, Telur, Bawang',
      extraNote: 'butuh sedikit garam',
      isMissingNote: false,
      calories: 220,
      matchPercent: 85,
      imageAsset: 'assets/images/recipes/orak_arik_telur_tahu.jpeg',
    ),
    _RecipeData(
      title: 'Sambal Goreng Tahu Telur',
      matchedWith: 'Tahu, Telur, Cabai',
      extraNote: 'Kurang: Tomat',
      isMissingNote: true,
      calories: 350,
      matchPercent: 75,
      imageAsset: 'assets/images/recipes/sambal_goreng.jpg',
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
            // ── Top Header: Logo SmartCook + Avatar Profil ──
            _buildTopBar(),

            // ── Scrollable Body ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  // 1. Title + Badge Bahan Tersedia
                  _buildHeadlineRow(ingredients.length),
                  const SizedBox(height: 14),

                  // 2. Horizontal Chips Bahan Terpilih
                  _buildIngredientsChips(ingredients),
                  const SizedBox(height: 20),

                  // 3. Daftar Kartu Rekomendasi Resep
                  ...List.generate(_recipes.length, (i) {
                    final r = _recipes[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RecommendationCard(
                        title: r.title,
                        matchedWith: r.matchedWith,
                        extraNote: r.extraNote,
                        isMissingNote: r.isMissingNote,
                        calories: r.calories,
                        matchPercent: r.matchPercent,
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

                  // 4. Card "Punya bahan lain di rumah?"
                  _buildAddMorePromptCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Bar dengan logo SmartCook di kiri dan Avatar di kanan
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

  /// Headline: "Rekomendasi untukmu" dan Badge "X Bahan Tersedia"
  Widget _buildHeadlineRow(int count) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rekomendasi\nuntukmu',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  height: 1.15,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Berdasarkan bahan pilihan di kulkasmu',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8FAF1),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFC7F2DB), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF0D7C55),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count Bahan',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF08543D),
                      height: 1.15,
                    ),
                  ),
                  const Text(
                    'Tersedia',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF08543D),
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Chips bahan-bahan terpilih (horizontal scroll)
  Widget _buildIngredientsChips(List<String> ingredients) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          ...ingredients.map(
            (name) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FAF1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFB5EAD0), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check,
                      size: 14,
                      color: Color(0xFF0D7C55),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF08543D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tombol '+' untuk tambah bahan lain
          GestureDetector(
            key: const ValueKey('add_ingredient_chip_button'),
            onTap: widget.onAddIngredients,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu bagian bawah: "Punya bahan lain di rumah?"
  Widget _buildAddMorePromptCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCDEFE0), width: 1.2),
      ),
      child: Column(
        children: [
          // Icon Kulkas
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.kitchen_outlined,
                size: 26,
                color: Color(0xFF084E38),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Title
          const Text(
            'Punya bahan lain di rumah?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          const Text(
            'Tambahkan bumbu atau sisa sayuran di kulkas untuk membuka lebih banyak pilihan masakan lezat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          // Outlined Button "+ Tambah Bahan Masakan"
          InkWell(
            onTap: widget.onAddIngredients,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF6EE7B7), width: 1.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Color(0xFF084E38), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Tambah Bahan Masakan',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: Color(0xFF084E38),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
