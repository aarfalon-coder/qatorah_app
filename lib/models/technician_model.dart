import 'package:flutter/material.dart';

enum TechnicianSpecialty {
  plumber,
  stationTech,
  electrician,
  maintenanceEng,
  plcProgrammer,
  waterLabTech,
  spareParts,
}

extension SpecialtyExtension on TechnicianSpecialty {
  String get arabicName {
    switch (this) {
      case TechnicianSpecialty.plumber:
        return 'سباك';
      case TechnicianSpecialty.stationTech:
        return 'فني محطات';
      case TechnicianSpecialty.electrician:
        return 'كهربائي';
      case TechnicianSpecialty.maintenanceEng:
        return 'مهندس صيانة';
      case TechnicianSpecialty.plcProgrammer:
        return 'مبرمج PLC';
      case TechnicianSpecialty.waterLabTech:
        return 'فني مختبر مياه';
      case TechnicianSpecialty.spareParts:
        return 'قطع صيانة';
    }
  }

  IconData get icon {
    switch (this) {
      case TechnicianSpecialty.plumber:
        return Icons.plumbing;
      case TechnicianSpecialty.stationTech:
        return Icons.water_damage;
      case TechnicianSpecialty.electrician:
        return Icons.electrical_services;
      case TechnicianSpecialty.maintenanceEng:
        return Icons.engineering;
      case TechnicianSpecialty.plcProgrammer:
        return Icons.memory;
      case TechnicianSpecialty.waterLabTech:
        return Icons.science;
      case TechnicianSpecialty.spareParts:
        return Icons.build;
    }
  }

  Color get color {
    switch (this) {
      case TechnicianSpecialty.plumber:
        return const Color(0xFFE53935);
      case TechnicianSpecialty.stationTech:
        return const Color(0xFF0288D1);
      case TechnicianSpecialty.electrician:
        return const Color(0xFFFFC107);
      case TechnicianSpecialty.maintenanceEng:
        return const Color(0xFF5E35B1);
      case TechnicianSpecialty.plcProgrammer:
        return const Color(0xFF00897B);
      case TechnicianSpecialty.waterLabTech:
        return const Color(0xFF43A047);
      case TechnicianSpecialty.spareParts:
        return const Color(0xFF6D4C41);
    }
  }
}

class TechnicianModel {
  final String id;
  final String name;
  final TechnicianSpecialty specialty;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final bool isAvailable;
  final String phone;
  final bool isSuspended;
  final String nextAvailableTime;
  final int activeRequestsCount;

  const TechnicianModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.isAvailable,
    required this.phone,
    this.isSuspended = false,
    this.nextAvailableTime = 'متاح الآن',
    this.activeRequestsCount = 0,
  });

  factory TechnicianModel.fromMap(Map<String, dynamic> map, String id) {
    return TechnicianModel(
      id: id,
      name: map['name'] ?? 'فني بدون اسم',
      specialty: TechnicianSpecialty.values.firstWhere(
        (e) => e.name == map['specialty'],
        orElse: () => TechnicianSpecialty.plumber,
      ),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['review_count'] ?? 0,
      distanceKm: (map['distance_km'] ?? 0.0).toDouble(),
      isAvailable: map['is_available'] ?? true,
      phone: map['phone'] ?? '',
      isSuspended: map['is_suspended'] ?? false,
      nextAvailableTime: map['next_available_time'] ?? 'متاح الآن',
      activeRequestsCount: map['active_requests_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialty': specialty.name,
      'rating': rating,
      'review_count': reviewCount,
      'distance_km': distanceKm,
      'is_available': isAvailable,
      'phone': phone,
      'is_suspended': isSuspended,
      'next_available_time': nextAvailableTime,
      'active_requests_count': activeRequestsCount,
    };
  }
}
