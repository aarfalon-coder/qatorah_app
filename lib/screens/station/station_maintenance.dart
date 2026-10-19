import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class StationMaintenanceScreen extends StatelessWidget {
  const StationMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = [
      {'id': 'MNT-001', 'type': 'سباك', 'desc': 'تسريب في خط المياه الرئيسي', 'status': 'pending', 'date': '15/10/2026'},
      {'id': 'MNT-002', 'type': 'كهربائي', 'desc': 'خلل في لوحة الكهرباء', 'status': 'in_progress', 'date': '14/10/2026'},
      {'id': 'MNT-003', 'type': 'فني محطات', 'desc': 'صيانة دورية للمضخة', 'status': 'done', 'date': '12/10/2026'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('صيانة المحطة', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.maintenanceOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('طلب صيانة', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, i) {
          final r = requests[i];
          final status = r['status'] as String;
          Color color;
          String label;
          switch (status) {
            case 'pending':
              color = AppColors.goldLight; label = 'قيد الانتظار';
              break;
            case 'in_progress':
              color = AppColors.crystalBlue; label = 'قيد التنفيذ';
              break;
            case 'done':
              color = AppColors.refillGreen; label = 'مكتمل';
              break;
            default:
              color = Colors.grey; label = 'غير معروف';
          }
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(r['id'] as String, style: const TextStyle(color: AppColors.crystalBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(r['type'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(r['desc'] as String, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(r['date'] as String, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }
}