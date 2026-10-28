import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/models/splash_ad_model.dart';
import 'package:qatorah_app/screens/admin/splash_ads/create_splash_ad_screen.dart';

class SplashAdsManagementScreen extends StatefulWidget {
  const SplashAdsManagementScreen({super.key});

  @override
  State<SplashAdsManagementScreen> createState() => _SplashAdsManagementScreenState();
}

class _SplashAdsManagementScreenState extends State<SplashAdsManagementScreen> {
  bool _isDeleting = false;

  // ✅ دالة مساعدة لتحويل نوع الإعلان لنص عربي
  String _getAdTypeName(String type) {
    switch (type) {
      case 'market': return 'السوق (مجاني)';
      case 'governorates': return 'شريط المحافظات';
      case 'hosting': return 'استضافة مدفوعة';
      case 'kingdom': return 'إعلان المملكة';
      default: return 'غير محدد';
    }
  }

  // ✅ دالة تفعيل / إيقاف الإعلان
  Future<void> _toggleAdStatus(String adId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('splash_ads').doc(adId).update({
        'isActive': !currentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!currentStatus ? '✅ تم تفعيل الإعلان' : '⛔ تم إيقاف الإعلان'),
            backgroundColor: !currentStatus ? AppColors.refillGreen : AppColors.plumberRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ فشل التحديث: $e'), backgroundColor: AppColors.plumberRed),
        );
      }
    }
  }

  // ✅ دالة حذف الإعلان نهائياً من Firestore
  Future<void> _deleteAd(String adId, String adTitle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.plumberRed, size: 28),
            SizedBox(width: 8),
            Text('حذف نهائي', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف الإعلان "$adTitle" نهائياً؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.plumberRed),
            child: const Text('نعم، احذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      try {
        // الحذف الفعلي من قاعدة البيانات
        await FirebaseFirestore.instance.collection('splash_ads').doc(adId).delete();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ تم حذف الإعلان نهائياً'),
              backgroundColor: AppColors.refillGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ فشل الحذف: $e'), backgroundColor: AppColors.plumberRed),
          );
        }
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('إدارة الإعلانات', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSplashAdScreen())),
        backgroundColor: AppColors.goldLight,
        foregroundColor: const Color(0xFF0A0E1A),
        icon: const Icon(Icons.add),
        label: const Text('إعلان جديد', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator(color: AppColors.goldLight))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('splash_ads')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.goldLight));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.plumberRed, size: 60),
                        const SizedBox(height: 16),
                        const Text('فشل تحميل الإعلانات', style: TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('${snapshot.error}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  );
                }

                final ads = snapshot.data?.docs.map((doc) {
                      return SplashAdModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                    }).toList() ??
                    [];

                if (ads.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: AppColors.crystalBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.campaign_outlined, size: 70, color: AppColors.crystalBlue),
                        ),
                        const SizedBox(height: 20),
                        const Text('لا توجد إعلانات حالياً', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('ابدأ بإضافة إعلان جديد', style: TextStyle(color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    final ad = ads[index];
                    final isActive = ad.isActive;
                    final hasExpired = DateTime.now().isAfter(ad.endDate);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ═══ صورة الإعلان وشارة الحالة ═══
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                            child: Stack(
                              children: [
                                if (ad.mediaType == 'video')
                                  Container(
                                    height: 140,
                                    width: double.infinity,
                                    color: Colors.black,
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.videocam, color: Colors.white54, size: 50),
                                          SizedBox(height: 8),
                                          Text('ملف فيديو', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Image.network(
                                    ad.mediaUrl,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 140,
                                      color: const Color(0xFF0A0E1A),
                                      child: const Center(child: Icon(Icons.broken_image, color: Colors.white24, size: 50)),
                                    ),
                                  ),
                                
                                // شارة الحالة
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isActive ? AppColors.refillGreen : (hasExpired ? AppColors.plumberRed : Colors.grey),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isActive ? '✅ نشط' : (hasExpired ? '⏰ منتهي' : '⏸️ متوقف'),
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),

                                // شارة النوع
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(ad.mediaType == 'video' ? Icons.videocam : Icons.image, color: AppColors.goldLight, size: 14),
                                        const SizedBox(width: 4),
                                        Text('${ad.durationSeconds} ث', style: const TextStyle(color: AppColors.goldLight, fontSize: 11, fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.crystalBlue.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: AppColors.crystalBlue.withValues(alpha: 0.4)),
                                          ),
                                          child: Text(
                                            _getAdTypeName(ad.adType),
                                            style: const TextStyle(color: AppColors.crystalBlue, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ═══ معلومات الإعلان ═══
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ad.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.business, color: Colors.white54, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(ad.advertiserName, style: const TextStyle(color: Colors.white54, fontSize: 12), overflow: TextOverflow.ellipsis)),
                                    const Icon(Icons.phone, color: Colors.white54, size: 14),
                                    const SizedBox(width: 4),
                                    Text(ad.advertiserPhone, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                
                                // ═══ أزرار التحكم (تفعيل / تعديل / حذف) ═══
                                Row(
                                  children: [
                                    // زر التفعيل/الإيقاف
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _toggleAdStatus(ad.id, isActive),
                                        icon: Icon(isActive ? Icons.pause : Icons.play_arrow, size: 16),
                                        label: Text(isActive ? 'إيقاف' : 'تفعيل'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: isActive ? AppColors.goldLight : AppColors.refillGreen,
                                          side: BorderSide(color: isActive ? AppColors.goldLight : AppColors.refillGreen),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    
                                    // زر التعديل
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateSplashAdScreen(existingAd: ad))),
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text('تعديل'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.crystalBlue,
                                          side: const BorderSide(color: AppColors.crystalBlue),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    
                                    // زر الحذف النهائي
                                    SizedBox(
                                      width: 50,
                                      child: OutlinedButton(
                                        onPressed: () => _deleteAd(ad.id, ad.title),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.plumberRed,
                                          side: const BorderSide(color: AppColors.plumberRed),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: const Icon(Icons.delete_outline, size: 20),
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
                  },
                );
              },
            ),
    );
  }
}