import 'package:cloud_firestore/cloud_firestore.dart';

enum TankerRequestStatus {
  pending,
  accepted,
  onTheWay,
  arrived,
  filling,
  completed,
  cancelled,
}

class TankerRequestModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  
  // ═══ تفاصيل الطلب ═══
  final String tankSize;         // '3m', '6m', '8m', '20m'
  final int quantity;            // عدد التنكات
  final String waterType;        // 'fresh', 'normal', 'agricultural'
  final String? notes;
  
  // ═══ الموقع ═══
  final double latitude;
  final double longitude;
  final String address;
  final String locationLabel;
  
  // ═══ الحالة ═══
  final TankerRequestStatus status;
  final DateTime? scheduledDate; // موعد مطلوب
  
  // ═══ السعر ═══
  final double? estimatedPrice;
  final double? finalPrice;
  final String paymentMethod;    // 'cash', 'wallet'
  final bool isPaid;
  
  // ═══ الأوقات ═══
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  
  // ═══ التقييم ═══
  final double? driverRating;
  final String? customerFeedback;
  final String? cancelReason;

  const TankerRequestModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.driverId,
    this.driverName,
    this.driverPhone,
    required this.tankSize,
    required this.quantity,
    this.waterType = 'normal',
    this.notes,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.locationLabel = '',
    this.status = TankerRequestStatus.pending,
    this.scheduledDate,
    this.estimatedPrice,
    this.finalPrice,
    this.paymentMethod = 'cash',
    this.isPaid = false,
    required this.createdAt,
    this.acceptedAt,
    this.arrivedAt,
    this.completedAt,
    this.cancelledAt,
    this.driverRating,
    this.customerFeedback,
    this.cancelReason,
  });

  // ═══ دوال مساعدة ═══
  bool get isPending => status == TankerRequestStatus.pending;
  bool get isActive => status == TankerRequestStatus.accepted ||
                       status == TankerRequestStatus.onTheWay ||
                       status == TankerRequestStatus.arrived ||
                       status == TankerRequestStatus.filling;
  bool get isCompleted => status == TankerRequestStatus.completed;
  bool get isCancelled => status == TankerRequestStatus.cancelled;

  String get statusName {
    switch (status) {
      case TankerRequestStatus.pending: return 'بانتظار القبول';
      case TankerRequestStatus.accepted: return 'تم القبول';
      case TankerRequestStatus.onTheWay: return 'في الطريق';
      case TankerRequestStatus.arrived: return 'وصل';
      case TankerRequestStatus.filling: return 'جاري التعبئة';
      case TankerRequestStatus.completed: return 'مكتمل';
      case TankerRequestStatus.cancelled: return 'ملغي';
    }
  }

  String get tankSizeName {
    switch (tankSize) {
      case '3m': return 'تنك 3 متر';
      case '6m': return 'تنك 6 متر';
      case '8m': return 'تنك 8 متر';
      case '20m': return 'تنك 20 متر';
      default: return 'تنك';
    }
  }

  String get waterTypeName {
    switch (waterType) {
      case 'fresh': return 'مياه عذبة';
      case 'agricultural': return 'مياه زراعية';
      default: return 'مياه عادية';
    }
  }

  // ═══ Firestore ═══
  factory TankerRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return TankerRequestModel(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      driverId: map['driverId'],
      driverName: map['driverName'],
      driverPhone: map['driverPhone'],
      tankSize: map['tankSize'] ?? '3m',
      quantity: map['quantity'] ?? 1,
      waterType: map['waterType'] ?? 'normal',
      notes: map['notes'],
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      locationLabel: map['locationLabel'] ?? '',
      status: _parseStatus(map['status'] ?? 'pending'),
      scheduledDate: (map['scheduledDate'] as Timestamp?)?.toDate(),
      estimatedPrice: (map['estimatedPrice'] as num?)?.toDouble(),
      finalPrice: (map['finalPrice'] as num?)?.toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'cash',
      isPaid: map['isPaid'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (map['acceptedAt'] as Timestamp?)?.toDate(),
      arrivedAt: (map['arrivedAt'] as Timestamp?)?.toDate(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (map['cancelledAt'] as Timestamp?)?.toDate(),
      driverRating: (map['driverRating'] as num?)?.toDouble(),
      customerFeedback: map['customerFeedback'],
      cancelReason: map['cancelReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'tankSize': tankSize,
      'quantity': quantity,
      'waterType': waterType,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'locationLabel': locationLabel,
      'status': status.name,
      'scheduledDate': scheduledDate,
      'estimatedPrice': estimatedPrice,
      'finalPrice': finalPrice,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'createdAt': createdAt,
      'acceptedAt': acceptedAt,
      'arrivedAt': arrivedAt,
      'completedAt': completedAt,
      'cancelledAt': cancelledAt,
      'driverRating': driverRating,
      'customerFeedback': customerFeedback,
      'cancelReason': cancelReason,
    };
  }

  TankerRequestModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? driverId,
    String? driverName,
    String? driverPhone,
    String? tankSize,
    int? quantity,
    String? waterType,
    String? notes,
    double? latitude,
    double? longitude,
    String? address,
    String? locationLabel,
    TankerRequestStatus? status,
    DateTime? scheduledDate,
    double? estimatedPrice,
    double? finalPrice,
    String? paymentMethod,
    bool? isPaid,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? arrivedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    double? driverRating,
    String? customerFeedback,
    String? cancelReason,
  }) {
    return TankerRequestModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      tankSize: tankSize ?? this.tankSize,
      quantity: quantity ?? this.quantity,
      waterType: waterType ?? this.waterType,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      locationLabel: locationLabel ?? this.locationLabel,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      driverRating: driverRating ?? this.driverRating,
      customerFeedback: customerFeedback ?? this.customerFeedback,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }

  static TankerRequestStatus _parseStatus(String status) {
    switch (status) {
      case 'accepted': return TankerRequestStatus.accepted;
      case 'onTheWay': return TankerRequestStatus.onTheWay;
      case 'arrived': return TankerRequestStatus.arrived;
      case 'filling': return TankerRequestStatus.filling;
      case 'completed': return TankerRequestStatus.completed;
      case 'cancelled': return TankerRequestStatus.cancelled;
      default: return TankerRequestStatus.pending;
    }
  }
}