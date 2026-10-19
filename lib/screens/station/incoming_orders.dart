import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class IncomingOrdersScreen extends StatelessWidget {
  const IncomingOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {'id': 'ORD-1024', 'customer': 'محمد أحمد', 'items': '2 قارورة 20 لتر', 'total': 6.30, 'status': 'new', 'time': 'منذ 3 د'},
      {'id': 'ORD-1023', 'customer': 'سارة خالد', 'items': 'أسطوانة غاز', 'total': 8.50, 'status': 'preparing', 'time': 'منذ 12 د'},
      {'id': 'ORD-1022', 'customer': 'مطعم البركة', 'items': 'تنك مياه 6 متر', 'total': 19.00, 'status': 'on_the_way', 'time': 'منذ 25 د'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('الطلبات الواردة', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, i) => _orderCard(context, orders[i]),
      ),
    );
  }

  Widget _orderCard(BuildContext context, Map<String, dynamic> o) {
    final status = o['status'] as String;
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case 'new':
        color = AppColors.plumberRed; label = 'جديد'; icon = Icons.fiber_new;
        break;
      case 'preparing':
        color = AppColors.goldLight; label = 'قيد التحضير'; icon = Icons.hourglass_empty;
        break;
      case 'on_the_way':
        color = AppColors.crystalBlue; label = 'في الطريق'; icon = Icons.local_shipping;
        break;
      default:
        color = Colors.grey; label = 'غير معروف'; icon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 12),
                    const SizedBox(width: 4),
                    Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Spacer(),
              Text(o['time'] as String, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Text(o['id'] as String, style: const TextStyle(color: AppColors.crystalBlue, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(o['customer'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(o['items'] as String, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('الإجمالي:', style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(width: 8),
              Text('${o['total']} د.أ', style: const TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (status == 'new') ...[
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفض الطلب'), backgroundColor: AppColors.plumberRed));
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.plumberRed, side: const BorderSide(color: AppColors.plumberRed)),
                  child: const Text('رفض'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم قبول الطلب'), backgroundColor: AppColors.refillGreen));
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('قبول'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.refillGreen, foregroundColor: Colors.white),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}