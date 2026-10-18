import 'package:flutter/material.dart';

import '../../core/services/bookmark_service.dart';
import '../../core/theme/app_text_styles.dart';
import 'detail_resep_page.dart';


class _ExploreRecipeItem {
  const _ExploreRecipeItem({
    required this.title,
    required this.subtitle,
    required this.calories,
    this.imageUrl,
    this.imageAsset,
    this.isDiet = false,
    this.portions = 2,
    this.time = '25 Menit',
    this.rating = 4.8,
    this.reviewCount = 120,
    this.reviews = const [],
    this.ingredientList = const [],
    this.stepList = const [],
  });

  final String title;
  final String subtitle;
  final int calories;
  final String? imageUrl;
  final String? imageAsset;
  final bool isDiet;
  final int portions;
  final String time;
  final double rating;
  final int reviewCount;
  final List<RecipeReview> reviews;
  final List<String> ingredientList;
  final List<Map<String, String>> stepList;
}

class EksplorasiPage extends StatefulWidget {
  const EksplorasiPage({super.key});

  @override
  State<EksplorasiPage> createState() => _EksplorasiPageState();
}

class _EksplorasiPageState extends State<EksplorasiPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late List<_ExploreRecipeItem> _shuffledRecipes;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';


  static const _allRecipesList = [
    _ExploreRecipeItem(
      title: 'Sop Buntut Kuah Rempah Segar',
      subtitle: 'Kuah kaldu sapi kaya rempah pilihan khas nusantara',
      calories: 450,
      isDiet: false,
      portions: 3,
      time: '45 Menit',
      rating: 4.9,
      reviewCount: 312,
      reviews: [
        RecipeReview(
          userName: 'Siti Rahma',
          rating: 5.0,
          comment:
              'Bumbunya meresap sekali sampai ke serat daging, kuahnya gurih segar!',
          date: '2 hari lalu',
        ),
        RecipeReview(
          userName: 'Budi Santoso',
          rating: 4.8,
          comment:
              'Buntut sapinya empuk dan aroma rempahnya harum khas nusantara.',
          date: '5 hari lalu',
        ),
      ],
      imageUrl:
          'https://images.unsplash.com/photo-1547928576-a4a33237cbc3?w=800&auto=format&fit=crop',
      imageAsset: 'assets/images/recipes/sup_ayam_jahe.jpg',
      ingredientList: [
        '500g Buntut Sapi Pilihan',
        '4 siung Bawang Putih',
        '6 siung Bawang Merah',
        '2 buah Wortel Segar',
        '1 batang Daun Bawang & Seledri',
        '1 buah Tomat Merah',
        '1 bungkus Rempah Kuah Sop',
        '1 sdt Garam & Merica',
      ],
      stepList: [
        {
          'title': 'Persiapan & Perebusan Awal',
          'description':
              'Rebus buntut sapi sebentar dalam air mendidih untuk membersihkan kotoran, lalu tiriskan.',
        },
        {
          'title': 'Merebus Kaldu Gurih',
          'description':
              'Rebus kembali buntut dengan air bersih baru menggunakan api kecil hingga daging empuk dan kaldu bening gurih keluar.',
        },
        {
          'title': 'Menumis Rempah Aromatik',
          'description':
              'Tumis bawang putih, bawang merah, dan bumbu rempah hingga harum semerbak, lalu masukkan ke dalam kuah kaldu.',
        },
        {
          'title': 'Memasak Sayuran',
          'description':
              'Masukkan potongan wortel dan tomat, bumbui dengan garam dan merica, masak hingga sayuran empuk matang sempurna.',
        },
        {
          'title': 'Penyajian Hangat',
          'description':
              'Taburi daun bawang dan seledri, sajikan sop buntut panas-panas bersama perasan jeruk nipis.',
        },
      ],
    ),
    _ExploreRecipeItem(
      title: 'Ayam Tumis Kecap Bawang Daun',
      subtitle: 'Dada ayam empuk dengan karamelisasi kecap gurih',
      calories: 350,
      isDiet: false,
      portions: 2,
      time: '25 Menit',
      rating: 4.8,
      reviewCount: 245,
      reviews: [
        RecipeReview(
          userName: 'Dewi Lestari',
          rating: 4.9,
          comment:
              'Keluarga suka sekali, manis gurihnya pas dan ayamnya juicy.',
          date: '1 hari lalu',
        ),
        RecipeReview(
          userName: 'Hendra Wijaya',
          rating: 4.7,
          comment:
              'Praktis dan cepat dibuat untuk menu makan malam lezat.',
          date: '4 hari lalu',
        ),
      ],
      imageUrl:
          'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=800&auto=format&fit=crop',
      imageAsset: 'assets/images/recipes/tumis_tahu_telur.jpg',
      ingredientList: [
        '250g Dada Ayam Fillet',
        '3 siung Bawang Putih',
        '2 batang Daun Bawang',
        '1 buah Tomat Segar',
        '2 sdm Kecap Manis Kental',
        '1 sdm Kecap Asin',
        '1 sdt Minyak Wijen Murni',
        '1/2 sdt Merica & Garam',
      ],
      stepList: [
        {
          'title': 'Persiapan & Marinasi',
          'description':
              'Potong dadu fillet dada ayam, lalu baluri secara merata dengan 1 sdm kecap asin, sedikit merica, dan 1 sendok teh minyak wijen. Diamkan sebentar agar bumbu meresap ke dalam serat daging dan tekstur ayam tetap lembut juicy saat dimasak.',
        },
        {
          'title': 'Tumis Bumbu Aromatik',
          'description':
              'Panaskan 1 sendok makan minyak goreng di wajan anti lengket. Masukkan bawang putih yang telah dicincang halus, tumis dengan api sedang hingga warnanya kekuningan dan harum sedap khas keluar tanpa gosong.',
        },
        {
          'title': 'Pematangan Daging Ayam',
          'description':
              'Masukkan potongan daging ayam yang telah dimarinasi ke dalam wajan. Aduk cepat secara merata hingga seluruh permukaan ayam berubah warna pucat keemasan dan matang merata di setiap sisinya.',
        },
        {
          'title': 'Karamelisasi Kecap & Daun Bawang',
          'description':
              'Tuangkan 2 sendok makan kecap manis, tambahkan irisan daun bawang, dan potongan tomat segar. Aduk rata di atas api sedang hingga bumbu kecap mengental mengliap (glaze) serta menyelimuti setiap potongan ayam.',
        },
        {
          'title': 'Penyajian Hangat',
          'description':
              'Angkat tumisan dari wajan dan sajikan selagi hangat mengepul bersama semangkuk nasi putih pulen. Masakan lezat bernutrisi siap dinikmati bersama keluarga tercinta.',
        },
      ],
    ),
    _ExploreRecipeItem(
      title: 'Salad Ayam Brokoli & Telur',
      subtitle: 'Paduan segar ayam, alpukat dan telur rebus',
      calories: 340,
      isDiet: true,
      portions: 2,
      time: '15 Menit',
      rating: 4.8,
      reviewCount: 198,
      reviews: [
        RecipeReview(
          userName: 'Anita Permata',
          rating: 4.8,
          comment:
              'Pilihan pas untuk menu diet tanpa mengorbankan rasa enak!',
          date: '3 hari lalu',
        ),
        RecipeReview(
          userName: 'Rizky Pratama',
          rating: 4.8,
          comment:
              'Dressing lemonnya segar berpadu dengan sayuran renyah.',
          date: '1 minggu lalu',
        ),
      ],
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&auto=format&fit=crop',
      ingredientList: [
        '200g Dada Ayam Panggang',
        '1 bonggol Brokoli Rebus',
        '2 butir Telur Rebus',
        '1 buah Alpukat Matang',
        '1 genggam Daun Selada Segar',
        '2 sdm Minyak Zaitun',
        '1 sdm Air Lemon Segar',
        '1/2 sdt Garam & Lada Hitam',
      ],
      stepList: [
        {
          'title': 'Persiapan Sayur & Telur',
          'description':
              'Potong brokoli menjadi kuntum kecil lalu rebus sebentar. Kupas telur rebus dan potong menjadi empat bagian.',
        },
        {
          'title': 'Menyiapkan Ayam & Alpukat',
          'description':
              'Iris dada ayam panggang memanjang dan potong dadu buah alpukat segar.',
        },
        {
          'title': 'Meracik Dressing Segar',
          'description':
              'Campurkan minyak zaitun, perasan air lemon, garam, dan lada hitam dalam wadah kecil hingga rata.',
        },
        {
          'title': 'Menata Hidangan',
          'description':
              'Susun daun selada, brokoli, irisan ayam, telur, dan alpukat di dalam mangkuk salad.',
        },
        {
          'title': 'Penyajian',
          'description':
              'Siram dressing lemon ke atas salad sesaat sebelum dinikmati untuk kesegaran maksimal.',
        },
      ],
    ),
    _ExploreRecipeItem(
      title: 'Tumis Sapi Brokoli Bawang',
      subtitle: 'Daging sapi empuk dengan saus gurih',
      calories: 380,
      isDiet: false,
      portions: 2,
      time: '20 Menit',
      rating: 4.9,
      reviewCount: 276,
      reviews: [
        RecipeReview(
          userName: 'Farhan Maulana',
          rating: 5.0,
          comment:
              'Daging sapinya lembut, saus tiramnya gurih meresap sempurna.',
          date: '2 hari lalu',
        ),
        RecipeReview(
          userName: 'Maya Putri',
          rating: 4.8,
          comment:
              'Brokolinya tetap renyah segar, bumbunya sedap banget.',
          date: '6 hari lalu',
        ),
      ],
      imageUrl:
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800&auto=format&fit=crop',
      ingredientList: [
        '250g Daging Sapi Iris Tipis',
        '1 bonggol Brokoli Hijau',
        '3 siung Bawang Putih Cincang',
        '1/2 buah Bawang Bombay',
        '2 sdm Saus Tiram Gurih',
        '1 sdm Kecap Asin',
        '1 sdt Minyak Wijen',
        '1/2 sdt Lada Bubuk',
      ],
      stepList: [
        {
          'title': 'Marinasi Daging',
          'description':
              'Lumuri irisan daging sapi dengan kecap asin dan lada bubuk, diamkan selama 10 menit.',
        },
        {
          'title': 'Tumis Bumbu Aromatik',
          'description':
              'Panaskan minyak, tumis bawang putih dan bawang bombay hingga harum dan layu keemasan.',
        },
        {
          'title': 'Memasak Daging',
          'description':
              'Masukkan daging sapi, aduk cepat dengan api besar hingga daging berubah warna dan matang empuk.',
        },
        {
          'title': 'Menambahkan Brokoli',
          'description':
              'Masukkan brokoli dan tuangkan saus tiram serta sedikit air. Aduk merata hingga saus mengental.',
        },
        {
          'title': 'Penyajian',
          'description':
              'Tambahkan minyak wijen sesaat sebelum diangkat, sajikan selagi panas.',
        },
      ],
    ),
    _ExploreRecipeItem(
      title: 'Ayam Panggang Madu Manis',
      subtitle: 'Glaze madu manis karamel rempah pilihan',
      calories: 420,
      isDiet: false,
      portions: 3,
      time: '35 Menit',
      rating: 4.8,
      reviewCount: 184,
      reviews: [
        RecipeReview(
          userName: 'Lestari Indah',
          rating: 4.9,
          comment:
              'Karamel madunya harum mengkilap dan rasa manisnya legit pas.',
          date: '4 hari lalu',
        ),
        RecipeReview(
          userName: 'Ahmad Fauzi',
          rating: 4.7,
          comment:
              'Bumbu madu meresap sampai ke dalam serat daging ayam.',
          date: '1 minggu lalu',
        ),
      ],
      imageUrl:
          'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=800&auto=format&fit=crop',
      imageAsset: 'assets/images/recipes/tahu_telur_kecap.jpg',
      ingredientList: [
        '300g Daging Ayam Pilihan',
        '3 sdm Madu Alami',
        '2 sdm Kecap Manis',
        '1 sdm Saus Tiram',
        '2 siung Bawang Putih Parut',
        '1 sdt Ketumbar Bubuk',
        '1 sdm Margarin',
        '1/2 sdt Garam & Merica',
      ],
      stepList: [
        {
          'title': 'Meracik Saus Glaze',
          'description':
              'Campurkan madu alami, kecap manis, saus tiram, bawang putih, dan ketumbar bubuk ke dalam mangkuk.',
        },
        {
          'title': 'Marinasi Ayam',
          'description':
              'Baluri daging ayam dengan bumbu madu, diamkan 20 menit di kulkas agar bumbu meresap.',
        },
        {
          'title': 'Memanggang Awal',
          'description':
              'Panaskan teflon dengan sedikit margarin, panggang ayam dengan api sedang.',
        },
        {
          'title': 'Mengoleskan Karamel Madu',
          'description':
              'Oleskan sisa bumbu madu secara berkala ke permukaan ayam hingga terbentuk karamelisasi yang harum.',
        },
        {
          'title': 'Penyajian',
          'description':
              'Angkat ayam panggang madu yang matang kecokelatan dan hidangkan bersama lalapan segar.',
        },
      ],
    ),
    _ExploreRecipeItem(
      title: 'Salmon Panggang Lemon',
      subtitle: 'Kaya omega-3 dipanggang lembut dan gurih',
      calories: 410,
      isDiet: true,
      portions: 1,
      time: '20 Menit',
      rating: 4.9,
      reviewCount: 220,
      reviews: [
        RecipeReview(
          userName: 'Jessica Tan',
          rating: 5.0,
          comment:
              'Salmon matang juicy sempurna dan aromanya wangi rosemary segar.',
          date: '3 hari lalu',
        ),
        RecipeReview(
          userName: 'Dimas Setiawan',
          rating: 4.8,
          comment:
              'Perasan lemon dan bumbu meresap bikin ikannya tidak amis sama sekali.',
          date: '5 hari lalu',
        ),
      ],
      imageUrl:
          'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=800&auto=format&fit=crop',
      ingredientList: [
        '200g Fillet Salmon Segar',
        '1 buah Lemon Segar',
        '2 siung Bawang Putih Cincang',
        '1 sdm Minyak Zaitun',
        '1 batang Rosemary Segar',
        '1/2 sdt Garam Laut',
        '1/2 sdt Lada Hitam Kasar',
      ],
      stepList: [
        {
          'title': 'Persiapan Salmon',
          'description':
              'Keringkan fillet salmon dengan tisu dapur, taburi garam laut dan lada hitam merata di kedua sisi.',
        },
        {
          'title': 'Marinasi Lemon',
          'description':
              'Lumuri salmon dengan perasan lemon, bawang putih cincang, dan minyak zaitun. Diamkan 5 menit.',
        },
        {
          'title': 'Memanggang Lembut',
          'description':
              'Panggang salmon dengan daun rosemary hingga matang lembut dan juicy.',
        },
        {
          'title': 'Sentuhan Akhir',
          'description':
              'Beri irisan lemon di samping salmon agar aroma sitrus meresap segar ke dalam serat ikan.',
        },
        {
          'title': 'Penyajian',
          'description':
              'Angkat dan sajikan segera selagi hangat.',
        },
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _shuffledRecipes = List<_ExploreRecipeItem>.from(_allRecipesList)..shuffle();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }


  void _toggleBookmark(_ExploreRecipeItem recipe) {
    BookmarkService.instance.toggleBookmark(
      SavedRecipe(
        name: recipe.title,
        time: recipe.time,
        ingredients: '${recipe.ingredientList.length} Bahan',
        imageUrl: recipe.imageUrl,
        imageAsset: recipe.imageAsset,
        calories: recipe.calories,
        isDiet: recipe.isDiet,
        portions: recipe.portions,
        ingredientList: recipe.ingredientList,
        stepList: recipe.stepList,
      ),
    );
  }

  List<_ExploreRecipeItem> get _categoryRecipes {
    return _shuffledRecipes.where((recipe) {
      if (_selectedCategory == 'Diet Sehat') return recipe.isDiet;
      if (_selectedCategory == 'Non-Diet') return !recipe.isDiet;
      return true;
    }).toList();
  }

  _ExploreRecipeItem? get _popularRecipe {
    final list = _categoryRecipes;
    if (list.isEmpty) return null;
    return list.first;
  }

  List<_ExploreRecipeItem> get _recommendedList {
    final list = _categoryRecipes;
    if (list.length <= 1) return const [];
    return list.sublist(1);
  }

  List<_ExploreRecipeItem> get _searchResults {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return const [];

    final terms =
        query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    final filtered = _allRecipesList.where((recipe) {
      final matchesCategory = _selectedCategory == 'Semua' ||
          (_selectedCategory == 'Diet Sehat' && recipe.isDiet) ||
          (_selectedCategory == 'Non-Diet' && !recipe.isDiet);
      if (!matchesCategory) return false;

      final title = recipe.title.toLowerCase();
      final subtitle = recipe.subtitle.toLowerCase();
      final ingredients = recipe.ingredientList.join(' ').toLowerCase();
      final dietKeyword = recipe.isDiet ? 'diet sehat' : 'non diet';

      return terms.every((term) =>
          title.contains(term) ||
          subtitle.contains(term) ||
          ingredients.contains(term) ||
          dietKeyword.contains(term) ||
          '${recipe.calories}'.contains(term));
    }).toList();

    filtered.sort((a, b) {
      int score(_ExploreRecipeItem item) {
        int s = 0;
        final t = item.title.toLowerCase();
        final ing = item.ingredientList.join(' ').toLowerCase();
        final sub = item.subtitle.toLowerCase();

        if (t == query) s += 100;
        if (t.startsWith(query)) s += 60;
        if (t.contains(query)) s += 40;

        for (final term in terms) {
          if (t.contains(term)) s += 25;
          if (ing.contains(term)) s += 15;
          if (sub.contains(term)) s += 10;
        }
        return s;
      }

      return score(b).compareTo(score(a));
    });

    return filtered;
  }

  void _openRecipeDetail(_ExploreRecipeItem recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailResepPage(
          title: recipe.title,
          imageUrl: recipe.imageUrl,
          imageAsset: recipe.imageAsset,
          calories: recipe.calories,
          portions: recipe.portions,
          isDiet: recipe.isDiet,
          rating: recipe.rating,
          reviewCount: recipe.reviewCount,
          reviews: recipe.reviews,
          ingredientList: recipe.ingredientList,
          stepList: recipe.stepList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop',
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 36,
                                height: 36,
                                color: const Color(0xFF818CF8),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
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
                              _buildCategoryChip('Semua'),
                              const SizedBox(width: 8),
                              _buildCategoryChip('Diet Sehat'),
                              const SizedBox(width: 8),
                              _buildCategoryChip('Non-Diet'),
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
                          if (searchResults.isEmpty)
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
                          if (popular == null && recommended.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              alignment: Alignment.center,
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.restaurant_menu_outlined,
                                    size: 48,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Tidak ada resep pada kategori ini',
                                    style: TextStyle(
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
    final isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = title;
        });
      },
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
        BookmarkService.instance.isBookmarked(recipe.title);
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
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: recipe.isDiet
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                recipe.isDiet ? 'Diet Sehat' : 'Non-Diet',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: recipe.isDiet
                                      ? const Color(0xFF065F46)
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
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
                        ),
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
        BookmarkService.instance.isBookmarked(recipe.title);
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: recipe.isDiet
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          recipe.isDiet ? 'Diet Sehat' : 'Non-Diet',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: recipe.isDiet
                                ? const Color(0xFF065F46)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
