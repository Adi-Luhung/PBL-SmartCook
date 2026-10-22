import 'package:flutter/material.dart';

import '../../core/services/bookmark_service.dart';
import '../../core/services/cook_doc_service.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../explore/eksplorasi_page.dart';
import '../home/beranda_page.dart';
import '../input_bahan/input_bahan_page.dart';
import '../profile/profile_page.dart';
import '../recommendation/recommendation_page.dart';

/// Shell utama setelah login: bottom nav 4 tab + IndexedStack.
/// Tab 0: Beranda
/// Tab 1: Eksplorasi (katalog resep umum tanpa input bahan)
/// Tab 2: Input (Input bahan & Hasil rekomendasi resep dari bahan)
/// Tab 3: Profil
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  bool _showRecommendationInInput = false;
  String _exploreSearchKeyword = '';
  int _exploreSearchRequestId = 0;

  @override
  void reassemble() {
    super.reassemble();
    // Hot reload (hanya saat debug): sinkron ulang data yang disimpan di singleton.
    BookmarkService.instance.loadFromServer();
    CookDocService.instance.loadFromServer();
  }

  @override
  void initState() {
    super.initState();
    // Muat bookmark milik pengguna yang baru masuk dari Supabase.
    BookmarkService.instance.loadFromServer();
    CookDocService.instance.loadFromServer();
  }

  void _goTo(int index) {
    setState(() {
      // Jika pengguna menekan tab Input lagi saat sedang melihat hasil rekomendasi,
      // kembalikan tampilan ke form input bahan
      if (_index == 2 && index == 2 && _showRecommendationInInput) {
        _showRecommendationInInput = false;
      }
      _index = index;
    });
  }

  void _openInputBahanForm() {
    setState(() {
      _showRecommendationInInput = false;
      _index = 2;
    });
  }

  void _openExploreWithSearch(String searchKeyword) {
    setState(() {
      _exploreSearchKeyword = searchKeyword;
      _exploreSearchRequestId++;
      _index = 1;
    });
  }

  /// Dipanggil setelah InputBahanPage selesai mencari di database
  /// (hasilnya disimpan di searchQueryProvider).
  void _onSearchWithIngredients(List<String> ingredients) {
    setState(() {
      // Tetap di tab Input (index 2), beralih ke halaman hasil rekomendasi
      _showRecommendationInInput = true;
      _index = 2;
    });
  }

  void _onBackToInputBahan() {
    setState(() {
      _showRecommendationInInput = false;
      _index = 2;
    });
  }

  Widget _buildInputTabContent() {
    if (_showRecommendationInInput) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _onBackToInputBahan();
        },
        child: RecommendationPage(
          onAddIngredients: _onBackToInputBahan,
          onProfileTap: () => _goTo(3),
        ),
      );
    }

    return InputBahanPage(
      onSearchRecipes: () {
        setState(() {
          _showRecommendationInInput = true;
          _index = 2;
        });
      },
      onSearchRecipesWithIngredients: _onSearchWithIngredients,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      BerandaPage(
        onNavigate: (index) {
          if (index == 2) {
            _openInputBahanForm();
          } else {
            _goTo(index);
          }
        },
        onSearchRecipes: _openExploreWithSearch,
      ),
      EksplorasiPage(
        onProfileTap: () => _goTo(3),
        searchKeyword: _exploreSearchKeyword,
        searchRequestId: _exploreSearchRequestId,
      ),
      _buildInputTabContent(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppBottomNav(currentIndex: _index, onTap: _goTo),
    );
  }
}
