import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_colors.dart';
import 'package:qatorah_app/managers/theme_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class PartsStoreScreen extends StatelessWidget {
  const PartsStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('متجر القطع',
            style: TextStyle(
                color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('marketplace_ads')
            .where('category', isEqualTo: 'parts')
            .where('status',
                isEqualTo:
                    'approved') // ✅ تم التعديل هنا فقط من 'active' إلى 'approved'
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
                  Text('حدث خطأ في تحميل القطع',
                      style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF1A2029))),
                ],
              ),
            );
          }

          // ✅ حالة عدم وجود قطع
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      size: 80),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد قطع متاحة حالياً',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A2029),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تابعنا قريباً لقطع غيار أصلية!',
                    style: TextStyle(
                        color:
                            isDark ? Colors.white54 : const Color(0xFF64748B)),
                  ),
                ],
              ),
            );
          }

          // ✅ عرض القطع المتاحة
          final parts = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: parts.length,
            itemBuilder: (context, index) {
              final doc = parts[index];
              final data = doc.data() as Map<String, dynamic>;

              final String title = data['title'] ?? 'بدون عنوان';
              final num price = data['price'] ?? 0;
              final String imageUrl =
                  (data['images'] as List<dynamic>?)?.firstOrNull ?? '';
              final String sellerName = data['seller_name'] ?? 'بائع';
              final String sellerPhone = data['seller_phone'] ?? '';
              final String governorate = data['governorate'] ?? '';

              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.goldLight.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldLight.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ صورة القطعة
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[800],
                            child: const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.goldLight)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: const Center(
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.white54, size: 40)),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ العنوان
                          Text(
                            title,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A2029),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // ✅ السعر
                          Row(
                            children: [
                              const Icon(Icons.price_check,
                                  size: 14, color: AppColors.goldLight),
                              const SizedBox(width: 4),
                              Text(
                                price > 0 ? '$price د.أ' : 'قابل للتفاوض',
                                style: const TextStyle(
                                  color: AppColors.goldLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // ✅ اسم البائع والمحافظة
                          Row(
                            children: [
                              Icon(Icons.store,
                                  size: 12,
                                  color: isDark
                                      ? Colors.white54
                                      : const Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  sellerName,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : const Color(0xFF64748B),
                                    fontSize: 10,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (governorate.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 12,
                                    color: isDark
                                        ? Colors.white54
                                        : const Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(
                                  governorate,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : const Color(0xFF64748B),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),

                          // ✅ أزرار التواصل
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _callSeller(sellerPhone),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.refillGreen,
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: const Text('اتصل',
                                      style: TextStyle(fontSize: 10)),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _chatWhatsApp(sellerPhone),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: const Text('واتساب',
                                      style: TextStyle(fontSize: 10)),
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

  // ✅ دالة الاتصال بالبائع
  Future<void> _callSeller(String phone) async {
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
