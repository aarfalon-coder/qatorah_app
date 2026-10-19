import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class PaymentStatusBadge extends StatelessWidget {
  final String status; // 'completed', 'pending', 'failed', 'cash'

  const PaymentStatusBadge({super.key, required this.status});

  Color _getColor() {
    switch (status) {
      case 'completed':
        return AppColors.refillGreen;
      case 'pending':
        return AppColors.goldLight;
      case 'failed':
      case 'cancelled':
        return AppColors.plumberRed;
      case 'cash':
        return AppColors.crystalBlue;
      default:
        return Colors.white54;
    }
  }

  String _getLabel() {
    switch (status) {
      case 'completed':
        return 'مدفوع';
      case 'pending':
        return 'قيد الانتظار';
      case 'failed':
        return 'فشل';
      case 'cancelled':
        return 'ملغي';
      case 'cash':
        return 'دفع نقدي';
      default:
        return status;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'failed':
      case 'cancelled':
        return Icons.cancel;
      case 'cash':
        return Icons.payments;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            _getLabel(),
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}