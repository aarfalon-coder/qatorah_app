import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class TechnicianProfileScreen extends StatelessWidget {
  final String name;
  final String spec;
  final double rating;
  final int jobs;

  const TechnicianProfileScreen({
    super.key,
    this.name = 'أحمد السباك',
    this.spec = 'سباك',
    this.rating = 4.9,
    this.jobs = 145,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ملف الفني', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.crystalBlue.withValues(alpha: 0.2),
              child: const Icon(Icons.person, color: AppColors.crystalBlue, size: 50),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
          const SizedBox(height: 6),
          Center(child: Text(spec, style: const TextStyle(color: AppColors.goldLight, fontSize: 14))),
          const SizedBox(height: 24),
          Row(
            children: [
              _stat('التقييم', '$rating', Icons.star, AppColors.goldLight),
              const SizedBox(width: 12),
              _stat('الأعمال', '$jobs', Icons.check_circle, AppColors.refillGreen),
              const SizedBox(width: 12),
              _stat('الخبرة', '5 سنوات', Icons.workspace_premium, AppColors.crystalBlue),
            ],
          ),
          const SizedBox(height: 24),
          const Text('الخدمات', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _service('تصليح تسريبات المياه', 15.0),
          _service('تركيب خلاطات', 20.0),
          _service('صيانة سخانات', 25.0),
          _service('تمديدات صحية', 50.0),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.phone),
              label: const Text('اتصل بالفني', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.refillGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _service(String name, double price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.refillGreen, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14))),
          Text('$price د.أ', style: const TextStyle(color: AppColors.goldLight, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}