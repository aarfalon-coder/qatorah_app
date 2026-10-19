import 'package:flutter/material.dart';
import 'package:qatorah_app/core/constants/app_info.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/screens/auth/login_screen.dart';
import 'package:qatorah_app/screens/ads/startup_screen.dart'; // ✅ إضافة جديدة
import 'package:qatorah_app/screens/provider_home.dart';
import 'package:qatorah_app/screens/shared/placeholder_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _init();
  }

  Future<void> _init() async {
    // انتظار ثانيتين + تحميل الجلسة
    await Future.delayed(const Duration(seconds: 2));
    await AuthManager.loadSession();
    if (mounted) _goNext();
  }

  void _goNext() {
    if (!mounted) return;

    Widget nextScreen;

    if (AuthManager.isLoggedIn) {
      debugPrint('=== SPLASH: المستخدم مسجل دخول ===');
      debugPrint('=== role: ${AuthManager.role} ===');
      debugPrint('=== isProvider: ${AuthManager.isProvider} ===');

      switch (AuthManager.role) {
        case UserRole.customer:
          // ✅ التعديل هنا: توجيه العميل إلى شاشة بدء التشغيل (لفحص الإعلان أولاً)
          nextScreen = const StartupScreen();
          break;
        case UserRole.stationOwner:
        case UserRole.factory:
        case UserRole.stationTechnician:
        case UserRole.plumber:
          nextScreen = const ProviderHomeScreen();
          break;
        case UserRole.driver:
          nextScreen = const PlaceholderScreen(title: 'شاشة السائق');
          break;
        case UserRole.tanker:
          nextScreen = const PlaceholderScreen(title: 'شاشة التنك (أوبر)');
          break;
        default:
          nextScreen = const StartupScreen();
      }
    } else {
      debugPrint('=== SPLASH: المستخدم غير مسجل → LoginScreen ===');
      nextScreen = const LoginScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.welcomeBackground,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulse,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldDark.withValues(alpha: 0.5),
                        blurRadius: 60,
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: AppColors.crystalBlue.withValues(alpha: 0.4),
                        blurRadius: 80,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.water_drop,
                        size: 180,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppGradients.goldGradient.createShader(bounds),
                child: const Text(
                  AppInfo.appName,
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppInfo.tagline,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 35),
              const CircularProgressIndicator(
                color: AppColors.goldLight,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}