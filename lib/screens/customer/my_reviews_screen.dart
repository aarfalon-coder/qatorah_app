import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/reviews/review_item_card.dart';
import 'package:qatorah_app/core/widgets/reviews/star_rating_widget.dart';
import 'package:qatorah_app/screens/customer/customer_review_screen.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  // ✅ قائمة المزودين حسب النوع (لاحقاً من Firebase)
  final Map<String, List<String>> _providersByType = {
    'صاحب محطة': ['محطة السلام', 'محطة النور', 'محطة الجبل'],
    'سائق تنك': ['تنك المياه الشمالي', 'تنك البركة', 'تنك الأقصى'],
    'موزع غاز': ['أسطوانات الأمانة', 'غاز الشرق', 'غاز الوطن'],
    'سباك / فني': ['فني السباكة محمد', 'فني الصحة أحمد', 'فني التمديدات علي'],
  };

  // تقييماتي السابقة (لاحقاً من Firebase)
  final List<Map<String, dynamic>> _myReviews = [
    {
      'providerName': 'محطة السلام',
      'rating': 5,
      'comment': 'خدمة ممتازة وسريعة جداً! التوصيل كان في الوقت المحدد.',
      'date': '12 أكتوبر 2026',
    },
    {
      'providerName': 'تنك المياه الشمالي',
      'rating': 4,
      'comment': 'خدمة جيدة، لكن التأخر قليلاً في الموعد.',
      'date': '10 أكتوبر 2026',
    },
    {
      'providerName': 'أسطوانات الأمانة',
      'rating': 5,
      'comment': 'أفضل موزع غاز في المنطقة، أسعار مناسبة وخدمة راقية.',
      'date': '5 أكتوبر 2026',
    },
  ];

  // ═══ نافذة اختيار المزود للتقييم ═══
  void _showAddReviewDialog() {
    String selectedType = 'صاحب محطة';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final providers = _providersByType[selectedType] ?? [];
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1F2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('من تريد أن تقيّم؟', style: TextStyle(color: AppColors.goldLight)),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1. اختر نوع المزود:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _providersByType.keys.map((type) {
                      final isSelected = selectedType == type;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedType = type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.goldLight.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? AppColors.goldLight : Colors.white24),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('2. اختر المزود:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: providers.map((name) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.crystalBlue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.store, color: AppColors.crystalBlue, size: 20),
                          ),
                          title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          trailing: const Icon(Icons.chevron_left, color: Colors.white38),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomerReviewScreen(
                                  providerName: name,
                                  providerType: selectedType,
                                  orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
                                  paymentMethod: 'wallet',
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double avgRating = _myReviews.isEmpty
        ? 0
        : _myReviews.fold(0.0, (sum, r) => sum + (r['rating'] as int)) / _myReviews.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('تقييماتي', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      // ✅ الزر العائم: تقييم مزود خدمة جديد
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReviewDialog,
        backgroundColor: AppColors.goldLight,
        foregroundColor: const Color(0xFF0A0E1A),
        icon: const Icon(Icons.rate_review, size: 20),
        label: const Text('قيّم مزود خدمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        elevation: 6,
      ),
      body: Column(
        children: [
          // ملخص التقييمات
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.goldLight.withValues(alpha: 0.3),
                  AppColors.goldLight.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, color: AppColors.goldLight, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إجمالي تقييماتك', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '${_myReviews.length} تقييم',
                        style: const TextStyle(color: AppColors.goldLight, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'متوسط تقييماتك: ${avgRating.toStringAsFixed(1)} من 5',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                StarRatingWidget(rating: avgRating.round(), size: 16),
              ],
            ),
          ),

          // قائمة التقييمات
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              itemCount: _myReviews.length,
              itemBuilder: (context, index) {
                final review = _myReviews[index];
                return ReviewItemCard(
                  reviewerName: review['providerName'] as String,
                  rating: review['rating'] as int,
                  comment: review['comment'] as String,
                  date: review['date'] as String,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}