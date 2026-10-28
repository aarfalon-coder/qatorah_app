import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/utils/helpers.dart';

class CashReceiptWidget extends StatelessWidget {
  final String receiptNumber;
  final String customerName;
  final String customerPhone;
  final String serviceType;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String paymentMethod;
  final DateTime date;
  final String? notes;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;

  const CashReceiptWidget({
    super.key,
    required this.receiptNumber,
    required this.customerName,
    required this.customerPhone,
    required this.serviceType,
    required this.subtotal,
    this.deliveryFee = 1.0,
    this.discount = 0.0,
    required this.total,
    this.paymentMethod = 'نقداً',
    required this.date,
    this.notes,
    this.onPrint,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══ الترويسة ═══
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppColors.goldLight,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'إيصال دفع',
                  style: TextStyle(
                    color: Color(0xFF0A0E1A),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  receiptNumber,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ═══ الخط الفاصل ═══
          _buildDashedLine(),
          const SizedBox(height: 16),

          // ═══ معلومات العميل ═══
          _buildInfoRow('العميل', customerName),
          _buildInfoRow('الهاتف', customerPhone),
          _buildInfoRow('الخدمة', serviceType),
          _buildInfoRow('التاريخ', Helpers.formatDateTime(date)),
          _buildInfoRow('طريقة الدفع', paymentMethod),

          const SizedBox(height: 16),
          _buildDashedLine(),
          const SizedBox(height: 16),

          // ═══ التفاصيل المالية ═══
          _buildPriceRow('المجموع الفرعي', subtotal),
          _buildPriceRow('رسوم التوصيل', deliveryFee),
          if (discount > 0)
            _buildPriceRow(
              'الخصم',
              -discount,
              color: AppColors.refillGreen,
            ),

          const SizedBox(height: 12),
          _buildDashedLine(),
          const SizedBox(height: 12),

          // ═══ الإجمالي ═══
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإجمالي',
                style: TextStyle(
                  color: Color(0xFF0A0E1A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} د.أ',
                style: const TextStyle(
                  color: AppColors.refillGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // ═══ ملاحظات ═══
          if (notes != null && notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDashedLine(),
            const SizedBox(height: 12),
            const Text(
              'ملاحظات:',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notes!,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 12,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // ═══ الختم ═══
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.refillGreen.withValues(alpha: 0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'مدفوع ✓',
                style: TextStyle(
                  color: AppColors.refillGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ═══ الأزرار ═══
          if (onPrint != null || onShare != null)
            Row(
              children: [
                if (onPrint != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPrint,
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('طباعة'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0A0E1A),
                        side: const BorderSide(color: Color(0xFF0A0E1A)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                if (onPrint != null && onShare != null)
                  const SizedBox(width: 10),
                if (onShare != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('مشاركة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldLight,
                        foregroundColor: const Color(0xFF0A0E1A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0A0E1A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} د.أ',
            style: TextStyle(
              color: color ?? const Color(0xFF0A0E1A),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}