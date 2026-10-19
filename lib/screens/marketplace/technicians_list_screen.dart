import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/screens/marketplace/technician_profile_screen.dart';

class TechniciansListScreen extends StatelessWidget {
  const TechniciansListScreen({super.key});

  List<Map<String, dynamic>> get _techs => [
    {
      'name': 'أحمد السباك',
      'spec': 'سباك',
      'rating': 4.9,
      'jobs': 145,
      'phone': '0791234567',
      'icon': Icons.plumbing,
      'color': AppColors.crystalBlue,
    },
    {
      'name': 'محمد الكهربائي',
      'spec': 'كهربائي',
      'rating': 4.8,
      'jobs': 98,
      'phone': '0781234567',
      'icon': Icons.electrical_services,
      'color': AppColors.goldLight,
    },
    {
      'name': 'خالد المهندس',
      'spec': 'مهندس صيانة',
      'rating': 4.7,
      'jobs': 76,
      'phone': '0771234567',
      'icon': Icons.engineering,
      'color': AppColors.maintenanceOrange,
    },
    {
      'name': 'سامر الفني',
      'spec': 'فني محطات',
      'rating': 4.6,
      'jobs': 52,
      'phone': '0761234567',
      'icon': Icons.build_circle,
      'color': AppColors.factoryPurple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'الفنيين المتاحين',
          style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _techs.length,
        itemBuilder: (context, index) => _techCard(context, _techs[index]),
      ),
    );
  }

  Widget _techCard(BuildContext context, Map<String, dynamic> t) {
    final color = t['color'] as Color;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TechnicianProfileScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(t['icon'] as IconData, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t['spec'] as String,
                    style: TextStyle(color: color, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.goldLight, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${t['rating']}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.work_outline, color: Colors.white54, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${t['jobs']} مهمة',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}