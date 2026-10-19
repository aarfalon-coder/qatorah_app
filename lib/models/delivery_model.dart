import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryModel {
  final String id;
  final String orderId;         // ربط مع OrderModel
  final String driverId;        // ربط مع DriverModel
  final String providerId;      // ربط مع UserModel (المزود)
  final String customerId;      // ربط مع UserModel (العميل)
  
  // ═══ الحالة ═══
  final String status;          // 'assigned', 'picked_up', 'in_transit', 'delivered', 'failed', 'cancelled'
  
  // ═══ المواقع ═══
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final String dropoffAddress;
  
  // ═══ التتبع ═══
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime? lastLocationUpdate;
  
  // ═══ الأوقات ═══
  final DateTime assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? estimatedDelivery;
  final DateTime createdAt;
  
  // ═══ التكلفة ═══
  final double deliveryFee;     // 1.0 دينار ثابت
  final double? tip;
  final String paymentMethod;   // 'cash', 'wallet', 'card'
  final bool isPaid;
  
  // ═══ ملاحظات ═══
  final String? driverNotes;
  final String? customerNotes;
  final String? cancelReason;
  
  // ═══ التقييم ═══
  final double? driverRating;
  final String? customerFeedback;

  const DeliveryModel({
    required this.id,
    required this.orderId,
    required this.driverId,
    required this.providerId,
    required this.customerId,
    this.status = 'assigned',
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.dropoffAddress,
    this.currentLatitude,
    this.currentLongitude,
    this.lastLocationUpdate,
    required this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.estimatedDelivery,
    required this.createdAt,
    this.deliveryFee = 1.0,
    this.tip,
    this.paymentMethod = 'cash',
    this.isPaid = false,
    this.driverNotes,
    this.customerNotes,
    this.cancelReason,
    this.driverRating,
    this.customerFeedback,
  });

  // ═══ دوال مساعدة ═══
  bool get isCompleted => status == 'delivered';
  bool get isActive => status == 'assigned' || status == 'picked_up' || status == 'in_transit';
  bool get isCancelled => status == 'cancelled' || status == 'failed';

  String get statusName {
    switch (status) {
      case 'assigned': return 'تم التعيين';
      case 'picked_up': return 'تم الاستلام';
      case 'in_transit': return 'في الطريق';
      case 'delivered': return 'تم التسليم';
      case 'failed': return 'فشل';
      case 'cancelled': return 'ملغي';
      default: return 'غير معروف';
    }
  }

  String get paymentMethodName {
    switch (paymentMethod) {
      case 'cash': return 'نقداً';
      case 'wallet': return 'المحفظة';
      case 'card': return 'بطاقة';
      default: return 'غير محدد';
    }
  }

  // ═══ Firestore ═══
  factory DeliveryModel.fromMap(Map<String, dynamic> map, String id) {
    return DeliveryModel(
      id: id,
      orderId: map['orderId'] ?? '',
      driverId: map['driverId'] ?? '',
      providerId: map['providerId'] ?? '',
      customerId: map['customerId'] ?? '',
      status: map['status'] ?? 'assigned',
      pickupLatitude: (map['pickupLatitude'] ?? 0.0).toDouble(),
      pickupLongitude: (map['pickupLongitude'] ?? 0.0).toDouble(),
      pickupAddress: map['pickupAddress'] ?? '',
      dropoffLatitude: (map['dropoffLatitude'] ?? 0.0).toDouble(),
      dropoffLongitude: (map['dropoffLongitude'] ?? 0.0).toDouble(),
      dropoffAddress: map['dropoffAddress'] ?? '',
      currentLatitude: (map['currentLatitude'] as num?)?.toDouble(),
      currentLongitude: (map['currentLongitude'] as num?)?.toDouble(),
      lastLocationUpdate: (map['lastLocationUpdate'] as Timestamp?)?.toDate(),
      assignedAt: (map['assignedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pickedUpAt: (map['pickedUpAt'] as Timestamp?)?.toDate(),
      deliveredAt: (map['deliveredAt'] as Timestamp?)?.toDate(),
      estimatedDelivery: (map['estimatedDelivery'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryFee: (map['deliveryFee'] ?? 1.0).toDouble(),
      tip: (map['tip'] as num?)?.toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'cash',
      isPaid: map['isPaid'] ?? false,
      driverNotes: map['driverNotes'],
      customerNotes: map['customerNotes'],
      cancelReason: map['cancelReason'],
      driverRating: (map['driverRating'] as num?)?.toDouble(),
      customerFeedback: map['customerFeedback'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'driverId': driverId,
      'providerId': providerId,
      'customerId': customerId,
      'status': status,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'pickupAddress': pickupAddress,
      'dropoffLatitude': dropoffLatitude,
      'dropoffLongitude': dropoffLongitude,
      'dropoffAddress': dropoffAddress,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'lastLocationUpdate': lastLocationUpdate,
      'assignedAt': assignedAt,
      'pickedUpAt': pickedUpAt,
      'deliveredAt': deliveredAt,
      'estimatedDelivery': estimatedDelivery,
      'createdAt': createdAt,
      'deliveryFee': deliveryFee,
      'tip': tip,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'driverNotes': driverNotes,
      'customerNotes': customerNotes,
      'cancelReason': cancelReason,
      'driverRating': driverRating,
      'customerFeedback': customerFeedback,
    };
  }

  DeliveryModel copyWith({
    String? id,
    String? orderId,
    String? driverId,
    String? providerId,
    String? customerId,
    String? status,
    double? pickupLatitude,
    double? pickupLongitude,
    String? pickupAddress,
    double? dropoffLatitude,
    double? dropoffLongitude,
    String? dropoffAddress,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? lastLocationUpdate,
    DateTime? assignedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    DateTime? estimatedDelivery,
    DateTime? createdAt,
    double? deliveryFee,
    double? tip,
    String? paymentMethod,
    bool? isPaid,
    String? driverNotes,
    String? customerNotes,
    String? cancelReason,
    double? driverRating,
    String? customerFeedback,
  }) {
    return DeliveryModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      driverId: driverId ?? this.driverId,
      providerId: providerId ?? this.providerId,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
      dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      assignedAt: assignedAt ?? this.assignedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      createdAt: createdAt ?? this.createdAt,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tip: tip ?? this.tip,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      driverNotes: driverNotes ?? this.driverNotes,
      customerNotes: customerNotes ?? this.customerNotes,
      cancelReason: cancelReason ?? this.cancelReason,
      driverRating: driverRating ?? this.driverRating,
      customerFeedback: customerFeedback ?? this.customerFeedback,
    );
  }
}