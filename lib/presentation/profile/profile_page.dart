import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models.dart';
import '../../providers/app_providers.dart';
import '../common/actions.dart';
import '../recipe/recipe_detail_page.dart';
import 'edit_profile_page.dart';

/// Tab Profil — data dari tabel `profiles`, `bookmarks`, dan `cook_docs`.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _logout(WidgetRef ref) async {
    ref.read(searchQueryProvider.notifier).clear();
    await ref.read(supabaseProvider).auth.signOut();
    // AuthGate otomatis kembali ke halaman login.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final email = ref.watch(supabaseProvider).auth.currentUser?.email;
    final savedCount = ref.watch(savedRecipesProvider).value?.length ?? 0;
    final cookCount = ref.watch(cookDocsProvider).value?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _ProfileHeader(profile: profile, email: email),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _StatPill(label: 'Masakan Dibuat', value: '$cookCount')),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatPill(label: 'Resep Disimpan', value: '$savedCount')),
              ],
            ),
            const SizedBox(height: 20),
            _HealthCard(profile: profile),
            const SizedBox(height: 20),
            const _SavedRecipesSection(),
            const SizedBox(height: 20),
            const _CookDocSection(),
            const SizedBox(height: 28),
            AppButton(
              label: 'Ganti Akun',
              variant: AppButtonVariant.outline,
              icon: Icons.swap_horiz_rounded,
              onPressed: () => _logout(ref),
            ),
            const SizedBox(height: 12),
            _LogoutButton(onPressed: () => _logout(ref)),
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
  const _ProfileHeader({required this.profile, required this.email});

  final UserProfile? profile;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final name = (profile?.fullName?.trim().isNotEmpty ?? false)
        ? profile!.fullName!
        : (email?.split('@').first ?? 'Pengguna');

    return Column(
      children: [
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
        Text(name, style: AppTextStyles.h2),
        const SizedBox(height: 4),
        Text(email ?? '', style: AppTextStyles.bodyMuted),
        const SizedBox(height: 10),
        if (profile?.gender != null || profile?.age != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (profile?.gender != null) _InfoPill(label: profile!.gender!),
              if (profile?.gender != null && profile?.age != null)
                const SizedBox(width: 10),
              if (profile?.age != null) _InfoPill(label: '${profile!.age} Tahun'),
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
  const _HealthCard({required this.profile});

  final UserProfile? profile;

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
                  children: [
                    const Text('Kesehatan & Kalori', style: AppTextStyles.label),
                    Text(_bodyLine(profile), style: AppTextStyles.bodyMuted),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfilePage(),
                    ),
                  );
                },
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
                            profile?.bmi == null ? '-' : profile!.bmi!.toStringAsFixed(1),
                            style: AppTextStyles.h1.copyWith(fontSize: 28),
                          ),
                          const SizedBox(width: 6),
                          if (profile?.bmiLabel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: profile!.bmiLabel == 'Ideal'
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                profile!.bmiLabel!,
                                style: TextStyle(
                                  color: profile!.bmiLabel == 'Ideal'
                                      ? AppColors.success
                                      : const Color(0xFFD97706),
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
                              text: profile?.targetKkal == null
                                  ? '-'
                                  : _formatKkal(profile!.targetKkal!),
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

  /// 1829 -> "1.829"
  static String _formatKkal(int n) => n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  static String _bodyLine(UserProfile? p) {
    if (p == null || p.weightKg == null || p.heightCm == null) {
      return 'Data tubuh belum diisi';
    }
    return '${p.weightKg!.toStringAsFixed(0)} kg • ${p.heightCm!.toStringAsFixed(0)} cm';
  }
}

// ─────────────────────────────────────────────────
// Resep Disimpan
// ─────────────────────────────────────────────────
class _SavedRecipesSection extends ConsumerWidget {
  const _SavedRecipesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedRecipesProvider);
    final list = saved.value ?? const <RecipeSummary>[];

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.bookmark_outline,
                color: AppColors.textPrimary, size: 18),
            const SizedBox(width: 6),
            const Expanded(
              child: Text('Resep Disimpan', style: AppTextStyles.label),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${list.length} Resep',
                style: const TextStyle(
                  color: Color(0xFFD97706),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: saved.isLoading && list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
              : list.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Belum ada resep yang disimpan. Ketuk ikon bookmark pada resep.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMuted,
                      ),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < list.length; i++)
                          _SavedRecipeItem(
                            name: list[i].title,
                            detail:
                                '${list[i].totalSteps} langkah • ${list[i].totalIngredients} bahan',
                            showDivider: i < list.length - 1,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecipeDetailPage(recipeId: list[i].id),
                              ),
                            ),
                          ),
                      ],
                    ),
        ),
      ],
    );
  }
}

class _SavedRecipeItem extends StatelessWidget {
  const _SavedRecipeItem({
    required this.name,
    required this.detail,
    required this.showDivider,
    required this.onTap,
  });

  final String name;
  final String detail;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
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
                      Text(name,
                          style: AppTextStyles.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(detail, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 14, endIndent: 14, thickness: 0.8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────
// Dokumentasi Masak (foto dari galeri)
// ─────────────────────────────────────────────────
class _CookDocSection extends ConsumerWidget {
  const _CookDocSection();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static String _timeLabel(DateTime t) =>
      '${t.day} ${_months[t.month - 1]} ${t.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(cookDocsProvider);
    final list = docs.value ?? const <CookDoc>[];

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.camera_alt_outlined,
                color: AppColors.textPrimary, size: 18),
            const SizedBox(width: 6),
            const Expanded(
              child: Text('Dokumentasi Masak', style: AppTextStyles.label),
            ),
            GestureDetector(
              onTap: () => pickAndUploadCookDoc(context, ref),
              child: const Text(
                'Tambah Foto',
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
        if (docs.isLoading && list.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (list.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Belum ada foto. Ketuk "Tambah Foto" untuk memilih dari galeri.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
          )
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.2,
            children: [
              for (final d in list)
                _PhotoCard(
                  name: d.recipeTitle ?? 'Masakanku',
                  time: _timeLabel(d.createdAt),
                  imageUrl: d.imageUrl,
                ),
            ],
          ),
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.name, required this.time, this.imageUrl});
  final String name;
  final String time;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl == null)
            Container(color: const Color(0xFFB0B8C1))
          else
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFFB0B8C1)),
            ),
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
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
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
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
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
