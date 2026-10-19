import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class ReviewSummaryCard extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  const ReviewSummaryCard({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    this.ratingDistribution = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // متوسط التقييم
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < averageRating.round() ? Icons.star : Icons.star_border,
                    color: AppColors.goldLight,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalReviews تقييم',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // توزيع التقييمات
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = ratingDistribution[star] ?? 0;
                // ✅ تم إصلاح الخطأ: تغيير 0 إلى 0.0 لضمان أن النوع double
                final percentage = totalReviews > 0 ? count / totalReviews : 0.0;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                      const Icon(Icons.star, color: AppColors.goldLight, size: 12),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerRight,
                            widthFactor: percentage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.goldLight,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}