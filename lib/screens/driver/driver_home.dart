import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('لوحة السائق', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.refillGreen.withValues(alpha: 0.3), AppColors.refillGreen.withValues(alpha: 0.1)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.refillGreen.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أرباح اليوم', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                const Text('45.50 د.أ', style: TextStyle(color: AppColors.refillGreen, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppColors.refillGreen, size: 16),
                    const SizedBox(width: 4),
                    const Text('+12% عن أمس', style: TextStyle(color: AppColors.refillGreen, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _statCard('الطلبات', '8', Icons.inbox, AppColors.crystalBlue),
              const SizedBox(width: 12),
              _statCard('التوصيلات', '6', Icons.check_circle, AppColors.refillGreen),
              const SizedBox(width: 12),
              _statCard('التقييم', '4.9', Icons.star, AppColors.goldLight),
            ],
          ),
          const SizedBox(height: 24),
          const Text('إجراءات سريعة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _actionBtn(context, 'الطلبات المتاحة', Icons.list_alt, AppColors.crystalBlue, () {}),
          _actionBtn(context, 'التوصيلات الحالية', Icons.local_shipping, AppColors.goldLight, () {}),
          _actionBtn(context, 'الأرباح', Icons.account_balance_wallet, AppColors.refillGreen, () {}),
          _actionBtn(context, 'الملف الشخصي', Icons.person, AppColors.factoryPurple, () {}),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        tileColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withValues(alpha: 0.3))),
        leading: Icon(icon, color: color, size: 24),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      ),
    );
  }
}