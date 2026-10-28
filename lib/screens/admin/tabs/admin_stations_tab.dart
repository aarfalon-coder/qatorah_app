import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class AdminStationsTab extends StatefulWidget {
  const AdminStationsTab({super.key});

  @override
  State<AdminStationsTab> createState() => _AdminStationsTabState();
}

class _AdminStationsTabState extends State<AdminStationsTab> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _filterStatus = 'all';

  // ✅ دالة الحذف الجديدة (مع رسالة تأكيد)
  Future<void> _deleteProvider(
      BuildContext context, String userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف المزود نهائياً',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'هل أنت متأكد من حذف "$userName"؟\nلا يمكن التراجع عن هذا الإجراء وسيتم حذف جميع بياناته من قاعدة البيانات.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.plumberRed),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await _db.collection('users').doc(userId).delete();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم حذف المزود بنجاح'),
            backgroundColor: AppColors.refillGreen,
          ),
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل الحذف: $e'),
              backgroundColor: AppColors.plumberRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _updateProviderStatus(String userId, String newStatus) async {
    try {
      await _db.collection('users').doc(userId).update({
        'status': newStatus,
        'approvedByAdmin': newStatus == 'active',
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == 'active'
                ? '✅ تم تفعيل المزود بنجاح'
                : '🚫 تم إيقاف المزود'),
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
              _filterButton('موقوف', 'suspended'),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('users').where('role', whereIn: [
              'station_owner',
              'factory',
              'driver',
              'tanker',
              'station_technician',
              'plumber'
            ]).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.goldLight));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text('لا يوجد مزودين مسجلين بعد',
                        style: TextStyle(color: Colors.white54)));
              }

              var providers = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'] ?? 'pending';
                if (_filterStatus == 'all') return true;
                return status == _filterStatus;
              }).toList();

              if (providers.isEmpty) {
                return const Center(
                    child: Text('لا يوجد مزودين بهذه الحالة',
                        style: TextStyle(color: Colors.white54)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: providers.length,
                itemBuilder: (context, i) {
                  final doc = providers[i];
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'pending';
                  final isPending = status == 'pending';
                  final isActive = status == 'active';

                  Color statusColor = isPending
                      ? AppColors.goldLight
                      : (isActive
                          ? AppColors.refillGreen
                          : AppColors.plumberRed);
                  String statusText = isPending
                      ? 'بانتظار الموافقة'
                      : (isActive ? 'نشط' : 'موقوف');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1F2E),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  statusColor.withValues(alpha: 0.2),
                              child: Icon(
                                  isActive
                                      ? Icons.check_circle
                                      : (isPending
                                          ? Icons.hourglass_empty
                                          : Icons.block),
                                  color: statusColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['name'] ?? 'مزود بدون اسم',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  Text(data['phone'] ?? '',
                                      style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.6),
                                          fontSize: 12)),
                                ],
                              ),
                            ),
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
                                      fontWeight: FontWeight.bold)),
                            ),
                            // ✅ زر الحذف المضاف بجانب حالة المزود
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.plumberRed, size: 22),
                              tooltip: 'حذف المزود نهائياً',
                              onPressed: () => _deleteProvider(context, doc.id,
                                  data['name'] ?? 'هذا المزود'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showProviderDetails(data),
                                icon: const Icon(Icons.info_outline, size: 16),
                                label: const Text('التفاصيل'),
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.crystalBlue,
                                    side: const BorderSide(
                                        color: AppColors.crystalBlue)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isPending) ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _updateProviderStatus(doc.id, 'active'),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('موافقة'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.refillGreen,
                                      foregroundColor: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _updateProviderStatus(
                                      doc.id, 'suspended'),
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text('رفض'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.plumberRed,
                                      foregroundColor: Colors.white),
                                ),
                              ),
                            ] else if (isActive) ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _updateProviderStatus(
                                      doc.id, 'suspended'),
                                  icon: const Icon(Icons.block, size: 16),
                                  label: const Text('إيقاف'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.plumberRed,
                                      foregroundColor: Colors.white),
                                ),
                              ),
                            ] else if (status == 'suspended') ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _updateProviderStatus(doc.id, 'active'),
                                  icon:
                                      const Icon(Icons.check_circle, size: 16),
                                  label: const Text('تفعيل'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.refillGreen,
                                      foregroundColor: Colors.white),
                                ),
                              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.goldLight.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? AppColors.goldLight : Colors.white24),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? AppColors.goldLight : Colors.white54,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  void _showProviderDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('تفاصيل المزود', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('الاسم', data['name'] ?? 'غير محدد'),
              _detailRow('الهاتف', data['phone'] ?? 'غير محدد'),
              _detailRow('المنطقة', data['area'] ?? 'غير محدد'),
              _detailRow('نوع الخدمة', data['role'] ?? 'غير محدد'),
              _detailRow('الحالة', data['status'] ?? 'pending'),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('إغلاق', style: TextStyle(color: Colors.white54))),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
