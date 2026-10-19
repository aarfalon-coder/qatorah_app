import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final earnings = [
      {'id': 'ORD-1024', 'date': '2026-10-15', 'amount': 6.30, 'customer': 'محمد أحمد'},
      {'id': 'ORD-1023', 'date': '2026-10-15', 'amount': 8.50, 'customer': 'سارة خالد'},
      {'id': 'ORD-1022', 'date': '2026-10-14', 'amount': 19.00, 'customer': 'مطعم البركة'},
      {'id': 'ORD-1021', 'date': '2026-10-14', 'amount': 5.75, 'customer': 'خالد يوسف'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('أرباحي', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('إجمالي الأرباح', style: TextStyle(color: Colors.white70, fontSize: 13)),
                SizedBox(height: 8),
                Text('324.55 د.أ', style: TextStyle(color: AppColors.refillGreen, fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('منذ بداية الشهر', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _statBox('اليوم', '45.50', AppColors.crystalBlue)),
              const SizedBox(width: 12),
              Expanded(child: _statBox('الأسبوع', '128.30', AppColors.goldLight)),
              const SizedBox(width: 12),
              Expanded(child: _statBox('الشهر', '324.55', AppColors.refillGreen)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('سجل الأرباح', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...earnings.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.refillGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.attach_money, color: AppColors.refillGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e['customer'] as String, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('${e['id']} • ${e['date']}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
                Text('+${e['amount']} د.أ', style: const TextStyle(color: AppColors.refillGreen, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}