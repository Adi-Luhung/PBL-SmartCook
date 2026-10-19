import 'package:flutter/foundation.dart';

class CookDocItem {
  const CookDocItem({
    required this.name,
    required this.time,
    this.photoPath,
    this.rating = 5.0,
    this.tags = const [],
    this.notes = '',
  });

  final String name;
  final String time;
  final String? photoPath;
  final double rating;
  final List<String> tags;
  final String notes;
}

class CookDocService extends ChangeNotifier {
  CookDocService._();
  static final CookDocService instance = CookDocService._();

  final List<CookDocItem> _items = [
    const CookDocItem(name: 'Nasi Telur Kecap', time: 'Kemarin siang'),
    const CookDocItem(name: 'Tumis Kangkung', time: '2 hari lalu'),
    const CookDocItem(name: 'Tempe Goreng', time: '24 Okt'),
    const CookDocItem(name: 'Tahu Telur', time: '20 Okt'),
  ];

  List<CookDocItem> get items => List.unmodifiable(_items);

  void addCookDoc(CookDocItem item) {
    _items.insert(0, item);
    notifyListeners();
  }
}
