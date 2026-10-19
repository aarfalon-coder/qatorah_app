import 'package:cloud_firestore/cloud_firestore.dart';

class DriverModel {
  final String id;
  final String userId;          // ربط مع UserModel
  final String fullName;
  final String phone;
  final String vehicleType;     // 'tanker', 'pickup', 'truck', 'motorcycle'
  final String vehiclePlate;    // رقم اللوحة
  final String licenseNumber;   // رقم الرخصة
  final DateTime? licenseExpiry;
  
  // ═══ الموقع ═══
  final double currentLatitude;
  final double currentLongitude;
  final DateTime? lastLocationUpdate;
  
  // ═══ الحالة ═══
  final bool isAvailable;       // متاح للطلبات
  final bool isOnline;          // متصل الآن
  final String status;          // 'active', 'inactive', 'suspended', 'pending_approval'
  
  // ═══ الأداء ═══
  final double rating;          // 0.0 - 5.0
  final int totalDeliveries;    // عدد التوصيلات
  final double totalEarnings;   // إجمالي الأرباح
  final double walletBalance;   // رصيد المحفظة
  
  // ═══ التوثيق ═══
  final String? idCardUrl;      // صورة الهوية
  final String? licenseUrl;     // صورة الرخصة
  final String? vehicleImageUrl;
  final bool isVerified;        // موثق من الإدارة
  
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  const DriverModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.licenseNumber,
    this.licenseExpiry,
    this.currentLatitude = 0.0,
    this.currentLongitude = 0.0,
    this.lastLocationUpdate,
    this.isAvailable = false,
    this.isOnline = false,
    this.status = 'pending_approval',
    this.rating = 0.0,
    this.totalDeliveries = 0,
    this.totalEarnings = 0.0,
    this.walletBalance = 0.0,
    this.idCardUrl,
    this.licenseUrl,
    this.vehicleImageUrl,
    this.isVerified = false,
    required this.createdAt,
    this.lastActiveAt,
  });

  // ═══ دوال مساعدة ═══
  bool get canReceiveOrders => isOnline && isAvailable && isVerified && status == 'active';
  
  String get statusName {
    switch (status) {
      case 'active': return 'نشط';
      case 'inactive': return 'غير نشط';
      case 'suspended': return 'موقوف';
      case 'pending_approval': return 'بانتظار الموافقة';
      default: return 'غير معروف';
    }
  }

  String get vehicleTypeName {
    switch (vehicleType) {
      case 'tanker': return 'تنك مياه';
      case 'pickup': return 'بيك أب';
      case 'truck': return 'شاحنة';
      case 'motorcycle': return 'دراجة';
      default: return 'مركبة';
    }
  }

  // ═══ Firestore ═══
  factory DriverModel.fromMap(Map<String, dynamic> map, String id) {
    return DriverModel(
      id: id,
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      licenseExpiry: (map['licenseExpiry'] as Timestamp?)?.toDate(),
      currentLatitude: (map['currentLatitude'] ?? 0.0).toDouble(),
      currentLongitude: (map['currentLongitude'] ?? 0.0).toDouble(),
      lastLocationUpdate: (map['lastLocationUpdate'] as Timestamp?)?.toDate(),
      isAvailable: map['isAvailable'] ?? false,
      isOnline: map['isOnline'] ?? false,
      status: map['status'] ?? 'pending_approval',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalDeliveries: map['totalDeliveries'] ?? 0,
      totalEarnings: (map['totalEarnings'] ?? 0.0).toDouble(),
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      idCardUrl: map['idCardUrl'],
      licenseUrl: map['licenseUrl'],
      vehicleImageUrl: map['vehicleImageUrl'],
      isVerified: map['isVerified'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (map['lastActiveAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'phone': phone,
      'vehicleType': vehicleType,
      'vehiclePlate': vehiclePlate,
      'licenseNumber': licenseNumber,
      'licenseExpiry': licenseExpiry,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'lastLocationUpdate': lastLocationUpdate,
      'isAvailable': isAvailable,
      'isOnline': isOnline,
      'status': status,
      'rating': rating,
      'totalDeliveries': totalDeliveries,
      'totalEarnings': totalEarnings,
      'walletBalance': walletBalance,
      'idCardUrl': idCardUrl,
      'licenseUrl': licenseUrl,
      'vehicleImageUrl': vehicleImageUrl,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'lastActiveAt': lastActiveAt,
    };
  }

  DriverModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? vehicleType,
    String? vehiclePlate,
    String? licenseNumber,
    DateTime? licenseExpiry,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? lastLocationUpdate,
    bool? isAvailable,
    bool? isOnline,
    String? status,
    double? rating,
    int? totalDeliveries,
    double? totalEarnings,
    double? walletBalance,
    String? idCardUrl,
    String? licenseUrl,
    String? vehicleImageUrl,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      isAvailable: isAvailable ?? this.isAvailable,
      isOnline: isOnline ?? this.isOnline,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      walletBalance: walletBalance ?? this.walletBalance,
      idCardUrl: idCardUrl ?? this.idCardUrl,
      licenseUrl: licenseUrl ?? this.licenseUrl,
      vehicleImageUrl: vehicleImageUrl ?? this.vehicleImageUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}