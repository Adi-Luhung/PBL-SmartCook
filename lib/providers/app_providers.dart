import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/ml_service.dart';
import '../core/utils/nutrition.dart';
import '../data/models.dart';
import '../data/profile_repository.dart';
import '../data/recipe_repository.dart';

// ── Infrastruktur ──────────────────────────────────────────────────────────

final supabaseProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

final recipeRepositoryProvider = Provider<RecipeRepository>(
    (ref) => RecipeRepository(ref.watch(supabaseProvider)));

final profileRepositoryProvider = Provider<ProfileRepository>(
    (ref) => ProfileRepository(ref.watch(supabaseProvider)));

// ── Auth ───────────────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<AuthState>(
    (ref) => ref.watch(supabaseProvider).auth.onAuthStateChange);

/// ID pengguna yang sedang login (null kalau belum login). Provider lain
/// memantau ini, jadi datanya otomatis dimuat ulang saat ganti akun.
final currentUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.value?.session?.user.id ??
      ref.watch(supabaseProvider).auth.currentUser?.id;
});

// ── Pencarian resep dari bahan ─────────────────────────────────────────────

class SearchQuery {
  const SearchQuery({
    this.names = const [],
    this.ids = const [],
    this.canonical = const [],
  });

  /// Nama bahan seperti yang dipilih pengguna (untuk ditampilkan).
  final List<String> names;

  /// ID bahan baku di database (untuk query).
  final List<int> ids;

  /// Nama baku bahan di database (mis. "ayam", "cabai rawit").
  final List<String> canonical;
}

class SearchQueryNotifier extends Notifier<SearchQuery> {
  @override
  SearchQuery build() => const SearchQuery();

  void set(SearchQuery query) => state = query;
  void clear() => state = const SearchQuery();
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, SearchQuery>(SearchQueryNotifier.new);

final recommendationsProvider = FutureProvider<List<RecipeMatch>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final repo = ref.watch(recipeRepositoryProvider);
  return repo.matchRecipes(query.ids);
});

final ingredientCatalogProvider = FutureProvider<List<CatalogIngredient>>(
    (ref) => ref.watch(recipeRepositoryProvider).catalog());

final featuredRecipesProvider = FutureProvider<List<RecipeSummary>>(
    (ref) => ref.watch(recipeRepositoryProvider).featured(limit: 5));

final recipeDetailProvider = FutureProvider.family<RecipeDetail, int>(
    (ref, id) => ref.watch(recipeRepositoryProvider).detail(id));

// ── Profil & dokumentasi masak ─────────────────────────────────────────────

/// Anggaran kalori per kali makan berbasis skor BMI × TDEE (Modul 3 Machine Learning).
final mealBudgetProvider = Provider<int>((ref) {
  final profile = ref.watch(profileProvider).value;
  if (profile != null && profile.mealCalorieBudget != null) {
    return profile.mealCalorieBudget!;
  }
  return mealBudgetFor(profile?.targetKkal);
});

/// Kategori Diet personal pengguna berdasarkan Decision Tree BMI x TDEE.
final userDietCategoryProvider = Provider<String?>((ref) {
  return ref.watch(profileProvider).value?.dietCategory;
});

final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  final repo = ref.watch(profileRepositoryProvider);
  if (uid == null) return null;
  return repo.fetchProfile(uid);
});

final recipeReviewsProvider = FutureProvider.family<List<RecipeReview>, int>(
    (ref, recipeId) =>
        ref.watch(recipeRepositoryProvider).fetchReviews(recipeId));


// ── Machine Learning Microservice ──────────────────────────────────────────

final mlServiceProvider = Provider<MlService>((ref) => MlService());

/// Status koneksi ke server Machine Learning
final mlApiAvailableProvider = FutureProvider<bool>(
    (ref) => ref.watch(mlServiceProvider).isAvailable());

/// Prediksi diet personal dari model Machine Learning (Decision Tree)
final mlDietPredictionProvider = FutureProvider<MlDietResult?>((ref) async {
  final profile = ref.watch(profileProvider).value;
  if (profile == null) return null;
  final bmi = profile.bmi;
  final tdee = profile.tdee;
  if (bmi == null || tdee == null) return null;

  return ref.watch(mlServiceProvider).predictDiet(
        bmi: bmi,
        tdee: tdee,
        weightKg: profile.weightKg,
        heightCm: profile.heightCm,
        age: profile.age,
        gender: profile.gender,
      );
});
