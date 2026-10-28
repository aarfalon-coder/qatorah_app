import 'package:cloud_firestore/cloud_firestore.dart';

/// ═══════════════════════════════════════════════════════════
///  SplashAdModel — إعلان الاستضافة
/// ═══════════════════════════════════════════════════════════

class SplashAdModel {
  final String id;
  final String title;
  final String? description;

  // 🎬 الوسائط
  final String mediaUrl;
  final String mediaType; // 'image' | 'video'

  // ⏰ مدة العرض (1-30 ثانية)
  final int durationSeconds;

  // 📅 فترة عرض الإعلان
  final DateTime startDate;
  final DateTime endDate;

  // 🎯 الاستهداف
  final List<String> targetRegions; // ['zarqa', 'amman', 'irbid']
  final List<String> targetUserTypes; // ['customer', 'provider']

  // 🔗 الرابط والإجراء
  final String? targetUrl;
  final String? callToAction; // 'اتصل الآن', 'زيارة'

  // 💰 الدفع
  final String pricingModel; // 'cpm' | 'flat' | 'free'
  final double? price;

  // 📊 الإحصائيات
  final int maxImpressions;
  final int currentImpressions;
  final int clicks;

  // 📌 الحالة
  final bool isActive;
  final String advertiserName;
  final String advertiserPhone;

  // 🆕 نوع الإعلان (للتحكم في مكان العرض)
  final String adType; // 'market', 'governorates', 'hosting', 'kingdom'

  // 🕐 التوقيت
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const SplashAdModel({
    required this.id,
    required this.title,
    this.description,
    required this.mediaUrl,
    this.mediaType = 'image',
    this.durationSeconds = 5,
    required this.startDate,
    required this.endDate,
    this.targetRegions = const [],
    this.targetUserTypes = const [],
    this.targetUrl,
    this.callToAction,
    this.pricingModel = 'free',
    this.price,
    this.maxImpressions = 10000,
    this.currentImpressions = 0,
    this.clicks = 0,
    this.isActive = true,
    required this.advertiserName,
    required this.advertiserPhone,
    this.adType = 'market', // ✅ قيمة افتراضية آمنة
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  // ═══ دوال مساعدة ═══
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        currentImpressions < maxImpressions;
  }

  int get remainingImpressions {
    if (maxImpressions <= 0) return -1;
    return (maxImpressions - currentImpressions).clamp(0, maxImpressions);
  }

  double get ctr {
    if (currentImpressions == 0) return 0;
    return (clicks / currentImpressions) * 100;
  }

  String get pricingModelName {
    switch (pricingModel) {
      case 'cpm':
        return 'CPM (\$$price/1000)';
      case 'flat':
        return 'Flat (\$$price/يوم)';
      default:
        return 'مجاني';
    }
  }

  // ═══ Firestore ═══
  factory SplashAdModel.fromMap(Map<String, dynamic> map, String id) {
    return SplashAdModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'],
      mediaUrl: map['mediaUrl'] ?? '',
      mediaType: map['mediaType'] ?? 'image',
      durationSeconds: map['durationSeconds'] ?? 5,
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 30)),
      targetRegions: List<String>.from(map['targetRegions'] ?? []),
      targetUserTypes: List<String>.from(map['targetUserTypes'] ?? []),
      targetUrl: map['targetUrl'],
      callToAction: map['callToAction'],
      pricingModel: map['pricingModel'] ?? 'free',
      price: (map['price'] as num?)?.toDouble(),
      maxImpressions: map['maxImpressions'] ?? 10000,
      currentImpressions: map['currentImpressions'] ?? 0,
      clicks: map['clicks'] ?? 0,
      isActive: map['isActive'] ?? true,
      advertiserName: map['advertiserName'] ?? '',
      advertiserPhone: map['advertiserPhone'] ?? '',
      adType: map['adType'] ?? 'market', // ✅ قراءة النوع من القاعدة
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'durationSeconds': durationSeconds,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'targetRegions': targetRegions,
      'targetUserTypes': targetUserTypes,
      'targetUrl': targetUrl,
      'callToAction': callToAction,
      'pricingModel': pricingModel,
      'price': price,
      'maxImpressions': maxImpressions,
      'currentImpressions': currentImpressions,
      'clicks': clicks,
      'isActive': isActive,
      'advertiserName': advertiserName,
      'advertiserPhone': advertiserPhone,
      'adType': adType, // ✅ حفظ النوع في القاعدة
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  SplashAdModel copyWith({
    String? id,
    String? title,
    String? description,
    String? mediaUrl,
    String? mediaType,
    int? durationSeconds,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? targetRegions,
    List<String>? targetUserTypes,
    String? targetUrl,
    String? callToAction,
    String? pricingModel,
    double? price,
    int? maxImpressions,
    int? currentImpressions,
    int? clicks,
    bool? isActive,
    String? advertiserName,
    String? advertiserPhone,
    String? adType, // ✅ إضافة للنسخ
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return SplashAdModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetRegions: targetRegions ?? this.targetRegions,
      targetUserTypes: targetUserTypes ?? this.targetUserTypes,
      targetUrl: targetUrl ?? this.targetUrl,
      callToAction: callToAction ?? this.callToAction,
      pricingModel: pricingModel ?? this.pricingModel,
      price: price ?? this.price,
      maxImpressions: maxImpressions ?? this.maxImpressions,
      currentImpressions: currentImpressions ?? this.currentImpressions,
      clicks: clicks ?? this.clicks,
      isActive: isActive ?? this.isActive,
      advertiserName: advertiserName ?? this.advertiserName,
      advertiserPhone: advertiserPhone ?? this.advertiserPhone,
      adType: adType ?? this.adType, // ✅
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}