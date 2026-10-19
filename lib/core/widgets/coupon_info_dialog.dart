import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class CouponInfoDialog extends StatelessWidget {
  const CouponInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.goldLight.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.menu_book, color: AppColors.goldLight, size: 40),
            ),
            const SizedBox(height: 14),
            const Text('كيف يعمل دفتر الكوبونات؟', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _bullet('دفترك صالح لدى أي محطة مشتركة مع قطوره في جميع أنحاء المملكة'),
            _bullet('غير مربوط بمحطة واحدة — عبّيه واستخدميه من وين ما كنت'),
            _bullet('كل كوبون = خدمة واحدة حسب نوع الدفتر'),
            _bullet('رصيد كوبوناتك يظهر لحظياً داخل التطبيق'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.crystalBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, color: AppColors.crystalBlue, size: 16),
                  SizedBox(width: 6),
                  Text('قريباً: زر "شاهد المحطات المشتركة"', style: TextStyle(color: AppColors.crystalBlue, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight, foregroundColor: const Color(0xFF0A0E1A)),
                child: const Text('فهمت', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✔ ', style: TextStyle(color: AppColors.refillGreen, fontSize: 13)),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13))),
        ],
      ),
    );
  }
}

void showCouponBookInfo(BuildContext context) {
  showDialog(context: context, builder: (_) => const CouponInfoDialog());
}