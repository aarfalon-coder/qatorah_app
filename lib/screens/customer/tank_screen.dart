import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/screens/customer/tank_order_screen.dart';

class TankScreen extends StatelessWidget {
  const TankScreen({super.key});

  static const List<Map<String, dynamic>> tankOptions = [
    {'size': 3, 'price': 10.0, 'icon': Icons.water_drop, 'popular': false},
    {'size': 4, 'price': 13.0, 'icon': Icons.water_drop, 'popular': false},
    {'size': 6, 'price': 19.0, 'icon': Icons.opacity, 'popular': true},
    {'size': 8, 'price': 25.0, 'icon': Icons.opacity, 'popular': false},
    {'size': 10, 'price': 31.0, 'icon': Icons.water, 'popular': true},
    {'size': 20, 'price': 61.0, 'icon': Icons.water, 'popular': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنك المياه',
            style: TextStyle(
                color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.tankCyan.withValues(alpha: 0.4),
                      AppColors.tankCyan.withValues(alpha: 0.1),
                    ]),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.tankCyan.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.opacity,
                          color: AppColors.tankCyan, size: 35),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('اختر حجم التنك',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('السعر يشمل التوصيل والخدمة',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: tankOptions.length,
                  itemBuilder: (context, index) {
                    final option = tankOptions[index];
                    return _buildTankOption(context, option);
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTankOption(
      BuildContext context, Map<String, dynamic> option) {
    final int size = option['size'] as int;
    final double price = option['price'] as double;
    final bool isPopular = option['popular'] as bool;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TankOrderScreen(
              tankSize: size,
              tankPrice: price,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.tankCyan.withValues(alpha: 0.3),
              AppColors.tankCyan.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular
                ? AppColors.goldLight
                : AppColors.tankCyan.withValues(alpha: 0.5),
            width: isPopular ? 2 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            if (isPopular)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: AppGradients.goldGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('الأكثر طلباً',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.tankCyan.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tankCyan.withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Icon(option['icon'] as IconData,
                        color: AppColors.tankCyan, size: 28),
                  ),
                  const SizedBox(height: 8),

                  Text('$size متر',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 4),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$price د.أ',
                        style: const TextStyle(
                            color: AppColors.goldLight,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}