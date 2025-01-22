import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _selectedLanguage = 'English'; // Default language

  String get selectedLanguage => _selectedLanguage;

  LanguageProvider() {
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedLanguage = prefs.getString('language_code') ?? 'English';
    notifyListeners(); // Notify listeners for state change
  }

  Future<void> updateLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', language);
    _selectedLanguage = language;
    notifyListeners(); // Notify listeners for state change
  }
}
