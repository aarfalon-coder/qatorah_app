import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionPlan {
  free,
  weekly,
  monthly,
  quarterly,
  yearly,
}

enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  pending,
}

class SubscriptionModel {
  final String id;
  final String userId;
  final String userName;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  
  // ═══ الأسعار ═══
  final double price;
  final String currency;
  
  // ═══ الصلاحية ═══
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? cancelledAt;
  final bool autoRenew;
  
  // ═══ الميزات ═══
  final int adsLimit;        // عدد الإعلانات المسموحة
  final int adsUsed;
  final bool hasPrioritySupport;
  final bool hasVerifiedBadge;
  final bool hasAdvancedStats;
  final double? discountPercent; // خصم على الخدمات
  
  // ═══ الدفع ═══
  final String? paymentId;
  final String paymentMethod;
  final bool isPaid;
  
  final DateTime createdAt;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.plan,
    this.status = SubscriptionStatus.pending,
    required this.price,
    this.currency = 'JOD',
    required this.startDate,
    required this.endDate,
    this.cancelledAt,
    this.autoRenew = false,
    this.adsLimit = 0,
    this.adsUsed = 0,
    this.hasPrioritySupport = false,
    this.hasVerifiedBadge = false,
    this.hasAdvancedStats = false,
    this.discountPercent,
    this.paymentId,
    this.paymentMethod = 'wallet',
    this.isPaid = false,
    required this.createdAt,
  });

  // ═══ دوال مساعدة ═══
  bool get isActive => status == SubscriptionStatus.active && !isExpired;
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isCancelled => status == SubscriptionStatus.cancelled;
  
  int get daysRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  int get adsRemaining {
    if (adsLimit <= 0) return -1; // غير محدود
    return (adsLimit - adsUsed).clamp(0, adsLimit);
  }

  String get planName {
    switch (plan) {
      case SubscriptionPlan.free: return 'مجاني';
      case SubscriptionPlan.weekly: return 'أسبوعي';
      case SubscriptionPlan.monthly: return 'شهري';
      case SubscriptionPlan.quarterly: return 'ربع سنوي';
      case SubscriptionPlan.yearly: return 'سنوي';
    }
  }

  String get statusName {
    switch (status) {
      case SubscriptionStatus.active: return 'نشط';
      case SubscriptionStatus.expired: return 'منتهي';
      case SubscriptionStatus.cancelled: return 'ملغي';
      case SubscriptionStatus.pending: return 'بانتظار الدفع';
    }
  }

  // ═══ Firestore ═══
  factory SubscriptionModel.fromMap(Map<String, dynamic> map, String id) {
    return SubscriptionModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      plan: _parsePlan(map['plan'] ?? 'free'),
      status: _parseStatus(map['status'] ?? 'pending'),
      price: (map['price'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'JOD',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cancelledAt: (map['cancelledAt'] as Timestamp?)?.toDate(),
      autoRenew: map['autoRenew'] ?? false,
      adsLimit: map['adsLimit'] ?? 0,
      adsUsed: map['adsUsed'] ?? 0,
      hasPrioritySupport: map['hasPrioritySupport'] ?? false,
      hasVerifiedBadge: map['hasVerifiedBadge'] ?? false,
      hasAdvancedStats: map['hasAdvancedStats'] ?? false,
      discountPercent: (map['discountPercent'] as num?)?.toDouble(),
      paymentId: map['paymentId'],
      paymentMethod: map['paymentMethod'] ?? 'wallet',
      isPaid: map['isPaid'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'plan': plan.name,
      'status': status.name,
      'price': price,
      'currency': currency,
      'startDate': startDate,
      'endDate': endDate,
      'cancelledAt': cancelledAt,
      'autoRenew': autoRenew,
      'adsLimit': adsLimit,
      'adsUsed': adsUsed,
      'hasPrioritySupport': hasPrioritySupport,
      'hasVerifiedBadge': hasVerifiedBadge,
      'hasAdvancedStats': hasAdvancedStats,
      'discountPercent': discountPercent,
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'createdAt': createdAt,
    };
  }

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? userName,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    double? price,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? cancelledAt,
    bool? autoRenew,
    int? adsLimit,
    int? adsUsed,
    bool? hasPrioritySupport,
    bool? hasVerifiedBadge,
    bool? hasAdvancedStats,
    double? discountPercent,
    String? paymentId,
    String? paymentMethod,
    bool? isPaid,
    DateTime? createdAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      autoRenew: autoRenew ?? this.autoRenew,
      adsLimit: adsLimit ?? this.adsLimit,
      adsUsed: adsUsed ?? this.adsUsed,
      hasPrioritySupport: hasPrioritySupport ?? this.hasPrioritySupport,
      hasVerifiedBadge: hasVerifiedBadge ?? this.hasVerifiedBadge,
      hasAdvancedStats: hasAdvancedStats ?? this.hasAdvancedStats,
      discountPercent: discountPercent ?? this.discountPercent,
      paymentId: paymentId ?? this.paymentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static SubscriptionPlan _parsePlan(String plan) {
    switch (plan) {
      case 'weekly': return SubscriptionPlan.weekly;
      case 'monthly': return SubscriptionPlan.monthly;
      case 'quarterly': return SubscriptionPlan.quarterly;
      case 'yearly': return SubscriptionPlan.yearly;
      default: return SubscriptionPlan.free;
    }
  }

  static SubscriptionStatus _parseStatus(String status) {
    switch (status) {
      case 'active': return SubscriptionStatus.active;
      case 'expired': return SubscriptionStatus.expired;
      case 'cancelled': return SubscriptionStatus.cancelled;
      default: return SubscriptionStatus.pending;
    }
  }

  // ═══ الأسعار الجاهزة (من ملفك) ═══
  static const Map<SubscriptionPlan, Map<String, dynamic>> planPrices = {
    SubscriptionPlan.free: {'price': 0.0, 'days': 30, 'ads': 3},
    SubscriptionPlan.weekly: {'price': 10.0, 'days': 7, 'ads': 5},
    SubscriptionPlan.monthly: {'price': 25.0, 'days': 30, 'ads': 10},
    SubscriptionPlan.quarterly: {'price': 60.0, 'days': 90, 'ads': 30},
    SubscriptionPlan.yearly: {'price': 200.0, 'days': 365, 'ads': 100},
  };
}