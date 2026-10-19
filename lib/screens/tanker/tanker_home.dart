import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class TankerHomeScreen extends StatelessWidget {
  const TankerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('لوحة الصهريج', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.tankCyan.withValues(alpha: 0.3), AppColors.tankCyan.withValues(alpha: 0.1)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.tankCyan.withValues(alpha: 0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_shipping, color: AppColors.tankCyan, size: 40),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('صهريج المياه', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('الحالة: متاح', style: TextStyle(color: AppColors.tankCyan, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _stat('اليوم', '8 طلبات', Icons.inbox, AppColors.crystalBlue),
              const SizedBox(width: 12),
              _stat('الأرباح', '45 د.أ', Icons.attach_money, AppColors.refillGreen),
              const SizedBox(width: 12),
              _stat('التقييم', '4.8', Icons.star, AppColors.goldLight),
            ],
          ),
          const SizedBox(height: 24),
          const Text('إجراءات سريعة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _action(context, 'الطلبات الجديدة', Icons.notifications_active, AppColors.plumberRed),
          _action(context, 'سجل التوصيلات', Icons.history, AppColors.crystalBlue),
          _action(context, 'الأرباح', Icons.account_balance_wallet, AppColors.refillGreen),
          _action(context, 'الإعدادات', Icons.settings, AppColors.goldLight),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
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
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _action(BuildContext context, String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withValues(alpha: 0.3))),
        leading: Icon(icon, color: color, size: 24),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {},
      ),
    );
  }
}