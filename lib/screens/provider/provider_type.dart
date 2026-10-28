import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class ProviderTypeScreen extends StatelessWidget {
  const ProviderTypeScreen({super.key});

  // ✅ 9 أدوار كاملة ومحدثة
  List<Map<String, dynamic>> get _types => [
    {'id': 'station_owner', 'label': 'صاحب محطة مياه', 'icon': Icons.store, 'color': AppColors.waterBlue},
    {'id': 'factory_owner', 'label': 'صاحب مصنع مياه', 'icon': Icons.factory, 'color': AppColors.factoryPurple},
    {'id': 'tanker_driver', 'label': 'سائق تنك مياه', 'icon': Icons.local_shipping, 'color': AppColors.tankCyan},
    {'id': 'distribution_driver', 'label': 'سائق توزيع مياه', 'icon': Icons.delivery_dining, 'color': const Color(0xFF00897B)},
    {'id': 'station_technician', 'label': 'فني محطات', 'icon': Icons.build_circle, 'color': AppColors.maintenanceOrange},
    {'id': 'electrician', 'label': 'كهربائي', 'icon': Icons.electrical_services, 'color': const Color(0xFFFFD600)},
    {'id': 'general_driver', 'label': 'سائق عام', 'icon': Icons.directions_car, 'color': const Color(0xFF5C6BC0)},
    {'id': 'programmer', 'label': 'مبرمج PLC / أنظمة', 'icon': Icons.memory, 'color': AppColors.crystalBlue},
    {'id': 'parts_provider', 'label': 'صاحب محل قطع غيار', 'icon': Icons.handyman, 'color': AppColors.goldLight},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('اختر نوع خدمتك', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('حدد نوع الخدمة التي تقدمها لتتمكن من التسجيل', 
            style: TextStyle(color: Colors.white70, fontSize: 14), 
            textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ..._types.map((t) => _typeCard(context, t)),
        ],
      ),
    );
  }

  Widget _typeCard(BuildContext context, Map<String, dynamic> t) {
    final color = t['color'] as Color;
    return GestureDetector(
      onTap: () {
        // ⚠️ مهم: وجهه لشاشة التسجيل عشان نحفظ الدور والوثائق
        // Navigator.push(context, MaterialPageRoute(builder: (_) => ProviderRegisterScreen(role: t['id'])));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ تم اختيار: ${t['label']}'), backgroundColor: color),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Icon(t['icon'] as IconData, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(t['label'] as String, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}