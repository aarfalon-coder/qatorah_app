import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/screens/auth/login_screen.dart';
import 'package:qatorah_app/screens/ads/startup_screen.dart';
import 'package:qatorah_app/screens/provider_home.dart';
import 'package:qatorah_app/screens/shared/placeholder_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
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
          nextScreen = const StartupScreen();
          break;
        case UserRole.stationOwner:
        case UserRole.factoryOwner:
        case UserRole.stationTechnician:
        case UserRole.plumber:
        case UserRole.electrician:
        case UserRole.partsProvider:
        case UserRole.gasSupplier:
          nextScreen = const ProviderHomeScreen();
          break;
        case UserRole.tankerDriver:
        case UserRole.distributionDriver:
          nextScreen = const PlaceholderScreen(title: 'شاشة السائقين');
          break;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.water_drop, size: 180, color: Colors.white),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.goldLight,
                strokeWidth: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
