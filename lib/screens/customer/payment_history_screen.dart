import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/payments/payment_status_badge.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  // بيانات تجريبية
  final List<Map<String, dynamic>> _transactions = const [
    {
      'id': 'TXN-1024',
      'description': 'طلب أسطوانة غاز - محطة السلام',
      'amount': -14.50,
      'method': 'wallet',
      'status': 'completed',
      'date': '2026-10-12',
      'time': '10:30 ص',
    },
    {
      'id': 'TXN-1023',
      'description': 'شحن رصيد المحفظة',
      'amount': 20.00,
      'method': 'card',
      'status': 'completed',
      'date': '2026-10-11',
      'time': '03:15 م',
    },
    {
      'id': 'TXN-1022',
      'description': 'طلب تنك مياه - 4 متر',
      'amount': -13.00,
      'method': 'cash',
      'status': 'completed',
      'date': '2026-10-10',
      'time': '09:00 ص',
    },
    {
      'id': 'TXN-1021',
      'description': 'إعلان بريميوم - متجر الأمانة',
      'amount': -25.00,
      'method': 'wallet',
      'status': 'pending',
      'date': '2026-10-09',
      'time': '02:30 م',
    },
    {
      'id': 'TXN-1020',
      'description': 'استرداد - طلب ملغي',
      'amount': 7.50,
      'method': 'wallet',
      'status': 'completed',
      'date': '2026-10-08',
      'time': '11:20 ص',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('سجل المدفوعات', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final txn = _transactions[index];
          final amount = txn['amount'] as double;
          final isPositive = amount > 0;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppColors.refillGreen : AppColors.crystalBlue).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isPositive ? AppColors.refillGreen : AppColors.crystalBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn['description'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${txn['date']} - ${txn['time']}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                          ),
                          const SizedBox(width: 8),
                          PaymentStatusBadge(status: txn['status'] as String),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isPositive ? '+' : ''}${amount.toStringAsFixed(2)} د.أ',
                      style: TextStyle(
                        color: isPositive ? AppColors.refillGreen : AppColors.plumberRed,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      txn['method'] == 'wallet' ? 'محفظة' : txn['method'] == 'cash' ? 'نقداً' : 'بطاقة',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}