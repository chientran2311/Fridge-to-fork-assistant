import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  // Mặc định là tiếng Việt
  Locale _locale = const Locale('vi');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale(); // Load từ bộ nhớ khi khởi tạo
  }

  // Hàm gọi từ UI để đổi ngôn ngữ
  void setLocale(Locale locale) async {
    // Chỉ chấp nhận 'vi' hoặc 'en'
    if (!['vi', 'en'].contains(locale.languageCode)) return;

    _locale = locale;
    notifyListeners(); // <--- Quan trọng: Báo Main vẽ lại UI

    // Lưu vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  // Hàm load nội bộ
  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }
}