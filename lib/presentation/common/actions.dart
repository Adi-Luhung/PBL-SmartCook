import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';

void _snack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.danger : AppColors.primary,
    ));
}

/// Simpan / hapus bookmark dan tampilkan pesan kalau gagal.
Future<void> toggleBookmark(
    BuildContext context, WidgetRef ref, int recipeId) async {
  try {
    await ref.read(bookmarkProvider.notifier).toggle(recipeId);
  } catch (_) {
    if (context.mounted) {
      _snack(context, 'Gagal menyimpan resep. Coba lagi.', error: true);
    }
  }
}

/// Pilih foto dari galeri lalu unggah sebagai dokumentasi masak.
/// Android 13+ memakai Photo Picker sistem (tanpa izin tambahan);
/// iOS butuh NSPhotoLibraryUsageDescription di Info.plist.
Future<void> pickAndUploadCookDoc(BuildContext context, WidgetRef ref,
    {int? recipeId}) async {
  final uid = ref.read(currentUserIdProvider);
  if (uid == null) return;

  try {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return; // dibatalkan
    if (!context.mounted) return;

    _snack(context, 'Mengunggah foto...');
    await ref
        .read(profileRepositoryProvider)
        .uploadCookDoc(userId: uid, file: file, recipeId: recipeId);
    ref.invalidate(cookDocsProvider);
    if (context.mounted) _snack(context, 'Foto tersimpan di dokumentasi masak.');
  } catch (_) {
    if (context.mounted) {
      _snack(context, 'Gagal mengunggah foto. Periksa koneksi lalu coba lagi.',
          error: true);
    }
  }
}
