import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/utils/helpers.dart';
import 'package:qatorah_app/models/order_model.dart';

class OrderItemCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onTrack;
  final VoidCallback? onRate;
  final bool showActions;

  const OrderItemCard({
    super.key,
    required this.order,
    this.onTap,
    this.onCancel,
    this.onTrack,
    this.onRate,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = Helpers.getStatusColor(order.status);
    final statusIcon = Helpers.getStatusIcon(order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══ الصف الأول: الأيقونة + النوع + الحالة ═══
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getServiceIcon(order.serviceType),
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getServiceName(order.serviceType),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'طلب #${order.id.substring(order.id.length - 6)}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusName(order.status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ═══ العنوان ═══
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white54,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.locationLabel.isNotEmpty
                        ? order.locationLabel
                        : order.address,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ═══ الصف الأخير: التاريخ + الإجراءات ═══
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.white54,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  Helpers.timeAgo(order.timestamp),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                if (showActions) ...[
                  if (order.status == 'pending' && onCancel != null)
                    _buildActionButton(
                      'إلغاء',
                      Icons.close,
                      AppColors.plumberRed,
                      onCancel!,
                    ),
                  if (order.status == 'in_progress' && onTrack != null)
                    _buildActionButton(
                      'تتبع',
                      Icons.location_on,
                      AppColors.crystalBlue,
                      onTrack!,
                    ),
                  if (order.status == 'completed' && onRate != null)
                    _buildActionButton(
                      'قيّم',
                      Icons.star,
                      AppColors.goldLight,
                      onRate!,
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'water':
        return Icons.water_drop;
      case 'gas':
        return Icons.local_fire_department;
      case 'tanker':
        return Icons.local_shipping;
      case 'maintenance':
        return Icons.build_circle;
      default:
        return Icons.shopping_bag;
    }
  }

  String _getServiceName(String serviceType) {
    switch (serviceType) {
      case 'water':
        return 'توصيل مياه';
      case 'gas':
        return 'توصيل غاز';
      case 'tanker':
        return 'تنك مياه';
      case 'maintenance':
        return 'صيانة';
      default:
        return 'طلب خدمة';
    }
  }

  String _getStatusName(String status) {
    switch (status) {
      case 'pending':
        return 'بانتظار القبول';
      case 'accepted':
        return 'تم القبول';
      case 'in_progress':
        return 'جاري التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'قيد المعالجة';
    }
  }
}