import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'file_storage.dart';
import 'main.dart';

class StorageService {
  final FileStorage _fileStorage = FileStorage();

  Future<void> saveUser(User user) async {
    String jsonStr = jsonEncode(user.toJson());
    await _fileStorage.write(jsonStr);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
  }

  Future<User?> loadUser() async {
    String? jsonStr = await _fileStorage.read();
    if (jsonStr != null) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
      return User.fromJson(jsonMap);
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  Future<void> logout() async {
    await _fileStorage.delete();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
  }
}