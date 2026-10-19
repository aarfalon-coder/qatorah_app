import 'package:flutter/foundation.dart';
import 'package:qatorah_app/managers/auth_manager.dart';

class UserModel {
  final String id;
  final String firstName;
  final String phone;
  final UserRole role;
  final bool isProvider;
  final String providerServiceType;
  final int adminLevel;
  final bool isSuperAdmin;
  final String? email;
  final String? profileImageUrl;
  final double walletBalance;
  final int loyaltyPoints;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final bool isBanned;
  final String? banReason;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.phone,
    required this.role,
    this.isProvider = false,
    this.providerServiceType = '',
    this.adminLevel = 0,
    this.isSuperAdmin = false,
    this.email,
    this.profileImageUrl,
    this.walletBalance = 0.0,
    this.loyaltyPoints = 0,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.isBanned = false,
    this.banReason,
  });

  // ═══ دوال مساعدة ═══
  bool get isCustomer => role == UserRole.customer && !isProvider;
  bool get isDriver => role == UserRole.driver;
  bool get isStationOwner => role == UserRole.stationOwner;
  bool get isFactory => role == UserRole.factory;
  bool get isTanker => role == UserRole.tanker;
  bool get isTechnician => role == UserRole.stationTechnician || role == UserRole.plumber;

  String get roleName {
    switch (role) {
      case UserRole.customer: return 'مستهلك';
      case UserRole.stationOwner: return 'صاحب محطة';
      case UserRole.factory: return 'مصنع';
      case UserRole.driver: return 'سائق';
      case UserRole.tanker: return 'سائق تنك';
      case UserRole.stationTechnician: return 'فني';
      case UserRole.plumber: return 'سباك';
    }
  }

  // ═══ Firestore ═══
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      firstName: map['firstName'] ?? '',
      phone: map['phone'] ?? '',
      role: _parseRole(map['role'] ?? 'customer'),
      isProvider: map['isProvider'] ?? false,
      providerServiceType: map['providerServiceType'] ?? '',
      adminLevel: map['adminLevel'] ?? 0,
      isSuperAdmin: map['isSuperAdmin'] ?? false,
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      lastLoginAt: (map['lastLoginAt'] as dynamic)?.toDate(),
      isActive: map['isActive'] ?? true,
      isBanned: map['isBanned'] ?? false,
      banReason: map['banReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'phone': phone,
      'role': role.name,
      'isProvider': isProvider,
      'providerServiceType': providerServiceType,
      'adminLevel': adminLevel,
      'isSuperAdmin': isSuperAdmin,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'walletBalance': walletBalance,
      'loyaltyPoints': loyaltyPoints,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'isActive': isActive,
      'isBanned': isBanned,
      'banReason': banReason,
    };
  }

  // ═══ من AuthManager ═══
  factory UserModel.fromAuthManager({required String id}) {
    return UserModel(
      id: id,
      firstName: AuthManager.firstName,
      phone: AuthManager.phone,
      role: AuthManager.role,
      isProvider: AuthManager.isProvider,
      providerServiceType: AuthManager.providerServiceType,
      adminLevel: AuthManager.adminLevel,
      isSuperAdmin: AuthManager.isSuperAdmin,
      createdAt: DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? phone,
    UserRole? role,
    bool? isProvider,
    String? providerServiceType,
    int? adminLevel,
    bool? isSuperAdmin,
    String? email,
    String? profileImageUrl,
    double? walletBalance,
    int? loyaltyPoints,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    bool? isBanned,
    String? banReason,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isProvider: isProvider ?? this.isProvider,
      providerServiceType: providerServiceType ?? this.providerServiceType,
      adminLevel: adminLevel ?? this.adminLevel,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      walletBalance: walletBalance ?? this.walletBalance,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      isBanned: isBanned ?? this.isBanned,
      banReason: banReason ?? this.banReason,
    );
  }

  static UserRole _parseRole(String roleStr) {
    switch (roleStr) {
      case 'stationOwner': return UserRole.stationOwner;
      case 'factory': return UserRole.factory;
      case 'driver': return UserRole.driver;
      case 'tanker': return UserRole.tanker;
      case 'stationTechnician': return UserRole.stationTechnician;
      case 'plumber': return UserRole.plumber;
      default: return UserRole.customer;
    }
  }
}