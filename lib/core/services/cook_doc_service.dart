import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/profile_repository.dart';

class CookDocItem {
  const CookDocItem({
    required this.name,
    required this.time,
    this.photoPath,
    this.imageUrl,
    this.rating = 5.0,
    this.tags = const [],
    this.notes = '',
    this.recipeId,
  });

  final String name;
  final String time;

  /// Foto lokal (baru dipilih dari galeri/kamera).
  final String? photoPath;

  /// Foto dari Supabase Storage (signed URL), untuk dokumentasi yang sudah tersimpan.
  final String? imageUrl;
  final double rating;
  final List<String> tags;
  final String notes;

  /// Resep database yang dimasak; null untuk foto lepas.
  final int? recipeId;
}

/// Jurnal dapur: daftar dokumentasi masak. Disimpan di tabel `cook_docs`
/// (foto di bucket `cook-docs`) dan dimuat ulang setelah login.
class CookDocService extends ChangeNotifier {
  CookDocService._();
  static final CookDocService instance = CookDocService._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  final List<CookDocItem> _items = [];

  List<CookDocItem> get items => List.unmodifiable(_items);

  ProfileRepository get _repo => ProfileRepository(Supabase.instance.client);
  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  static String _relative(DateTime t) {
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(t.year, t.month, t.day))
        .inDays;
    if (days <= 0) return 'Hari ini';
    if (days == 1) return 'Kemarin';
    if (days < 7) return '$days hari lalu';
    return '${t.day} ${_months[t.month - 1]}';
  }

  /// Muat jurnal pengguna dari Supabase (dipanggil setelah login).
  Future<void> loadFromServer() async {
    if (_userId == null) return;
    try {
      final docs = await _repo.listCookDocs();
      _items
        ..clear()
        ..addAll(docs.map((d) => CookDocItem(
              name: d.recipeTitle ?? 'Masakanku',
              time: _relative(d.createdAt),
              imageUrl: d.imageUrl,
              rating: d.rating ?? 5.0,
              tags: d.tags,
              notes: d.note,
              recipeId: d.recipeId,
            )));
      notifyListeners();
    } catch (_) {
      // Biarkan daftar apa adanya; dimuat ulang saat aplikasi dibuka lagi.
    }
  }

  /// Bersihkan jurnal akun yang baru keluar.
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Tambah dokumentasi: langsung tampil, lalu disimpan ke Supabase.
  /// Mengembalikan false bila gagal disimpan ke server (item tetap tampil
  /// selama aplikasi terbuka).
  Future<bool> addCookDoc(CookDocItem item) async {
    _items.insert(0, item);
    notifyListeners();

    final uid = _userId;
    if (uid == null) return false;
    try {
      await _repo.saveCookDoc(
        userId: uid,
        recipeId: item.recipeId,
        photoPath: item.photoPath,
        note: item.notes,
        rating: item.rating,
        tags: item.tags,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
