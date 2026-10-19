import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/ads/ad_type_badge.dart';
import 'package:qatorah_app/core/widgets/ads/ad_status_badge.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/models/region_model.dart';

class AdStatsScreen extends StatelessWidget {
  final AdvertisementModel ad;
  const AdStatsScreen({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    final total = ad.duration.days;
    final elapsed = total - ad.remainingDays;
    final progress = total == 0 ? 0.0 : (elapsed / total).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('إحصائيات الإعلان', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ad.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: [
                    AdTypeBadge(type: ad.type, compact: true),
                    AdStatusBadge(status: ad.status),
                  ]),
                  const SizedBox(height: 8),
                  Text('📍 ${Regions.describeCoverage(ad.region, ad.type.code)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _statBox(context, Icons.visibility, '${ad.stats.views}', 'مشاهدة', AppColors.crystalBlue),
                const SizedBox(width: 10),
                _statBox(context, Icons.touch_app, '${ad.stats.clicks}', 'نقرة', AppColors.goldLight),
                const SizedBox(width: 10),
                _statBox(context, Icons.trending_up, '${ad.stats.conversionRate.toStringAsFixed(0)}%', 'تحويل', AppColors.refillGreen),
              ],
            ),
            const SizedBox(height: 24),
            const Text('مدة العرض', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation(AppColors.goldLight),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('بدأ: ${_fmt(ad.duration.startDate)}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                Text('يتبقى: ${ad.remainingDays} يوم', style: const TextStyle(color: AppColors.goldLight, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.crystalBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.crystalBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.crystalBlue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('الرسم البياني اليومي وأوقات الذروة تُضاف عند ربط Firebase (المرحلة 4).', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(BuildContext context, IconData icon, String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
