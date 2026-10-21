import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

/// Anggaran kalori per kali makan (target harian / 3), dasar label Diet/Non-Diet.
final mealBudgetProvider = Provider<int>(
    (ref) => mealBudgetFor(ref.watch(profileProvider).value?.targetKkal));

final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  final repo = ref.watch(profileRepositoryProvider);
  if (uid == null) return null;
  return repo.fetchProfile(uid);
});
