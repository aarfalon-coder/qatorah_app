import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/auth_manager.dart';

class SubscriptionExpiredScreen extends StatelessWidget {
  const SubscriptionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.plumberRed.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.lock_clock, color: AppColors.plumberRed, size: 64),
              ),
              const SizedBox(height: 24),
              const Text('انتهت فترة الاشتراك', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('عذراً، لقد انتهت مدة اشتراكك في التطبيق. يرجى تجديد الاشتراك عبر التواصل مع الإدارة أو الدفع عبر المحفظة لاستعادة الوصول إلى لوحة التحكم.', style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // يمكنك توجيهه هنا لشاشة الدفع أو التواصل مع الدعم
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('تجديد الاشتراك الآن'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  await AuthManager.logout();
                  // توجه لشاشة الدخول هنا
                },
                child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white54)),
              )
            ],
          ),
        ),
      ),
    );
  }
}