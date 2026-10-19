import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/models/part_model.dart';

class PartsStoreScreen extends StatelessWidget {
  const PartsStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('متجر القطع',
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: PartsCatalog.all.length,
              itemBuilder: (context, index) {
                final part = PartsCatalog.all[index];
                return GlassCard(
                  glowColor: part.color,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // الأيقونة بدون حدود
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              part.color.withValues(alpha: 0.5),
                              part.color.withValues(alpha: 0.2)
                            ]),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: part.color.withValues(alpha: 0.5),
                                  blurRadius: 10)
                            ],
                          ),
                          child: Icon(part.icon, size: 32, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        // اسم القطعة فقط
                        Text(
                          part.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        // السعر
                        Text(
                          '${part.price.toStringAsFixed(2)} دينار',
                          style: const TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        // زر الإضافة
                        GestureDetector(
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تمت إضافة ${part.name} للسلة'),
                              backgroundColor: AppColors.refillGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: AppGradients.goldGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_shopping_cart,
                                    size: 14, color: Colors.black),
                                SizedBox(width: 4),
                                Text('أضف للسلة',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
