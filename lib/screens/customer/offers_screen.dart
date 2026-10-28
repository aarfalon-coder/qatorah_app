import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_colors.dart';
import 'package:qatorah_app/managers/theme_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('عروض المزودين',
            style: TextStyle(
                color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ✅ تم تغيير اسم المجموعة للحل الجذري والمضمون
        stream: FirebaseFirestore.instance
            .collection('official_provider_offers')
            // ✅ نعرض فقط العروض التي وافق عليها الأدمن (approved)
            .where('status', isEqualTo: 'approved')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // ✅ حالة التحميل
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.goldLight));
          }

          // ✅ حالة الخطأ
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.plumberRed, size: 60),
                  const SizedBox(height: 16),
                  Text('حدث خطأ في تحميل العروض',
                      style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF1A2029))),
                ],
              ),
            );
          }

          // ✅ حالة عدم وجود عروض
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      size: 80),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد عروض حالياً',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A2029),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تابعنا قريباً لعروض حصرية!',
                    style: TextStyle(
                        color:
                            isDark ? Colors.white54 : const Color(0xFF64748B)),
                  ),
                ],
              ),
            );
          }

          // ✅ عرض العروض النشطة
          final offers = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final doc = offers[index];
              final data = doc.data() as Map<String, dynamic>;

              // ✅ تخطي العروض منتهية الصلاحية
              if (data['expiry_date'] != null) {
                final expiryDate = (data['expiry_date'] as Timestamp).toDate();
                if (expiryDate.isBefore(DateTime.now())) {
                  return const SizedBox.shrink();
                }
              }

              final String title = data['title'] ?? 'بدون عنوان';
              final String description = data['description'] ?? '';
              final int discount = data['discount'] ?? 0;
              final String providerName = data['provider_name'] ?? 'مزود';
              final String providerPhone = data['provider_phone'] ?? '';
              final String imageUrl = data['image_url'] ?? '';
              final String category = data['category'] ?? 'عام';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.goldLight.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldLight.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ صورة العرض
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 180,
                            color: Colors.grey[800],
                            child: const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.goldLight)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 180,
                            color: Colors.grey[800],
                            child: const Center(
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.white54, size: 50)),
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ العنوان والخصم
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1A2029),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (discount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.plumberRed,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'خصم $discount%',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // ✅ وصف العرض
                          if (description.isNotEmpty)
                            Text(
                              description,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF64748B),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          const SizedBox(height: 12),

                          // ✅ معلومات المزود
                          Row(
                            children: [
                              const Icon(Icons.store,
                                  size: 16, color: AppColors.goldLight),
                              const SizedBox(width: 6),
                              Text(
                                providerName,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : const Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.crystalBlue
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    color: AppColors.crystalBlue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ✅ أزرار التواصل
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _callProvider(providerPhone),
                                  icon: const Icon(Icons.phone, size: 18),
                                  label: const Text('اتصل الآن'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.refillGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _chatWhatsApp(providerPhone),
                                  icon: const Icon(Icons.message, size: 18),
                                  label: const Text('واتساب'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
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

  // ✅ دالة الاتصال بالمزود
  Future<void> _callProvider(String phone) async {
    if (phone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // ✅ دالة المراسلة عبر واتساب
  Future<void> _chatWhatsApp(String phone) async {
    if (phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final Uri launchUri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}
