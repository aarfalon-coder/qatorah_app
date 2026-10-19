import 'package:flutter/material.dart';
import 'package:qatorah_app/screens/customer/customer_home.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/screens/ads/splash_ad_screen.dart';
import 'package:qatorah_app/services/splash_ad_service.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndRoute();
  }

  Future<void> _checkAndRoute() async {
    debugPrint('🚀 === STARTUP: بدء فحص الإعلان من Firestore ===');
    try {
      final userType = AuthManager.isProvider ? 'provider' : 'customer';
      final ad = await SplashAdService().getActiveAd(userType: userType);
      
      debugPrint('🚀 === STARTUP: النتيجة: ${ad != null ? "✅ لقيت إعلان" : "❌ ما لقيت"} ===');

      if (!mounted) return;

      if (ad != null) {
        debugPrint('🚀 === STARTUP: جاري عرض الإعلان ===');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SplashAdScreen(
              ad: ad,
              onFinished: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => CustomerHomeScreen()),
                );
              },
            ),
          ),
        );
      } else {
        debugPrint('🚀 === STARTUP: لا يوجد إعلان، انتقال مباشر للشاشة الرئيسية ===');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => CustomerHomeScreen()),
        );
      }
    } catch (e) {
      debugPrint('❌ === STARTUP: حدث خطأ أثناء الفحص: $e ===');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => CustomerHomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(color: AppColors.goldLight, strokeWidth: 3),
            ),
            const SizedBox(height: 20),
            Text(
              'جاري تجهيز التطبيق...',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}