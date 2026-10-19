import 'package:flutter/foundation.dart';

class IngredientService extends ChangeNotifier {
  IngredientService._();
  static final IngredientService instance = IngredientService._();

  List<String> _selectedIngredients = [
    'Daging Ayam',
    'Bawang Putih',
    'Daun Bawang',
    'Tomat',
    'Kecap Manis',
    'Garam & Merica',
  ];

  List<String> get selectedIngredients => List.unmodifiable(_selectedIngredients);

  void setSelectedIngredients(List<String> ingredients) {
    _selectedIngredients = List.from(ingredients);
    notifyListeners();
  }

  void toggleIngredient(String name) {
    if (_selectedIngredients.contains(name)) {
      _selectedIngredients.remove(name);
    } else {
      _selectedIngredients.add(name);
    }
    notifyListeners();
  }

  void removeIngredient(String name) {
    if (_selectedIngredients.remove(name)) {
      notifyListeners();
    }
  }

  bool isSelected(String name) {
    return _selectedIngredients.contains(name);
  }
}
