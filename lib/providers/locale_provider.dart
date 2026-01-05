/// ============================================
/// LOCALE PROVIDER - LANGUAGE MANAGEMENT
/// ============================================
/// 
/// State management for app localization:
/// - Vietnamese (vi) - Default language
/// - English (en) - Alternative language
/// 
/// Features:
/// - Persistent language preference via SharedPreferences
/// - Real-time UI language switching
/// - Auto-load saved preference on startup
/// 
/// Usage in Settings:
/// - Language selector dropdown
/// - Immediate UI refresh on change
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for locale/language state management
class LocaleProvider extends ChangeNotifier {
  // Default to Vietnamese
  Locale _locale = const Locale('vi');

  /// Current locale getter
  Locale get locale => _locale;

  /// Constructor - loads saved locale on init
  LocaleProvider() {
    _loadLocale();
  }

  /// Set locale from UI and persist to storage
  void setLocale(Locale locale) async {
    // Only accept supported locales
    if (!['vi', 'en'].contains(locale.languageCode)) return;

    _locale = locale;
    notifyListeners(); // Trigger UI rebuild

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  /// Load saved locale from SharedPreferences
  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }
}