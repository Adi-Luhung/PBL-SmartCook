import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';

/// Profil pengguna dan dokumentasi masak (foto dari galeri).
class ProfileRepository {
  ProfileRepository(this._db);

  final SupabaseClient _db;

  static const _bucket = 'cook-docs';

  Future<UserProfile?> fetchProfile(String userId) async {
    final r = await _db
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return r == null ? null : UserProfile.fromJson(r);
  }

  /// Simpan/ubah profil (BMI dihitung dari berat & tinggi, target kalori dari TDEE + kategori BMI).
  Future<void> saveProfile({
    required String userId,
    String? fullName,
    required String gender,
    required int age,
    required double weightKg,
    required double heightCm,
    required int targetKkal,
    required int activityLevel,
  }) async {
    await _db.from('profiles').upsert({
      'user_id': userId,
      if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
      'gender': gender,
      'age': age,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'target_kkal': targetKkal,
      'activity_level': activityLevel,
    }, onConflict: 'user_id');
  }

  Future<List<CookDoc>> listCookDocs({int limit = 48}) async {
    final rows = await _db
        .from('cook_docs')
        .select('id,recipe_id,image_path,note,rating,tags,created_at,recipes(title)')
        .order('created_at', ascending: false)
        .limit(limit) as List;

    return Future.wait(rows.map((e) async {
      final m = e as Map<String, dynamic>;
      final path = m['image_path'] as String?;
      String? url;
      if (path != null && path.isNotEmpty) {
        try {
          url = await _db.storage.from(_bucket).createSignedUrl(path, 3600);
        } catch (_) {
          url = null;
        }
      }
      return CookDoc(
        id: m['id'] as String,
        recipeId: (m['recipe_id'] as num?)?.toInt(),
        recipeTitle: (m['recipes'] as Map?)?['title'] as String?,
        imageUrl: url,
        rating: (m['rating'] as num?)?.toDouble(),
        tags: ((m['tags'] as List?) ?? const []).map((e) => e.toString()).toList(),
        note: (m['note'] as String?) ?? '',
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      );
    }));
  }

  /// Simpan dokumentasi masak: unggah foto (kalau ada) ke Storage lalu catat di `cook_docs`.
  Future<void> saveCookDoc({
    required String userId,
    int? recipeId,
    String? photoPath,
    String? note,
    double? rating,
    List<String> tags = const [],
  }) async {
    String? path;
    if (photoPath != null && photoPath.isNotEmpty) {
      final file = XFile(photoPath);
      final bytes = await file.readAsBytes();
      final ext = _extension(file.name);
      path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _db.storage.from(_bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: _mime(ext)),
          );
    }
    await _db.from('cook_docs').insert({
      'user_id': userId,
      'recipe_id': recipeId,
      'image_path': path,
      'note': (note == null || note.isEmpty) ? null : note,
      'rating': rating,
      'tags': tags,
    });
  }

  static String _extension(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return 'jpg';
    final ext = name.substring(dot + 1).toLowerCase();
    return const {'jpg', 'jpeg', 'png', 'webp', 'heic'}.contains(ext)
        ? ext
        : 'jpg';
  }

  static String _mime(String ext) => switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'heic' => 'image/heic',
        _ => 'image/jpeg',
      };
}
