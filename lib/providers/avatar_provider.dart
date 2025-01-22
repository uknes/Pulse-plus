import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarProvider with ChangeNotifier {
  String _selectedAvatar = 'assets/avatars/default_avatar.png';

  String get selectedAvatar => _selectedAvatar;

  AvatarProvider() {
    _loadAvatarPreference();
  }

  Future<void> _loadAvatarPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedAvatar = prefs.getString('selected_avatar') ?? 'assets/avatars/default_avatar.png';
    notifyListeners();
  }

  Future<void> updateAvatar(String avatarPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_avatar', avatarPath);
    _selectedAvatar = avatarPath;
    notifyListeners();
  }
} 