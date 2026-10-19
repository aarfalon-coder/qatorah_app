import 'region_model.dart';

/// ═══════════════════════════════════════════════════════════
///  Advertisement Model — الكيان المركزي لنظام الإعلانات
///  يطابق مواصفة القطورة v1.0 (25 قراراً) + 🆕 AdScope
/// ═══════════════════════════════════════════════════════════

/// 🆕 نطاق الإعلان (محافظة أو مملكة)
enum AdScope { governorate, kingdom }

extension AdScopeExt on AdScope {
  String get code => this == AdScope.kingdom ? 'kingdom' : 'governorate';
  String get label => this == AdScope.governorate ? 'محافظة' : 'كل المملكة';
  String get emoji => this == AdScope.governorate ? '📍' : '🌍';
  
  static AdScope fromCode(String? c) =>
      c == 'kingdom' ? AdScope.kingdom : AdScope.governorate;
}

enum AdType {
  free('free', 'مجاني', '🆓'),
  premium('premium', 'بريميوم', '⭐'),
  qatorah('qatorah', 'قطوره', '🏢');

  const AdType(this.code, this.label, this.emoji);
  final String code;
  final String label;
  final String emoji;

  static AdType fromCode(String? c) =>
      AdType.values.firstWhere((e) => e.code == c, orElse: () => AdType.free);
}

enum AdStatus {
  pending('pending', 'قيد المراجعة'),
  approved('approved', 'معتمد'),
  active('active', 'نشط'),
  rejected('rejected', 'مرفوض'),
  expired('expired', 'منتهي'),
  cancelled('cancelled', 'ملغى');

  const AdStatus(this.code, this.label);
  final String code;
  final String label;

  static AdStatus fromCode(String? c) =>
      AdStatus.values.firstWhere((e) => e.code == c, orElse: () => AdStatus.pending);
}

enum AdCategory {
  water('water', 'مياه', '💧'),
  gas('gas', 'غاز', '🔥'),
  maintenance('maintenance', 'صيانة', '🔧'),
  marketplace('marketplace', 'سوق', '🛒'),
  other('other', 'أخرى', '📦');

  const AdCategory(this.code, this.label, this.emoji);
  final String code;
  final String label;
  final String emoji;

  static AdCategory fromCode(String? c) =>
      AdCategory.values.firstWhere((e) => e.code == c, orElse: () => AdCategory.other);
}

/// ═══ حدود النظام (القرارات 6، 14) ═══
class AdLimits {
  AdLimits._();
  static const int freeMonthlyLimit = 3;
  static const Map<AdType, int> maxImages = {
    AdType.free: 1,
    AdType.premium: 3,
    AdType.qatorah: 5,
  };
  static const int autoPauseReports = 5;
}

// ───────────────────────── الكائنات الفرعية ─────────────────────────

class PublisherInfo {
  final String userId;
  final String userName;
  final String userRole;
  final double userRating;
  final String userPhone;

  const PublisherInfo({
    required this.userId,
    required this.userName,
    this.userRole = '',
    this.userRating = 0.0,
    this.userPhone = '',
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'userRole': userRole,
        'userRating': userRating,
        'userPhone': userPhone,
      };

  factory PublisherInfo.fromMap(Map<String, dynamic> m) => PublisherInfo(
        userId: m['userId'] ?? '',
        userName: m['userName'] ?? '',
        userRole: m['userRole'] ?? '',
        userRating: (m['userRating'] ?? 0).toDouble(),
        userPhone: m['userPhone'] ?? '',
      );
}

class AdPricing {
  final double amount;
  final String currency;
  final String paymentMethod;
  final String? transactionId;
  final bool isHeld;

  const AdPricing({
    this.amount = 0,
    this.currency = 'JOD',
    this.paymentMethod = 'wallet',
    this.transactionId,
    this.isHeld = false,
  });

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'currency': currency,
        'paymentMethod': paymentMethod,
        'transactionId': transactionId,
        'isHeld': isHeld,
      };

  factory AdPricing.fromMap(Map<String, dynamic> m) => AdPricing(
        amount: (m['amount'] ?? 0).toDouble(),
        currency: m['currency'] ?? 'JOD',
        paymentMethod: m['paymentMethod'] ?? 'wallet',
        transactionId: m['transactionId'],
        isHeld: m['isHeld'] ?? false,
      );

  AdPricing copyWith({bool? isHeld, String? transactionId}) => AdPricing(
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
        transactionId: transactionId ?? this.transactionId,
        isHeld: isHeld ?? this.isHeld,
      );
}

class AdDuration {
  final int days;
  final DateTime startDate;
  final DateTime endDate;
  final bool renewalReminded;

  const AdDuration({
    required this.days,
    required this.startDate,
    required this.endDate,
    this.renewalReminded = false,
  });

  Map<String, dynamic> toMap() => {
        'days': days,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'renewalReminded': renewalReminded,
      };

  factory AdDuration.fromMap(Map<String, dynamic> m) => AdDuration(
        days: m['days'] ?? 0,
        startDate: DateTime.tryParse(m['startDate'] ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(m['endDate'] ?? '') ?? DateTime.now(),
        renewalReminded: m['renewalReminded'] ?? false,
      );

  AdDuration copyWith({DateTime? endDate, bool? renewalReminded}) => AdDuration(
        days: days,
        startDate: startDate,
        endDate: endDate ?? this.endDate,
        renewalReminded: renewalReminded ?? this.renewalReminded,
      );
}

class AdModeration {
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final String? notes;

  const AdModeration({
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'reviewedBy': reviewedBy,
        'reviewedAt': reviewedAt?.toIso8601String(),
        'rejectionReason': rejectionReason,
        'notes': notes,
      };

  factory AdModeration.fromMap(Map<String, dynamic>? m) => AdModeration(
        reviewedBy: m?['reviewedBy'],
        reviewedAt: m?['reviewedAt'] != null
            ? DateTime.tryParse(m!['reviewedAt'])
            : null,
        rejectionReason: m?['rejectionReason'],
        notes: m?['notes'],
      );
}

class AdStats {
  final int views;
  final int clicks;
  final int shares;
  final List<String> peakDays;
  final List<String> peakHours;

  const AdStats({
    this.views = 0,
    this.clicks = 0,
    this.shares = 0,
    this.peakDays = const [],
    this.peakHours = const [],
  });

  double get conversionRate => views == 0 ? 0 : (clicks / views) * 100;

  Map<String, dynamic> toMap() => {
        'views': views,
        'clicks': clicks,
        'shares': shares,
        'peakDays': peakDays,
        'peakHours': peakHours,
      };

  factory AdStats.fromMap(Map<String, dynamic> m) => AdStats(
        views: m['views'] ?? 0,
        clicks: m['clicks'] ?? 0,
        shares: m['shares'] ?? 0,
        peakDays: List<String>.from(m['peakDays'] ?? []),
        peakHours: List<String>.from(m['peakHours'] ?? []),
      );

  AdStats copyWith({int? views, int? clicks, int? shares}) => AdStats(
        views: views ?? this.views,
        clicks: clicks ?? this.clicks,
        shares: shares ?? this.shares,
        peakDays: peakDays,
        peakHours: peakHours,
      );
}

class AdVisibility {
  final bool showInTicker;
  final bool showInMarketplace;
  final int priority;
  final bool featured;

  const AdVisibility({
    this.showInTicker = false,
    this.showInMarketplace = true,
    this.priority = 3,
    this.featured = false,
  });

  Map<String, dynamic> toMap() => {
        'showInTicker': showInTicker,
        'showInMarketplace': showInMarketplace,
        'priority': priority,
        'featured': featured,
      };

  factory AdVisibility.fromMap(Map<String, dynamic> m) => AdVisibility(
        showInTicker: m['showInTicker'] ?? false,
        showInMarketplace: m['showInMarketplace'] ?? true,
        priority: m['priority'] ?? 3,
        featured: m['featured'] ?? false,
      );
}

class AdReports {
  final int count;
  final List<String> reasons;

  const AdReports({this.count = 0, this.reasons = const []});

  bool get shouldAutoPause => count >= AdLimits.autoPauseReports;

  Map<String, dynamic> toMap() => {'count': count, 'reasons': reasons};

  factory AdReports.fromMap(Map<String, dynamic> m) => AdReports(
        count: m['count'] ?? 0,
        reasons: List<String>.from(m['reasons'] ?? []),
      );

  AdReports addReport(String reason) => AdReports(
        count: count + 1,
        reasons: [...reasons, reason],
      );
}

// ───────────────────────── النموذج الرئيسي ─────────────────────────

class AdvertisementModel {
  final String id;
  final PublisherInfo publisher;
  final String title;
  final String description;
  final List<String> images;
  final AdCategory category;
  final AdType type;
  final AdScope scope;         // 🆕 نطاق الإعلان (محافظة / مملكة)
  final AdPricing pricing;
  final Governorate region;
  final List<String> coverage;
  final AdDuration duration;
  final AdStatus status;
  final AdModeration moderation;
  final AdStats stats;
  final AdVisibility visibility;
  final AdReports reports;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdvertisementModel({
    required this.id,
    required this.publisher,
    required this.title,
    required this.description,
    required this.images,
    required this.category,
    required this.type,
    required this.scope,         // 🆕
    required this.pricing,
    required this.region,
    required this.coverage,
    required this.duration,
    required this.status,
    required this.moderation,
    required this.stats,
    required this.visibility,
    required this.reports,
    required this.createdAt,
    required this.updatedAt,
  });

  // ═══ getters مساعدة ═══

  bool get isActive => status == AdStatus.active;
  bool get isPending => status == AdStatus.pending;
  bool get isRejected => status == AdStatus.rejected;
  bool get isExpired => status == AdStatus.expired;

  bool get isDisplayable =>
      isActive && DateTime.now().isBefore(duration.endDate);

  int get remainingDays {
    final diff = duration.endDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  bool get needsRenewalReminder =>
      isActive && (remainingDays == 3 || remainingDays == 1);

  bool get eligibleForTicker =>
      visibility.showInTicker &&
      (type == AdType.premium || type == AdType.qatorah);

  int get sortPriority => visibility.priority;

  bool visibleTo(Governorate? customerGov) =>
      Regions.isVisibleTo(coverage, customerGov);

  // ═══ copyWith ═══
  AdvertisementModel copyWith({
    String? title,
    String? description,
    List<String>? images,
    AdCategory? category,
    AdType? type,
    AdScope? scope,             // 🆕
    AdPricing? pricing,
    Governorate? region,
    List<String>? coverage,
    AdDuration? duration,
    AdStatus? status,
    AdModeration? moderation,
    AdStats? stats,
    AdVisibility? visibility,
    AdReports? reports,
    DateTime? updatedAt,
  }) {
    return AdvertisementModel(
      id: id,
      publisher: publisher,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      category: category ?? this.category,
      type: type ?? this.type,
      scope: scope ?? this.scope,         // 🆕
      pricing: pricing ?? this.pricing,
      region: region ?? this.region,
      coverage: coverage ?? this.coverage,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      moderation: moderation ?? this.moderation,
      stats: stats ?? this.stats,
      visibility: visibility ?? this.visibility,
      reports: reports ?? this.reports,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ═══ تسلسل Firestore ═══
  Map<String, dynamic> toMap() => {
        'id': id,
        'publisher': publisher.toMap(),
        'title': title,
        'description': description,
        'images': images,
        'category': category.code,
        'type': type.code,
        'scope': scope.code,             // 🆕
        'pricing': pricing.toMap(),
        'region': region.code,
        'coverage': coverage,
        'duration': duration.toMap(),
        'status': status.code,
        'moderation': moderation.toMap(),
        'stats': stats.toMap(),
        'visibility': visibility.toMap(),
        'reports': reports.toMap(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory AdvertisementModel.fromMap(Map<String, dynamic> m) {
    final gov = Governorate.fromCode(m['region']) ?? Governorate.amman;
    return AdvertisementModel(
      id: m['id'] ?? '',
      publisher: PublisherInfo.fromMap(
          Map<String, dynamic>.from(m['publisher'] ?? {})),
      title: m['title'] ?? '',
      description: m['description'] ?? '',
      images: List<String>.from(m['images'] ?? []),
      category: AdCategory.fromCode(m['category']),
      type: AdType.fromCode(m['type']),
      scope: AdScopeExt.fromCode(m['scope']),   // 🆕
      pricing: AdPricing.fromMap(
          Map<String, dynamic>.from(m['pricing'] ?? {})),
      region: gov,
      coverage: List<String>.from(m['coverage'] ?? [gov.code]),
      duration: AdDuration.fromMap(
          Map<String, dynamic>.from(m['duration'] ?? {})),
      status: AdStatus.fromCode(m['status']),
      moderation: AdModeration.fromMap(
          m['moderation'] != null
              ? Map<String, dynamic>.from(m['moderation'])
              : null),
      stats: AdStats.fromMap(Map<String, dynamic>.from(m['stats'] ?? {})),
      visibility: AdVisibility.fromMap(
          Map<String, dynamic>.from(m['visibility'] ?? {})),
      reports: AdReports.fromMap(
          Map<String, dynamic>.from(m['reports'] ?? {})),
      createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(m['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}