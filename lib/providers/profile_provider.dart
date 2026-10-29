import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = 'Santiago';
  String? _avatarPath;

  String get name => _name;
  String? get avatarPath => _avatarPath;

  ProfileProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _name = prefs.getString('profile_name') ?? 'Santiago';
      _avatarPath = prefs.getString('profile_avatar');
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setName(String name) async {
    if (name.trim().isEmpty) return;
    _name = name.trim();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', _name);
    } catch (_) {}
  }

  Future<void> setAvatarPath(String? path) async {
    _avatarPath = path;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (path == null) {
        await prefs.remove('profile_avatar');
      } else {
        await prefs.setString('profile_avatar', path);
      }
    } catch (_) {}
  }
}
