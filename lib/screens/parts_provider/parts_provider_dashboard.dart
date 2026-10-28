import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class PartsProviderDashboard extends StatelessWidget {
  final String userName;
  const PartsProviderDashboard({super.key, this.userName = 'مزود القطع'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('محل $userName', style: const TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _buildStatCard('مبيعات اليوم', '45 د.أ', Icons.point_of_sale, AppColors.refillGreen),
              const SizedBox(width: 12),
              _buildStatCard('طلبات جديدة', '3', Icons.shopping_cart, AppColors.goldLight),
            ],
          ),
          const SizedBox(height: 24),
          const Text('أحدث طلبات القطع', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildPartRequestCard(partName: 'فلتر رمل 1652 (حجم كبير)', customer: 'فني صيانة: أحمد', price: '12.00 د.أ'),
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

  Widget _buildPartRequestCard({required String partName, required String customer, required String price}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.handyman, color: AppColors.goldLight, size: 32),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(partName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(customer, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ])),
          Text(price, style: const TextStyle(color: AppColors.refillGreen, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}