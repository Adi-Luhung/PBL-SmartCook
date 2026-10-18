import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePhotoService extends ChangeNotifier {
  ProfilePhotoService._();
  static final ProfilePhotoService instance = ProfilePhotoService._();

  static const String _key = 'profile_photo_path';

  String? _photoPath;

  String? get photoPath => _photoPath;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _photoPath = prefs.getString(_key);
    notifyListeners();
  }

  Future<void> updatePhoto(String path) async {
    _photoPath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, path);
    notifyListeners();
  }

  Future<void> clearPhoto() async {
    _photoPath = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    notifyListeners();
  }
}
