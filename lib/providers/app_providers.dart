import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models.dart';
import '../data/profile_repository.dart';
import '../data/recipe_repository.dart';

// ── Infrastruktur ──────────────────────────────────────────────────────────

final supabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => RecipeRepository(ref.watch(supabaseProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(supabaseProvider)),
);

// ── Auth ───────────────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(supabaseProvider).auth.onAuthStateChange,
);

/// ID pengguna yang sedang login (null kalau belum login). Provider lain
/// memantau ini, jadi datanya otomatis dimuat ulang saat ganti akun.
final currentUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.value?.session?.user.id ??
      ref.watch(supabaseProvider).auth.currentUser?.id;
});

// ── Pencarian resep dari bahan ─────────────────────────────────────────────

class SearchQuery {
  const SearchQuery({this.names = const [], this.ids = const []});

  /// Nama bahan seperti yang dipilih pengguna (untuk ditampilkan).
  final List<String> names;

  /// ID bahan baku di database (untuk query).
  final List<int> ids;
}

class SearchQueryNotifier extends Notifier<SearchQuery> {
  @override
  SearchQuery build() => const SearchQuery();

  void set(SearchQuery query) => state = query;
  void clear() => state = const SearchQuery();
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, SearchQuery>(
  SearchQueryNotifier.new,
);

final recommendationsProvider = FutureProvider<List<RecipeMatch>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final repo = ref.watch(recipeRepositoryProvider);
  return repo.matchRecipes(query.ids);
});

final ingredientCatalogProvider = FutureProvider<List<CatalogIngredient>>(
  (ref) => ref.watch(recipeRepositoryProvider).catalog(),
);

final featuredRecipesProvider = FutureProvider<List<RecipeSummary>>(
  (ref) => ref.watch(recipeRepositoryProvider).featured(limit: 5),
);

final recipeDetailProvider = FutureProvider.family<RecipeDetail, int>(
  (ref, id) => ref.watch(recipeRepositoryProvider).detail(id),
);

// ── Bookmark ───────────────────────────────────────────────────────────────

class BookmarkNotifier extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() async {
    final uid = ref.watch(currentUserIdProvider);
    final repo = ref.watch(recipeRepositoryProvider);
    if (uid == null) return <int>{};
    return repo.bookmarkedIds();
  }

  /// Simpan / hapus bookmark. UI diperbarui dulu (optimistic), dikembalikan
  /// kalau request gagal.
  Future<void> toggle(int recipeId) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final repo = ref.read(recipeRepositoryProvider);

    final before = Set<int>.of(state.value ?? <int>{});
    final wasSaved = before.contains(recipeId);
    final after = Set<int>.of(before);
    wasSaved ? after.remove(recipeId) : after.add(recipeId);
    state = AsyncData(after);

    try {
      if (wasSaved) {
        await repo.removeBookmark(recipeId, uid);
      } else {
        await repo.addBookmark(recipeId, uid);
      }
      ref.invalidate(savedRecipesProvider);
    } catch (_) {
      state = AsyncData(before);
      rethrow;
    }
  }
}

final bookmarkProvider = AsyncNotifierProvider<BookmarkNotifier, Set<int>>(
  BookmarkNotifier.new,
);

final savedRecipesProvider = FutureProvider<List<RecipeSummary>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  final repo = ref.watch(recipeRepositoryProvider);
  if (uid == null) return [];
  return repo.bookmarkedRecipes();
});

// ── Profil & dokumentasi masak ─────────────────────────────────────────────

final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  final repo = ref.watch(profileRepositoryProvider);
  if (uid == null) return null;
  return repo.fetchProfile(uid);
});

final cookDocsProvider = FutureProvider<List<CookDoc>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  final repo = ref.watch(profileRepositoryProvider);
  if (uid == null) return [];
  return repo.listCookDocs();
});
