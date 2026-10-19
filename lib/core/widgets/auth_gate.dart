import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/screens/auth/login_screen.dart';
import 'package:qatorah_app/screens/auth/register_screen.dart';

/// بوابة الأفعال: الزائر يتصفح بحرية، لكن أي فعل تجاري يتطلب دخولاً
class AuthGate {
  /// نفّذ [action] فقط إذا كان المستخدم مسجلاً،
  /// وإلا اعرض شيت تسجيل الدخول الفاخر.
  static void requireAuth(
    BuildContext context, {
    String message = 'سجّل دخولك لإكمال هذا الإجراء 💧',
    required VoidCallback action,
  }) {
    if (AuthManager.isLoggedIn) {
      action();
      return;
    }
    _showAuthSheet(context, message);
  }

  static void _showAuthSheet(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: AppColors.navyDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border(
            top: BorderSide(color: AppColors.goldDark, width: 2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مؤشر السحب
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.goldDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.goldDark.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.goldLight.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: AppColors.goldLight,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تقدر تتصفح كل شي بحرية، بس الشراء والطلب بحاجة حساب',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 25),
            GoldButton(
              text: 'تسجيل الدخول',
              icon: Icons.login,
              onPressed: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  sheetContext,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  sheetContext,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text(
                'ما عندك حساب؟ أنشئ حساباً جديداً',
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
