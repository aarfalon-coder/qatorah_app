import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'provider_management_template.dart';

class GasProvider extends StatelessWidget {
  const GasProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderManagementTemplate(
      role: 'gas_supplier',
      title: 'مزودو الغاز',
      icon: Icons.local_fire_department,
      color: AppColors.maintenanceOrange,
    );
  }
}