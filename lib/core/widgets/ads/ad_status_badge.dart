import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/models/advertisement_model.dart';

class AdStatusBadge extends StatelessWidget {
  final AdStatus status;
  final bool compact;
  const AdStatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(status), color: color, size: compact ? 10 : 13),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(status.label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ],
      ),
    );
  }

  Color _colorFor(AdStatus status) {
    switch (status) {
      case AdStatus.active:
      case AdStatus.approved:
        return AppColors.refillGreen;
      case AdStatus.pending:
        return AppColors.goldLight;
      case AdStatus.rejected:
      case AdStatus.cancelled:
        return AppColors.plumberRed;
      case AdStatus.expired:
        return Colors.grey;
    }
  }

  IconData _iconFor(AdStatus status) {
    switch (status) {
      case AdStatus.active:
      case AdStatus.approved:
        return Icons.check_circle;
      case AdStatus.pending:
        return Icons.hourglass_empty;
      case AdStatus.rejected:
        return Icons.cancel;
      case AdStatus.expired:
        return Icons.timer_off;
      case AdStatus.cancelled:
        return Icons.block;
    }
  }
}