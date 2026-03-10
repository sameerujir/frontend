import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  
  ThemeViewModel() { _loadTheme(); }
  
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
    notifyListeners();
  }

  // --- ADD THIS NEW FUNCTION ---
  Future<void> resetTheme() async {
    _isDarkMode = false; // Force Light Mode
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', false); // Save it so it sticks
    notifyListeners();
  }
}