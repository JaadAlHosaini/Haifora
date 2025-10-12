import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _prefsKey = 'isDarkMode';
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeController() {
    _loadTheme();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme(_isDarkMode);
    notifyListeners();
  }

  Future<void> _saveTheme(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, value);
    } catch (e) {
      // optionally log error
      // print('Error saving theme preference: $e');
    }
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_prefsKey) ?? false;
      notifyListeners();
    } catch (e) {
      // handle or log errors as needed
      // print('Error loading theme preference: $e');
      _isDarkMode = false;
      notifyListeners();
    }
  }
}
