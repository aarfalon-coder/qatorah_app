import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/screens/admin/tabs/providers/provider_management_template.dart';

class AdminProvidersTab extends StatelessWidget {
  const AdminProvidersTab({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة الفئات مع ربط كل فئة بـ role الخاص بها في Firestore
    final List<Map<String, dynamic>> categories = [
      {'role': 'station_owner', 'title': 'محطات المياه', 'icon': Icons.water_drop, 'color': AppColors.waterBlue},
      {'role': 'factory_owner', 'title': 'مصانع المياه', 'icon': Icons.factory, 'color': AppColors.factoryPurple},
      {'role': 'tanker_driver', 'title': 'سائقو التنك', 'icon': Icons.opacity, 'color': AppColors.tankCyan},
      {'role': 'distribution_driver', 'title': 'سائقو التوزيع', 'icon': Icons.directions_car, 'color': AppColors.maintenanceOrange},
      {'role': 'station_technician', 'title': 'فنيو المحطات', 'icon': Icons.build, 'color': AppColors.crystalBlue},
      {'role': 'electrician', 'title': 'كهربائيين', 'icon': Icons.electrical_services, 'color': AppColors.goldLight},
      {'role': 'parts_provider', 'title': 'مزودو قطع الغيار', 'icon': Icons.handyman, 'color': AppColors.refillGreen},
    ];

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('إدارة مزودي الخدمة', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.goldLight,
            labelColor: AppColors.goldLight,
            unselectedLabelColor: Colors.white54,
            tabs: categories.map((cat) => Tab(
              icon: Icon(cat['icon'] as IconData, size: 18),
              text: cat['title'] as String,
            )).toList(),
          ),
        ),
        body: TabBarView(
          children: categories.map((cat) => ProviderManagementTemplate(
            role: cat['role'] as String,
            title: cat['title'] as String,
            icon: cat['icon'] as IconData,
            color: cat['color'] as Color,
          )).toList(),
        ),
      ),
    );
  }
}