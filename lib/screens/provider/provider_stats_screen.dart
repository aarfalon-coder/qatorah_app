import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class ProviderStatsScreen extends StatelessWidget {
  const ProviderStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('الإحصائيات', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══ 1. ملخص الأرباح ═══
            const Text('ملخص الأرباح', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildEarningsCard('اليوم', '45.00', 'د.أ', AppColors.crystalBlue, Icons.today),
                const SizedBox(width: 12),
                _buildEarningsCard('الأسبوع', '280.50', 'د.أ', AppColors.goldLight, Icons.date_range),
                const SizedBox(width: 12),
                _buildEarningsCard('الشهر', '1,250.00', 'د.أ', AppColors.refillGreen, Icons.calendar_month),
              ],
            ),
            const SizedBox(height: 30),

            // ═══ 2. إحصائيات الإعلانات ═══
            const Text('أداء الإعلانات', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildStatRow('إجمالي المشاهدات', '1,234', Icons.visibility, AppColors.crystalBlue),
                  const SizedBox(height: 16),
                  _buildStatRow('إجمالي النقرات', '89', Icons.touch_app, AppColors.goldLight),
                  const SizedBox(height: 16),
                  _buildStatRow('معدل التحويل', '7.2%', Icons.trending_up, AppColors.refillGreen),
                  const SizedBox(height: 16),
                  _buildStatRow('الإعلانات النشطة', '3', Icons.check_circle, AppColors.goldLight),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ═══ 3. إحصائيات الطلبات ═══
            const Text('أداء الطلبات', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildStatRow('طلبات اليوم', '12', Icons.shopping_bag, AppColors.crystalBlue),
                  const SizedBox(height: 16),
                  _buildStatRow('طلبات مكتملة', '156', Icons.check_circle, AppColors.refillGreen),
                  const SizedBox(height: 16),
                  _buildStatRow('طلبات ملغاة', '8', Icons.cancel, AppColors.plumberRed),
                  const SizedBox(height: 16),
                  _buildStatRow('متوسط التقييم', '4.8 ⭐', Icons.star, AppColors.goldLight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard(String period, String amount, String currency, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(period, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(amount, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(currency, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}