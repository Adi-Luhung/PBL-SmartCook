import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/profile_repository.dart';

class CookDocItem {
  const CookDocItem({
    this.id,
    required this.name,
    required this.time,
    this.photoPath,
    this.imageUrl,
    this.rating = 5.0,
    this.tags = const [],
    this.notes = '',
    this.recipeId,
  });

  final String? id;
  final String name;
  final String time;

  /// Foto lokal (di dokumen aplikasi atau baru dipilih dari galeri/kamera).
  final String? photoPath;

  /// URL foto cadangan (jika ada); null jika hanya lokal.
  final String? imageUrl;
  final double rating;
  final List<String> tags;
  final String notes;

  /// Resep database yang dimasak; null untuk foto lepas.
  final int? recipeId;
}

/// Jurnal dapur: daftar dokumentasi masak. Metadata disimpan di tabel `cook_docs`
/// Supabase, sedangkan file foto disimpan secara lokal di perangkat pengguna.
class CookDocService extends ChangeNotifier {
  CookDocService._();
  static final CookDocService instance = CookDocService._();

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const _spMapPrefix = 'cook_doc_photos_';

  final List<CookDocItem> _items = [];

  List<CookDocItem> get items => List.unmodifiable(_items);

  ProfileRepository get _repo => ProfileRepository(Supabase.instance.client);
  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  static String _relative(DateTime t) {
    final now = DateTime.now();
    final days = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(t.year, t.month, t.day)).inDays;
    if (days <= 0) return 'Hari ini';
    if (days == 1) return 'Kemarin';
    if (days < 7) return '$days hari lalu';
    return '${t.day} ${_months[t.month - 1]}';
  }

  Future<Directory> get _cookDocsDir async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${docsDir.path}/cook_docs');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  String _mapKey(String userId) => '$_spMapPrefix$userId';

  Future<Map<String, String>> _loadPhotoMap(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_mapKey(userId));
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> _savePhotoMap(String userId, Map<String, String> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mapKey(userId), jsonEncode(map));
  }

  /// Muat jurnal pengguna dari Supabase dan gabungkan dengan foto lokal di perangkat.
  Future<void> loadFromServer() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      final photoMap = await _loadPhotoMap(uid);
      final docs = await _repo.listCookDocs();
      _items
        ..clear()
        ..addAll(
          docs.map((d) {
            final localPath = photoMap[d.id];
            final hasFile = localPath != null && File(localPath).existsSync();
            return CookDocItem(
              id: d.id,
              name: d.recipeTitle ?? 'Masakanku',
              time: _relative(d.createdAt),
              photoPath: hasFile ? localPath : null,
              imageUrl: null,
              rating: d.rating ?? 5.0,
              tags: d.tags,
              notes: d.note,
              recipeId: d.recipeId,
            );
          }),
        );
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

  /// Tambah dokumentasi: simpan metadata ke database dan salin foto ke penyimpanan lokal perangkat.
  Future<bool> addCookDoc(CookDocItem item) async {
    final uid = _userId;
    if (uid == null) {
      _items.insert(0, item);
      notifyListeners();
      return false;
    }

    try {
      final docId = await _repo.saveCookDoc(
        userId: uid,
        recipeId: item.recipeId,
        note: item.notes,
        rating: item.rating,
        tags: item.tags,
      );

      String? savedLocalPath;
      if (item.photoPath != null && File(item.photoPath!).existsSync()) {
        final dir = await _cookDocsDir;
        final targetPath = '${dir.path}/$docId.jpg';
        await File(item.photoPath!).copy(targetPath);
        savedLocalPath = targetPath;

        final photoMap = await _loadPhotoMap(uid);
        photoMap[docId] = targetPath;
        await _savePhotoMap(uid, photoMap);
      }

      final savedItem = CookDocItem(
        id: docId,
        name: item.name,
        time: item.time,
        photoPath: savedLocalPath ?? item.photoPath,
        imageUrl: null,
        rating: item.rating,
        tags: item.tags,
        notes: item.notes,
        recipeId: item.recipeId,
      );

      _items.insert(0, savedItem);
      notifyListeners();
      return true;
    } catch (_) {
      _items.insert(0, item);
      notifyListeners();
      return false;
    }
  }
}
