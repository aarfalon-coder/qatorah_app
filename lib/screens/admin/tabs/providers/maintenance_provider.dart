import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'provider_management_template.dart';

class MaintenanceProvider extends StatelessWidget {
  const MaintenanceProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderManagementTemplate(
      role: 'maintenance',
      title: 'صيانة عامة',
      icon: Icons.build,
      color: AppColors.refillGreen,
    );
  }
}