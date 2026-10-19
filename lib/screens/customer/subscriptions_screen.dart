import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = [
      {'name': 'الباقة الأساسية', 'price': 15.0, 'period': 'شهرياً', 'features': ['4 قوارير مياه', 'توصيل مجاني', 'دعم فني']},
      {'name': 'الباقة الذهبية', 'price': 25.0, 'period': 'شهرياً', 'features': ['10 قوارير مياه', 'توصيل مجاني', 'أولوية في الطلبات', 'خصم 10%', 'دعم 24/7'], 'popular': true},
      {'name': 'الباقة الماسية', 'price': 45.0, 'period': 'شهرياً', 'features': ['20 قارورة مياه', 'توصيل مجاني', 'أولوية قصوى', 'خصم 15%', 'دعم 24/7', 'صيانة مجانية']},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('الاشتراكات', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.goldLight.withValues(alpha: 0.2), AppColors.goldLight.withValues(alpha: 0.05)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.card_membership, color: AppColors.goldLight, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('وفّر أكثر مع الاشتراكات!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('احصل على مياه بأسعار مخفضة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...plans.map((plan) => _buildPlanCard(context, plan)),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan) {
    final isPopular = plan['popular'] == true;
    final color = isPopular ? AppColors.goldLight : AppColors.crystalBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0.05),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPopular ? color : Colors.white.withValues(alpha: 0.1), width: isPopular ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
              child: const Text('الأكثر طلباً', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 8),
          Text(plan['name'], style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${plan['price']}', style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text('د.أ / ${plan['period']}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          ...(plan['features'] as List<String>).map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: color, size: 16),
                const SizedBox(width: 8),
                Text(f, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم اختيار ${plan['name']}'), backgroundColor: color),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('اشترك الآن', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}