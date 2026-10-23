import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/bookmark_service.dart';
import '../../core/services/cook_doc_service.dart';
import '../../core/services/ingredient_service.dart';
import '../../core/services/profile_photo_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models.dart';
import '../../providers/app_providers.dart';
import '../common/actions.dart';
import '../explore/detail_resep_page.dart';
import '../recipe/recipe_detail_loader.dart';
import 'edit_profile_page.dart';
import 'photo_crop_page.dart';

/// Tab Profil — data dari tabel `profiles`, `bookmarks`, dan `cook_docs`.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _logout(WidgetRef ref) async {
    ref.read(searchQueryProvider.notifier).clear();
    IngredientService.instance.setSelectedIngredients(const []);
    BookmarkService.instance.clearServerBacked();
    CookDocService.instance.clear();
    ProfilePhotoService.instance.clearUser();
    await ref.read(supabaseProvider).auth.signOut();
    // AuthGate otomatis kembali ke halaman login.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final email = ref.watch(supabaseProvider).auth.currentUser?.email;

    return ListenableBuilder(
      listenable: Listenable.merge([BookmarkService.instance, CookDocService.instance]),
      builder: (context, _) {
        final savedCount = BookmarkService.instance.savedRecipes.length;
        final cookCount = CookDocService.instance.items.length;
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
                        child: _StatPill(
                            label: 'Masakan Dibuat', value: '$cookCount')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatPill(
                            label: 'Resep Disimpan', value: '$savedCount')),
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
      },
    );
  }
}

class _ProfileHeader extends StatefulWidget {
  const _ProfileHeader({required this.profile, required this.email});

  final UserProfile? profile;
  final String? email;

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  String get _displayName {
    final name = widget.profile?.fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return widget.email?.split('@').first ?? 'Pengguna';
  }

  Future<void> _pickPhoto() async {
    setState(() => _isLoading = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );
      if (image != null && mounted) {
        // Buka halaman crop untuk atur posisi foto
        final croppedPath = await Navigator.of(context).push<String?>(
          MaterialPageRoute(
            builder: (_) => PhotoCropPage(imagePath: image.path),
          ),
        );
        if (croppedPath != null) {
          await ProfilePhotoService.instance.updatePhoto(croppedPath);
        }
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

  Future<void> _deletePhoto() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Foto Profil?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: const Text(
          'Foto profil kamu akan dihapus secara permanen.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await ProfilePhotoService.instance.clearPhoto();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showPhotoOptions() {
    final hasPhoto = ProfilePhotoService.instance.photoPath != null &&
        File(ProfilePhotoService.instance.photoPath!).existsSync();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'Foto Profil',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const Divider(height: 16),
              // Opsi: Unggah dari Galeri
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppColors.primary, size: 22),
                ),
                title: const Text('Unggah dari Galeri',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A))),
                subtitle: const Text('Pilih foto dari galeri HP kamu',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickPhoto();
                },
              ),
              // Opsi: Hapus Foto (hanya muncul jika ada foto)
              if (hasPhoto) ...[
                const Divider(height: 1, indent: 20, endIndent: 20),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.red, size: 22),
                  ),
                  title: const Text('Hapus Foto Profil',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red)),
                  subtitle: const Text('Foto akan dihapus secara permanen',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _deletePhoto();
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
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
              onTap: _showPhotoOptions,
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
            GestureDetector(
              onTap: _showPhotoOptions,
              child: Text(
                hasPhoto ? 'Ubah Foto' : 'Tambah Foto',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(_displayName, style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text(widget.email ?? '', style: AppTextStyles.bodyMuted),
            const SizedBox(height: 10),
            if (widget.profile?.gender != null || widget.profile?.age != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.profile?.gender != null)
                    _InfoPill(label: widget.profile!.gender!),
                  if (widget.profile?.gender != null && widget.profile?.age != null)
                    const SizedBox(width: 10),
                  if (widget.profile?.age != null)
                    _InfoPill(label: '${widget.profile!.age} Tahun'),
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
class _SavedRecipesSection extends StatelessWidget {
  const _SavedRecipesSection();

  @override
  Widget build(BuildContext context) {
    // Mendengarkan BookmarkService sendiri: widget ini const, jadi tidak ikut
    // dibangun ulang saat induknya berubah.
    return ListenableBuilder(
      listenable: BookmarkService.instance,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
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
            final id = recipe.recipeId;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => id != null
                    ? RecipeDetailLoader(recipeId: id)
                    : DetailResepPage(
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CookDocService.instance,
      builder: (context, _) {
        final docs = CookDocService.instance.items;

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
                  onTap: () => pickCookPhotoFromGallery(context),
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
            if (docs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Belum ada dokumentasi. Selesaikan sebuah resep atau ketuk "Tambah Foto" untuk memilih dari galeri.',
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
                children: docs
                    .map((p) => _PhotoCard(
                          name: p.name,
                          time: p.time,
                          photoPath: p.photoPath,
                          imageUrl: p.imageUrl,
                        ))
                    .toList(),
              ),
          ],
        );
      },
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.name,
    required this.time,
    this.photoPath,
    this.imageUrl,
  });

  final String name;
  final String time;
  final String? photoPath;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasLocal = photoPath != null && File(photoPath!).existsSync();
    const placeholder = ColoredBox(color: Color(0xFFB0B8C1));

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasLocal)
            Image.file(File(photoPath!), fit: BoxFit.cover)
          else if (imageUrl != null)
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            )
          else
            placeholder,
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
