import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class FactoryDashboardScreen extends StatelessWidget {
  final String userName;
  const FactoryDashboardScreen({super.key, this.userName = 'صاحب المصنع'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('لوحة مصنع $userName', style: const TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.goldLight), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _buildStatCard('إجمالي الإنتاج', '15,000', Icons.factory, AppColors.factoryPurple),
              const SizedBox(width: 12),
              _buildStatCard('طلبات المحطات', '24', Icons.water_drop, AppColors.waterBlue),
            ],
          ),
          const SizedBox(height: 24),
          const Text('طلبات التزويد الجديدة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildRequestCard(stationName: 'محطة الرمثا المركزية', quantity: '500 قارورة', status: 'بانتظار الموافقة', color: AppColors.maintenanceOrange),
          const SizedBox(height: 12),
          _buildRequestCard(stationName: 'محطة إربد الشمالية', quantity: '1200 قارورة', status: 'جاري التجهيز', color: AppColors.crystalBlue),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _buildRequestCard({required String stationName, required String quantity, required String status, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle), child: Icon(Icons.request_quote, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(stationName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text('الكمية: $quantity', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }
}