import 'package:flutter/material.dart';

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
  List<String> _selectedIngredients = ['Tahu', 'Telur', 'Bawang', 'Cabai'];

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

  String _simplifyIngredientName(String name) {
    if (name.contains('Telur')) return 'Telur';
    if (name.contains('Tahu')) return 'Tahu';
    if (name.contains('Bawang')) return 'Bawang';
    if (name.contains('Cabai')) return 'Cabai';
    return name.split(' ').first;
  }

  void _onSearchWithIngredients(List<String> ingredients) {
    setState(() {
      if (ingredients.isNotEmpty) {
        _selectedIngredients =
            ingredients.map(_simplifyIngredientName).toSet().toList();
      }
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
          selectedIngredients: _selectedIngredients,
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
      ),
      EksplorasiPage(
        onProfileTap: () => _goTo(3),
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
