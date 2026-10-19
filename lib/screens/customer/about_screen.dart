import 'package:flutter/material.dart';
import 'package:qatorah_app/core/constants/app_info.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عن التطبيق',
            style: TextStyle(
                color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.goldGradient,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.goldDark.withValues(alpha: 0.5),
                            blurRadius: 30)
                      ]),
                  child: const Icon(Icons.water_drop,
                      size: 60, color: Colors.black),
                ),
                const SizedBox(height: 25),
                const Text(AppInfo.appName,
                    style: TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(AppInfo.tagline,
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 40),
                _infoRow('الإصدار', AppInfo.version),
                _infoRow('المطور', AppInfo.developer),
                _infoRow('الفريق', AppInfo.developerTeam),
                _infoRow('البريد', AppInfo.supportEmail),
                _infoRow('الموقع', AppInfo.website),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
          color: AppColors.navyDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.goldDark.withValues(alpha: 0.3))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.goldLight, fontSize: 14)),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
