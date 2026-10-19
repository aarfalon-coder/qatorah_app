import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class MachineDetailsScreen extends StatelessWidget {
  final String name;
  final String price;
  final String seller;
  final String description;

  const MachineDetailsScreen({
    super.key,
    this.name = 'فلتر مياه 5 مراحل',
    this.price = '25.00',
    this.seller = 'محلات الأمانة',
    this.description = 'فلتر مياه عالي الجودة، 5 مراحل تنقية، مناسب للاستخدام المنزلي. ضمان سنة كاملة.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('تفاصيل الماكينة', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.factoryPurple.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Icon(Icons.build_circle, color: AppColors.factoryPurple, size: 80),
            ),
          ),
          const SizedBox(height: 20),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white54, size: 16),
              const SizedBox(width: 6),
              Text(seller, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('السعر:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const Spacer(),
                Text('$price د.أ', style: const TextStyle(color: AppColors.goldLight, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('الوصف', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6)),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.phone),
              label: const Text('تواصل مع البائع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.factoryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}