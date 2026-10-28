import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class AdminMarketplaceAdsTab extends StatefulWidget {
  const AdminMarketplaceAdsTab({super.key});

  @override
  State<AdminMarketplaceAdsTab> createState() => _AdminMarketplaceAdsTabState();
}

class _AdminMarketplaceAdsTabState extends State<AdminMarketplaceAdsTab> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _filterStatus = 'all';
  int _currentPage = 0; // لتتبع صفحة الصور

  Future<void> _updateAdStatus(String adId, String newStatus) async {
    try {
      await _db.collection('marketplace_ads').doc(adId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'active'
                  ? '✅ تم تفعيل الإعلان بنجاح'
                  : newStatus == 'rejected'
                      ? '🚫 تم رفض الإعلان'
                      : '⏸️ تم إيقاف الإعلان',
            ),
            backgroundColor: newStatus == 'active'
                ? AppColors.refillGreen
                : AppColors.plumberRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('خطأ: $e'), backgroundColor: AppColors.plumberRed));
      }
    }
  }

  Future<void> _deleteAd(
      BuildContext context, String adId, String adTitle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الإعلان نهائياً',
            style: TextStyle(color: Colors.white)),
        content: Text(
            'هل أنت متأكد من حذف "$adTitle"؟\nلا يمكن التراجع عن هذا الإجراء وسيتم حذف الصور والبيانات.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:
                  const Text('إلغاء', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.plumberRed),
              child: const Text('حذف نهائي')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      try {
        await _db.collection('marketplace_ads').doc(adId).delete();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('✅ تم حذف الإعلان بنجاح'),
            backgroundColor: AppColors.refillGreen));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('فشل الحذف: $e'),
              backgroundColor: AppColors.plumberRed));
        }
      }
    }
  }

  void _showAdDetails(Map<String, dynamic> data, String adId) {
    final images = List<String>.from(data['images'] ?? []);
    showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
              builder: (ctx, setDialogState) => Dialog(
                backgroundColor: const Color(0xFF1A1F2E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (images.isNotEmpty) ...[
                          SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
                                PageView.builder(
                                  itemCount: images.length,
                                  onPageChanged: (index) => setDialogState(
                                      () => _currentPage = index),
                                  itemBuilder: (context, index) => ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: images[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child: CircularProgressIndicator(
                                                  color: AppColors.goldLight)),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                              color: Colors.grey[800],
                                              child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.white54,
                                                  size: 50)),
                                    ),
                                  ),
                                ),
                                if (images.length > 1)
                                  Positioned(
                                    bottom: 10,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                          images.length,
                                          (index) => Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4),
                                                width: _currentPage == index
                                                    ? 10
                                                    : 6,
                                                height: _currentPage == index
                                                    ? 10
                                                    : 6,
                                                decoration: BoxDecoration(
                                                  color: _currentPage == index
                                                      ? AppColors.goldLight
                                                      : Colors.white54,
                                                  shape: BoxShape.circle,
                                                ),
                                              )),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const Text('تفاصيل الإعلان',
                            style: TextStyle(
                                color: AppColors.goldLight,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const Divider(color: Colors.white24),
                        _detailRow('العنوان', data['title'] ?? 'غير محدد'),
                        _detailRow(
                            'السعر',
                            data['price'] != null
                                ? '${data['price']} د.أ'
                                : 'قابل للتفاوض'),
                        _detailRow('البائع', data['seller_name'] ?? 'غير محدد'),
                        _detailRow(
                            'رقم الهاتف', data['seller_phone'] ?? 'غير محدد'),
                        _detailRow(
                            'المحافظة', data['governorate'] ?? 'غير محدد'),
                        _detailRow('كفالة قطوره',
                            data['isGuaranteed'] == true ? '✅ نعم' : '❌ لا'),
                        _detailRow('الحالة', data['status'] ?? 'pending'),
                        _detailRow('المشاهدات', '${data['views'] ?? 0}'),
                        _detailRow('الإعجابات', '${data['likes'] ?? 0}'),
                        const SizedBox(height: 12),
                        const Text('الوصف:',
                            style: TextStyle(
                                color: AppColors.goldLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(data['description'] ?? 'لا يوجد وصف',
                              style: const TextStyle(
                                  color: Colors.white70, height: 1.5)),
                        ),
                        const SizedBox(height: 20),
                        Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('إغلاق',
                                    style: TextStyle(
                                        color: Colors.white54, fontSize: 16)))),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  Widget _detailRow(String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 14)),
            Flexible(
                child: Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis)),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            color: const Color(0xFF0A0E1A),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _filterButton('الكل', 'all'),
                _filterButton('قيد المراجعة', 'pending'),
                _filterButton('نشط', 'active'),
                _filterButton('مرفوض', 'rejected'),
              ],
            )),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db
                .collection('marketplace_ads')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.goldLight));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text('لا توجد إعلانات في السوق بعد',
                        style: TextStyle(color: Colors.white54, fontSize: 16)));
              }

              var ads = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'] ?? 'pending';
                if (_filterStatus == 'all') return true;
                return status == _filterStatus;
              }).toList();

              if (ads.isEmpty) {
                return const Center(
                    child: Text('لا توجد إعلانات بهذه الحالة',
                        style: TextStyle(color: Colors.white54, fontSize: 16)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ads.length,
                itemBuilder: (context, i) {
                  final doc = ads[i];
                  final data = doc.data() as Map<String, dynamic>;
                  final adId = doc.id;
                  final status = data['status'] ?? 'pending';
                  final images = List<String>.from(data['images'] ?? []);
                  final isPending = status == 'pending';
                  final isActive = status == 'active';
                  Color statusColor = isPending
                      ? AppColors.goldLight
                      : (isActive
                          ? AppColors.refillGreen
                          : AppColors.plumberRed);
                  String statusText = isPending
                      ? 'بانتظار الموافقة'
                      : (isActive ? 'نشط' : 'مرفوض');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1A1F2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.4))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: images.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: images.first,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey[800],
                                                    child: const Icon(
                                                        Icons.image,
                                                        color: Colors.white54)),
                                            errorWidget: (context, url, error) =>
                                                Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey[800],
                                                    child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.white54)))
                                        : Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[800],
                                            child: const Icon(Icons.image,
                                                color: Colors.white54))),
                                if (images.length > 1)
                                  Positioned(
                                      bottom: 4,
                                      right: 4,
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: Text('${images.length}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.bold)))),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['title'] ?? 'بدون عنوان',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(data['seller_name'] ?? 'بائع',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                    data['price'] != null
                                        ? '${data['price']} د.أ'
                                        : 'قابل للتفاوض',
                                    style: const TextStyle(
                                        color: AppColors.goldLight,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ],
                            )),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text(statusText,
                                    style: TextStyle(
                                        color: statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child: OutlinedButton.icon(
                                    onPressed: () => _showAdDetails(data, adId),
                                    icon: const Icon(Icons.info_outline,
                                        size: 16),
                                    label: const Text('التفاصيل'),
                                    style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.crystalBlue,
                                        side: const BorderSide(
                                            color: AppColors.crystalBlue)))),
                            const SizedBox(width: 8),
                            IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.plumberRed, size: 28),
                                tooltip: 'حذف الإعلان',
                                onPressed: () => _deleteAd(context, adId,
                                    data['title'] ?? 'هذا الإعلان')),
                            const SizedBox(width: 8),
                            if (isPending) ...[
                              Expanded(
                                  child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _updateAdStatus(adId, 'active'),
                                      icon: const Icon(Icons.check, size: 16),
                                      label: const Text('موافقة'),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.refillGreen,
                                          foregroundColor: Colors.white))),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _updateAdStatus(adId, 'rejected'),
                                      icon: const Icon(Icons.close, size: 16),
                                      label: const Text('رفض'),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.plumberRed,
                                          foregroundColor: Colors.white))),
                            ] else if (isActive) ...[
                              Expanded(
                                  child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _updateAdStatus(adId, 'suspended'),
                                      icon: const Icon(Icons.pause_circle,
                                          size: 16),
                                      label: const Text('إيقاف'),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.plumberRed,
                                          foregroundColor: Colors.white))),
                            ] else ...[
                              Expanded(
                                  child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _updateAdStatus(adId, 'active'),
                                      icon: const Icon(Icons.play_circle,
                                          size: 16),
                                      label: const Text('تفعيل'),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.refillGreen,
                                          foregroundColor: Colors.white))),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _filterButton(String label, String status) {
    final isSelected = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: isSelected
                ? AppColors.goldLight.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isSelected ? AppColors.goldLight : Colors.white24)),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? AppColors.goldLight : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}
