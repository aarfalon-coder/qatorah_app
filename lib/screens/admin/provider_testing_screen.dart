import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/screens/provider_home.dart';
import 'package:qatorah_app/screens/factory/factory_dashboard_screen.dart';
import 'package:qatorah_app/screens/parts_provider/parts_provider_dashboard.dart';
import 'package:qatorah_app/screens/provider/specialist_provider_dashboard.dart';
import 'package:qatorah_app/screens/technician/technician_dashboard_screen.dart';

class ProviderTestingScreen extends StatelessWidget {
  const ProviderTestingScreen({super.key});

  final List<Map<String, dynamic>> _providerTypes = const [
    {
      'id': 'station',
      'title': 'صاحب محطة تعبئة',
      'icon': Icons.water_drop,
      'color': AppColors.waterBlue,
      'subtitle': 'إدارة محطات تعبئة المياه',
      'screen': 'ProviderHomeScreen',
    },
    {
      'id': 'factory',
      'title': 'صاحب مصنع مياه',
      'icon': Icons.factory,
      'color': AppColors.factoryPurple,
      'subtitle': 'إنتاج وتوزيع المصانع',
      'screen': 'FactoryDashboardScreen',
    },
    {
      'id': 'tanker',
      'title': 'سائق تنك مياه',
      'icon': Icons.local_shipping,
      'color': AppColors.tankCyan,
      'subtitle': 'توصيل التنكات للمنازل',
      'screen': 'SpecialistProviderDashboard',
    },
    {
      'id': 'distribution',
      'title': 'سائق توزيع مياه',
      'icon': Icons.delivery_dining,
      'color': Color(0xFF00897B),
      'subtitle': 'توصيل القوارير',
      'screen': 'SpecialistProviderDashboard',
    },
    {
      'id': 'technician',
      'title': 'فني محطات',
      'icon': Icons.build,
      'color': AppColors.maintenanceOrange,
      'subtitle': 'صيانة وإصلاح المحطات',
      'screen': 'TechnicianDashboardScreen',
    },
    {
      'id': 'electrician',
      'title': 'فني كهرباء',
      'icon': Icons.electrical_services,
      'color': Color(0xFFFFD600),
      'subtitle': 'أعطال الكهرباء للمحطات',
      'screen': 'SpecialistProviderDashboard',
    },
    {
      'id': 'plumber',
      'title': 'سباك / صيانة',
      'icon': Icons.plumbing,
      'color': AppColors.crystalBlue,
      'subtitle': 'صيانة شبكات المياه',
      'screen': 'TechnicianDashboardScreen',
    },
    {
      'id': 'parts',
      'title': 'مزود قطع غيار',
      'icon': Icons.handyman,
      'color': AppColors.goldLight,
      'subtitle': 'بيع قطع الغيار والفلاتر',
      'screen': 'PartsProviderDashboard',
    },
    {
      'id': 'gas',
      'title': 'مزود غاز',
      'icon': Icons.local_fire_department,
      'color': Color(0xFFE65100),
      'subtitle': 'توصيل أسطوانات الغاز',
      'screen': 'ProviderHomeScreen',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('اختبار لوحات المزودين', 
          style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _providerTypes.length,
        itemBuilder: (context, index) {
          final provider = _providerTypes[index];
          return _buildProviderCard(context, provider);
        },
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, Map<String, dynamic> provider) {
    final color = provider['color'] as Color;
    
    return GestureDetector(
      onTap: () {
        _openDashboard(context, provider);
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                provider['icon'] as IconData,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider['subtitle'] as String,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDashboard(BuildContext context, Map<String, dynamic> provider) {
    Widget dashboard;
    
    switch (provider['id']) {
      case 'factory':
        dashboard = const FactoryDashboardScreen();
        break;
      case 'parts':
        dashboard = const PartsProviderDashboard();
        break;
      case 'tanker':
        dashboard = const SpecialistProviderDashboard(role: 'tanker_driver');
        break;
      case 'distribution':
        dashboard = const SpecialistProviderDashboard(role: 'distribution_driver');
        break;
      case 'electrician':
        dashboard = const SpecialistProviderDashboard(role: 'electrician');
        break;
      case 'technician':
      case 'plumber':
        dashboard = const TechnicianDashboardScreen();
        break;
      case 'station':
      case 'gas':
      default:
        dashboard = const ProviderHomeScreen();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }
}