import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'provider_management_template.dart';

class ElectricianProvider extends StatelessWidget {
  const ElectricianProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderManagementTemplate(
      role: 'electrician',
      title: 'كهرباء',
      icon: Icons.electrical_services,
      color: AppColors.goldLight,
    );
  }
}