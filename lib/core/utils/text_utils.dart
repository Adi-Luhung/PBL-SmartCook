/// "cabai rawit" -> "Cabai Rawit"
String titleCase(String s) {
  return s
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

/// "≈ 148 kkal/100 g" dari total kalori dan total berat bahan resep.
String? kaloriPer100gLabel(double? kalori, double? beratG) {
  if (kalori == null || beratG == null || beratG <= 0) return null;
  final v = (kalori / beratG * 100).round();
  final s = v.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => '.',
  );
  return '≈ $s kkal/100 g';
}
