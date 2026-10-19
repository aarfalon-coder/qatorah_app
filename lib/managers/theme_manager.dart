import 'package:flutter/material.dart';

/// مدير تخصيص الثيم (الألوان والشفافية)
class ThemeManager {
  static Color _accentColor = const Color(0xFFFFD700);
  static double _bgOpacity = 0.97;
  static bool _glassEnabled = true;

  static Color get accentColor => _accentColor;
  static double get bgOpacity => _bgOpacity;
  static bool get glassEnabled => _glassEnabled;

  static void setAccentColor(Color color) => _accentColor = color;
  static void setBgOpacity(double value) => _bgOpacity = value;
  static void setGlassEnabled(bool value) => _glassEnabled = value;

  static const List<Color> palette = [
    Color(0xFFFFD700), // ذهبي
    Color(0xFF00BCD4), // أزرق كريستالي
    Color(0xFF4CAF50), // أخضر
    Color(0xFFE53935), // أحمر
    Color(0xFF9C27B0), // بنفسجي
    Color(0xFFFF9800), // برتقالي
    Color(0xFF3F51B5), // نيلي
    Color(0xFFEC407A), // وردي
  ];
}
