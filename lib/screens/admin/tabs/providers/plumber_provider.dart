import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'provider_management_template.dart';

class PlumberProvider extends StatelessWidget {
  const PlumberProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderManagementTemplate(
      role: 'plumber',
      title: 'سباكة',
      icon: Icons.plumbing,
      color: AppColors.crystalBlue,
    );
  }
}