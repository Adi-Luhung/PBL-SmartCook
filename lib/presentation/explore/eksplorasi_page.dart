import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/bookmark_service.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/nutrition.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../data/models.dart';
import '../../providers/app_providers.dart';
import '../common/actions.dart';
import '../profile/profile_page.dart';
import '../recipe/recipe_detail_loader.dart';

/// Satu resep dari database untuk ditampilkan di Eksplorasi.
class _ExploreRecipeItem {
  const _ExploreRecipeItem({
    required this.summary,
    required this.subtitle,
    required this.calories,
  });

  factory _ExploreRecipeItem.fromSummary(RecipeSummary s) => _ExploreRecipeItem(
        summary: s,
        subtitle: s.category == null
            ? '${s.totalIngredients} bahan'
            : '${titleCase(s.category!)} • ${s.totalIngredients} bahan',
        calories: caloriesPerPortion(s.kalori, s.beratG),
      );

  final RecipeSummary summary;
  final String subtitle;

  /// Perkiraan kalori per porsi (lihat core/utils/nutrition.dart).
  final int calories;

  String get title => summary.title;
  String get time => '${summary.totalSteps} Langkah';

  // Resep database belum punya foto, rating, atau ulasan.
  String? get imageUrl => null;
  String? get imageAsset => null;
  bool get hasDiet => calories > 0;
  bool get hasRating => false;
  double get rating => 0;
  int get reviewCount => 0;
}

class EksplorasiPage extends ConsumerStatefulWidget {
  const EksplorasiPage({
    super.key,
    this.onProfileTap,
    this.searchKeyword = '',
    this.searchRequestId = 0,
  });

  final VoidCallback? onProfileTap;
  final String searchKeyword;
  final int searchRequestId;

  @override
  ConsumerState<EksplorasiPage> createState() => _EksplorasiPageState();
}

class _EksplorasiPageState extends ConsumerState<EksplorasiPage> {
  /// Sesuai kolom `category` di tabel recipes.
  static const _dietDiet = 'Diet Sehat';
  static const _dietNon = 'Non-Diet';
  static const _categories = [
    'Semua', _dietDiet, _dietNon,
    'Ayam', 'Ikan', 'Sapi', 'Kambing', 'Telur', 'Tahu', 'Tempe', 'Udang',
  ];

  final _random = Random();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedCategory = 'Semua';
  String? _dietFilter; // _dietDiet | _dietNon | null
  int _mealBudget = kDefaultMealBudget;
  String _searchQuery = '';

  List<_ExploreRecipeItem> _browseItems = const [];
  List<_ExploreRecipeItem> _searchItems = const [];
  bool _loadingBrowse = true;
  bool _loadingSearch = false;
  bool _browseError = false;
  Timer? _debounce;
  int _browseSeq = 0;
  int _searchSeq = 0;

  void _openProfile() {
    if (widget.onProfileTap != null) {
      widget.onProfileTap!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBrowse(initial: true);
    if (widget.searchKeyword.trim().isNotEmpty) {
      _applyExternalSearch(widget.searchKeyword);
    }
  }

  @override
  void didUpdateWidget(covariant EksplorasiPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchRequestId != oldWidget.searchRequestId) {
      final categoryChanged = _selectedCategory != 'Semua';
      setState(() {
        _applyExternalSearch(widget.searchKeyword);
      });
      if (categoryChanged) _loadBrowse();
    }
  }

  void _applyExternalSearch(String searchKeyword) {
    final trimmedKeyword = searchKeyword.trim();
    _searchController.value = TextEditingValue(
      text: trimmedKeyword,
      selection: TextSelection.collapsed(offset: trimmedKeyword.length),
    );
    _searchQuery = trimmedKeyword;
    _selectedCategory = 'Semua';
    _scheduleSearch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String? get _categoryFilter =>
      _selectedCategory == 'Semua' ? null : _selectedCategory.toLowerCase();

  /// Diet Sehat: kalori per porsi <= anggaran per makan; Non-Diet: di atasnya.
  double? get _maxKkal => _dietFilter == _dietDiet ? _mealBudget.toDouble() : null;
  double? get _minKkal => _dietFilter == _dietNon ? _mealBudget.toDouble() : null;

  bool _isDiet(_ExploreRecipeItem r) => r.calories > 0 && r.calories <= _mealBudget;

  bool _isChipSelected(String title) {
    if (title == 'Semua') return _selectedCategory == 'Semua' && _dietFilter == null;
    if (title == _dietDiet || title == _dietNon) return _dietFilter == title;
    return _selectedCategory == title;
  }

  void _onChipTap(String title) {
    setState(() {
      if (title == 'Semua') {
        _selectedCategory = 'Semua';
        _dietFilter = null;
      } else if (title == _dietDiet || title == _dietNon) {
        _dietFilter = _dietFilter == title ? null : title;
      } else {
        _selectedCategory = _selectedCategory == title ? 'Semua' : title;
      }
      if (_searchQuery.trim().isNotEmpty) _scheduleSearch();
    });
    _loadBrowse();
  }

  /// Muat daftar resep untuk bagian "Paling Populer" dan "Rekomendasi".
  /// Posisi awal diacak supaya isinya bervariasi tiap kali dibuka.
  Future<void> _loadBrowse({bool initial = false}) async {
    final seq = ++_browseSeq;
    if (!initial) {
      setState(() {
        _loadingBrowse = true;
        _browseError = false;
      });
    }
    try {
      final repo = ref.read(recipeRepositoryProvider);
      final maxOffset = (_categoryFilter == null && _dietFilter == null) ? 5000 : 150;
      var rows = await repo.exploreRecipes(
        category: _categoryFilter,
        maxKkal: _maxKkal,
        minKkal: _minKkal,
        offset: _random.nextInt(maxOffset),
      );
      if (rows.isEmpty) {
        rows = await repo.exploreRecipes(
          category: _categoryFilter,
          maxKkal: _maxKkal,
          minKkal: _minKkal,
        );
      }
      if (!mounted || seq != _browseSeq) return;
      setState(() {
        _browseItems = rows.map(_ExploreRecipeItem.fromSummary).toList();
        _loadingBrowse = false;
        _browseError = false;
      });
    } catch (_) {
      if (!mounted || seq != _browseSeq) return;
      setState(() {
        _loadingBrowse = false;
        _browseError = true;
      });
    }
  }

  /// Jadwalkan pencarian (ditunda 350 md agar tidak memanggil server tiap ketikan).
  /// Panggil di dalam setState.
  void _scheduleSearch() {
    _debounce?.cancel();
    if (_searchQuery.trim().isEmpty) {
      _searchItems = const [];
      _loadingSearch = false;
      return;
    }
    _loadingSearch = true;
    _debounce = Timer(const Duration(milliseconds: 350), _runSearch);
  }

  Future<void> _runSearch() async {
    final query = _searchQuery.trim();
    if (query.isEmpty) return;
    final seq = ++_searchSeq;
    try {
      final rows = await ref
          .read(recipeRepositoryProvider)
          .searchRecipes(query,
              category: _categoryFilter, maxKkal: _maxKkal, minKkal: _minKkal);
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _searchItems = rows.map(_ExploreRecipeItem.fromSummary).toList();
        _loadingSearch = false;
      });
    } catch (_) {
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _searchItems = const [];
        _loadingSearch = false;
      });
    }
  }

  void _toggleBookmark(_ExploreRecipeItem recipe) {
    toggleRecipeBookmark(context, recipe.summary);
  }

  _ExploreRecipeItem? get _popularRecipe =>
      _browseItems.isEmpty ? null : _browseItems.first;

  List<_ExploreRecipeItem> get _recommendedList =>
      _browseItems.length <= 1 ? const [] : _browseItems.sublist(1);

  List<_ExploreRecipeItem> get _searchResults => _searchItems;

  void _openRecipeDetail(_ExploreRecipeItem recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailLoader(recipeId: recipe.summary.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Anggaran kalori per makan berasal dari target kalori profil (BMI/TDEE).
    _mealBudget = ref.watch(mealBudgetProvider);
    ref.listen<int>(mealBudgetProvider, (previous, next) {
      if (previous != next && _dietFilter != null) {
        _mealBudget = next;
        setState(() {
          if (_searchQuery.trim().isNotEmpty) _scheduleSearch();
        });
        _loadBrowse();
      }
    });
    return ListenableBuilder(
      listenable: BookmarkService.instance,
      builder: (context, _) {
        final popular = _popularRecipe;
        final recommended = _recommendedList;
        final isSearching = _searchQuery.trim().isNotEmpty;
        final searchResults = _searchResults;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom:
                            BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
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
                          onTap: _openProfile,
                          borderRadius: BorderRadius.circular(20),
                          child: const Tooltip(
                            message: 'Profil',
                            child: ProfileAvatar(radius: 18, iconSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        const Text(
                          'Eksplorasi Resep',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Inspirasi hidangan lezat & bernutrisi untuk Anda',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1.2,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) {
                              _searchFocusNode.unfocus();
                            },
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                                _scheduleSearch();
                              });
                            },
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14,
                              color: Color(0xFF1F2937),
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Ketik nama masakan... (misal: sop, ayam)',
                              hintStyle: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 13.5,
                                color: Color(0xFF9CA3AF),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 22,
                                color: Color(0xFF9CA3AF),
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 0; i < _categories.length; i++) ...[
                                if (i > 0) const SizedBox(width: 8),
                                _buildCategoryChip(_categories[i]),
                              ],
                            ],
                          ),
                        ),
                        if (isSearching) ...[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Hasil Pencarian',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${searchResults.length} Masakan',
                                      style: const TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF084E38),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.refresh_rounded,
                                      size: 14,
                                      color: Color(0xFF084E38),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Reset',
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
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_loadingSearch && searchResults.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 36),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (searchResults.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 36, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F5F9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.search_off_rounded,
                                      size: 30,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'Resep Tidak Ditemukan',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tidak ada resep yang cocok dengan "$_searchQuery"',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF64748B),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                    icon: const Icon(Icons.refresh_rounded,
                                        size: 16, color: Color(0xFF084E38)),
                                    label: const Text(
                                      'Tampilkan Semua Resep',
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF084E38),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...List.generate(searchResults.length, (index) {
                              final item = searchResults[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildRecommendationCard(item),
                              );
                            }),
                        ] else ...[
                          if (_loadingBrowse && _browseItems.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (popular != null) ...[

                            const SizedBox(height: 20),
                            const Text(
                              'Paling Populer',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildFeaturedCard(popular),
                          ],
                          if (recommended.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            const Text(
                              'Rekomendasi Untuk Anda',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(recommended.length, (index) {
                              final item = recommended[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildRecommendationCard(item),
                              );
                            }),
                          ],
                          if (popular == null && recommended.isEmpty && !_loadingBrowse)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.restaurant_menu_outlined,
                                    size: 48,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _browseError
                                        ? 'Gagal memuat resep. Periksa koneksi internetmu.'
                                        : 'Tidak ada resep pada kategori ini',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String title) {
    final isSelected = _isChipSelected(title);
    return GestureDetector(
      onTap: () => _onChipTap(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF084E38) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(_ExploreRecipeItem recipe) {
    final isBookmarked =
        BookmarkService.instance.isRecipeBookmarked(recipe.summary.id);
    return GestureDetector(
      onTap: () => _openRecipeDetail(recipe),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 190,
                  width: double.infinity,
                  color: const Color(0xFFE8EEFB),
                  child: recipe.imageUrl != null
                      ? Image.network(
                          recipe.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              recipe.imageAsset != null
                                  ? Image.asset(
                                      recipe.imageAsset!,
                                      fit: BoxFit.cover,
                                    )
                                  : const SizedBox.expand(),
                        )
                      : (recipe.imageAsset != null
                          ? Image.asset(
                              recipe.imageAsset!,
                              fit: BoxFit.cover,
                            )
                          : null),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _toggleBookmark(recipe),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          size: 20,
                          color: isBookmarked
                              ? const Color(0xFF084E38)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              size: 16,
                              color: Color(0xFFEA580C),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.calories} kkal',
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEA580C),
                              ),
                            ),
                            if (recipe.hasDiet) ...[const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _isDiet(recipe)
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _isDiet(recipe) ? 'Diet Sehat' : 'Non-Diet',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _isDiet(recipe)
                                      ? const Color(0xFF065F46)
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),],
                          ],
                        ),
                        if (recipe.hasRating) ...[const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.rating}',
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${recipe.reviewCount} ulasan)',
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _openRecipeDetail(recipe),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF084E38),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lihat',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 15,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(_ExploreRecipeItem recipe) {
    final isBookmarked =
        BookmarkService.instance.isRecipeBookmarked(recipe.summary.id);
    return GestureDetector(
      onTap: () => _openRecipeDetail(recipe),
      child: Container(
        padding: const EdgeInsets.all(12),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 76,
                height: 76,
                color: const Color(0xFFE8EEFB),
                child: recipe.imageUrl != null
                    ? Image.network(
                        recipe.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            recipe.imageAsset != null
                                ? Image.asset(
                                    recipe.imageAsset!,
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox.expand(),
                      )
                    : (recipe.imageAsset != null
                        ? Image.asset(
                            recipe.imageAsset!,
                            fit: BoxFit.cover,
                          )
                        : null),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.title,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleBookmark(recipe),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            size: 20,
                            color: isBookmarked
                                ? const Color(0xFF084E38)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    recipe.subtitle,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 15,
                        color: Color(0xFFEA580C),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.calories} kkal',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                      if (recipe.hasDiet) ...[const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _isDiet(recipe)
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _isDiet(recipe) ? 'Diet Sehat' : 'Non-Diet',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _isDiet(recipe)
                                ? const Color(0xFF065F46)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),],
                    ],
                  ),
                  if (recipe.hasRating) ...[const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${recipe.rating}',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '(${recipe.reviewCount} ulasan)',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
