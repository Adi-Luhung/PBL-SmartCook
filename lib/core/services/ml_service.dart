import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../config/env.dart';
import '../utils/nutrition.dart';

class MlDietResult {
  const MlDietResult({
    required this.dietCategory,
    required this.mealCalorieBudget,
    required this.mealRatio,
    required this.mlModel,
    this.isLiveFromApi = true,
  });

  final String dietCategory;
  final int mealCalorieBudget;
  final double mealRatio;
  final String mlModel;
  final bool isLiveFromApi;
}

class MlCategoryResult {
  const MlCategoryResult({
    required this.predictedCategory,
    required this.confidence,
    required this.mlModel,
  });

  final String predictedCategory;
  final double confidence;
  final String mlModel;
}

/// Service untuk menghubungkan aplikasi Flutter ke REST API Microservice Machine Learning (Python FastAPI).
class MlService {
  MlService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Daftar URL target untuk mencoba koneksi ke server Python ML:
  /// 1. Prioritas utama: Nilai dari --dart-define=ML_API_URL
  /// 2. Jika di Android:
  ///    - http://127.0.0.1:8000 (bekerja langsung via USB dengan adb reverse)
  ///    - http://192.168.1.6:8000 (IP Wi-Fi laptop saat ini)
  ///    - http://10.0.2.2:8000 (Android Emulator)
  /// 3. Jika Windows / Web: http://127.0.0.1:8000
  static List<String> get candidateUrls {
    if (Env.mlApiUrl.isNotEmpty) {
      final u = Env.mlApiUrl.endsWith('/')
          ? Env.mlApiUrl.substring(0, Env.mlApiUrl.length - 1)
          : Env.mlApiUrl;
      return [u];
    }
    if (!kIsWeb && Platform.isAndroid) {
      return const [
        'http://127.0.0.1:8000',
        'http://192.168.1.6:8000',
        'http://10.0.2.2:8000',
      ];
    }
    return const ['http://127.0.0.1:8000'];
  }

  /// Memeriksa apakah Backend ML Python sedang aktif / online.
  Future<bool> isAvailable() async {
    for (final base in candidateUrls) {
      try {
        final res = await _client
            .get(Uri.parse('$base/health'))
            .timeout(const Duration(milliseconds: 1200));
        if (res.statusCode == 200) return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  /// Modul 3: Prediksi Kategori Diet & Anggaran Kalori dari Model Decision Tree.
  /// Jika API Python tidak terjangkau (offline), otomatis fallback ke model lokal di Dart.
  Future<MlDietResult> predictDiet({
    required double bmi,
    required double tdee,
    double? weightKg,
    double? heightCm,
    int? age,
    String? gender,
  }) async {
    final skor = calculateBmiTdeeScore(bmi: bmi, tdee: tdee);

    for (final base in candidateUrls) {
      try {
        final res = await _client
            .post(
              Uri.parse('$base/predict-diet'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'bmi': bmi,
                'tdee': tdee,
                'skor_bmi_tdee': skor,
                'weight_kg': weightKg,
                'height_cm': heightCm,
                'age': age,
                'gender': gender ?? 'Pria',
              }),
            )
            .timeout(const Duration(milliseconds: 1500));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          return MlDietResult(
            dietCategory: data['diet_category'] as String,
            mealCalorieBudget: (data['meal_calorie_budget'] as num).toInt(),
            mealRatio: (data['meal_ratio'] as num).toDouble(),
            mlModel: data['ml_model'] as String? ?? 'Decision Tree',
            isLiveFromApi: true,
          );
        }
      } catch (_) {
        continue;
      }
    }

    // Fallback ke model lokal jika backend server offline
    final localCategory = predictDietCategory(bmi);
    final localRatio = getDietMealRatio(localCategory);
    final localBudget = (tdee * localRatio).round();

    return MlDietResult(
      dietCategory: localCategory,
      mealCalorieBudget: localBudget,
      mealRatio: localRatio,
      mlModel: 'Decision Tree (Embedded Rules)',
      isLiveFromApi: false,
    );
  }

  /// Modul 2: Auto-tagging kategori protein resep menggunakan Logistic Regression.
  Future<MlCategoryResult?> predictCategory({
    required String title,
    required String ingredients,
  }) async {
    for (final base in candidateUrls) {
      try {
        final res = await _client
            .post(
              Uri.parse('$base/predict-category'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'title': title,
                'ingredients': ingredients,
              }),
            )
            .timeout(const Duration(milliseconds: 1500));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          return MlCategoryResult(
            predictedCategory: data['predicted_category'] as String,
            confidence: (data['confidence'] as num).toDouble(),
            mlModel: data['ml_model'] as String? ?? 'Logistic Regression',
          );
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  /// Modul 1: Rekomendasi resep berbasis TF-IDF Cosine Similarity langsung dari Python ML.
  Future<List<Map<String, dynamic>>> recommendFromMl({
    required List<String> ingredients,
    int limit = 10,
  }) async {
    for (final base in candidateUrls) {
      try {
        final res = await _client
            .post(
              Uri.parse('$base/recommend'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'ingredients': ingredients,
                'limit': limit,
              }),
            )
            .timeout(const Duration(milliseconds: 1500));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final list = (data['recipes'] as List?) ?? [];
          return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      } catch (_) {
        continue;
      }
    }
    return [];
  }
}
