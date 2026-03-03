import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  
  ThemeMode _themeMode = ThemeMode.system;
  String _languageCode = 'en'; // Default to English
  
  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  // Initialize theme settings
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme mode
    final themeModeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    
    // Load language
    _languageCode = prefs.getString(_languageKey) ?? 'en';
    
    notifyListeners();
  }
  
  // Set theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    _themeMode = themeMode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
  }
  
  // Toggle dark mode
  Future<void> toggleDarkMode(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
  
  // Set language
  Future<void> setLanguage(String languageCode) async {
    if (_languageCode == languageCode) return;
    
    _languageCode = languageCode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }
  
  // Get supported languages
  static Map<String, String> get supportedLanguages => {
    'en': 'English',
    'ta': 'தமிழ்', // Tamil
  };
  
  // Get current language display name
  String get currentLanguageDisplayName => 
      supportedLanguages[_languageCode] ?? 'English';
  
  // Change language and notify listeners
  Future<void> changeLanguage(String language) async {
    String languageCode = 'en';
    switch (language) {
      case 'Tamil':
        languageCode = 'ta';
        break;
      case 'English':
      default:
        languageCode = 'en';
        break;
    }
    
    if (_languageCode != languageCode) {
      _languageCode = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      notifyListeners();
    }
  }
}