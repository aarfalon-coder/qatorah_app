import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/models/splash_ad_model.dart';
import 'package:qatorah_app/services/splash_ad_service.dart';
import 'package:qatorah_app/screens/admin/splash_ads/create_splash_ad_screen.dart';

/// ═══════════════════════════════════════════════════════════
///  SplashAdsManagementScreen — إدارة إعلانات الاستضافة
/// ═══════════════════════════════════════════════════════════

class SplashAdsManagementScreen extends StatelessWidget {
  const SplashAdsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SplashAdService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateSplashAdScreen(),
          ),
        ),
        backgroundColor: AppColors.goldLight,
        foregroundColor: const Color(0xFF0A0E1A),
        icon: const Icon(Icons.add),
        label: const Text(
          'إعلان جديد',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<SplashAdModel>>(
        stream: service.getAllAds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.goldLight),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.plumberRed, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'فشل تحميل الإعلانات',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final ads = snapshot.data ?? [];

          if (ads.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ads.length,
            itemBuilder: (context, i) => _AdCard(ad: ads[i], service: service),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.crystalBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.campaign_outlined,
                size: 70,
                color: AppColors.crystalBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد إعلانات بعد',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ بإضافة إعلان استضافة جديد',
              style: TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateSplashAdScreen(),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('إضافة إعلان'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldLight,
                foregroundColor: const Color(0xFF0A0E1A),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  AdCard — بطاقة إعلان
// ═══════════════════════════════════════════════════════════
class _AdCard extends StatelessWidget {
  final SplashAdModel ad;
  final SplashAdService service;

  const _AdCard({required this.ad, required this.service});

  @override
  Widget build(BuildContext context) {
    final isActive = ad.isCurrentlyActive;
    final hasExpired = DateTime.now().isAfter(ad.endDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppColors.refillGreen.withValues(alpha: 0.4)
              : hasExpired
                  ? AppColors.plumberRed.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // ═══ الصورة ═══
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(
              children: [
                Image.network(
                  ad.mediaUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 140,
                    color: const Color(0xFF0A0E1A),
                    child: const Center(
                      child: Icon(Icons.broken_image,
                          color: Colors.white24, size: 50),
                    ),
                  ),
                ),
                // شارة الحالة
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.refillGreen
                          : hasExpired
                              ? AppColors.plumberRed
                              : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive
                          ? '✅ نشط'
                          : hasExpired
                              ? '⏰ منتهي'
                              : '⏸️ متوقف',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // شارة النوع
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          ad.mediaType == 'video'
                              ? Icons.videocam
                              : Icons.image,
                          color: AppColors.goldLight,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${ad.durationSeconds} ث',
                          style: const TextStyle(
                            color: AppColors.goldLight,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ═══ المعلومات ═══
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان
                Text(
                  ad.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // المعلن
                Row(
                  children: [
                    const Icon(Icons.business,
                        color: Colors.white54, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ad.advertiserName,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.phone,
                        color: Colors.white54, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      ad.advertiserPhone,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 🎯 المناطق
                if (ad.targetRegions.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: ad.targetRegions.map((region) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              AppColors.crystalBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.crystalBlue
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on,
                                color: AppColors.crystalBlue, size: 10),
                            const SizedBox(width: 3),
                            Text(
                              region,
                              style: const TextStyle(
                                color: AppColors.crystalBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 10),

                // 📅 الفترة
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white54, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDate(ad.startDate)} → ${_formatDate(ad.endDate)}',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 📊 الإحصائيات
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E1A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _stat('👁️', '${ad.currentImpressions}',
                          'مشاهدة'),
                      _stat('👆', '${ad.clicks}', 'ضغطة'),
                      _stat('📈', '${ad.ctr.toStringAsFixed(1)}%', 'CTR'),
                      _stat('🎯', '${ad.remainingImpressions}',
                          'متبقي'),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ═══ الأزرار ═══
                Row(
                  children: [
                    // تفعيل / إيقاف
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => service.toggleAd(ad.id, !ad.isActive),
                        icon: Icon(
                          ad.isActive ? Icons.pause : Icons.play_arrow,
                          size: 16,
                        ),
                        label: Text(ad.isActive ? 'إيقاف' : 'تفعيل'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ad.isActive
                              ? AppColors.goldLight
                              : AppColors.refillGreen,
                          side: BorderSide(
                            color: ad.isActive
                                ? AppColors.goldLight
                                : AppColors.refillGreen,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // تعديل
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CreateSplashAdScreen(existingAd: ad),
                          ),
                        ),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('تعديل'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.crystalBlue,
                          side: const BorderSide(
                              color: AppColors.crystalBlue),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // حذف
                    SizedBox(
                      width: 48,
                      child: OutlinedButton(
                        onPressed: () => _confirmDelete(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.plumberRed,
                          side: const BorderSide(
                              color: AppColors.plumberRed),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Icon(Icons.delete_outline, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 9),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الإعلان',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'هل أنت متأكد من حذف "${ad.title}"؟',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await service.deleteAd(ad.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ تم حذف الإعلان'),
                      backgroundColor: AppColors.refillGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ فشل الحذف: $e'),
                      backgroundColor: AppColors.plumberRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.plumberRed),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}