import 'package:flutter/foundation.dart';
import 'package:qatorah_app/models/review_model.dart';

class ReviewService {
  // مؤقتاً نستخدم بيانات محلية - لاحقاً سنربطها بـ Firebase
  final List<ReviewModel> _reviews = [];

  Future<void> submitReview(ReviewModel review) async {
    // هنا سيتم إرسال التقييم لـ Firebase
    _reviews.add(review);
    debugPrint('✅ تم حفظ التقييم: ${review.id}');
  }

  Future<List<ReviewModel>> getReviewsForProvider(String providerId) async {
    // هنا سيتم جلب التقييمات من Firebase
    return _reviews.where((r) => r.revieweeId == providerId).toList();
  }

  Future<List<ReviewModel>> getReviewsForUser(String userId) async {
    return _reviews.where((r) => r.reviewerId == userId).toList();
  }

  Future<double> getAverageRating(String providerId) async {
    final reviews = await getReviewsForProvider(providerId);
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold(0.0, (total, review) => total + review.rating);
    return sum / reviews.length;
  }
}