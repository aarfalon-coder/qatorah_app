import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String id;
  final String title;
  final String description;
  final String providerId;
  final String providerName;
  final String serviceType; // 'water', 'gas', 'tanker', 'maintenance', 'all'
  
  // ═══ الخصم ═══
  final String discountType; // 'percentage', 'fixed'
  final double discountValue;
  final double? minOrderAmount;
  final double? maxDiscount;
  
  // ═══ الصلاحية ═══
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  
  // ═══ القيود ═══
  final int? usageLimit;
  final int usedCount;
  final int? perUserLimit;
  final String? promoCode;
  
  // ═══ الاستهداف ═══
  final List<String> targetRegions;
  final List<String> targetUserRoles;
  
  // ═══ الوسائط ═══
  final String? imageUrl;
  final String? bannerColor;
  
  final DateTime createdAt;

  const OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.providerId,
    required this.providerName,
    required this.serviceType,
    this.discountType = 'percentage',
    required this.discountValue,
    this.minOrderAmount,
    this.maxDiscount,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.usageLimit,
    this.usedCount = 0,
    this.perUserLimit,
    this.promoCode,
    this.targetRegions = const [],
    this.targetUserRoles = const [],
    this.imageUrl,
    this.bannerColor,
    required this.createdAt,
  });

  // ═══ دوال مساعدة ═══
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get hasUsageLimit => usageLimit != null && usageLimit! > 0;
  bool get isFullyUsed => hasUsageLimit && usedCount >= usageLimit!;
  int get remainingUses => hasUsageLimit ? (usageLimit! - usedCount) : -1;

  String get discountText {
    if (discountType == 'percentage') {
      return '${discountValue.toStringAsFixed(0)}%';
    }
    return '${discountValue.toStringAsFixed(2)} د.أ';
  }

  String get statusText {
    if (!isActive) return 'غير مفعل';
    if (isExpired) return 'منتهي';
    if (isUpcoming) return 'قادم';
    if (isFullyUsed) return 'استُهلك';
    return 'نشط';
  }

  // ═══ Firestore ═══
  factory OfferModel.fromMap(Map<String, dynamic> map, String id) {
    return OfferModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? '',
      serviceType: map['serviceType'] ?? 'all',
      discountType: map['discountType'] ?? 'percentage',
      discountValue: (map['discountValue'] ?? 0.0).toDouble(),
      minOrderAmount: (map['minOrderAmount'] as num?)?.toDouble(),
      maxDiscount: (map['maxDiscount'] as num?)?.toDouble(),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      usageLimit: map['usageLimit'],
      usedCount: map['usedCount'] ?? 0,
      perUserLimit: map['perUserLimit'],
      promoCode: map['promoCode'],
      targetRegions: List<String>.from(map['targetRegions'] ?? []),
      targetUserRoles: List<String>.from(map['targetUserRoles'] ?? []),
      imageUrl: map['imageUrl'],
      bannerColor: map['bannerColor'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'providerId': providerId,
      'providerName': providerName,
      'serviceType': serviceType,
      'discountType': discountType,
      'discountValue': discountValue,
      'minOrderAmount': minOrderAmount,
      'maxDiscount': maxDiscount,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'perUserLimit': perUserLimit,
      'promoCode': promoCode,
      'targetRegions': targetRegions,
      'targetUserRoles': targetUserRoles,
      'imageUrl': imageUrl,
      'bannerColor': bannerColor,
      'createdAt': createdAt,
    };
  }

  OfferModel copyWith({
    String? id,
    String? title,
    String? description,
    String? providerId,
    String? providerName,
    String? serviceType,
    String? discountType,
    double? discountValue,
    double? minOrderAmount,
    double? maxDiscount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? usageLimit,
    int? usedCount,
    int? perUserLimit,
    String? promoCode,
    List<String>? targetRegions,
    List<String>? targetUserRoles,
    String? imageUrl,
    String? bannerColor,
    DateTime? createdAt,
  }) {
    return OfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      serviceType: serviceType ?? this.serviceType,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      perUserLimit: perUserLimit ?? this.perUserLimit,
      promoCode: promoCode ?? this.promoCode,
      targetRegions: targetRegions ?? this.targetRegions,
      targetUserRoles: targetUserRoles ?? this.targetUserRoles,
      imageUrl: imageUrl ?? this.imageUrl,
      bannerColor: bannerColor ?? this.bannerColor,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}