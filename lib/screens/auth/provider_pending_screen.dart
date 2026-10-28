import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/screens/auth/login_screen.dart';

class ProviderPendingScreen extends StatelessWidget {
  final String providerName;
  final String providerRole;

  const ProviderPendingScreen({
    super.key,
    required this.providerName,
    required this.providerRole,
  });

  Future<void> _logout(BuildContext context) async {
    await AuthManager.logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Icon(Icons.hourglass_top, size: 72, color: AppColors.goldLight),
                ),
                const SizedBox(height: 32),
                Text(
                  'مرحباً $providerName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  providerRole,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.goldLight, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                const Text(
                  'حسابك قيد المراجعة من الإدارة.\nستتمكن من استخدام لوحة المزود بعد الموافقة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                ),
                const Spacer(),
                GoldButton(
                  text: 'تسجيل الخروج',
                  icon: Icons.logout,
                  onPressed: () => _logout(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
