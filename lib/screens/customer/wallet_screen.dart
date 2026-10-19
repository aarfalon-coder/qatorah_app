import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/payments/wallet_balance_card.dart';
import 'package:qatorah_app/core/widgets/payments/payment_status_badge.dart';
import 'package:qatorah_app/managers/payment_manager.dart';
import 'package:qatorah_app/models/transaction_model.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('المحفظة', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: Consumer<PaymentManager>(
        builder: (context, mgr, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. بطاقة الرصيد
                WalletBalanceCard(
                  balance: mgr.balance,
                  points: mgr.points,
                  onRecharge: () async {
                    await mgr.rechargeBalance(20.0); // تجربة شحن وهمية
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم شحن 20.00 د.أ بنجاح!'), backgroundColor: AppColors.refillGreen),
                      );
                    }
                  },
                ),
                
                const SizedBox(height: 24),

                // 2. أزرار الإجراءات السريعة
                Row(
                  children: [
                    Expanded(child: _actionButton(context, Icons.add, 'شحن', AppColors.refillGreen)),
                    const SizedBox(width: 12),
                    Expanded(child: _actionButton(context, Icons.send, 'تحويل', AppColors.crystalBlue)),
                    const SizedBox(width: 12),
                    Expanded(child: _actionButton(context, Icons.receipt_long, 'الفواتير', AppColors.goldLight)),
                  ],
                ),

                const SizedBox(height: 28),

                // 3. سجل العمليات
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('آخر العمليات', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),

                if (mgr.transactions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('لا توجد عمليات حتى الآن', style: TextStyle(color: Colors.white54)),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: mgr.transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final txn = mgr.transactions[index];
                      return _transactionTile(txn);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label قيد التطوير'), backgroundColor: color),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _transactionTile(TransactionModel txn) {
    final isNegative = txn.type == 'payment' || txn.type == 'transfer';
    final amountColor = isNegative ? AppColors.plumberRed : AppColors.refillGreen;
    final sign = isNegative ? '-' : '+';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              txn.type == 'payment' ? Icons.shopping_cart : Icons.add_circle,
              color: amountColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.description, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy/MM/dd - hh:mm a', 'ar_JO').format(txn.createdAt),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${txn.amount.toStringAsFixed(2)} د.أ',
                style: TextStyle(color: amountColor, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              PaymentStatusBadge(status: txn.status),
            ],
          ),
        ],
      ),
    );
  }
}