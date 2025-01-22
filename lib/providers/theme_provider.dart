import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode;
  bool _isInitialized = false;

  ThemeProvider(this.isDarkMode) {
    _loadThemePreference();
  }

  // Load the saved theme preference
  Future<void> _loadThemePreference() async {
    if (_isInitialized) return;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('dark_mode') ?? isDarkMode;
    _isInitialized = true;
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    _saveThemePreference(); // Save the new preference
    notifyListeners();
  }

  // Save the theme preference
  Future<void> _saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDarkMode);
  }

  // Method to initialize theme synchronously
  static Future<bool> getInitialTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dark_mode') ?? false;
  }
}
