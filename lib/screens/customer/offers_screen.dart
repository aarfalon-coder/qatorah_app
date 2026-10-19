import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  final List<Map<String, dynamic>> _offers = const [
    {
      'icon': Icons.local_drink,
      'color': AppColors.tankCyan,
      'title': 'دفتر كوبونات + قارورة مجاناً',
      'desc': 'اشتري دفتر كوبونات مياه واحصل على قارورة مجانية مع كل دفتر.',
      'terms': 'يسري حتى نهاية الشهر - مرة واحدة لكل عميل',
    },
    {
      'icon': Icons.local_fire_department,
      'color': Color(0xFFE65100),
      'title': 'خصم 15% على أول طلب غاز',
      'desc': 'عميل جديد؟ أول طلب أسطوانة غاز عليك بخصم 15%.',
      'terms': 'للحسابات الجديدة فقط - يُطبق تلقائياً عند الدفع',
    },
    {
      'icon': Icons.group_add,
      'color': AppColors.goldLight,
      'title': 'ادعُ 100 صديق = دفتر مجاني',
      'desc': 'شارك رابطك الخاص وكل 100 مشترك ناجح عن طريقك = دفتر كوبونات مجاني (وللمزودين 10 د.أ رصيد).',
      'terms': 'تُحتسب الدعوة بعد أول طلب مدفوع للمدعو',
    },
  ];

  void _claimOffer(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تفعيل العرض', style: TextStyle(color: AppColors.goldLight)),
        content: Text('سيتم تطبيق عرض "$title" تلقائياً عند إتمام الطلب المؤهل.', style: const TextStyle(color: Colors.white)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight, foregroundColor: const Color(0xFF0A0E1A)),
            child: const Text('فهمت'),
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
        title: const Text('عروض قطوره', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _offers.length,
        itemBuilder: (context, index) {
          final offer = _offers[index];
          final color = offer['color'] as Color;
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                      child: Icon(offer['icon'] as IconData, color: color, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(offer['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                      child: const Text('عرض', style: TextStyle(color: Color(0xFF0A0E1A), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(offer['desc'] as String, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white38, size: 14),
                    const SizedBox(width: 6),
                    Expanded(child: Text(offer['terms'] as String, style: const TextStyle(color: Colors.white38, fontSize: 11))),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _claimOffer(context, offer['title'] as String),
                    style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: const Color(0xFF0A0E1A)),
                    child: const Text('استفد من العرض'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}