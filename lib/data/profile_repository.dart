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

  Future<List<CookDoc>> listCookDocs({int limit = 24}) async {
    final rows = await _db
        .from('cook_docs')
        .select('id,image_path,created_at,recipes(title)')
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
        recipeTitle: (m['recipes'] as Map?)?['title'] as String?,
        imageUrl: url,
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      );
    }));
  }

  /// Unggah foto (dari galeri) ke Storage lalu catat di tabel `cook_docs`.
  Future<void> uploadCookDoc({
    required String userId,
    required XFile file,
    int? recipeId,
    String? note,
  }) async {
    final bytes = await file.readAsBytes();
    final ext = _extension(file.name);
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _db.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: _mime(ext)),
        );
    await _db.from('cook_docs').insert({
      'user_id': userId,
      'recipe_id': recipeId,
      'image_path': path,
      'note': note,
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
