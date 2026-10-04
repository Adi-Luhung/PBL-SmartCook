import 'package:flutter/material.dart';

import '../../core/widgets/app_bottom_nav.dart';
import '../home/beranda_page.dart';
import '../input_bahan/input_bahan_page.dart';
import '../profile/profile_page.dart';
import '../../presentation/recommendation/recommendation_page.dart';

/// Shell utama setelah login: bottom nav 4 tab + IndexedStack.
/// Semua tab sudah tampil dengan data dummy — belum query Supabase.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      BerandaPage(onNavigate: _goTo),
      const RecommendationPage(),
      const InputBahanPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppBottomNav(currentIndex: _index, onTap: _goTo),
    );
  }
}
