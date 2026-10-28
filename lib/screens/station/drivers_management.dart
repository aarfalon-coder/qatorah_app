import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
// import 'package:qatorah_app/services/driver_service.dart'; // ✅ فك التعليق عند الربط

class DriversManagementScreen extends StatefulWidget {
  const DriversManagementScreen({super.key});

  @override
  State<DriversManagementScreen> createState() => _DriversManagementScreenState();
}

class _DriversManagementScreenState extends State<DriversManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('إدارة السائقين', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: فتح شاشة إضافة سائق جديد
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('سيتم فتح شاشة إضافة سائق جديد')),
          );
        },
        backgroundColor: AppColors.goldLight,
        foregroundColor: const Color(0xFF0A0E1A),
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة سائق', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        // ✅ واجهة فارغة نظيفة بدلاً من البيانات الوهمية
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, color: Colors.white38, size: 64),
            SizedBox(height: 16),
            Text(
              'لا يوجد سائقين مسجلين حالياً',
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'سيتم عرض قائمة السائقين التابعين لمحطتك هنا بمجرد ربط هذه الشاشة بـ DriverService أو StationProvider',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
          ],
        ),

        // 💡 ملاحظة: عند جاهزية الخدمة، استبدل الـ Center أعلاه بـ:
        // FutureBuilder أو StreamBuilder لجلب البيانات:
        // StreamBuilder<List<DriverModel>>(
        //   stream: DriverService.getDriversForStation(stationId),
        //   builder: (context, snapshot) { ... }
        // )
      ),
    );
  }
}