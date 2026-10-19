import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/payments/payment_option_card.dart';
import 'package:qatorah_app/core/widgets/payments/wallet_balance_card.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double amount;
  final String orderDescription;

  const PaymentMethodScreen({
    super.key,
    required this.amount,
    required this.orderDescription,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selectedMethod = 'wallet';
  final double _walletBalance = 45.50;
  final int _walletPoints = 1250;
  bool _saveForFuture = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('طريقة الدفع', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ملخص الطلب
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('المبلغ المطلوب', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.amount.toStringAsFixed(2)} د.أ',
                          style: const TextStyle(color: AppColors.goldLight, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.orderDescription,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.shopping_bag, color: AppColors.goldLight, size: 32),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // رصيد المحفظة (يظهر فقط إذا اختار المحفظة)
            if (_selectedMethod == 'wallet') ...[
              WalletBalanceCard(
                balance: _walletBalance,
                points: _walletPoints,
              ),
              const SizedBox(height: 16),
              if (_walletBalance < widget.amount)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.plumberRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.plumberRed.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: AppColors.plumberRed, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'رصيدك غير كافٍ. يرجى شحن المحفظة أو اختيار طريقة دفع أخرى.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // عنوان طرق الدفع
            const Text(
              'اختر طريقة الدفع',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // خيارات الدفع
            PaymentOptionCard(
              icon: Icons.account_balance_wallet,
              title: 'محفظة قطوره',
              subtitle: 'خصم فوري + نقاط مكافأة',
              color: AppColors.refillGreen,
              isSelected: _selectedMethod == 'wallet',
              onTap: () => setState(() => _selectedMethod = 'wallet'),
            ),
            const SizedBox(height: 12),

            PaymentOptionCard(
              icon: Icons.payments,
              title: 'الدفع نقداً عند الاستلام',
              subtitle: 'ادفع للسائق مباشرة',
              color: AppColors.crystalBlue,
              isSelected: _selectedMethod == 'cash',
              onTap: () => setState(() => _selectedMethod = 'cash'),
            ),
            const SizedBox(height: 12),

            PaymentOptionCard(
              icon: Icons.credit_card,
              title: 'بطاقة ائتمان / مدى',
              subtitle: 'Visa / Mastercard - قريباً',
              color: AppColors.factoryPurple,
              isSelected: _selectedMethod == 'card',
              isEnabled: false,
              onTap: () {},
            ),
            const SizedBox(height: 24),

            // حفظ الطريقة للمستقبل
            if (_selectedMethod != 'cash')
              Row(
                children: [
                  Checkbox(
                    value: _saveForFuture,
                    onChanged: (val) => setState(() => _saveForFuture = val ?? false),
                    activeColor: AppColors.goldLight,
                    checkColor: const Color(0xFF0A0E1A),
                  ),
                  const Expanded(
                    child: Text(
                      'احفظ هذه الطريقة للمرات القادمة',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // زر تأكيد الدفع
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _selectedMethod == 'wallet' && _walletBalance < widget.amount
                    ? null
                    : () => _confirmPayment(),
                icon: const Icon(Icons.lock, size: 20),
                label: Text(
                  _selectedMethod == 'wallet' && _walletBalance < widget.amount
                      ? 'رصيد غير كافٍ'
                      : 'تأكيد الدفع - ${widget.amount.toStringAsFixed(2)} د.أ',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedMethod == 'wallet' && _walletBalance < widget.amount
                      ? Colors.grey
                      : AppColors.refillGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPayment() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تأكيد الدفع', style: TextStyle(color: AppColors.goldLight)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.payment, color: AppColors.refillGreen, size: 50),
            const SizedBox(height: 12),
            Text(
              '${widget.amount.toStringAsFixed(2)} د.أ',
              style: const TextStyle(color: AppColors.goldLight, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'عبر ${_selectedMethod == 'wallet' ? 'محفظة قطوره' : 'الدفع النقدي'}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم الدفع بنجاح! ✅'),
                  backgroundColor: AppColors.refillGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.refillGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}