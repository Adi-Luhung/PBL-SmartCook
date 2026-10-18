import 'package:flutter/foundation.dart';

class SavedRecipe {
  const SavedRecipe({
    required this.name,
    required this.time,
    required this.ingredients,
    this.imageUrl,
    this.imageAsset,
    this.calories = 0,
    this.isDiet = false,
    this.portions = 2,
    this.ingredientList = const [],
    this.stepList = const [],
  });

  final String name;
  final String time;
  final String ingredients;
  final String? imageUrl;
  final String? imageAsset;
  final int calories;
  final bool isDiet;
  final int portions;
  final List<String> ingredientList;
  final List<Map<String, String>> stepList;
}

class BookmarkService extends ChangeNotifier {
  BookmarkService._();
  static final BookmarkService instance = BookmarkService._();

  final List<SavedRecipe> _savedRecipes = [
    const SavedRecipe(
      name: 'Sup Telur Tomat',
      time: '12 Menit',
      ingredients: '3 Bahan',
      imageUrl:
          'https://images.unsplash.com/photo-1547928576-a4a33237cbc3?w=500&auto=format&fit=crop',
      imageAsset: 'assets/images/recipes/sup_ayam_jahe.jpg',
      calories: 210,
      isDiet: true,
      portions: 2,
      ingredientList: [
        '2 butir Telur Ayam',
        '2 buah Tomat Segar',
        '2 batang Daun Bawang',
        '1 sdm Minyak Wijen',
        '1/2 sdt Garam & Merica',
      ],
      stepList: [
        {
          'title': 'Persiapan Bahan',
          'description':
              'Kocok lepas telur dalam mangkuk. Iris tomat menjadi potongan baji dan iris halus daun bawang.',
        },
        {
          'title': 'Menumis Tomat',
          'description':
              'Tumis irisan tomat dengan sedikit minyak hingga layu dan mengeluarkan sari asam manis alaminya.',
        },
        {
          'title': 'Menuangkan Telur & Kuah',
          'description':
              'Tuangkan air secukupnya, masak hingga mendidih. Tuang kocokan telur secara perlahan sambil diaduk memutar.',
        },
        {
          'title': 'Penyajian Hangat',
          'description':
              'Bumbui dengan garam dan minyak wijen, taburi daun bawang, sajikan selagi panas.',
        },
      ],
    ),
    const SavedRecipe(
      name: 'Orak Arik Tahu Gurih',
      time: '10 Menit',
      ingredients: '4 Bahan',
      imageUrl:
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500&auto=format&fit=crop',
      imageAsset: 'assets/images/recipes/orak_arik_telur_tahu.jpeg',
      calories: 240,
      isDiet: true,
      portions: 2,
      ingredientList: [
        '2 kotak Tahu Putih',
        '2 butir Telur Ayam',
        '2 siung Bawang Putih',
        '1 batang Daun Bawang',
        '1/2 sdt Kaldu Jamur & Merica',
      ],
      stepList: [
        {
          'title': 'Hancurkan Tahu',
          'description':
              'Hancurkan tahu putih menggunakan garpu hingga berbutir kasar namun tidak terlalu halus.',
        },
        {
          'title': 'Tumis Bumbu',
          'description':
              'Tumis bawang putih cincang hingga harum keemasan di atas api sedang.',
        },
        {
          'title': 'Orak-Arik Tahu & Telur',
          'description':
              'Masukkan tahu, aduk sebentar, lalu buat ruang di tengah wajan untuk telur. Orak-arik telur hingga matang menyatu.',
        },
        {
          'title': 'Penyajian',
          'description':
              'Tambahkan daun bawang, kaldu jamur, dan lada. Aduk cepat lalu hidangkan hangat.',
        },
      ],
    ),
  ];

  List<SavedRecipe> get savedRecipes => List.unmodifiable(_savedRecipes);

  bool isBookmarked(String title) {
    return _savedRecipes
        .any((r) => r.name.toLowerCase() == title.toLowerCase());
  }

  void toggleBookmark(SavedRecipe recipe) {
    final index = _savedRecipes.indexWhere(
      (r) => r.name.toLowerCase() == recipe.name.toLowerCase(),
    );
    if (index >= 0) {
      _savedRecipes.removeAt(index);
    } else {
      _savedRecipes.insert(0, recipe);
    }
    notifyListeners();
  }

  void removeBookmark(String title) {
    _savedRecipes.removeWhere(
      (r) => r.name.toLowerCase() == title.toLowerCase(),
    );
    notifyListeners();
  }
}
