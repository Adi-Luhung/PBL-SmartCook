import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

/// Tab Profil — tampilan statis, data masih dummy (belum query Supabase).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, size: 36, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text('Adi Luhung', style: AppTextStyles.h2),
                Text('adi.luhung@example.com', style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: _StatPill(label: 'Masakan Dibuat', value: '14')),
              SizedBox(width: 12),
              Expanded(child: _StatPill(label: 'Resep Disimpan', value: '8')),
            ],
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Kesehatan & Kalori',
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Indeks Massa Tubuh', style: AppTextStyles.bodyMuted),
                      Text('21.3 (Ideal)', style: AppTextStyles.label),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target Kalori Harian', style: AppTextStyles.bodyMuted),
                      Text('1.829 kkal', style: AppTextStyles.label),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Dokumentasi Masak',
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.4,
              children: List.generate(4, (_) => const _PhotoPlaceholder()),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(label: 'Ganti Akun', variant: AppButtonVariant.outline, onPressed: () {}),
          const SizedBox(height: 10),
          AppButton(label: 'Keluar Akun', variant: AppButtonVariant.text, onPressed: () {}),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h1),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

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
          Text(title, style: AppTextStyles.label),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: AppColors.border.withOpacity(0.5),
        child: const Center(child: Icon(Icons.photo_outlined, color: AppColors.textMuted)),
      ),
    );
  }
}
