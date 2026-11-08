import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/bookmark_service.dart';
import '../../core/services/cook_doc_service.dart';
import '../../core/widgets/app_notification.dart';
import '../../data/models.dart';

void _snack(BuildContext context, String message, {bool error = false}) {
  if (error) {
    AppNotification.showError(context, message);
  } else {
    AppNotification.showSuccess(context, message);
  }
}

/// Simpan / hapus bookmark resep database; tampilkan pesan kalau gagal.
Future<void> toggleRecipeBookmark(
    BuildContext context, RecipeSummary recipe) async {
  try {
    await BookmarkService.instance.toggleRecipe(SavedRecipe.fromSummary(recipe));
  } catch (_) {
    if (context.mounted) {
      AppNotification.showError(context, 'Gagal menyimpan resep. Coba lagi.');
    }
  }
}

/// Pilih foto dari galeri lalu simpan sebagai dokumentasi masak (jurnal dapur).
/// Android 13+ memakai Photo Picker sistem (tanpa izin tambahan);
/// iOS butuh NSPhotoLibraryUsageDescription di Info.plist.
Future<void> pickCookPhotoFromGallery(BuildContext context) async {
  try {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return; // dibatalkan
    if (!context.mounted) return;

    _snack(context, 'Mengunggah foto...');
    final saved = await CookDocService.instance.addCookDoc(
      CookDocItem(name: 'Masakanku', time: 'Hari ini', photoPath: file.path),
    );
    if (!context.mounted) return;
    if (saved) {
      _snack(context, 'Foto tersimpan di dokumentasi masak.');
    } else {
      _snack(context, 'Gagal mengunggah foto. Periksa koneksi lalu coba lagi.',
          error: true);
    }
  } catch (_) {
    if (context.mounted) {
      _snack(context, 'Gagal memilih foto.', error: true);
    }
  }
}
