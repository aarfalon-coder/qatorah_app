import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_colors.dart';
import 'package:qatorah_app/managers/theme_manager.dart';

class AdminContentReviewTab extends StatefulWidget {
  const AdminContentReviewTab({super.key});

  @override
  State<AdminContentReviewTab> createState() => _AdminContentReviewTabState();
}

class _AdminContentReviewTabState extends State<AdminContentReviewTab> {
  // ✅ نبدأ بعروض المزودين كخيار افتراضي
  String _contentType = 'official_provider_offers';

  final Map<String, String> _contentTypes = {
    'official_provider_offers': 'عروض المزودين',
    'marketplace_ads': 'إعلانات السوق (القطع)',
    'maintenance_requests': 'طلبات الصيانة',
  };

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('مراجعة المحتوى',
            style: TextStyle(
                color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: Column(
        children: [
          // ✅ 1. قائمة اختيار نوع المحتوى
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
            child: DropdownButtonFormField<String>(
              initialValue: _contentType,
              decoration: InputDecoration(
                labelText: 'نوع المحتوى للمراجعة',
                labelStyle:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _contentTypes.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (val) => setState(() => _contentType = val!),
            ),
          ),

          // ✅ 2. عرض العناصر المعلقة (Pending) فقط
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(_contentType)
                  .where('status', isEqualTo: 'pending')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.goldLight));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('خطأ: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 80, color: AppColors.refillGreen),
                        const SizedBox(height: 16),
                        Text('لا يوجد محتوى معلق للمراجعة',
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 16)),
                      ],
                    ),
                  );
                }

                final items = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final doc = items[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;

                    return _ReviewCard(
                      docId: docId,
                      data: data,
                      collection: _contentType,
                      isDark: isDark,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ كارت المراجعة (يحتوي على الصورة وأزرار القرار)
class _ReviewCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final String collection;
  final bool isDark;

  const _ReviewCard(
      {required this.docId,
      required this.data,
      required this.collection,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? 'بدون عنوان';
    final String providerName =
        data['provider_name'] ?? data['seller_name'] ?? 'غير معروف';
    final String imageUrl =
        (data['image_url'] ?? (data['images'] as List?)?.firstOrNull) ?? '';
    final String description = data['description'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover),
            ),
          const SizedBox(height: 12),
          Text(title,
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('المزود: $providerName',
              style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 12)),
          const SizedBox(height: 8),
          if (description.isNotEmpty)
            Text(description,
                style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(context, docId, 'rejected'),
                  icon: const Icon(Icons.close),
                  label: const Text('رفض'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.plumberRed,
                      foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(context, docId, 'approved'),
                  icon: const Icon(Icons.check),
                  label: const Text('موافقة'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.refillGreen,
                      foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _deleteItem(context, docId),
                icon: const Icon(Icons.delete, color: AppColors.plumberRed),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
      BuildContext context, String docId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(docId)
          .update({'status': status});
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('تم $status بنجاح'),
            backgroundColor: status == 'approved'
                ? AppColors.refillGreen
                : AppColors.plumberRed),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteItem(BuildContext context, String docId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المحتوى نهائياً؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.plumberRed),
              child: const Text('حذف')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      try {
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(docId)
            .delete();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم الحذف نهائياً'),
            backgroundColor: AppColors.plumberRed));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }
}
