import 'package:flutter/material.dart';
import 'package:qatorah_app/managers/theme_manager.dart';

/// ألوان قطوره - الهوية الفاخرة (مصدر الحقيقة الوحيد)
class AppColors {
  // الخلفيات
  static const Color blackDeep = Color(0xFF0A0A0A);
  static const Color navyDark = Color(0xFF1A1A2E);
  static const Color royalBlue = Color(0xFF0F3460);
  static const Color crystalBlue = Color(0xFF0288D1);
  static const Color deepNavy = Color(0xFF01579B);

  // الذهبي الفاخر
  static const Color goldDark = Color(0xFFB8860B);
  static const Color goldLight = Color(0xFFDAA520);

  // ألوان الخدمات والحالات
  static const Color waterBlue = Color(0xFF0288D1);
  static const Color tankCyan = Color(0xFF00BCD4);
  static const Color maintenanceOrange = Color(0xFFFF9800);
  static const Color plumberRed = Color(0xFFF44336);
  static const Color refillGreen = Color(0xFF4CAF50);
  static const Color factoryPurple = Color(0xFF9C27B0);
}

/// التدرجات اللونية المشتركة
class AppGradients {
  static const LinearGradient mainBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.blackDeep, AppColors.navyDark, AppColors.royalBlue],
  );

  static const LinearGradient welcomeBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.blackDeep, AppColors.navyDark, AppColors.royalBlue, AppColors.crystalBlue],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [AppColors.goldDark, AppColors.goldLight, AppColors.goldDark],
  );
}

/// ✅ مساعد الألوان الذكي (يتغير حسب الوضع الليلي/النهاري)
class ThemeHelper {
  static Color getBackgroundColor(BuildContext context) {
    return ThemeManager.isDarkMode ? AppColors.blackDeep : const Color(0xFFF5F7FA);
  }

  static Color getCardColor(BuildContext context) {
    return ThemeManager.isDarkMode ? const Color(0xFF1A1F2E) : Colors.white;
  }

  static Color getTextColor(BuildContext context) {
    return ThemeManager.isDarkMode ? Colors.white : const Color(0xFF1A2029);
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return ThemeManager.isDarkMode ? Colors.white54 : const Color(0xFF64748B);
  }
}