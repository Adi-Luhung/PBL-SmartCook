import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

/// Tab Profil — tampilan statis, data masih dummy (belum query Supabase).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [

            // ── Avatar + Info Pengguna ──
            _ProfileHeader(),
            const SizedBox(height: 20),

            // ── Stat Pills ──
            const Row(
              children: [
                Expanded(
                    child: _StatPill(label: 'Masakan Dibuat', value: '14')),
                SizedBox(width: 12),
                Expanded(
                    child: _StatPill(label: 'Resep Disimpan', value: '8')),
              ],
            ),
            const SizedBox(height: 20),

            // ── Kesehatan & Kalori ──
            _HealthCard(),
            const SizedBox(height: 20),

            // ── Resep Disimpan ──
            _SavedRecipesSection(),
            const SizedBox(height: 20),

            // ── Dokumentasi Masak ──
            _CookDocSection(),
            const SizedBox(height: 28),

            // ── Aksi Akun ──
            AppButton(
              label: 'Ganti Akun',
              variant: AppButtonVariant.outline,
              icon: Icons.swap_horiz_rounded,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            _LogoutButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Banner Sukses
// ─────────────────────────────────────────────────
class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Header Profil
// ─────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar dengan badge centang
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 44,
              backgroundImage: null,
              backgroundColor: AppColors.border,
              child: Icon(Icons.person, size: 40, color: AppColors.textMuted),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.check, size: 12, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Nama
        const Text('Heisenberg', style: AppTextStyles.h2),
        const SizedBox(height: 4),

        // Email
        const Text('heisenberg123@gmail.com', style: AppTextStyles.bodyMuted),
        const SizedBox(height: 10),

        // Gender & Usia
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _InfoPill(label: 'Perempuan'),
            const SizedBox(width: 10),
            _InfoPill(label: '24 Tahun'),
          ],
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppTextStyles.label),
    );
  }
}

// ─────────────────────────────────────────────────
// Stat Pill
// ─────────────────────────────────────────────────
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Kesehatan & Kalori Card
// ─────────────────────────────────────────────────
class _HealthCard extends StatelessWidget {
  const _HealthCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header baris: ikon + judul + tombol Ubah
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield_outlined,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Kesehatan & Kalori', style: AppTextStyles.label),
                    Text('58 kg • 165 cm', style: AppTextStyles.bodyMuted),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Ubah'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  textStyle:
                      const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dua kolom: IMT & Target Kalori
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Indeks Massa Tubuh',
                          style: AppTextStyles.bodyMuted),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '21.3',
                            style: AppTextStyles.h1.copyWith(fontSize: 28),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Ideal',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // BMI Color Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Container(height: 6, color: const Color(0xFF60A5FA))),
                            Expanded(
                                flex: 3,
                                child: Container(height: 6, color: const Color(0xFF4ADE80))),
                            Expanded(
                                flex: 2,
                                child: Container(height: 6, color: const Color(0xFFFBBF24))),
                            Expanded(
                                flex: 2,
                                child: Container(height: 6, color: const Color(0xFFF87171))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target Kalori Harian',
                          style: AppTextStyles.bodyMuted),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '1.829',
                              style: AppTextStyles.h1.copyWith(fontSize: 28),
                            ),
                            const TextSpan(
                              text: ' kkal',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Resep Disimpan
// ─────────────────────────────────────────────────
class _SavedRecipesSection extends StatelessWidget {
  const _SavedRecipesSection();

  static const _recipes = [
    {'name': 'Sup Telur Tomat', 'time': '12 Menit', 'ingredients': '3 Bahan'},
    {
      'name': 'Orak Arik Tahu Gurih',
      'time': '10 Menit',
      'ingredients': '4 Bahan'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.bookmark_outline,
                color: AppColors.textPrimary, size: 18),
            const SizedBox(width: 6),
            const Expanded(
              child: Text('Resep Disimpan', style: AppTextStyles.label),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '8 Resep',
                style: TextStyle(
                  color: Color(0xFFD97706),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // List resep
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: _recipes
                .asMap()
                .entries
                .map((e) => _SavedRecipeItem(
                      name: e.value['name']!,
                      time: e.value['time']!,
                      ingredients: e.value['ingredients']!,
                      showDivider: e.key < _recipes.length - 1,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SavedRecipeItem extends StatelessWidget {
  const _SavedRecipeItem({
    required this.name,
    required this.time,
    required this.ingredients,
    required this.showDivider,
  });

  final String name;
  final String time;
  final String ingredients;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Foto placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 56,
                  height: 56,
                  color: AppColors.border,
                  child: const Icon(Icons.fastfood_outlined,
                      color: AppColors.textMuted),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text('$time • $ingredients',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 14, endIndent: 14, thickness: 0.8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────
// Dokumentasi Masak
// ─────────────────────────────────────────────────
class _CookDocSection extends StatelessWidget {
  const _CookDocSection();

  static const _photos = [
    {'name': 'Nasi Telur Kecap', 'time': 'Kemarin siang'},
    {'name': 'Tumis Kangkung', 'time': '2 hari lalu'},
    {'name': 'Tempe Goreng', 'time': '24 Okt'},
    {'name': 'Tahu Telur', 'time': '20 Okt'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.camera_alt_outlined,
                color: AppColors.textPrimary, size: 18),
            const SizedBox(width: 6),
            const Expanded(
              child: Text('Dokumentasi Masak', style: AppTextStyles.label),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Galeri Pribadi',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Grid 2x2
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.2,
          children: _photos
              .map((p) =>
                  _PhotoCard(name: p['name']!, time: p['time']!))
              .toList(),
        ),
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.name, required this.time});
  final String name;
  final String time;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Foto placeholder abu-abu
          Container(color: const Color(0xFFB0B8C1)),

          // Gradient gelap di bawah
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC000000)],
                stops: [0.45, 1.0],
              ),
            ),
          ),

          // Label nama & waktu
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
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

// ─────────────────────────────────────────────────
// Tombol Keluar (merah outline)
// ─────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, color: AppColors.danger, size: 18),
        label: const Text('Keluar Akun'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: const BorderSide(color: Color(0xFFFFD7D7)),
          backgroundColor: const Color(0xFFFFF5F5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
