/// Perkiraan porsi & kalori per porsi untuk resep dari database.
///
/// Dataset hanya punya total kalori dan total berat bahan seluruh resep, tanpa
/// jumlah porsi. Jumlah porsi diperkirakan dari berat bahan, jadi hasilnya
/// perkiraan kasar. Ubah [kGramsPerPortion] untuk menyesuaikan.
const double kGramsPerPortion = 250;

int estimatePortions(double? beratG) {
  if (beratG == null || beratG <= 0) return 2;
  return (beratG / kGramsPerPortion).round().clamp(1, 12);
}

int caloriesPerPortion(double? kalori, double? beratG) {
  if (kalori == null || kalori <= 0) return 0;
  return (kalori / estimatePortions(beratG)).round();
}

/// Anggaran kalori per kali makan bila profil belum diisi (≈ 1.800 kkal / 3).
const int kDefaultMealBudget = 600;

// ── Modul 3 Machine Learning: Formula Mifflin-St Jeor & Skor BMI × TDEE ──

/// Menghitung Body Mass Index (BMI).
double calculateBmi(double weightKg, double heightCm) {
  if (heightCm <= 0) return 0;
  final heightM = heightCm / 100.0;
  return weightKg / (heightM * heightM);
}

/// Menghitung Basal Metabolic Rate (BMR) dengan rumus Mifflin-St Jeor.
double calculateBmr({
  required double weightKg,
  required double heightCm,
  required int age,
  required String gender,
}) {
  final isMale = gender.trim().toLowerCase().startsWith('l') ||
      gender.trim().toLowerCase().contains('pria');
  if (isMale) {
    return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
  } else {
    return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
  }
}

/// Multiplier aktivitas fisik standar (Mifflin-St Jeor).
/// Index 0: Sedentary (1.2)
/// Index 1: Ringan (1.375)
/// Index 2: Sedang (1.55)
/// Index 3: Aktif (1.725)
const List<double> kActivityMultipliers = [1.2, 1.375, 1.55, 1.725];

/// Menghitung Total Daily Energy Expenditure (TDEE).
double calculateTdee({
  required double bmr,
  int activityIndex = 1,
}) {
  final index = activityIndex.clamp(0, kActivityMultipliers.length - 1);
  return bmr * kActivityMultipliers[index];
}

/// Menghitung Skor Gabungan BMI × TDEE.
double calculateBmiTdeeScore({required double bmi, required double tdee}) {
  return bmi * tdee;
}

/// Prediksi Kategori Diet berbasis model Machine Learning Decision Tree:
/// - Obesitas (BMI >= 30)        -> Diet Ketat (Defisit Besar)
/// - Overweight (25 <= BMI < 30) -> Diet Ringan (Defisit Ringan)
/// - Normal (18.5 <= BMI < 25)    -> Maintenance (Seimbang)
/// - Underweight (BMI < 18.5)      -> Bulking (Surplus)
String predictDietCategory(double bmi) {
  if (bmi >= 30.0) return 'Diet Ketat (Defisit Besar)';
  if (bmi >= 25.0) return 'Diet Ringan (Defisit Ringan)';
  if (bmi >= 18.5) return 'Maintenance (Seimbang)';
  return 'Bulking (Surplus)';
}

/// Rasio porsi kalori per makan terhadap TDEE berdasarkan kategori diet:
/// - Diet Ketat: 25% TDEE per makan
/// - Diet Ringan: 30% TDEE per makan
/// - Maintenance: 35% TDEE per makan
/// - Bulking: 45% TDEE per makan
double getDietMealRatio(String dietCategory) {
  switch (dietCategory) {
    case 'Diet Ketat (Defisit Besar)':
      return 0.25;
    case 'Diet Ringan (Defisit Ringan)':
      return 0.30;
    case 'Maintenance (Seimbang)':
      return 0.35;
    case 'Bulking (Surplus)':
      return 0.45;
    default:
      return 0.35;
  }
}

/// Menghitung batas kalori per makan dari skor BMI × TDEE pengguna.
int mealBudgetFromBmiTdee({
  required double weightKg,
  required double heightCm,
  required int age,
  required String gender,
  int activityIndex = 1,
}) {
  final bmi = calculateBmi(weightKg, heightCm);
  final bmr = calculateBmr(
    weightKg: weightKg,
    heightCm: heightCm,
    age: age,
    gender: gender,
  );
  final tdee = calculateTdee(bmr: bmr, activityIndex: activityIndex);
  final category = predictDietCategory(bmi);
  final ratio = getDietMealRatio(category);
  return (tdee * ratio).round();
}

/// Anggaran kalori per kali makan (kompatibilitas dengan kode sebelumnya,
/// bila hanya ada targetKkal harian).
int mealBudgetFor(int? targetKkal) =>
    (targetKkal != null && targetKkal > 0) ? (targetKkal / 3).round() : kDefaultMealBudget;

/// Diet = kalori per porsi tidak melebihi anggaran satu kali makan.
/// Null bila kalori resep tidak diketahui.
bool? isDietPortion(int caloriesPerPortion, int mealBudget) =>
    caloriesPerPortion <= 0 ? null : caloriesPerPortion <= mealBudget;
