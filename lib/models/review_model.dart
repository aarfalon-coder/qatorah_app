class ReviewModel {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String revieweeId;
  final String revieweeName;
  final String reviewType; // 'customer_to_provider', 'provider_to_customer', 'app'
  final int rating;
  final String comment;
  final List<String> images;
  final String paymentMethod; // 'cash', 'wallet', 'card'
  final String? orderId;
  final String? adId;
  final bool isFlagged;
  final String? adminResponse;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.revieweeId,
    required this.revieweeName,
    required this.reviewType,
    required this.rating,
    this.comment = '',
    this.images = const [],
    this.paymentMethod = 'wallet',
    this.orderId,
    this.adId,
    this.isFlagged = false,
    this.adminResponse,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'revieweeId': revieweeId,
      'revieweeName': revieweeName,
      'reviewType': reviewType,
      'rating': rating,
      'comment': comment,
      'images': images,
      'paymentMethod': paymentMethod,
      'orderId': orderId,
      'adId': adId,
      'isFlagged': isFlagged,
      'adminResponse': adminResponse,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      revieweeId: map['revieweeId'] ?? '',
      revieweeName: map['revieweeName'] ?? '',
      reviewType: map['reviewType'] ?? 'app',
      rating: map['rating'] ?? 5,
      comment: map['comment'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      paymentMethod: map['paymentMethod'] ?? 'wallet',
      orderId: map['orderId'],
      adId: map['adId'],
      isFlagged: map['isFlagged'] ?? false,
      adminResponse: map['adminResponse'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}