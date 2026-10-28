import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class SpecialistProviderDashboard extends StatelessWidget {
  final String role;
  final String userName;
  
  const SpecialistProviderDashboard({super.key, required this.role, this.userName = 'مزود خدمة'});

  String get _title {
    switch (role) {
      case 'electrician': return 'لوحة الكهربائي';
      case 'programmer': return 'لوحة مبرمج الأنظمة';
      case 'distribution_driver': return 'لوحة سائق التوزيع';
      default: return 'لوحة التحكم';
    }
  }

  IconData get _icon {
    switch (role) {
      case 'electrician': return Icons.electrical_services;
      case 'programmer': return Icons.memory;
      case 'distribution_driver': return Icons.delivery_dining;
      default: return Icons.person;
    }
  }

  Color get _color {
    switch (role) {
      case 'electrician': return const Color(0xFFFFD600);
      case 'programmer': return AppColors.crystalBlue;
      case 'distribution_driver': return const Color(0xFF00897B);
      default: return AppColors.goldLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_title, style: TextStyle(color: _color, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, size: 80, color: _color.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            Text('مرحباً $userName', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('هذه اللوحة مخصصة لخدمات $_title', style: const TextStyle(color: Colors.white54, fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('تسجيل طلب / مهمة جديدة'),
              style: ElevatedButton.styleFrom(backgroundColor: _color, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            )
          ],
        ),
      ),
    );
  }
}