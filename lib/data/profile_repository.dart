import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';

/// Profil pengguna dan dokumentasi masak.
class ProfileRepository {
  ProfileRepository(this._db);

  final SupabaseClient _db;

  Future<UserProfile?> fetchProfile(String userId) async {
    final r = await _db
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return r == null ? null : UserProfile.fromJson(r);
  }

  /// Simpan/ubah profil.
  Future<void> saveProfile({
    required String userId,
    String? fullName,
    required String gender,
    required int age,
    required double weightKg,
    required double heightCm,
    required int activityLevel,
  }) async {
    await _db.from('profiles').upsert({
      'user_id': userId,
      if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
      'gender': gender,
      'age': age,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'activity_level': activityLevel,
    }, onConflict: 'user_id');
  }

  Future<List<CookDoc>> listCookDocs({int limit = 48}) async {
    final rows =
        await _db
                .from('cook_docs')
                .select(
                  'id,recipe_id,note,rating,tags,created_at,recipes(title)',
                )
                .order('created_at', ascending: false)
                .limit(limit)
            as List;

    return rows.map((e) {
      final m = e as Map<String, dynamic>;
      return CookDoc(
        id: m['id'] as String,
        recipeId: (m['recipe_id'] as num?)?.toInt(),
        recipeTitle: (m['recipes'] as Map?)?['title'] as String?,
        imageUrl: null,
        rating: (m['rating'] as num?)?.toDouble(),
        tags: ((m['tags'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        note: (m['note'] as String?) ?? '',
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      );
    }).toList();
  }

  /// Simpan dokumentasi masak: catat di `cook_docs` tanpa upload Storage,
  /// mengembalikan id baris (UUID). Foto disimpan lokal di perangkat.
  Future<String> saveCookDoc({
    required String userId,
    int? recipeId,
    String? note,
    double? rating,
    List<String> tags = const [],
  }) async {
    final res = await _db
        .from('cook_docs')
        .insert({
          'user_id': userId,
          'recipe_id': recipeId,
          'note': (note == null || note.isEmpty) ? null : note,
          'rating': rating,
          'tags': tags,
        })
        .select('id')
        .single();
    return res['id'] as String;
  }
}
