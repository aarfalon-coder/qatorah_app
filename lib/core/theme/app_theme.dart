import 'package:flutter/material.dart';

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
    colors: [
      AppColors.blackDeep,
      AppColors.navyDark,
      AppColors.royalBlue,
    ],
  );

  static const LinearGradient welcomeBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.blackDeep,
      AppColors.navyDark,
      AppColors.royalBlue,
      AppColors.crystalBlue,
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      AppColors.goldDark,
      AppColors.goldLight,
      AppColors.goldDark,
    ],
  );

  static const LinearGradient blackCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A1A),
      AppColors.blackDeep,
    ],
  );
}
