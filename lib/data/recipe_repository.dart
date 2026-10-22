import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';

/// Akses data resep, bahan, dan bookmark di Supabase.
class RecipeRepository {
  RecipeRepository(this._db);

  final SupabaseClient _db;

  // ── Bahan ────────────────────────────────────────────────────────────────

  /// Cari bahan baku dari teks bebas (sinonim & typo ditangani di database
  /// lewat tabel `ingredient_aliases` + pg_trgm). Null jika tidak mirip apa pun.
  Future<IngredientHit?> findIngredient(String text,
      {double minSim = 0.35}) async {
    final q = text.trim().toLowerCase();
    if (q.isEmpty) return null;
    final res = await _db.rpc('find_ingredient', params: {'q': q}) as List;
    if (res.isEmpty) return null;
    final top = res.first as Map<String, dynamic>;
    final sim = (top['sim'] as num).toDouble();
    if (sim < minSim) return null;
    return IngredientHit(
      id: (top['id'] as num).toInt(),
      name: top['name'] as String,
      sim: sim,
    );
  }

  /// Ubah daftar nama (mis. "Telur Ayam", "Garam & Merica") menjadi bahan baku
  /// di database (ID + nama baku), tanpa duplikat.
  Future<List<IngredientHit>> resolveIngredients(Iterable<String> names) async {
    final hits = <int, IngredientHit>{};
    for (final raw in names) {
      for (final part in raw.split('&')) {
        final hit = await findIngredient(part);
        if (hit != null) hits[hit.id] = hit;
      }
    }
    return hits.values.toList();
  }

  /// Seluruh bahan baku beserta kategorinya, populer dulu.
  Future<List<CatalogIngredient>> catalog() async {
    final res = await _db
        .from('ingredient_catalog')
        .select('id,name,category,is_staple,recipe_count')
        .order('recipe_count', ascending: false) as List;
    return res
        .map((e) => CatalogIngredient.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Resep ────────────────────────────────────────────────────────────────

  Future<List<RecipeMatch>> matchRecipes(List<int> ingredientIds,
      {int limit = 20}) async {
    if (ingredientIds.isEmpty) return [];
    final res = await _db.rpc('match_recipes', params: {
      'ingredient_ids': ingredientIds,
      'lim': limit,
    }) as List;
    var list = res
        .map((e) => RecipeMatch.fromJson(e as Map<String, dynamic>))
        .toList();

    // Fungsi SQL versi lama belum mengembalikan kalori & berat: lengkapi lewat
    // satu query tambahan supaya kartu tidak menampilkan "0 kkal".
    if (list.any((r) => r.kalori == null)) {
      final extra = await _db
              .from('recipes')
              .select('id,kalori,berat_g')
              .inFilter('id', list.map((r) => r.id).toList()) as List;
      final byId = {
        for (final e in extra) (e['id'] as num).toInt(): e as Map<String, dynamic>,
      };
      list = [
        for (final r in list)
          r.kalori != null || byId[r.id] == null
              ? r
              : r.withNutrition(
                  kalori: (byId[r.id]!['kalori'] as num?)?.toDouble(),
                  beratG: (byId[r.id]!['berat_g'] as num?)?.toDouble(),
                ),
      ];
    }
    return list;
  }

  Future<List<RecipeSummary>> featured({int limit = 5}) async {
    final res = await _db
        .from('recipes')
        .select('id,title,category,total_steps,total_ingredients,kalori,berat_g')
        .order('id')
        .limit(limit) as List;
    return res
        .map((e) => RecipeSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Daftar resep untuk halaman Eksplorasi. [maxKkal] = hanya resep dengan kalori per porsi
  /// <= nilai itu (Diet Sehat); [minKkal] = hanya yang di atasnya (Non-Diet).
  Future<List<RecipeSummary>> exploreRecipes({
    String? category,
    double? maxKkal,
    double? minKkal,
    int limit = 15,
    int offset = 0,
  }) async {
    var query = _db
        .from('recipes')
        .select('id,title,category,total_steps,total_ingredients,kalori,berat_g');
    if (category != null) query = query.eq('category', category);
    if (maxKkal != null) query = query.lte('kkal_porsi', maxKkal);
    if (minKkal != null) query = query.gt('kkal_porsi', minKkal);
    final res = await query.order('id').range(offset, offset + limit - 1) as List;
    return res
        .map((e) => RecipeSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cari resep berdasarkan judul atau nama bahan (semua kata kunci harus cocok).
  Future<List<RecipeSummary>> searchRecipes(String query,
      {String? category, double? maxKkal, double? minKkal, int limit = 30}) async {
    final res = await _db.rpc('search_recipes', params: {
      'q': query,
      'cat': category,
      'lim': limit,
      'max_kkal': maxKkal,
      'min_kkal': minKkal,
    }) as List;
    return res
        .map((e) => RecipeSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RecipeDetail> detail(int id) async {
    const base = 'id,title,steps,category,kalori,protein_g,lemak_g,karbo_g,berat_g';
    Map<String, dynamic> r;
    try {
      r = await _db
          .from('recipes')
          .select('$base,recipe_ingredients(takaran,ingredients(name))')
          .eq('id', id)
          .single();
    } catch (_) {
      // Kolom `takaran` belum ada (migrasi 005 belum dijalankan): tampilkan tanpa takaran.
      r = await _db
          .from('recipes')
          .select('$base,recipe_ingredients(ingredients(name))')
          .eq('id', id)
          .single();
    }

    final quantities = <String, String>{};
    final ingredients = <String>[];
    for (final e in (r['recipe_ingredients'] as List?) ?? const []) {
      final name = ((e as Map)['ingredients'] as Map)['name'] as String;
      ingredients.add(name);
      final q = (e['takaran'] as String?)?.trim();
      if (q != null && q.isNotEmpty) quantities[name] = q;
    }
    ingredients.sort();

    final steps = ((r['steps'] as String?) ?? '')
        .split('\n')
        .map((s) => _cleanStep(s.replaceFirst(RegExp(r'^\s*\d+\)\s*'), '')))
        .where((s) => s.isNotEmpty)
        .toList();

    return RecipeDetail(
      id: (r['id'] as num).toInt(),
      title: r['title'] as String,
      category: r['category'] as String?,
      steps: steps,
      ingredients: ingredients,
      quantities: quantities,
      kalori: (r['kalori'] as num?)?.toDouble(),
      proteinG: (r['protein_g'] as num?)?.toDouble(),
      lemakG: (r['lemak_g'] as num?)?.toDouble(),
      karboG: (r['karbo_g'] as num?)?.toDouble(),
      beratG: (r['berat_g'] as num?)?.toDouble(),
    );
  }

  /// Rapikan teks langkah dari dataset: " n " -> " dan ", spasi setelah koma,
  /// huruf awal kapital.
  static String _cleanStep(String raw) {
    var s = raw.trim();
    s = s.replaceAll(RegExp(r'\s+n\s+'), ' dan ');
    s = s.replaceAllMapped(RegExp(r'(?<=[A-Za-z]),(?=[A-Za-z])'), (m) => ', ');
    s = s.replaceAll(RegExp(r'\s{2,}'), ' ');
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // ── Bookmark ─────────────────────────────────────────────────────────────

  Future<void> addBookmark(int recipeId, String userId) async {
    await _db
        .from('bookmarks')
        .insert({'user_id': userId, 'recipe_id': recipeId});
  }

  Future<void> removeBookmark(int recipeId, String userId) async {
    await _db
        .from('bookmarks')
        .delete()
        .eq('user_id', userId)
        .eq('recipe_id', recipeId);
  }

  Future<List<RecipeSummary>> bookmarkedRecipes() async {
    final res = await _db
        .from('bookmarks')
        .select(
            'created_at, recipes(id,title,category,total_steps,total_ingredients,kalori,berat_g)')
        .order('created_at', ascending: false) as List;
    return res
        .map((e) => (e as Map)['recipes'])
        .whereType<Map<String, dynamic>>()
        .map(RecipeSummary.fromJson)
        .toList();
  }
}
