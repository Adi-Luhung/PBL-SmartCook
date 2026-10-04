import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import 'widgets/home_recipe_list_item.dart';

/// Tab Beranda — tampilan statis, data masih dummy (belum query Supabase).
class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key, required this.onNavigate});

  /// Dipanggil saat user mau pindah tab: 0=Beranda, 1=Rekomendasi,
  /// 2=Input, 3=Profil.
  final ValueChanged<int> onNavigate;

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final Set<String> _bookmarked = {};

  static const _recommended = [
    (
      title: 'Sup Ayam Jahe Hangat',
      subtitle: 'Cocok untuk dada ayam & daun bawang',
      duration: 25,
      calories: 320,
    ),
    (
      title: 'Tumis Tahu Telur Saus Tiram',
      subtitle: 'Gunakan stok tahu dan telur ayam',
      duration: 15,
      calories: 240,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Halo, Mau Masak Apa?', style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Text(
            'Pilih bahan yang ada, kami temukan resepnya, atau cari resep makanan favoritmu.',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 20),
          _SearchCard(onSearchTap: () => widget.onNavigate(1)),
          const SizedBox(height: 12),
          _HighlightCard(onTap: () => widget.onNavigate(2)),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Rekomendasi Masakan', style: AppTextStyles.h2),
              const Spacer(),
              GestureDetector(
                onTap: () => widget.onNavigate(1),
                child: Row(
                  children: [
                    Text(
                      'Lihat Semua (24)',
                      style: AppTextStyles.label.copyWith(color: AppColors.primary),
                    ),
                    const Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_recommended.length, (i) {
            final item = _recommended[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HomeRecipeListItem(
                title: item.title,
                subtitle: item.subtitle,
                durationMinutes: item.duration,
                calories: item.calories,
                bookmarked: _bookmarked.contains(item.title),
                onBookmarkTap: () => setState(() {
                  if (_bookmarked.contains(item.title)) {
                    _bookmarked.remove(item.title);
                  } else {
                    _bookmarked.add(item.title);
                  }
                }),
                onTap: () {},
              ),
            );
          }),
          const SizedBox(height: 8),
          AppButton(
            label: 'Jelajahi Semua Resep Masakan',
            onPressed: () => widget.onNavigate(1),
          ),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Cari Resep Masakan', style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text('Misal: Soto Ayam, Rendang', style: AppTextStyles.bodyMuted),
                ),
                GestureDetector(
                  onTap: onSearchTap,
                  child: Row(
                    children: [
                      Text('Cari', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                      const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rtl, size: 18, color: AppColors.primaryDark),
              const SizedBox(width: 8),
              Text(
                'Masukkan Bahan Masakan',
                style: AppTextStyles.label.copyWith(color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppButton(label: 'Cari & Masukkan Bahan', onPressed: onTap),
        ],
      ),
    );
  }
}
