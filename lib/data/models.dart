/// Model data SmartCook (hasil query Supabase).

class IngredientHit {
  const IngredientHit({required this.id, required this.name, required this.sim});

  final int id;
  final String name;
  final double sim;
}

/// Satu baris hasil fungsi SQL `match_recipes`.
class RecipeMatch {
  const RecipeMatch({
    required this.id,
    required this.title,
    required this.category,
    required this.totalSteps,
    required this.matched,
    required this.total,
    required this.score,
    required this.matchedNames,
    this.kalori,
    this.beratG,
  });

  /// Total kalori & berat seluruh bahan resep (bukan per porsi).
  final double? kalori;
  final double? beratG;

  final int id;
  final String title;
  final String? category;
  final int totalSteps;

  /// Jumlah bahan resep (non-pokok) yang dimiliki pengguna.
  final int matched;

  /// Jumlah bahan resep (non-pokok) seluruhnya.
  final int total;

  /// 0..1, berbobot IDF.
  final double score;
  final List<String> matchedNames;

  int get percent => (score * 100).round().clamp(0, 100);

  RecipeMatch withNutrition({double? kalori, double? beratG}) => RecipeMatch(
        id: id,
        title: title,
        category: category,
        totalSteps: totalSteps,
        matched: matched,
        total: total,
        score: score,
        matchedNames: matchedNames,
        kalori: kalori,
        beratG: beratG,
      );

  RecipeSummary toSummary() => RecipeSummary(
        id: id,
        title: title,
        category: category,
        totalSteps: totalSteps,
        totalIngredients: total,
        kalori: kalori,
        beratG: beratG,
      );

  factory RecipeMatch.fromJson(Map<String, dynamic> j) => RecipeMatch(
        id: (j['id'] as num).toInt(),
        title: j['title'] as String,
        category: j['category'] as String?,
        totalSteps: (j['total_steps'] as num?)?.toInt() ?? 0,
        matched: (j['matched'] as num).toInt(),
        total: (j['total'] as num).toInt(),
        score: (j['score'] as num).toDouble(),
        matchedNames: ((j['matched_names'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        kalori: (j['kalori'] as num?)?.toDouble(),
        beratG: (j['berat_g'] as num?)?.toDouble(),
      );
}

/// Ringkasan resep untuk daftar (beranda, resep disimpan).
class RecipeSummary {
  const RecipeSummary({
    required this.id,
    required this.title,
    required this.category,
    required this.totalSteps,
    required this.totalIngredients,
    this.kalori,
    this.beratG,
  });

  /// Total kalori & berat seluruh bahan resep (bukan per porsi).
  final double? kalori;
  final double? beratG;

  final int id;
  final String title;
  final String? category;
  final int totalSteps;
  final int totalIngredients;

  factory RecipeSummary.fromJson(Map<String, dynamic> j) => RecipeSummary(
        id: (j['id'] as num).toInt(),
        title: j['title'] as String,
        category: j['category'] as String?,
        totalSteps: (j['total_steps'] as num?)?.toInt() ?? 0,
        totalIngredients: (j['total_ingredients'] as num?)?.toInt() ?? 0,
        kalori: (j['kalori'] as num?)?.toDouble(),
        beratG: (j['berat_g'] as num?)?.toDouble(),
      );
}

class RecipeDetail {
  const RecipeDetail({
    required this.id,
    required this.title,
    required this.category,
    required this.steps,
    required this.ingredients,
    this.kalori,
    this.proteinG,
    this.lemakG,
    this.karboG,
    this.beratG,
    this.quantities = const {},
  });

  /// Takaran per bahan (nama baku -> mis. "2 siung"); kosong bila belum ada datanya.
  final Map<String, String> quantities;

  /// Perkiraan gizi TOTAL seluruh bahan resep (bukan per porsi). Null kalau tidak ada.
  final double? kalori;
  final double? proteinG;
  final double? lemakG;
  final double? karboG;

  /// Total berat bahan (gram).
  final double? beratG;

  final int id;
  final String title;
  final String? category;

  /// Langkah-langkah, sudah dipisah per baris dan dibersihkan dari nomor "1)".
  final List<String> steps;
  final List<String> ingredients;
}

class UserProfile {
  const UserProfile({
    this.fullName,
    this.gender,
    this.age,
    this.weightKg,
    this.heightCm,
    this.targetKkal,
    this.activityLevel,
  });

  final String? fullName;
  final String? gender;
  final int? age;
  final double? weightKg;
  final double? heightCm;
  final int? targetKkal;

  /// Indeks tingkat aktivitas (0 = jarang bergerak ... 3 = sangat aktif).
  final int? activityLevel;

  double? get bmi {
    final w = weightKg, h = heightCm;
    if (w == null || h == null || h <= 0) return null;
    final m = h / 100;
    return w / (m * m);
  }

  String? get bmiLabel {
    final b = bmi;
    if (b == null) return null;
    if (b < 18.5) return 'Kurus';
    if (b < 25) return 'Ideal';
    if (b < 30) return 'Gemuk';
    return 'Obesitas';
  }

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        fullName: j['full_name'] as String?,
        gender: j['gender'] as String?,
        age: (j['age'] as num?)?.toInt(),
        weightKg: (j['weight_kg'] as num?)?.toDouble(),
        heightCm: (j['height_cm'] as num?)?.toDouble(),
        targetKkal: (j['target_kkal'] as num?)?.toInt(),
        activityLevel: (j['activity_level'] as num?)?.toInt(),
      );
}

class CookDoc {
  const CookDoc({
    required this.id,
    required this.recipeTitle,
    required this.imageUrl,
    required this.createdAt,
    this.recipeId,
    this.rating,
    this.tags = const [],
    this.note = '',
  });

  final String id;
  final int? recipeId;
  final double? rating;
  final List<String> tags;
  final String note;
  final String? recipeTitle;

  /// Signed URL (berlaku sementara); null kalau gagal dibuat.
  final String? imageUrl;
  final DateTime createdAt;
}

/// Satu bahan baku di katalog (view `ingredient_catalog`).
class CatalogIngredient {
  const CatalogIngredient({
    required this.id,
    required this.name,
    required this.category,
    required this.isStaple,
    required this.recipeCount,
  });

  final int id;
  final String name;
  final String category;
  final bool isStaple;

  /// Jumlah resep yang memakai bahan ini (dipakai untuk mengurutkan populer dulu).
  final int recipeCount;

  factory CatalogIngredient.fromJson(Map<String, dynamic> j) => CatalogIngredient(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String,
        category: (j['category'] as String?) ?? 'Lainnya',
        isStaple: (j['is_staple'] as bool?) ?? false,
        recipeCount: (j['recipe_count'] as num?)?.toInt() ?? 0,
      );
}
