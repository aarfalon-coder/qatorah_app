import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class AccountingLedgerScreen extends StatelessWidget {
  const AccountingLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {'type': 'in', 'desc': 'طلب ORD-1024', 'amount': 6.30, 'date': '15/10/2026'},
      {'type': 'in', 'desc': 'طلب ORD-1023', 'amount': 8.50, 'date': '15/10/2026'},
      {'type': 'out', 'desc': 'سحب رصيد', 'amount': 50.00, 'date': '14/10/2026'},
      {'type': 'in', 'desc': 'طلب ORD-1022', 'amount': 19.00, 'date': '14/10/2026'},
      {'type': 'out', 'desc': 'عمولة التطبيق 5%', 'amount': 1.70, 'date': '14/10/2026'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('دفتر الحسابات', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.goldLight.withValues(alpha: 0.3), AppColors.goldLight.withValues(alpha: 0.1)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الرصيد الحالي', style: TextStyle(color: Colors.white70, fontSize: 13)),
                SizedBox(height: 8),
                Text('125.45 د.أ', style: TextStyle(color: AppColors.goldLight, fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.arrow_downward, color: AppColors.refillGreen, size: 14),
                    SizedBox(width: 4),
                    Text('وارد: 245.30', style: TextStyle(color: AppColors.refillGreen, fontSize: 12)),
                    SizedBox(width: 16),
                    Icon(Icons.arrow_upward, color: AppColors.plumberRed, size: 14),
                    SizedBox(width: 4),
                    Text('صادر: 119.85', style: TextStyle(color: AppColors.plumberRed, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('طلب سحب'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.refillGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('آخر العمليات', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...transactions.map((t) {
            final isIn = t['type'] == 'in';
            final color = isIn ? AppColors.refillGreen : AppColors.plumberRed;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Icon(isIn ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['desc'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        Text(t['date'] as String, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text('${isIn ? '+' : '-'}${t['amount']} د.أ',
                      style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}