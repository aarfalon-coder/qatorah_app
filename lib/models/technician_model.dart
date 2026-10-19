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

  const TechnicianModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.isAvailable,
    required this.phone,
  });
}

class TechnicianCatalog {
  static final List<TechnicianModel> all = [
    const TechnicianModel(
        id: 't1',
        name: 'أبو أحمد السباك',
        specialty: TechnicianSpecialty.plumber,
        rating: 4.8,
        reviewCount: 124,
        distanceKm: 1.2,
        isAvailable: true,
        phone: '0791111111'),
    const TechnicianModel(
        id: 't2',
        name: 'مؤسسة النور للسباكة',
        specialty: TechnicianSpecialty.plumber,
        rating: 4.5,
        reviewCount: 89,
        distanceKm: 2.5,
        isAvailable: true,
        phone: '0792222222'),
    const TechnicianModel(
        id: 't3',
        name: 'أبو خالد - فني محطات',
        specialty: TechnicianSpecialty.stationTech,
        rating: 4.9,
        reviewCount: 56,
        distanceKm: 3.0,
        isAvailable: true,
        phone: '0793333333'),
    const TechnicianModel(
        id: 't4',
        name: 'شركة المياه المتقدمة',
        specialty: TechnicianSpecialty.stationTech,
        rating: 4.7,
        reviewCount: 42,
        distanceKm: 4.5,
        isAvailable: false,
        phone: '0794444444'),
    const TechnicianModel(
        id: 't5',
        name: 'كهربائي أبو محمد',
        specialty: TechnicianSpecialty.electrician,
        rating: 4.6,
        reviewCount: 78,
        distanceKm: 1.8,
        isAvailable: true,
        phone: '0795555555'),
    const TechnicianModel(
        id: 't6',
        name: 'م. سامي الصيادي',
        specialty: TechnicianSpecialty.maintenanceEng,
        rating: 4.9,
        reviewCount: 34,
        distanceKm: 5.0,
        isAvailable: true,
        phone: '0796666666'),
    const TechnicianModel(
        id: 't7',
        name: 'م. ليث الأتمتة',
        specialty: TechnicianSpecialty.plcProgrammer,
        rating: 5.0,
        reviewCount: 18,
        distanceKm: 7.2,
        isAvailable: true,
        phone: '0797777777'),
    const TechnicianModel(
        id: 't8',
        name: 'مختبر الجودة المركزي',
        specialty: TechnicianSpecialty.waterLabTech,
        rating: 4.8,
        reviewCount: 27,
        distanceKm: 6.0,
        isAvailable: true,
        phone: '0798888888'),
    const TechnicianModel(
        id: 't9',
        name: 'مستودع قطع الغيار',
        specialty: TechnicianSpecialty.spareParts,
        rating: 4.4,
        reviewCount: 63,
        distanceKm: 3.5,
        isAvailable: true,
        phone: '0799999999'),
  ];

  static List<TechnicianModel> bySpecialty(TechnicianSpecialty specialty) {
    final list = all.where((t) => t.specialty == specialty).toList();
    list.sort((a, b) => b.rating.compareTo(a.rating));
    return list;
  }
}
