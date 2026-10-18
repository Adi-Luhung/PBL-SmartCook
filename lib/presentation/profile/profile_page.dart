import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/bookmark_service.dart';
import '../../core/services/profile_photo_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../explore/detail_resep_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BookmarkService.instance,
      builder: (context, _) {
        final savedCount = BookmarkService.instance.savedRecipes.length;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                const _ProfileHeader(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                        child: _StatPill(label: 'Masakan Dibuat', value: '14')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatPill(
                            label: 'Resep Disimpan', value: '$savedCount')),
                  ],
                ),
                const SizedBox(height: 20),
                const _HealthCard(),
                const SizedBox(height: 20),
                const _SavedRecipesSection(),
                const SizedBox(height: 20),
                const _CookDocSection(),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Ganti Akun',
                  variant: AppButtonVariant.outline,
                  icon: Icons.swap_horiz_rounded,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                const _LogoutButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _ProfileHeader extends StatefulWidget {
  const _ProfileHeader();

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickPhoto() async {
    setState(() => _isLoading = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        await ProfilePhotoService.instance.updatePhoto(image.path);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memilih foto. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProfilePhotoService.instance,
      builder: (context, _) {
        final photoPath = ProfilePhotoService.instance.photoPath;
        final hasPhoto = photoPath != null && File(photoPath).existsSync();
        return Column(
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.border,
                    backgroundImage:
                        hasPhoto ? FileImage(File(photoPath)) : null,
                    child: hasPhoto
                        ? null
                        : const Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.textMuted,
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: _isLoading
                        ? const CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColors.border,
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : const CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              Icons.camera_alt,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ubah Foto',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Heisenberg', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            const Text(
              'heisenberg123@gmail.com',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 10),
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
      },
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

  @override
  Widget build(BuildContext context) {
    final recipes = BookmarkService.instance.savedRecipes;
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${recipes.length} Resep',
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
          child: recipes.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Belum ada resep yang disimpan',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: recipes
                      .asMap()
                      .entries
                      .map((e) => _SavedRecipeItem(
                            recipe: e.value,
                            showDivider: e.key < recipes.length - 1,
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
    required this.recipe,
    required this.showDivider,
  });

  final SavedRecipe recipe;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailResepPage(
                  title: recipe.name,
                  imageUrl: recipe.imageUrl,
                  imageAsset: recipe.imageAsset,
                  calories: recipe.calories,
                  portions: recipe.portions,
                  isDiet: recipe.isDiet,
                  ingredientList: recipe.ingredientList,
                  stepList: recipe.stepList,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 56,
                    height: 56,
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
                                    : Container(
                                        color: const Color(0xFFE8EEFB),
                                        child: const Icon(Icons.restaurant,
                                            color: AppColors.textMuted),
                                      ),
                          )
                        : (recipe.imageAsset != null
                            ? Image.asset(
                                recipe.imageAsset!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: const Color(0xFFE8EEFB),
                                child: const Icon(Icons.restaurant,
                                    color: AppColors.textMuted),
                              )),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe.name, style: AppTextStyles.label),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text('${recipe.time} • ${recipe.ingredients}',
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
