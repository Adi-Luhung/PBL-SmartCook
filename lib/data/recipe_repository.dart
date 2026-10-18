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

  /// Ubah daftar nama (mis. "Telur Ayam", "Garam & Merica") menjadi ID bahan.
  Future<List<int>> resolveIngredientIds(Iterable<String> names) async {
    final ids = <int>{};
    for (final raw in names) {
      for (final part in raw.split('&')) {
        final hit = await findIngredient(part);
        if (hit != null) ids.add(hit.id);
      }
    }
    return ids.toList();
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
    return res
        .map((e) => RecipeMatch.fromJson(e as Map<String, dynamic>))
        .toList();
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

  Future<RecipeDetail> detail(int id) async {
    final r = await _db
        .from('recipes')
        .select(
            'id,title,steps,category,kalori,protein_g,lemak_g,karbo_g,berat_g,'
            'recipe_ingredients(ingredients(name))')
        .eq('id', id)
        .single();

    final ingredients = ((r['recipe_ingredients'] as List?) ?? const [])
        .map((e) => ((e as Map)['ingredients'] as Map)['name'] as String)
        .toList()
      ..sort();

    final steps = ((r['steps'] as String?) ?? '')
        .split('\n')
        .map((s) => s.replaceFirst(RegExp(r'^\s*\d+\)\s*'), '').trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return RecipeDetail(
      id: (r['id'] as num).toInt(),
      title: r['title'] as String,
      category: r['category'] as String?,
      steps: steps,
      ingredients: ingredients,
      kalori: (r['kalori'] as num?)?.toDouble(),
      proteinG: (r['protein_g'] as num?)?.toDouble(),
      lemakG: (r['lemak_g'] as num?)?.toDouble(),
      karboG: (r['karbo_g'] as num?)?.toDouble(),
      beratG: (r['berat_g'] as num?)?.toDouble(),
    );
  }

  // ── Bookmark ─────────────────────────────────────────────────────────────

  /// ID resep yang di-bookmark pengguna login (RLS membatasi ke milik sendiri).
  Future<Set<int>> bookmarkedIds() async {
    final res = await _db.from('bookmarks').select('recipe_id') as List;
    return res.map((e) => ((e as Map)['recipe_id'] as num).toInt()).toSet();
  }

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
