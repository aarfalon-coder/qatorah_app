import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'provider_management_template.dart';

class WaterTankerProvider extends StatelessWidget {
  const WaterTankerProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderManagementTemplate(
      role: 'tanker',
      title: 'تنكات المياه',
      icon: Icons.opacity,
      color: AppColors.tankCyan,
    );
  }
}