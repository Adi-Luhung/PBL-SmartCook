import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/profile_photo_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models.dart';
import 'photo_crop_page.dart';

/// Widget header profil khusus untuk menampilkan dan mengubah foto profil:
/// - Ambil foto via Kamera
/// - Unggah foto via Galeri
/// - Crop foto profil lingkaran (Instagram-style)
/// - Hapus foto profil dengan dialog konfirmasi
class ProfilePhotoHeader extends StatefulWidget {
  const ProfilePhotoHeader({
    super.key,
    required this.profile,
    required this.email,
  });

  final UserProfile? profile;
  final String? email;

  @override
  State<ProfilePhotoHeader> createState() => _ProfilePhotoHeaderState();
}

class _ProfilePhotoHeaderState extends State<ProfilePhotoHeader> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  String get _displayName {
    final name = widget.profile?.fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return widget.email?.split('@').first ?? 'Pengguna';
  }

  // ── Ambil foto dari kamera atau galeri ─────────────────────────────────────
  Future<void> _pickPhoto(ImageSource source) async {
    setState(() => _isLoading = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
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
            content: Text('Gagal mengambil foto. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Hapus foto profil ─────────────────────────────────────────────────────
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
          'Foto profil kamu akan dihapus secara permanen dari perangkat ini.',
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
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus foto. Silakan coba lagi.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // ── Bottom sheet pilihan foto ──────────────────────────────────────────────
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
              // Opsi: Ambil dari Kamera
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.primary, size: 22),
                ),
                title: const Text('Ambil dari Kamera',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A))),
                subtitle: const Text('Foto langsung menggunakan kamera',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickPhoto(ImageSource.camera);
                },
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              // Opsi: Pilih dari Galeri
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppColors.primary, size: 22),
                ),
                title: const Text('Pilih dari Galeri',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A))),
                subtitle: const Text('Unggah foto dari galeri HP kamu',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickPhoto(ImageSource.gallery);
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
                      color: Colors.red.withValues(alpha: 0.1),
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

  // ── Build ─────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────
// Info Pill (Gender / Umur)
// ─────────────────────────────────────────────────
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

