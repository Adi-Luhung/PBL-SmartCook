import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/text_utils.dart';
import '../../data/models.dart';
import '../../providers/app_providers.dart';

class _IngredientItem {
  const _IngredientItem({
    required this.name,
    required this.assetPath,
    required this.icon,
    this.isDiet = true,
  });

  final String name;
  final String assetPath;
  final IconData icon;
  final bool isDiet;
}

class _CategoryGroup {
  const _CategoryGroup({
    required this.title,
    required this.indicatorColor,
    required this.items,
  });

  final String title;
  final Color indicatorColor;
  final List<_IngredientItem> items;
}

const _allCategories = [
  _CategoryGroup(
    title: 'Protein & Lauk',
    indicatorColor: Color(0xFFF59E0B),
    items: [
      _IngredientItem(
        name: 'Telur Ayam',
        assetPath: 'assets/images/ingredients/telur_ayam.jpg',
        icon: Icons.egg_outlined,
        isDiet: true,
      ),
      _IngredientItem(
        name: 'Tahu Putih',
        assetPath: 'assets/images/ingredients/tahu_putih.jpg',
        icon: Icons.lunch_dining_outlined,
        isDiet: true,
      ),
      _IngredientItem(
        name: 'Tempe',
        assetPath: 'assets/images/ingredients/tempe.jpg',
        icon: Icons.breakfast_dining_outlined,
        isDiet: true,
      ),
      _IngredientItem(
        name: 'Daging Ayam',
        assetPath: 'assets/images/ingredients/daging_ayam.jpg',
        icon: Icons.set_meal_outlined,
        isDiet: true,
      ),
    ],
  ),
  _CategoryGroup(
    title: 'Sayuran Segar',
    indicatorColor: Color(0xFF14B8A6),
    items: [
      _IngredientItem(
        name: 'Kangkung',
        assetPath: 'assets/images/ingredients/kangkung.jpg',
        icon: Icons.eco_outlined,
        isDiet: true,
      ),
      _IngredientItem(
        name: 'Bayam Hijau',
        assetPath: 'assets/images/ingredients/bayam.jpg',
        icon: Icons.eco_outlined,
        isDiet: true,
      ),
      _IngredientItem(
        name: 'Wortel',
        assetPath: 'assets/images/ingredients/kangkung.jpg',
        icon: Icons.spa_outlined,
        isDiet: true,
      ),
      _IngredientItem(
        name: 'Tomat',
        assetPath: 'assets/images/ingredients/cabai_rawit.jpg',
        icon: Icons.circle_outlined,
        isDiet: true,
      ),
    ],
  ),
  _CategoryGroup(
    title: 'Bumbu Dapur',
    indicatorColor: Color(0xFF10B981),
    items: [
      _IngredientItem(
        name: 'Bawang Merah',
        assetPath: 'assets/images/ingredients/bawang_merah.jpg',
        icon: Icons.circle_outlined,
        isDiet: false,
      ),
      _IngredientItem(
        name: 'Cabai Rawit',
        assetPath: 'assets/images/ingredients/cabai_rawit.jpg',
        icon: Icons.local_fire_department_outlined,
        isDiet: false,
      ),
      _IngredientItem(
        name: 'Bawang Putih',
        assetPath: 'assets/images/ingredients/bawang_putih.jpg',
        icon: Icons.circle_outlined,
        isDiet: false,
      ),
      _IngredientItem(
        name: 'Garam & Merica',
        assetPath: 'assets/images/ingredients/bawang_putih.jpg',
        icon: Icons.grain_outlined,
        isDiet: false,
      ),
    ],
  ),
];

// ── Katalog dari database ───────────────────────────────────────────────────

const _categoryOrder = [
  'Protein & Lauk',
  'Sayuran',
  'Bumbu & Rempah',
  'Saus & Penyedap',
  'Karbohidrat & Tepung',
  'Susu & Olahan',
  'Kacang, Biji & Kelapa',
  'Buah',
  'Minyak & Lemak',
  'Bahan Dasar',
  'Lainnya',
];

const _categoryColors = <String, Color>{
  'Protein & Lauk': Color(0xFFF59E0B),
  'Sayuran': Color(0xFF14B8A6),
  'Bumbu & Rempah': Color(0xFF10B981),
  'Saus & Penyedap': Color(0xFFEF4444),
  'Karbohidrat & Tepung': Color(0xFFA855F7),
  'Susu & Olahan': Color(0xFF3B82F6),
  'Kacang, Biji & Kelapa': Color(0xFF92400E),
  'Buah': Color(0xFFF97316),
  'Minyak & Lemak': Color(0xFFEAB308),
  'Bahan Dasar': Color(0xFF64748B),
  'Lainnya': Color(0xFF94A3B8),
};

const _categoryIcons = <String, IconData>{
  'Protein & Lauk': Icons.set_meal_outlined,
  'Sayuran': Icons.eco_outlined,
  'Bumbu & Rempah': Icons.spa_outlined,
  'Saus & Penyedap': Icons.water_drop_outlined,
  'Karbohidrat & Tepung': Icons.rice_bowl_outlined,
  'Susu & Olahan': Icons.local_drink_outlined,
  'Kacang, Biji & Kelapa': Icons.grain_outlined,
  'Buah': Icons.local_grocery_store_outlined,
  'Minyak & Lemak': Icons.opacity,
  'Bahan Dasar': Icons.kitchen_outlined,
  'Lainnya': Icons.restaurant_outlined,
};

/// Kategori yang dianggap "Diet Sehat" untuk filter tab (pola yang sama dengan
/// desain awal: protein & sayur ya, bumbu/saus tidak).
const _dietCategories = {'Protein & Lauk', 'Sayuran', 'Buah'};

/// Foto bahan yang sudah ada di assets (nama baku di database -> berkas).
const _knownAssets = <String, String>{
  'telur': 'telur_ayam.jpg',
  'tahu': 'tahu_putih.jpg',
  'tempe': 'tempe.jpg',
  'ayam': 'daging_ayam.jpg',
  'kangkung': 'kangkung.jpg',
  'bayam': 'bayam.jpg',
  'bawang merah': 'bawang_merah.jpg',
  'bawang putih': 'bawang_putih.jpg',
  'cabai rawit': 'cabai_rawit.jpg',
};

List<_CategoryGroup> _groupsFrom(List<CatalogIngredient> catalog) {
  final byCategory = <String, List<_IngredientItem>>{};
  for (final i in catalog) {
    final asset = _knownAssets[i.name];
    byCategory
        .putIfAbsent(i.category, () => [])
        .add(
          _IngredientItem(
            name: titleCase(i.name),
            assetPath:
                'assets/images/ingredients/${asset ?? '${i.name.replaceAll(' ', '_')}.jpg'}',
            icon: _categoryIcons[i.category] ?? Icons.restaurant_outlined,
            isDiet: _dietCategories.contains(i.category),
          ),
        );
  }
  final titles = [
    ..._categoryOrder.where(byCategory.containsKey),
    ...byCategory.keys.where((k) => !_categoryOrder.contains(k)),
  ];
  return [
    for (final t in titles)
      _CategoryGroup(
        title: t,
        indicatorColor: _categoryColors[t] ?? const Color(0xFF94A3B8),
        items: byCategory[t]!, // sudah terurut populer dulu dari query
      ),
  ];
}

/// Halaman Input Bahan Makanan & Masakan sesuai desain mockup Figma/SmartCook.
class InputBahanPage extends ConsumerStatefulWidget {
  const InputBahanPage({super.key, this.onSearchRecipes});

  final VoidCallback? onSearchRecipes;

  @override
  ConsumerState<InputBahanPage> createState() => _InputBahanPageState();
}

class _InputBahanPageState extends ConsumerState<InputBahanPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selected = {};
  bool _searching = false;

  // State untuk filter dan expand/collapse
  int _activeDietTab = 0; // 0 = Semua, 1 = Diet Sehat
  String _activeCategoryFilter = 'Semua Kategori';
  String _searchQuery = '';

  bool _isBahanTerpilihExpanded = true;
  final Map<String, bool> _expandedCategories = {'Protein & Lauk': true};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleIngredient(String name) {
    setState(() {
      if (_selected.contains(name)) {
        _selected.remove(name);
      } else {
        _selected.add(name);
      }
    });
  }

  void _removeIngredient(String name) {
    setState(() {
      _selected.remove(name);
    });
  }

  void _clearAllSelected() {
    setState(() {
      _selected.clear();
    });
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? AppColors.danger : AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  /// Enter di kolom pencarian: cocokkan teks (termasuk sinonim/typo) ke bahan
  /// baku di database, lalu tambahkan sebagai bahan terpilih.
  Future<void> _addTyped() async {
    final text = _searchController.text.trim();
    if (text.isEmpty) return;
    try {
      final hit = await ref.read(recipeRepositoryProvider).findIngredient(text);
      if (!mounted) return;
      if (hit == null) {
        _snack('Bahan "$text" tidak dikenali.', error: true);
        return;
      }
      final name = titleCase(hit.name);
      setState(() => _selected.add(name));
      _searchController.clear();
      _snack('Ditambahkan: $name');
    } catch (_) {
      if (mounted) _snack('Gagal mencari bahan. Periksa koneksi.', error: true);
    }
  }

  /// Tombol "Cari Resep": ubah nama bahan jadi ID, simpan ke provider,
  /// lalu pindah ke tab Rekomendasi.
  Future<void> _search() async {
    if (_selected.isEmpty) {
      _snack('Pilih minimal satu bahan dulu.', error: true);
      return;
    }
    setState(() => _searching = true);
    try {
      final names = _selected.toList();
      final ids = await ref
          .read(recipeRepositoryProvider)
          .resolveIngredientIds(names);
      if (!mounted) return;
      if (ids.isEmpty) {
        _snack('Bahan yang dipilih belum dikenali.', error: true);
        return;
      }
      ref
          .read(searchQueryProvider.notifier)
          .set(SearchQuery(names: names, ids: ids));
      widget.onSearchRecipes?.call();
    } catch (_) {
      if (mounted) _snack('Gagal mencari resep. Periksa koneksi.', error: true);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter kategori berdasarkan filter tab horizontal
    final catalog = ref.watch(ingredientCatalogProvider);
    // Daftar bahan dari database; kalau gagal dimuat, pakai daftar bawaan.
    final List<_CategoryGroup> allCategories = catalog.when(
      data: _groupsFrom,
      loading: () => const <_CategoryGroup>[],
      error: (_, __) => _allCategories,
    );

    final displayedCategories = allCategories.where((category) {
      if (_activeCategoryFilter != 'Semua Kategori' &&
          category.title != _activeCategoryFilter) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  // 1. Header (Logo SmartCook di kanan atas)
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // 2. Search Field
                  _buildSearchBar(),
                  const SizedBox(height: 14),

                  // 3. Filter Pills (Semua vs Diet Sehat)
                  _buildDietFilterPills(),
                  const SizedBox(height: 16),

                  // 4. Kartu Bahan Terpilih
                  if (_selected.isNotEmpty) ...[
                    _buildBahanTerpilihCard(),
                    const SizedBox(height: 16),
                  ],

                  // 5. Category Filter Chips (Horizontal)
                  _buildCategoryFilterRow(
                    allCategories.map((c) => c.title).toList(),
                  ),
                  const SizedBox(height: 16),

                  if (catalog.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // 6. Accordion per Kategori
                  ...displayedCategories.map(
                    (category) => _buildCategorySection(category),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // 7. Tombol Bottom CTA "Cari Resep"
            _buildBottomCta(),
          ],
        ),
      ),
    );
  }

  /// Header dengan Title & Logo SmartCook di kanan
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'Bahan dan Masakan',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -0.3,
                ),
              ),
            ),
            _buildSmartCookLogo(),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Pilih bahan makanan yang tersedia, kami temukan resep lezat untukmu.',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            color: Color(0xFF6B7280),
            height: 1.35,
          ),
        ),
      ],
    );
  }

  /// Logo SmartCook teks "SmartCook" dengan warna kontras
  Widget _buildSmartCookLogo() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
        children: [
          TextSpan(
            text: 'Smart',
            style: TextStyle(color: Color(0xFF111827)),
          ),
          TextSpan(
            text: 'Cook',
            style: TextStyle(color: Color(0xFF0C6B4E)),
          ),
        ],
      ),
    );
  }

  /// Search Bar dengan rounded corners dan icon search
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _addTyped(),
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 14,
          color: Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: 'Ketik nama bahan lalu Enter (misal: telur, tahu)',
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
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Segmented Control Pills: "Semua" vs "Diet Sehat"
  Widget _buildDietFilterPills() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDietPillItem(
              label: 'Semua',
              isSelected: _activeDietTab == 0,
              onTap: () => setState(() => _activeDietTab = 0),
            ),
          ),
          Expanded(
            child: _buildDietPillItem(
              label: 'Diet Sehat',
              isSelected: _activeDietTab == 1,
              onTap: () => setState(() => _activeDietTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietPillItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: const Color(0xFFE2E8F0), width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF0E6E4E)
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  /// Kartu Bahan Terpilih yang bisa di-expand/collapse
  Widget _buildBahanTerpilihCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          InkWell(
            onTap: () => setState(
              () => _isBahanTerpilihExpanded = !_isBahanTerpilihExpanded,
            ),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Text(
                    'BAHAN TERPILIH',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_selected.length}',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isBahanTerpilihExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF6B7280),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // Konten Body saat expanded
          if (_isBahanTerpilihExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selected.map((item) {
                  return Container(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 6,
                      top: 6,
                      bottom: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF00B074),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0E6E4E),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeIngredient(item),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFF0E6E4E),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Footer: Info jumlah & Hapus Semua
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selected.length} bahan aktif dipilih',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  InkWell(
                    onTap: _clearAllSelected,
                    borderRadius: BorderRadius.circular(4),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Hapus Semua',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Kategori Filter Chips Horizontal ("Semua Kategori", "Protein & Lauk", dsb.)
  Widget _buildCategoryFilterRow(List<String> titles) {
    final categories = ['Semua Kategori', ...titles];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _activeCategoryFilter == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _activeCategoryFilter = cat),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Bagian Accordion tiap Kategori (Protein & Lauk, Sayuran Segar, Bumbu Dapur)
  Widget _buildCategorySection(_CategoryGroup category) {
    // Filter bahan jika pencarian aktif atau tab Diet Sehat aktif
    final filteredItems = category.items.where((item) {
      if (_searchQuery.isNotEmpty &&
          !item.name.toLowerCase().contains(_searchQuery)) {
        return false;
      }
      if (_activeDietTab == 1 && !item.isDiet) {
        return false;
      }
      return true;
    }).toList();

    if (filteredItems.isEmpty && _searchQuery.isNotEmpty) {
      return const SizedBox.shrink();
    }

    // Saat mencari, semua kategori yang punya hasil otomatis terbuka.
    final isExpanded =
        _searchQuery.isNotEmpty ||
        (_expandedCategories[category.title] ?? false);
    final selectedInCat = category.items
        .where((item) => _selected.contains(item.name))
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Accordion Kategori
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategories[category.title] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Dot Indikator berwarna
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: category.indicatorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Judul Kategori
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Badge jumlah bahan / dipilih
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: selectedInCat > 0
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      selectedInCat > 0
                          ? '$selectedInCat dipilih'
                          : '${category.items.length} bahan',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: selectedInCat > 0
                            ? const Color(0xFF065F46)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF6B7280),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // Grid Card Bahan saat Expanded
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: _buildIngredientsGrid(filteredItems),
            ),
          ],
        ],
      ),
    );
  }

  /// Grid 2 kolom kartu bahan makanan
  Widget _buildIngredientsGrid(List<_IngredientItem> items) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final item1 = items[i];
      final item2 = (i + 1 < items.length) ? items[i + 1] : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(child: _buildIngredientCard(item1)),
              const SizedBox(width: 10),
              Expanded(
                child: item2 != null
                    ? _buildIngredientCard(item2)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  /// Kartu Bahan Makanan sesuai persis dengan mockup
  Widget _buildIngredientCard(_IngredientItem item) {
    final isSelected = _selected.contains(item.name);

    return InkWell(
      onTap: () => _toggleIngredient(item.name),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00B074)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bagian Foto Bahan + Checkbox di pojok kanan atas
              Stack(
                children: [
                  SizedBox(
                    height: 105,
                    width: double.infinity,
                    child: Image.asset(
                      item.assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF3F4F6),
                          child: Center(
                            child: Icon(
                              item.icon,
                              size: 40,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Checkmark / Indicator di pojok kanan atas
                  Positioned(
                    top: 8,
                    right: 8,
                    child: isSelected
                        ? Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00B074),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 15,
                              color: Colors.white,
                            ),
                          )
                        : Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                width: 1.5,
                              ),
                            ),
                          ),
                  ),
                ],
              ),

              // Bagian Label Nama Bahan
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tombol Bottom CTA "Cari Resep"
  Widget _buildBottomCta() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _searching ? null : _search,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF08543D),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _searching
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Cari Resep',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
