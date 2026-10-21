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

/// Anggaran kalori per kali makan = target kalori harian (dihitung dari BMI/TDEE
/// di profil) dibagi 3. Tanpa target, dipakai [kDefaultMealBudget].
int mealBudgetFor(int? targetKkal) =>
    (targetKkal != null && targetKkal > 0) ? (targetKkal / 3).round() : kDefaultMealBudget;

/// Diet = kalori per porsi tidak melebihi anggaran satu kali makan.
/// Null bila kalori resep tidak diketahui.
bool? isDietPortion(int caloriesPerPortion, int mealBudget) =>
    caloriesPerPortion <= 0 ? null : caloriesPerPortion <= mealBudget;
