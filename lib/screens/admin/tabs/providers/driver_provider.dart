import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'provider_management_template.dart';

class DriverProvider extends StatelessWidget {
  const DriverProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderManagementTemplate(
      role: 'driver',
      title: 'سائقين',
      icon: Icons.directions_car,
      color: AppColors.factoryPurple,
    );
  }
}