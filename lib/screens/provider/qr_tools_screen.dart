import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/unified_scanner_screen.dart';
import 'package:qatorah_app/services/qr_service.dart';
import 'package:qatorah_app/services/payment_service.dart';

class QrToolsScreen extends StatelessWidget {
  const QrToolsScreen({super.key});

  Future<void> _handleScan(BuildContext context, String code) async {
    final result = await QrService.processQrCode(code);

    if (!context.mounted) return;

    if (result['valid'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'رمز غير صالح'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // ✅ إذا كان طلب: نعرض نافذة تأكيد الدفع
    if (result['type'] == 'order') {
      final confirmed = await _showPaymentConfirmation(context, result);
      if (confirmed == true) {
        final payment = await PaymentService().completeOrderPayment(
          orderId: result['orderId'],
          providerId: result['providerId'] ?? '',
          customerId: result['customerId'] ?? '',
          amount: (result['amount'] as num).toDouble(),
        );
        if (!context.mounted) return;
        if (payment != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ تم الدفع!\nالعمولة: ${payment.commission.toStringAsFixed(2)} | صافي المزود: ${payment.providerNet.toStringAsFixed(2)}',
              ),
              backgroundColor: AppColors.refillGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ فشل الدفع، حاول مرة ثانية'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else if (result['type'] == 'coupon') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎟️ كوبون صالح: خصم ${result['discount']}'),
          backgroundColor: AppColors.crystalBlue,
        ),
      );
    } else if (result['type'] == 'user') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('👤 العميل: ${result['userId']}'),
          backgroundColor: AppColors.goldLight,
        ),
      );
    }
  }

  Future<bool?> _showPaymentConfirmation(
    BuildContext context,
    Map<String, dynamic> result,
  ) {
    final amount = (result['amount'] as num?)?.toDouble() ?? 0.0;
    final commission = amount * 0.05;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text('تأكيد الدفع', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('رقم الطلب: ${result['orderId']}',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('المبلغ: ${amount.toStringAsFixed(2)} د.أ',
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            Text('العمولة (5%): ${commission.toStringAsFixed(2)} د.أ',
                style: const TextStyle(color: Colors.amberAccent, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              'صافي المزود: ${(amount - commission).toStringAsFixed(2)} د.أ',
              style: const TextStyle(color: AppColors.refillGreen, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.refillGreen),
            child: const Text('تأكيد الدفع'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('أدوات QR',
            style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.goldLight.withValues(alpha: 0.2),
                AppColors.goldLight.withValues(alpha: 0.05),
              ]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.4)),
            ),
            child: const Column(
              children: [
                Icon(Icons.qr_code_2, color: AppColors.goldLight, size: 50),
                SizedBox(height: 10),
                Text('أدوات QR للمزود',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('امسح الكود لتأكيد الطلب أو الكوبون',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _toolCard(
            context,
            'ماسح QR',
            'امسح كود العميل',
            Icons.qr_code_scanner,
            AppColors.refillGreen,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UnifiedScannerScreen(
                    title: 'ماسح الطلبات',
                    onScanned: (code) => _handleScan(context, code),
                  ),
                ),
              );
            },
          ),
          _toolCard(
            context,
            'مولّد QR',
            'أنشئ كود لعرضك',
            Icons.qr_code_2,
            AppColors.crystalBlue,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('مولّد QR - قريباً'),
                  backgroundColor: AppColors.crystalBlue,
                ),
              );
            },
          ),
          _toolCard(
            context,
            'كوبوناتي',
            'إدارة أكواد الخصم',
            Icons.confirmation_number,
            AppColors.goldLight,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('كوبوناتي - قريباً'),
                  backgroundColor: AppColors.goldLight,
                ),
              );
            },
          ),
          _toolCard(
            context,
            'سجل المسح',
            'آخر عمليات المسح',
            Icons.history,
            AppColors.factoryPurple,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('سجل المسح - قريباً'),
                  backgroundColor: AppColors.factoryPurple,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _toolCard(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        tileColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          sub,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: color, size: 16),
      ),
    );
  }
}