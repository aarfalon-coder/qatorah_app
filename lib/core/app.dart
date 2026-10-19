import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qatorah_app/core/constants/app_info.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/screens/splash_screen.dart';

/// جذر تطبيق قطوره
class QatorahApp extends StatelessWidget {
  const QatorahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.crystalBlue,
        scaffoldBackgroundColor: AppColors.blackDeep,
        textTheme: GoogleFonts.cairoTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
