import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/screens/station/station_prices_screen.dart';

class StationDashboard extends StatefulWidget {
  const StationDashboard({super.key});
  @override
  State<StationDashboard> createState() => _StationDashboardState();
}

class _StationDashboardState extends State<StationDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.goldDark.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.goldDark, width: 1.5)),
                    child: const Icon(Icons.store,
                        color: AppColors.goldLight, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('مرحباً، ${AuthManager.firstName}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('لوحة تحكم المحطة',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.05,
                children: [
                  _actionCard(Icons.price_change, 'أسعار محطتي',
                      'تحكم بأسعار منتجاتك', AppColors.goldLight, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StationPricesScreen()));
                  }),
                  _actionCard(
                      Icons.receipt_long,
                      'الطلبات',
                      'طلبات الزبائن الواردة',
                      AppColors.crystalBlue,
                      () => _soon('الطلبات')),
                  _actionCard(Icons.inventory_2, 'المخزون', 'أصنافك المتوفرة',
                      AppColors.refillGreen, () => _soon('المخزون')),
                  _actionCard(Icons.person, 'الحساب', 'بيانات محطتك',
                      AppColors.factoryPurple, () => _soon('الحساب')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionCard(IconData icon, String title, String sub, Color color,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.25),
                color.withValues(alpha: 0.05)
              ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(sub,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _soon(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('شاشة $name قيد التطوير'),
          backgroundColor: AppColors.royalBlue,
          behavior: SnackBarBehavior.floating),
    );
  }
}
