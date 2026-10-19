import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  final String supplierName;
  final double totalPrice;
  final String? estimatedTime;

  const OrderConfirmationScreen({
    super.key,
    this.orderId = 'ORD-2026-XXXX',
    this.supplierName = 'محطة السلام',
    this.totalPrice = 0.0,
    this.estimatedTime = '15-20 دقيقة',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // ═══ أيقونة النجاح ═══
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.refillGreen.withValues(alpha: 0.3),
                    AppColors.refillGreen.withValues(alpha: 0.1),
                  ]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.refillGreen.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_circle, color: AppColors.refillGreen, size: 80),
              ),
              const SizedBox(height: 30),

              // ═══ العنوان ═══
              const Text('تم استلام طلبك!',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('رقم الطلب: $orderId',
                  style: const TextStyle(color: AppColors.goldLight, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // ═══ تفاصيل الطلب ═══
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    _row('المزود', supplierName, Icons.store),
                    const Divider(color: Colors.white12, height: 20),
                    _row('الإجمالي', '${totalPrice.toStringAsFixed(2)} د.أ', Icons.payments),
                    const Divider(color: Colors.white12, height: 20),
                    _row('الوقت المتوقع', estimatedTime ?? '--', Icons.access_time),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ═══ حالة الطلب ═══
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.crystalBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.crystalBlue.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.crystalBlue, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('سيتم التواصل معك من قبل المزود لتأكيد الطلب',
                          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ═══ زر المتابعة ═══
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home),
                  label: const Text('العودة للرئيسية',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldLight,
                    foregroundColor: const Color(0xFF0A0E1A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: const Text('تتبع الطلب',
                    style: TextStyle(color: AppColors.crystalBlue, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.goldLight, size: 20),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}