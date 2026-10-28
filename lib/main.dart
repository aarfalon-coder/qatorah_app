import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qatorah_app/firebase_options.dart';
import 'package:qatorah_app/screens/splash_screen.dart';
import 'package:qatorah_app/managers/profile_manager.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/managers/coupon_manager.dart';
import 'package:qatorah_app/managers/notification_manager.dart';
import 'package:qatorah_app/managers/theme_manager.dart';
import 'package:qatorah_app/core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // ✅ تحميل الثيم المحفوظ قبل تشغيل التطبيق
  await ThemeManager.loadTheme();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const QatorahApp());
}

class QatorahApp extends StatelessWidget {
  const QatorahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => ProfileManager()),
        ChangeNotifierProvider(create: (_) => AdvertisementManager()),
        ChangeNotifierProvider(create: (_) => CouponManager()),
        ChangeNotifierProvider(create: (_) => NotificationManager()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'قطوره',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeManager.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF5F7FA),
              primaryColor: AppColors.goldDark,
              colorScheme: const ColorScheme.light(primary: AppColors.goldDark),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.blackDeep,
              primaryColor: AppColors.goldLight,
              colorScheme: const ColorScheme.dark(primary: AppColors.goldLight),
            ),
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}