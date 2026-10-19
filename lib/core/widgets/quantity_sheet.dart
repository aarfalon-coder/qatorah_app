import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';

class QuantitySheet {
  static Future<int?> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required Color color,
    required double unitPrice,
  }) {
    int qty = 1;
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: AppColors.navyDark,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border:
                Border(top: BorderSide(color: AppColors.goldDark, width: 2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.goldDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Icon(icon, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.goldLight,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text('اختر الكمية',
                  style: TextStyle(color: Colors.white70, fontSize: 15)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (qty > 1) setState(() => qty--);
                    },
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: AppColors.royalBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.goldDark, width: 2),
                      ),
                      child: const Icon(Icons.remove,
                          color: AppColors.goldLight, size: 26),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppGradients.goldGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.goldDark.withValues(alpha: 0.5),
                            blurRadius: 15)
                      ],
                    ),
                    child: Center(
                      child: Text(
                        qty.toString(),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 34,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  GestureDetector(
                    onTap: () => setState(() => qty++),
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: AppColors.royalBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.goldDark, width: 2),
                      ),
                      child: const Icon(Icons.add,
                          color: AppColors.goldLight, size: 26),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                '${(unitPrice * qty).toStringAsFixed(2)} دينار',
                style: const TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GoldButton(
                text: 'أضف إلى السلة',
                icon: Icons.shopping_cart,
                onPressed: () => Navigator.pop(ctx, qty),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
