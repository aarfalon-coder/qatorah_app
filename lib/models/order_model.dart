import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String serviceType;
  final Map<String, dynamic> details;
  
  final double latitude;
  final double longitude;
  final String address;
  final String locationLabel; 
  final String notes;

  final String status;
  final DateTime timestamp;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.serviceType,
    required this.details,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.locationLabel,
    required this.notes,
    this.status = 'pending',
    required this.timestamp,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      serviceType: map['serviceType'] ?? '',
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      address: map['address'] ?? 'عنوان غير محدد',
      locationLabel: map['locationLabel'] ?? 'بدون تسمية',
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'pending',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'serviceType': serviceType,
      'details': details,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'locationLabel': locationLabel,
      'notes': notes,
      'status': status,
      'timestamp': timestamp,
    };
  }

  // 🆕 copyWith
  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? serviceType,
    Map<String, dynamic>? details,
    double? latitude,
    double? longitude,
    String? address,
    String? locationLabel,
    String? notes,
    String? status,
    DateTime? timestamp,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceType: serviceType ?? this.serviceType,
      details: details ?? this.details,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      locationLabel: locationLabel ?? this.locationLabel,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}