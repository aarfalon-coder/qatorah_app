import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class DeliveryRequestsScreen extends StatelessWidget {
  const DeliveryRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = [
      {'id': 'ORD-1024', 'customer': 'محمد أحمد', 'address': 'إربد - الحي الشرقي', 'distance': '1.2 كم', 'price': 6.30, 'items': '2 قارورة مياه'},
      {'id': 'ORD-1025', 'customer': 'سارة خالد', 'address': 'إربد - شارع الحصن', 'distance': '2.5 كم', 'price': 8.50, 'items': 'أسطوانة غاز'},
      {'id': 'ORD-1026', 'customer': 'مطعم البركة', 'address': 'إربد - وسط البلد', 'distance': '0.8 كم', 'price': 19.00, 'items': 'تنك مياه 6 متر'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('الطلبات المتاحة', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, i) {
          final r = requests[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.crystalBlue.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(r['id'] as String, style: const TextStyle(color: AppColors.crystalBlue, fontSize: 13, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${r['price']} د.أ', style: const TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(r['customer'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                _row(Icons.location_on, r['address'] as String),
                _row(Icons.shopping_bag, r['items'] as String),
                _row(Icons.route, r['distance'] as String),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفض الطلب'), backgroundColor: AppColors.plumberRed));
                        },
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.plumberRed, side: const BorderSide(color: AppColors.plumberRed)),
                        child: const Text('رفض'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم قبول الطلب'), backgroundColor: AppColors.refillGreen));
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('قبول الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.refillGreen, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 14),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
  }
}