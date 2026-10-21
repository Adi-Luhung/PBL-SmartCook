import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models.dart';
import '../../data/recipe_repository.dart';
import '../utils/nutrition.dart';

class SavedRecipe {
  const SavedRecipe({
    required this.name,
    required this.time,
    required this.ingredients,
    this.imageUrl,
    this.imageAsset,
    this.calories = 0,
    this.isDiet = false,
    this.portions = 2,
    this.ingredientList = const [],
    this.stepList = const [],
    this.recipeId,
  });

  /// Resep dari database (disimpan juga di tabel `bookmarks`).
  factory SavedRecipe.fromSummary(RecipeSummary s) => SavedRecipe(
        recipeId: s.id,
        name: s.title,
        time: '${s.totalSteps} Langkah',
        ingredients: '${s.totalIngredients} Bahan',
        calories: caloriesPerPortion(s.kalori, s.beratG),
        portions: estimatePortions(s.beratG),
      );

  /// ID resep di database; null = resep lokal (mis. data contoh di Eksplorasi).
  final int? recipeId;

  final String name;
  final String time;
  final String ingredients;
  final String? imageUrl;
  final String? imageAsset;
  final int calories;
  final bool isDiet;
  final int portions;
  final List<String> ingredientList;
  final List<Map<String, String>> stepList;
}

class BookmarkService extends ChangeNotifier {
  BookmarkService._();
  static final BookmarkService instance = BookmarkService._();

  // Daftar awal kosong. Bookmark resep database dimuat dari Supabase lewat
  // [loadFromServer]; resep lokal (data contoh) hanya hidup selama aplikasi jalan.
  final List<SavedRecipe> _savedRecipes = [];

  List<SavedRecipe> get savedRecipes => List.unmodifiable(_savedRecipes);

  bool isBookmarked(String title) {
    return _savedRecipes
        .any((r) => r.name.toLowerCase() == title.toLowerCase());
  }

  bool isRecipeBookmarked(int recipeId) =>
      _savedRecipes.any((r) => r.recipeId == recipeId);

  RecipeRepository get _repo => RecipeRepository(Supabase.instance.client);
  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  /// Muat bookmark pengguna dari Supabase (dipanggil setelah login).
  Future<void> loadFromServer() async {
    if (_userId == null) return;
    try {
      final rows = await _repo.bookmarkedRecipes();
      _savedRecipes
        ..removeWhere((r) => r.recipeId != null)
        ..insertAll(0, rows.map(SavedRecipe.fromSummary));
      notifyListeners();
    } catch (_) {
      // Biarkan daftar apa adanya; dimuat ulang saat aplikasi dibuka lagi.
    }
  }

  /// Bersihkan bookmark milik akun yang baru keluar.
  void clearServerBacked() {
    _savedRecipes.removeWhere((r) => r.recipeId != null);
    notifyListeners();
  }

  /// Simpan/hapus resep database. UI diperbarui dulu (optimistic) dan
  /// dikembalikan kalau server gagal; error dilempar ke pemanggil.
  Future<void> toggleRecipe(SavedRecipe recipe) async {
    final id = recipe.recipeId;
    final uid = _userId;
    if (id == null || uid == null) return;

    final index = _savedRecipes.indexWhere((r) => r.recipeId == id);
    final wasSaved = index >= 0;
    final removed = wasSaved ? _savedRecipes.removeAt(index) : null;
    if (!wasSaved) _savedRecipes.insert(0, recipe);
    notifyListeners();

    try {
      if (wasSaved) {
        await _repo.removeBookmark(id, uid);
      } else {
        await _repo.addBookmark(id, uid);
      }
    } catch (_) {
      if (wasSaved) {
        _savedRecipes.insert(index.clamp(0, _savedRecipes.length), removed!);
      } else {
        _savedRecipes.removeWhere((r) => r.recipeId == id);
      }
      notifyListeners();
      rethrow;
    }
  }

  void toggleBookmark(SavedRecipe recipe) {
    if (recipe.recipeId != null) {
      unawaited(toggleRecipe(recipe).catchError((_) {}));
      return;
    }
    final index = _savedRecipes.indexWhere(
      (r) => r.name.toLowerCase() == recipe.name.toLowerCase(),
    );
    if (index >= 0) {
      _savedRecipes.removeAt(index);
    } else {
      _savedRecipes.insert(0, recipe);
    }
    notifyListeners();
  }

  void removeBookmark(String title) {
    _savedRecipes.removeWhere(
      (r) => r.name.toLowerCase() == title.toLowerCase(),
    );
    notifyListeners();
  }
}
