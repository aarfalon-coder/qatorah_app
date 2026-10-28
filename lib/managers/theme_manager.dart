import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  // ═══════════════════════════════════════
  // 1. متغيرات الثيم (كلها static لتعمل مع الكود الحالي)
  // ═══════════════════════════════════════
  static ThemeMode themeMode = ThemeMode.dark;
  static bool get isDarkMode => themeMode == ThemeMode.dark;
  
  static Color _accentColor = const Color(0xFFFFD700);
  static double _bgOpacity = 0.97;
  static bool _glassEnabled = true;

  static Color get accentColor => _accentColor;
  static double get bgOpacity => _bgOpacity;
  static bool get glassEnabled => _glassEnabled;

  // ═══════════════════════════════════════
  // 2. Instance وحيد عشان notifyListeners تشتغل مع المتغيرات الـ static
  // ═══════════════════════════════════════
  static final ThemeManager _instance = ThemeManager._();
  factory ThemeManager() => _instance;
  ThemeManager._();

  // ═══════════════════════════════════════
  // 3. دوال التعديل والحفظ (Static)
  // ═══════════════════════════════════════
  static void setAccentColor(Color color) {
    _accentColor = color;
    _instance.notifyListeners();
  }

  static void setBgOpacity(double value) {
    _bgOpacity = value;
    _instance.notifyListeners();
  }

  static void setGlassEnabled(bool value) {
    _glassEnabled = value;
    _instance.notifyListeners();
  }

  static Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // تحميل الوضع الليلي/النهاري
      final isDark = prefs.getBool('app_theme_mode') ?? true;
      themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      
      // تحميل إعدادات التخصيم القديمة إن وجدت
      final savedOpacity = prefs.getDouble('bg_opacity');
      if (savedOpacity != null) _bgOpacity = savedOpacity;
      
      _instance.notifyListeners();
      debugPrint('✅ تم تحميل الثيم: ${isDark ? "ليلي" : "نهاري"}');
    } catch (e) {
      debugPrint('❌ فشل تحميل الثيم: $e');
    }
  }

  static Future<void> toggleTheme(bool isDark) async {
    try {
      themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('app_theme_mode', isDark);
      
      _instance.notifyListeners();
      debugPrint('✅ تم تغيير الثيم: ${isDark ? "ليلي" : "نهاري"}');
    } catch (e) {
      debugPrint('❌ فشل حفظ الثيم: $e');
    }
  }
}