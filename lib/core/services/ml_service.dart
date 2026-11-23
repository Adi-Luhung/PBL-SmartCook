import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;

import '../config/env.dart';

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
/// Backend ML hanya melayani klasifikasi kategori resep (/predict-category).
class MlService {
  MlService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Daftar URL target untuk mencoba koneksi ke server Python ML:
  /// 1. Prioritas utama: Nilai dari --dart-define=ML_API_URL
  /// 2. Jika di Android:
  ///    - http://127.0.0.1:8000 (bekerja langsung via USB dengan adb reverse)
  ///    - http://10.0.2.2:8000 (Android Emulator)
  /// 3. Jika Windows / Web / Cloud:
  ///    - https://pbl-smartcook.onrender.com
  static List<String> get candidateUrls {
    if (Env.mlApiUrl.isNotEmpty) {
      final u = Env.mlApiUrl.endsWith('/')
          ? Env.mlApiUrl.substring(0, Env.mlApiUrl.length - 1)
          : Env.mlApiUrl;
      return [u];
    }
    return const [
      'https://pbl-smartcook.onrender.com',
      'http://127.0.0.1:8000',
      'http://10.0.2.2:8000',
    ];
  }

  /// Memeriksa apakah Backend ML Python sedang aktif / online.
  Future<bool> isAvailable() async {
    for (final base in candidateUrls) {
      try {
        final res = await _client
            .get(Uri.parse('$base/health'))
            .timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) return true;
      } catch (e) {
        if (kDebugMode) {
          print('[MlService] isAvailable error pada $base: $e');
        }
        continue;
      }
    }
    return false;
  }

  /// Auto-tagging kategori protein resep baru menggunakan Logistic Regression.
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
              body: jsonEncode({'title': title, 'ingredients': ingredients}),
            )
            .timeout(const Duration(seconds: 15));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          return MlCategoryResult(
            predictedCategory: data['predicted_category'] as String,
            confidence: (data['confidence'] as num).toDouble(),
            mlModel: data['ml_model'] as String? ?? 'Logistic Regression',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('[MlService] Gagal predictCategory pada $base: $e');
        }
        continue;
      }
    }
    return null;
  }
}
