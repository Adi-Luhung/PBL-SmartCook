/// "cabai rawit" -> "Cabai Rawit"
String titleCase(String s) {
  return s
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
