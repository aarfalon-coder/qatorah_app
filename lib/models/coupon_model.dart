import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════
/// Coupon Model — نظام الكوبونات الإلكترونية
/// ═══════════════════════════════════════════════════════════

enum CouponType {
  water('water', 'مياه', '💧', Icons.water_drop),
  gas('gas', 'غاز', '🔥', Icons.local_fire_department),
  maintenance('maintenance', 'صيانة', '🔧', Icons.build_circle),
  mixed('mixed', 'مختلط', '📦', Icons.category);

  const CouponType(this.code, this.label, this.emoji, this.icon);
  final String code;
  final String label;
  final String emoji;
  final IconData icon;

  static CouponType fromCode(String? c) =>
      CouponType.values.firstWhere((e) => e.code == c, orElse: () => CouponType.water);
}

enum CouponStatus {
  active('active', 'نشط'),
  used('used', 'مستخدم'),
  expired('expired', 'منتهي'),
  cancelled('cancelled', 'ملغى');

  const CouponStatus(this.code, this.label);
  final String code;
  final String label;

  static CouponStatus fromCode(String? c) =>
      CouponStatus.values.firstWhere((e) => e.code == c, orElse: () => CouponStatus.active);
}

/// ═══ دفتر الكوبونات (يشتريه العميل) ═══
class CouponBookModel {
  final String id;
  final String customerId;
  final String customerName;
  final CouponType type;
  final int totalCoupons;
  final int remainingCoupons;
  final double price;
  final DateTime purchasedAt;
  final DateTime expiresAt;
  final bool isActive;

  const CouponBookModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.type,
    required this.totalCoupons,
    required this.remainingCoupons,
    required this.price,
    required this.purchasedAt,
    required this.expiresAt,
    this.isActive = true,
  });

  int get usedCoupons => totalCoupons - remainingCoupons;
  double get usedPercentage =>
      totalCoupons == 0 ? 0 : (usedCoupons / totalCoupons) * 100;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get canUse => isActive && !isExpired && remainingCoupons > 0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'customerId': customerId,
        'customerName': customerName,
        'type': type.code,
        'totalCoupons': totalCoupons,
        'remainingCoupons': remainingCoupons,
        'price': price,
        'purchasedAt': purchasedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'isActive': isActive,
      };

  factory CouponBookModel.fromMap(Map<String, dynamic> m) => CouponBookModel(
        id: m['id'] ?? '',
        customerId: m['customerId'] ?? '',
        customerName: m['customerName'] ?? '',
        type: CouponType.fromCode(m['type']),
        totalCoupons: m['totalCoupons'] ?? 0,
        remainingCoupons: m['remainingCoupons'] ?? 0,
        price: (m['price'] ?? 0).toDouble(),
        purchasedAt: DateTime.tryParse(m['purchasedAt'] ?? '') ?? DateTime.now(),
        expiresAt: DateTime.tryParse(m['expiresAt'] ?? '') ?? DateTime.now(),
        isActive: m['isActive'] ?? true,
      );

  CouponBookModel copyWith({
    int? remainingCoupons,
    bool? isActive,
  }) =>
      CouponBookModel(
        id: id,
        customerId: customerId,
        customerName: customerName,
        type: type,
        totalCoupons: totalCoupons,
        remainingCoupons: remainingCoupons ?? this.remainingCoupons,
        price: price,
        purchasedAt: purchasedAt,
        expiresAt: expiresAt,
        isActive: isActive ?? this.isActive,
      );
}

/// ═══ كوبون واحد (داخل الدفتر) ═══
class CouponModel {
  final String id;
  final String bookId;
  final String customerId;
  final CouponType type;
  final double value;
  final String qrCode;
  final CouponStatus status;
  final DateTime? usedAt;
  final String? usedAtStation;
  final DateTime createdAt;

  const CouponModel({
    required this.id,
    required this.bookId,
    required this.customerId,
    required this.type,
    required this.value,
    required this.qrCode,
    this.status = CouponStatus.active,
    this.usedAt,
    this.usedAtStation,
    required this.createdAt,
  });

  bool get isActive => status == CouponStatus.active;
  bool get isUsed => status == CouponStatus.used;

  Map<String, dynamic> toMap() => {
        'id': id,
        'bookId': bookId,
        'customerId': customerId,
        'type': type.code,
        'value': value,
        'qrCode': qrCode,
        'status': status.code,
        'usedAt': usedAt?.toIso8601String(),
        'usedAtStation': usedAtStation,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CouponModel.fromMap(Map<String, dynamic> m) => CouponModel(
        id: m['id'] ?? '',
        bookId: m['bookId'] ?? '',
        customerId: m['customerId'] ?? '',
        type: CouponType.fromCode(m['type']),
        value: (m['value'] ?? 0).toDouble(),
        qrCode: m['qrCode'] ?? '',
        status: CouponStatus.fromCode(m['status']),
        usedAt: m['usedAt'] != null ? DateTime.tryParse(m['usedAt']) : null,
        usedAtStation: m['usedAtStation'],
        createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
      );

  CouponModel copyWith({
    CouponStatus? status,
    DateTime? usedAt,
    String? usedAtStation,
  }) =>
      CouponModel(
        id: id,
        bookId: bookId,
        customerId: customerId,
        type: type,
        value: value,
        qrCode: qrCode,
        status: status ?? this.status,
        usedAt: usedAt ?? this.usedAt,
        usedAtStation: usedAtStation ?? this.usedAtStation,
        createdAt: createdAt,
      );
}

/// ═══ أنواع الدفاتر المتاحة (الأسعار) ═══
class CouponBookType {
  final String id;
  final CouponType type;
  final int totalCoupons;
  final double price;
  final int validDays;
  final String label;
  final String description;

  const CouponBookType({
    required this.id,
    required this.type,
    required this.totalCoupons,
    required this.price,
    required this.validDays,
    required this.label,
    required this.description,
  });
}

const List<CouponBookType> kCouponBookTypes = [
  CouponBookType(
    id: 'water_10',
    type: CouponType.water,
    totalCoupons: 10,
    price: 5.0,
    validDays: 90,
    label: 'دفتر مياه',
    description: '10 قوارير × 5 لتر',
  ),
  CouponBookType(
    id: 'water_20',
    type: CouponType.water,
    totalCoupons: 20,
    price: 9.0,
    validDays: 120,
    label: 'دفتر مياه كبير',
    description: '20 قارورة × 5 لتر',
  ),
  CouponBookType(
    id: 'mixed_15',
    type: CouponType.mixed,
    totalCoupons: 15,
    price: 15.0,
    validDays: 120,
    label: 'دفتر مختلط',
    description: '5 ماء + 5 غاز + 5 صيانة',
  ),
  CouponBookType(
    id: 'maintenance_5',
    type: CouponType.maintenance,
    totalCoupons: 5,
    price: 20.0,
    validDays: 180,
    label: 'دفتر صيانة',
    description: '5 كوبونات صيانة',
  ),
];