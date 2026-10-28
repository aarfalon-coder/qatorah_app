import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qatorah_app/core/theme/app_colors.dart';
import 'package:qatorah_app/managers/theme_manager.dart';
import 'package:qatorah_app/models/technician_model.dart';

class AdminTechniciansTab extends StatefulWidget {
  const AdminTechniciansTab({super.key});

  @override
  State<AdminTechniciansTab> createState() => _AdminTechniciansTabState();
}

class _AdminTechniciansTabState extends State<AdminTechniciansTab> {
  // ✅ دالة إيقاف أو تفعيل الفني
  Future<void> _toggleSuspension(String techId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('technicians')
          .doc(techId)
          .update({
        'is_suspended': !currentStatus,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              !currentStatus ? 'تم إيقاف الفني بنجاح' : 'تم تفعيل الفني بنجاح'),
          backgroundColor:
              !currentStatus ? AppColors.plumberRed : AppColors.refillGreen,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('فشل التحديث: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('إدارة الفنيين',
            style: TextStyle(
                color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('technicians')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.goldLight));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('لا يوجد فنيون مسجلون حتى الآن',
                  style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54)),
            );
          }

          final technicians = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: technicians.length,
            itemBuilder: (context, index) {
              final doc = technicians[index];
              final tech = TechnicianModel.fromMap(
                  doc.data() as Map<String, dynamic>, doc.id);
              final isSuspended = tech.isSuspended;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isSuspended
                          ? AppColors.plumberRed
                          : AppColors.goldLight.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: tech.specialty.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(tech.specialty.icon,
                              color: tech.specialty.color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tech.name,
                                style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 14, color: AppColors.goldLight),
                                  const SizedBox(width: 4),
                                  Text(
                                      '${tech.rating} (${tech.reviewCount} تقييم)',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              isSuspended ? 'موقوف' : 'نشط',
                              style: TextStyle(
                                color: isSuspended
                                    ? AppColors.plumberRed
                                    : AppColors.refillGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Switch(
                              value: !isSuspended,
                              onChanged: (val) =>
                                  _toggleSuspension(doc.id, !isSuspended),
                              activeThumbColor: AppColors.refillGreen,
                              activeTrackColor:
                                  AppColors.refillGreen.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isSuspended) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColors.plumberRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.warning,
                                color: AppColors.plumberRed, size: 16),
                            SizedBox(width: 8),
                            Text(
                                'هذا الفني متوقف عن العمل ولا يمكنه استقبال طلبات جديدة',
                                style: TextStyle(
                                    color: AppColors.plumberRed, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
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
