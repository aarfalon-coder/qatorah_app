import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class DriversManagementScreen extends StatelessWidget {
  const DriversManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final drivers = [
      {'name': 'أحمد محمد', 'phone': '0791234567', 'status': 'active', 'trips': 24, 'rating': 4.9},
      {'name': 'خالد يوسف', 'phone': '0781234567', 'status': 'active', 'trips': 18, 'rating': 4.7},
      {'name': 'محمد علي', 'phone': '0771234567', 'status': 'offline', 'trips': 32, 'rating': 4.8},
      {'name': 'سامر حسن', 'phone': '0798765432', 'status': 'active', 'trips': 12, 'rating': 4.6},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('إدارة السائقين', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.goldLight,
        foregroundColor: const Color(0xFF0A0E1A),
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة سائق', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: drivers.length,
        itemBuilder: (context, i) {
          final d = drivers[i];
          final isActive = d['status'] == 'active';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isActive ? AppColors.refillGreen.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isActive ? AppColors.refillGreen.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: isActive ? AppColors.refillGreen : Colors.white54),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(d['phone'] as String, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.goldLight, size: 13),
                          const SizedBox(width: 3),
                          Text('${d['rating']}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(width: 10),
                          const Icon(Icons.route, color: AppColors.crystalBlue, size: 13),
                          const SizedBox(width: 3),
                          Text('${d['trips']} رحلة', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.refillGreen.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(isActive ? 'نشط' : 'غير متصل',
                      style: TextStyle(color: isActive ? AppColors.refillGreen : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}