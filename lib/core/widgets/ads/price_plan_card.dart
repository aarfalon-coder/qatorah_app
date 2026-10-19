import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/models/advertisement_model.dart';

class AdPlan {
  final int days;
  final double price;
  final String label;
  const AdPlan({required this.days, required this.price, required this.label});
}

class AdPlans {
  AdPlans._();
  static const List<AdPlan> free = [AdPlan(days: 7, price: 0, label: 'أسبوع')];
  static const List<AdPlan> premium = [
    AdPlan(days: 7, price: 10, label: 'أسبوع'),
    AdPlan(days: 30, price: 25, label: 'شهر'),
    AdPlan(days: 90, price: 60, label: '3 أشهر'),
    AdPlan(days: 365, price: 200, label: 'سنة'),
  ];
  
  static List<AdPlan> forType(AdType type) => type == AdType.free ? free : premium;
  
  static double priceFor(AdType type, int days) {
    for (final p in forType(type)) { 
      if (p.days == days) return p.price; 
    }
    return 0;
  }
}

class PricePlanCard extends StatelessWidget {
  final AdType type;
  final int selectedDays;
  final ValueChanged<int> onChanged;
  
  const PricePlanCard({
    super.key, 
    required this.type, 
    required this.selectedDays, 
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final plans = AdPlans.forType(type);
    final accent = type == AdType.free ? AppColors.crystalBlue : AppColors.goldLight;
    
    return Wrap(
      spacing: 10, 
      runSpacing: 10,
      children: plans.map((plan) {
        final sel = plan.days == selectedDays;
        return GestureDetector(
          onTap: () => onChanged(plan.days),
          child: Container(
            width: 150,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: sel ? accent.withValues(alpha: 0.18) : const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sel ? accent : Colors.white.withValues(alpha: 0.1), width: sel ? 2 : 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.label, 
                      style: TextStyle(color: sel ? Colors.white : Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)
                    ),
                    if (sel) const Icon(Icons.check_circle, color: AppColors.goldLight, size: 18),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan.price == 0 ? 'مجاني' : '${plan.price.toInt()} د.أ', 
                  style: TextStyle(color: plan.price == 0 ? AppColors.refillGreen : accent, fontSize: 20, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 2),
                Text('${plan.days} يوم', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}