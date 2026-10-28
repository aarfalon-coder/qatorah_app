import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'provider_management_template.dart';

class WaterStationsProvider extends StatelessWidget {
  const WaterStationsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderManagementTemplate(
      role: 'station_owner',
      title: 'محطات المياه',
      icon: Icons.water_drop,
      color: AppColors.waterBlue,
    );
  }
}