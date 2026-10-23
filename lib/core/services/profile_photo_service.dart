import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan foto profil secara permanen per akun user.
///
/// - File disimpan di `<docsDir>/profile_photos/<userId>.png` — tidak akan
///   dihapus OS karena ada di documents directory (bukan temp/cache).
/// - Key SharedPreferences menggunakan user ID sehingga setiap akun
///   memiliki foto sendiri-sendiri.
/// - Panggil [loadForUser] saat login, [clearUser] saat logout.
class ProfilePhotoService extends ChangeNotifier {
  ProfilePhotoService._();
  static final ProfilePhotoService instance = ProfilePhotoService._();

  static const String _keyPrefix = 'profile_photo_path_';

  String? _currentUserId;
  String? _photoPath;

  String? get photoPath => _photoPath;
  String? get currentUserId => _currentUserId;

  String _keyFor(String userId) => '$_keyPrefix$userId';

  // ── Direktori permanen untuk foto profil ──────────────────────────────────
  Future<Directory> get _profilePhotosDir async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${docsDir.path}/profile_photos');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  // ── Load foto untuk user tertentu ─────────────────────────────────────────
  /// Dipanggil saat user login (atau saat AuthGate mendeteksi sesi aktif).
  Future<void> loadForUser(String userId) async {
    _currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_keyFor(userId));

    // Verifikasi file masih ada; kalau tidak, hapus key-nya.
    if (savedPath != null && File(savedPath).existsSync()) {
      _photoPath = savedPath;
    } else {
      _photoPath = null;
      if (savedPath != null) await prefs.remove(_keyFor(userId));
    }
    notifyListeners();
  }

  // ── Simpan foto baru (dari path temp hasil crop) ──────────────────────────
  /// Menyalin file dari [sourcePath] (temp) ke lokasi permanen, lalu
  /// menyimpan path-nya di SharedPreferences dengan key user ID.
  Future<void> updatePhoto(String sourcePath) async {
    if (_currentUserId == null) return;

    final dir = await _profilePhotosDir;
    final destPath = '${dir.path}/$_currentUserId.png';

    // Hapus file lama jika ada
    final dest = File(destPath);
    if (dest.existsSync()) await dest.delete();

    // Salin dari temp ke dokumen permanen
    await File(sourcePath).copy(destPath);

    _photoPath = destPath;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFor(_currentUserId!), destPath);
    notifyListeners();
  }

  // ── Hapus foto profil user ────────────────────────────────────────────────
  Future<void> clearPhoto() async {
    if (_currentUserId == null) return;

    if (_photoPath != null) {
      final f = File(_photoPath!);
      if (f.existsSync()) await f.delete();
    }

    _photoPath = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(_currentUserId!));
    notifyListeners();
  }

  // ── Reset saat logout ─────────────────────────────────────────────────────
  /// Hapus state di memori tanpa menghapus file (foto tetap tersimpan untuk
  /// saat user login kembali).
  void clearUser() {
    _currentUserId = null;
    _photoPath = null;
    notifyListeners();
  }

  // ── Backward-compat: dipanggil di main.dart sebelum user diketahui ────────
  // Setelah login, AuthGate akan memanggil loadForUser(userId).
  Future<void> load() async {
    // No-op: foto di-load berdasarkan user ID setelah login.
  }
}
