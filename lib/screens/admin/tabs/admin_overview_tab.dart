import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdvertisementManager>(
      builder: (context, mgr, _) {
        final totalAds = mgr.allAds.length;
        final pendingAds = mgr.pendingReviewAds.length;
        final activeAds = mgr.allAds.where((a) => a.isActive).length;
        final totalRevenue = mgr.allAds.where((a) => a.type == AdType.premium && a.isActive).fold<double>(0, (sum, a) => sum + a.pricing.amount);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.plumberRed.withValues(alpha: 0.3), AppColors.goldLight.withValues(alpha: 0.2)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.plumberRed.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [Icon(Icons.trending_up, color: AppColors.goldLight, size: 28), SizedBox(width: 10), Text('أهلاً بك يا قاسم 👑', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 8),
                    Text('إمبراطوريتك الرقمية اليوم:', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _bigStat('إجمالي الإعلانات', '$totalAds', AppColors.crystalBlue),
                        _bigStat('قيد المراجعة', '$pendingAds', AppColors.plumberRed),
                        _bigStat('الإيرادات', '${totalRevenue.toInt()} د.أ', AppColors.goldLight),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📊 ملخص النظام', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _infoRow('الإعلانات النشطة', '$activeAds'),
                    _infoRow('عدد المحطات المسجلة', 'قيد الربط مع Firebase'),
                    _infoRow('المستخدمين النشطين', 'قيد الربط مع Firebase'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bigStat(String label, String value, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
    ]);
  }

  Widget _infoRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
    ]));
  }
}