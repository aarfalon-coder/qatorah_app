import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class PaymentOptionsDialog extends StatelessWidget {
  final double amount;
  final String itemName;
  final double walletBalance;
  final Function(String paymentMethod) onPaymentSelected;

  const PaymentOptionsDialog({
    super.key,
    required this.amount,
    required this.itemName,
    required this.walletBalance,
    required this.onPaymentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSufficientBalance = walletBalance >= amount;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // العنوان
            const Icon(Icons.payment, color: AppColors.goldLight, size: 50),
            const SizedBox(height: 16),
            const Text(
              'اختر طريقة الدفع',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              itemName,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'المبلغ: ${amount.toStringAsFixed(2)} د.أ',
              style: const TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // خيار 1: الدفع من المحفظة
            GestureDetector(
              onTap: hasSufficientBalance 
                  ? () => onPaymentSelected('wallet')
                  : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: hasSufficientBalance 
                      ? AppColors.refillGreen.withValues(alpha: 0.15) 
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasSufficientBalance 
                        ? AppColors.refillGreen.withValues(alpha: 0.5) 
                        : Colors.grey.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: hasSufficientBalance 
                            ? AppColors.refillGreen.withValues(alpha: 0.2) 
                            : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: hasSufficientBalance ? AppColors.refillGreen : Colors.grey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الدفع من المحفظة',
                            style: TextStyle(
                              color: hasSufficientBalance ? Colors.white : Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'رصيدك: ${walletBalance.toStringAsFixed(2)} د.أ',
                            style: TextStyle(
                              color: hasSufficientBalance ? Colors.white70 : Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                          if (hasSufficientBalance)
                            Text(
                              'الرصيد بعد الدفع: ${(walletBalance - amount).toStringAsFixed(2)} د.أ',
                              style: const TextStyle(color: AppColors.refillGreen, fontSize: 11, fontWeight: FontWeight.bold),
                            )
                          else
                            const Text(
                              '⚠️ رصيد غير كافٍ',
                              style: TextStyle(color: AppColors.plumberRed, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                    if (hasSufficientBalance)
                      const Icon(Icons.check_circle, color: AppColors.refillGreen, size: 28),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // خيار 2: الدفع نقداً
            GestureDetector(
              onTap: () => onPaymentSelected('cash'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.crystalBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.crystalBlue.withValues(alpha: 0.5), width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.crystalBlue.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.payments, color: AppColors.crystalBlue, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الدفع نقداً عند الاستلام',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ادفع للسائق مباشرة عند التوصيل',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle, color: AppColors.crystalBlue, size: 28),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // زر الإلغاء
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء', style: TextStyle(color: Colors.white54, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}