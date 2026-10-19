import 'package:flutter/material.dart';

import '../../core/services/bookmark_service.dart';
import '../../core/services/ingredient_service.dart';
import '../../core/theme/app_text_styles.dart';
import '../profile/profile_page.dart';

class RecipeReview {
  const RecipeReview({
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.isVerified = false,
    this.helpfulCount = 0,
  });

  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final String date;
  final bool isVerified;
  final int helpfulCount;
}

class DetailPanduanMasakPage extends StatefulWidget {
  const DetailPanduanMasakPage({
    super.key,
    required this.title,
    this.imageUrl,
    this.imageAsset,
    this.calories = 380,
    this.portions = 2,
    this.isDiet = false,
    this.rating = 4.8,
    this.reviewCount = 142,
    this.reviews = const [],
    this.ingredientList = const [],
    this.stepList = const [],
    this.userIngredients,
    this.proteinGrams = 30,
    this.carbsGrams = 14,
    this.fatGrams = 12,
    this.fiberGrams = 4,
    this.sugarGrams = 3,
  });

  final String title;
  final String? imageUrl;
  final String? imageAsset;
  final int calories;
  final int portions;
  final bool isDiet;
  final double rating;
  final int reviewCount;
  final List<RecipeReview> reviews;
  final List<String> ingredientList;
  final List<Map<String, String>> stepList;
  final List<String>? userIngredients;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final int fiberGrams;
  final int sugarGrams;

  @override
  State<DetailPanduanMasakPage> createState() => _DetailPanduanMasakPageState();
}

class _DetailPanduanMasakPageState extends State<DetailPanduanMasakPage> {
  final Set<int> _helpfulReviews = {};

  @override
  void initState() {
    super.initState();
    IngredientService.instance.addListener(_onIngredientsChanged);
  }

  @override
  void dispose() {
    IngredientService.instance.removeListener(_onIngredientsChanged);
    super.dispose();
  }

  void _onIngredientsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<String> get _currentUserIngredients {
    if (widget.userIngredients != null && widget.userIngredients!.isNotEmpty) {
      return widget.userIngredients!;
    }
    return IngredientService.instance.selectedIngredients;
  }

  List<String> get _resolvedIngredients {
    if (widget.ingredientList.isNotEmpty) {
      return widget.ingredientList;
    }
    return const [
      '250g Dada Ayam Fillet',
      '3 siung Bawang Putih',
      '2 batang Daun Bawang',
      '1 buah Tomat Segar',
      '2 sdm Kecap Manis Kental',
      '1 sdm Kecap Asin Rendah Natrium',
      '1 sdt Minyak Wijen Murni',
      '1/2 sdt Merica & Garam Halus',
    ];
  }

  List<Map<String, String>> get _resolvedSteps {
    if (widget.stepList.isNotEmpty) {
      return widget.stepList;
    }
    return const [
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
        'tag': 'Sajikan Langsung',
        'description':
            'Angkat dari wajan dan sajikan selagi hangat mengepul bersama nasi putih pulen hangat atau quinoa sehat favorit keluarga. Selamat menikmati santapan buatan sendiri!',
      },
    ];
  }

  List<RecipeReview> get _resolvedReviews {
    if (widget.reviews.isNotEmpty) {
      return widget.reviews;
    }
    return const [
      RecipeReview(
        userName: 'Siti Rahma',
        rating: 5.0,
        comment:
            'Resepnya pas banget dan praktis buat makan siang keluarga! Tips: tambahin sedikit cabai rawit kalau suka pedas.',
        date: '2 hari lalu',
        isVerified: true,
        helpfulCount: 24,
      ),
    ];
  }

  bool _isKnownMatch(String recipe, String user) {
    if (user.contains('ayam')) {
      if (recipe.contains('ayam')) return true;
    }
    if (user.contains('telur')) {
      if (recipe.contains('telur')) return true;
    }
    if (user.contains('tahu')) {
      if (recipe.contains('tahu')) return true;
    }
    if (user.contains('tempe')) {
      if (recipe.contains('tempe')) return true;
    }
    if (user.contains('bawang putih')) {
      if (recipe.contains('bawang putih')) return true;
    }
    if (user.contains('bawang merah')) {
      if (recipe.contains('bawang merah')) return true;
    }
    if (user.contains('daun bawang')) {
      if (recipe.contains('daun bawang') || recipe.contains('bawang daun')) {
        return true;
      }
    }
    if (user == 'bawang') {
      if (recipe.contains('bawang')) return true;
    }
    if (user.contains('cabai') || user.contains('cabe')) {
      if (recipe.contains('cabai') || recipe.contains('cabe')) return true;
    }
    if (user.contains('tomat')) {
      if (recipe.contains('tomat')) return true;
    }
    if (user.contains('wortel')) {
      if (recipe.contains('wortel')) return true;
    }
    if (user.contains('kangkung')) {
      if (recipe.contains('kangkung')) return true;
    }
    if (user.contains('bayam')) {
      if (recipe.contains('bayam')) return true;
    }
    if (user.contains('kecap manis')) {
      if (recipe.contains('kecap manis')) return true;
    }
    if (user.contains('kecap asin')) {
      if (recipe.contains('kecap asin')) return true;
    }
    if (user.contains('minyak wijen')) {
      if (recipe.contains('minyak wijen')) return true;
    }
    if (user.contains('minyak')) {
      if (recipe.contains('minyak') && !recipe.contains('minyak wijen')) {
        return true;
      }
    }
    if (user.contains('garam') ||
        user.contains('merica') ||
        user.contains('lada')) {
      if (recipe.contains('garam') ||
          recipe.contains('merica') ||
          recipe.contains('lada')) {
        return true;
      }
    }
    if (user.contains('saus tiram')) {
      if (recipe.contains('saus tiram')) return true;
    }
    if (user.contains('jahe')) {
      if (recipe.contains('jahe')) return true;
    }
    return false;
  }

  bool _isAvailable(String ingredientName) {
    final recipeLower = ingredientName.toLowerCase().trim();
    final users = _currentUserIngredients;
    for (final raw in users) {
      final userLower = raw.toLowerCase().trim();
      if (userLower.isEmpty) continue;
      if (recipeLower == userLower) return true;
      if (_isKnownMatch(recipeLower, userLower)) return true;
    }
    return false;
  }

  bool _isSeasoning(String name) {
    final lower = name.toLowerCase();
    return lower.contains('kecap') ||
        lower.contains('saus') ||
        lower.contains('minyak') ||
        lower.contains('garam') ||
        lower.contains('merica') ||
        lower.contains('lada') ||
        lower.contains('gula') ||
        lower.contains('kaldu') ||
        lower.contains('wijen') ||
        lower.contains('rempah') ||
        lower.contains('cuka');
  }

  String _getIngredientNote(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dada ayam') || lower.contains('fillet')) {
      return 'Potong dadu 2 cm rapi';
    }
    if (lower.contains('ayam')) {
      return 'Potong dadu daging segar';
    }
    if (lower.contains('bawang putih')) {
      return 'Cincang halus wangi aromatik';
    }
    if (lower.contains('daun bawang')) {
      return 'Iris serong tebal renyah';
    }
    if (lower.contains('tomat')) {
      return 'Potong 6 bagian wedges juicy';
    }
    if (lower.contains('kecap manis')) {
      return 'Karamelisasi gurih manis alami';
    }
    if (lower.contains('kecap asin')) {
      return 'Asin gurih umami';
    }
    if (lower.contains('minyak wijen')) {
      return 'Aroma harum khas masakan asia';
    }
    if (lower.contains('merica') || lower.contains('garam')) {
      return 'Penyeimbang rasa gurih seimbang';
    }
    if (lower.contains('wortel')) {
      return 'Iris tipis bulat serasi';
    }
    if (lower.contains('brokoli')) {
      return 'Potong perkuntum segar';
    }
    if (lower.contains('telur')) {
      return 'Rebus matang sempurna';
    }
    if (lower.contains('tahu')) {
      return 'Potong dadu lembut';
    }
    if (lower.contains('tempe')) {
      return 'Iris tipis goreng gurih';
    }
    if (lower.contains('kangkung') || lower.contains('bayam')) {
      return 'Petik daun segar dicuci bersih';
    }
    if (lower.contains('saus tiram')) {
      return 'Saus kental gurih lezat';
    }
    return 'Bahan segar pilihan masakan';
  }

  void _toggleBookmark() {
    BookmarkService.instance.toggleBookmark(
      SavedRecipe(
        name: widget.title,
        time: '${_resolvedSteps.length * 5} Menit',
        ingredients: '${_resolvedIngredients.length} Bahan',
        imageUrl: widget.imageUrl,
        imageAsset: widget.imageAsset,
        calories: widget.calories,
        isDiet: widget.isDiet,
        portions: widget.portions,
        ingredientList: _resolvedIngredients,
        stepList: _resolvedSteps,
      ),
    );
    setState(() {});
  }

  Widget _buildHeader(BuildContext context) {
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  size: 22,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Detail Resep',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF084E38),
                shape: BoxShape.circle,
              ),
              child: const Icon(
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

  Widget _buildHeroCard(int availableCount, int totalCount) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.imageUrl != null)
            Image.network(
              widget.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  widget.imageAsset != null
                      ? Image.asset(widget.imageAsset!, fit: BoxFit.cover)
                      : Container(color: const Color(0xFF1E293B)),
            )
          else if (widget.imageAsset != null)
            Image.asset(widget.imageAsset!, fit: BoxFit.cover)
          else
            Container(color: const Color(0xFF1E293B)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.40, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$availableCount dari $totalCount Bahan Siap',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.isDiet
                            ? const Color(0xFF059669)
                            : const Color(0xFF5A2A0C).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.isDiet ? 'Diet Sehat' : 'Non-Diet',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: widget.isDiet
                              ? Colors.white
                              : const Color(0xFFFDE68A),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.rating} • ${widget.reviewCount} Ulasan',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortionsAndCaloriesCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.restaurant_rounded,
                      size: 20,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.portions}',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Porsi',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: const Color(0xFFF1F5F9),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 20,
                      color: Color(0xFFF97316),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.calories}',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'kkal / porsi',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.eco_rounded,
                    size: 18,
                    color: Color(0xFF059669),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Estimasi Nilai Gizi',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Per Porsi (150g)',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF059669),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Protein (Tinggi)',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                '${widget.proteinGrams}g | 70% AKG',
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.70,
              minHeight: 6,
              backgroundColor: Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF084E38)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildNutritionMiniBox('Karbo', '${widget.carbsGrams}g'),
              const SizedBox(width: 8),
              _buildNutritionMiniBox('Lemak', '${widget.fatGrams}g'),
              const SizedBox(width: 8),
              _buildNutritionMiniBox('Serat', '${widget.fiberGrams}g'),
              const SizedBox(width: 8),
              _buildNutritionMiniBox('Gula', '${widget.sugarGrams}g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionMiniBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1B4B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySummaryBanner(
      int availableCount, int unavailableCount, int totalCount, int percent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.kitchen_rounded,
              color: Color(0xFF065F46),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$availableCount dari $totalCount Bahan Tersedia',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF064E38),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unavailableCount == 0
                      ? 'Semua bahan lengkap siap dimasak!'
                      : 'Sebagian bahan siap, $unavailableCount bumbu perlu disiapkan.',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF084E38),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$percent% Siap',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(int availableCount, int unavailableCount) {
    final ingredients = _resolvedIngredients;
    final freshIngredients =
        ingredients.where((i) => !_isSeasoning(i)).toList();
    final seasonings = ingredients.where((i) => _isSeasoning(i)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bahan Utama',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${ingredients.length} Bahan',
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4338CA),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '$availableCount tersedia • $unavailableCount perlu disiapkan',
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 16),
        if (freshIngredients.isNotEmpty) ...[
          const Row(
            children: [
              Icon(
                Icons.eco_rounded,
                size: 14,
                color: Color(0xFF059669),
              ),
              SizedBox(width: 6),
              Text(
                'BAHAN SEGAR',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF059669),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...freshIngredients.map((ing) => _buildIngredientItemRow(ing)),
          const SizedBox(height: 16),
        ],
        if (seasonings.isNotEmpty) ...[
          const Row(
            children: [
              Icon(
                Icons.takeout_dining_rounded,
                size: 14,
                color: Color(0xFFB45309),
              ),
              SizedBox(width: 6),
              Text(
                'BUMBU & SAUS',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB45309),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...seasonings.map((ing) => _buildIngredientItemRow(ing)),
        ],
      ],
    );
  }

  Widget _buildIngredientItemRow(String ingredient) {
    final available = _isAvailable(ingredient);
    final note = _getIngredientNote(ingredient);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: available
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: available
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              available ? 'Tersedia ✓' : 'Belum Tersedia ⏱',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: available
                    ? const Color(0xFF065F46)
                    : const Color(0xFF991B1B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    final steps = _resolvedSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Langkah Memasak',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${steps.length} Tahap',
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4338CA),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(steps.length, (index) {
          final step = steps[index];
          final tag = step['tag'];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFF084E38),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step['title'] ?? '',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    if (tag != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  step['description'] ?? '',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF475569),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReviewsSection() {
    final reviews = _resolvedReviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Penilaian Resep',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(
              Icons.star_rounded,
              size: 16,
              color: Color(0xFFF59E0B),
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.rating} / 5.0 • ${widget.reviewCount} ulasan',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(reviews.length, (index) {
          final review = reviews[index];
          final isHelpful = _helpfulReviews.contains(index);
          final baseHelpful =
              review.helpfulCount > 0 ? review.helpfulCount : 24;
          final currentHelpful =
              isHelpful ? baseHelpful + 1 : baseHelpful;
          final initial = review.userName.isNotEmpty
              ? review.userName
                  .split(' ')
                  .map((e) => e[0])
                  .take(2)
                  .join()
                  .toUpperCase()
              : 'U';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFA7F3D0),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        review.userName,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (starIndex) => Icon(
                          starIndex < review.rating.floor()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 16,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  review.comment,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF334155),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          if (_helpfulReviews.contains(index)) {
                            _helpfulReviews.remove(index);
                          } else {
                            _helpfulReviews.add(index);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              isHelpful
                                  ? Icons.thumb_up_rounded
                                  : Icons.thumb_up_alt_outlined,
                              size: 14,
                              color: isHelpful
                                  ? const Color(0xFF084E38)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Membantu ($currentHelpful)',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 12,
                                fontWeight: isHelpful
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isHelpful
                                    ? const Color(0xFF084E38)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      review.date,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            onPressed: () {},
            child: Text(
              'Lihat Semua ${widget.reviewCount} Ulasan →',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF084E38),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final isBookmarked = BookmarkService.instance.isBookmarked(widget.title);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            InkWell(
              onTap: _toggleBookmark,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isBookmarked
                      ? const Color(0xFFE8F7F0)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isBookmarked
                        ? const Color(0xFF084E38)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: isBookmarked
                      ? const Color(0xFF084E38)
                      : const Color(0xFF64748B),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Selamat! Anda telah menyelesaikan resep ini.'),
                        backgroundColor: Color(0xFF084E38),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF084E38),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Selesai Memasak',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = _resolvedIngredients;
    final totalCount = ingredients.length;
    final availableCount = ingredients.where((i) => _isAvailable(i)).length;
    final unavailableCount = totalCount - availableCount;
    final percent =
        totalCount > 0 ? ((availableCount / totalCount) * 100).round() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _buildHeroCard(availableCount, totalCount),
                  const SizedBox(height: 16),
                  _buildPortionsAndCaloriesCard(),
                  const SizedBox(height: 16),
                  _buildNutritionCard(),
                  const SizedBox(height: 16),
                  _buildAvailabilitySummaryBanner(
                    availableCount,
                    unavailableCount,
                    totalCount,
                    percent,
                  ),
                  const SizedBox(height: 20),
                  _buildIngredientsSection(availableCount, unavailableCount),
                  const SizedBox(height: 24),
                  _buildStepsSection(),
                  const SizedBox(height: 24),
                  _buildReviewsSection(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }
}
