import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class WaterProduct {
  final String id;
  final String name;
  final String unit;
  final String category;
  final IconData icon;
  final Color color;

  const WaterProduct({
    required this.id,
    required this.name,
    required this.unit,
    required this.category,
    required this.icon,
    required this.color,
  });
}

class WaterCatalog {
  static const List<WaterProduct> products = [
    // ═══ استبدال ═══
    WaterProduct(
        id: 'w_ex_20',
        name: 'قارورة استبدال',
        unit: '20 لتر',
        category: 'استبدال',
        icon: Icons.refresh,
        color: AppColors.waterBlue),
    WaterProduct(
        id: 'w_ex_10',
        name: 'قارورة استبدال',
        unit: '10 لتر',
        category: 'استبدال',
        icon: Icons.refresh,
        color: AppColors.waterBlue),

    // ═══ استخدام مرة واحدة ═══
    WaterProduct(
        id: 'w_one_20',
        name: 'قارورة استخدام مرة',
        unit: '20 لتر',
        category: 'مرة واحدة',
        icon: Icons.water_drop,
        color: AppColors.tankCyan),
    WaterProduct(
        id: 'w_one_12',
        name: 'قارورة استخدام مرة',
        unit: '12 لتر',
        category: 'مرة واحدة',
        icon: Icons.water_drop,
        color: AppColors.tankCyan),
    WaterProduct(
        id: 'w_one_5',
        name: 'قارورة استخدام مرة',
        unit: '5 لتر',
        category: 'مرة واحدة',
        icon: Icons.water_drop,
        color: AppColors.tankCyan),

    // ═══ فارغة أردنية (جديدة) ═══
    WaterProduct(
        id: 'w_empty_jo_20',
        name: 'قارورة فارغة أردنية',
        unit: '20 لتر',
        category: 'فارغة أردنية',
        icon: Icons.inventory_2_outlined,
        color: AppColors.maintenanceOrange),
    WaterProduct(
        id: 'w_empty_jo_12',
        name: 'قارورة فارغة أردنية',
        unit: '12 لتر',
        category: 'فارغة أردنية',
        icon: Icons.inventory_2_outlined,
        color: AppColors.maintenanceOrange),

    // ═══ فارغة سعودية (جديدة) ═══
    WaterProduct(
        id: 'w_empty_sa_20',
        name: 'قارورة فارغة سعودية',
        unit: '20 لتر',
        category: 'فارغة سعودية',
        icon: Icons.inventory_outlined,
        color: AppColors.goldDark),
    WaterProduct(
        id: 'w_empty_sa_25',
        name: 'قارورة فارغة سعودية',
        unit: '25 لتر',
        category: 'فارغة سعودية',
        icon: Icons.inventory_outlined,
        color: AppColors.goldDark),

    // ═══ كاسات مدورة ═══
    WaterProduct(
        id: 'w_cup_r_240_n',
        name: 'كاسات مدورة 240 مل',
        unit: '40 كاسة - غطاء نايلون',
        category: 'كاسات مدورة',
        icon: Icons.local_drink,
        color: AppColors.crystalBlue),
    WaterProduct(
        id: 'w_cup_r_240_f',
        name: 'كاسات مدورة 240 مل',
        unit: '40 كاسة - غطاء قصدير',
        category: 'كاسات مدورة',
        icon: Icons.local_drink,
        color: AppColors.crystalBlue),
    WaterProduct(
        id: 'w_cup_r_200_n',
        name: 'كاسات مدورة 200 مل',
        unit: '40 كاسة - غطاء نايلون',
        category: 'كاسات مدورة',
        icon: Icons.local_drink,
        color: AppColors.crystalBlue),
    WaterProduct(
        id: 'w_cup_r_200_f',
        name: 'كاسات مدورة 200 مل',
        unit: '40 كاسة - غطاء قصدير',
        category: 'كاسات مدورة',
        icon: Icons.local_drink,
        color: AppColors.crystalBlue),

    // ═══ كاسات مربعة ═══
    WaterProduct(
        id: 'w_cup_s_180',
        name: 'كاسات مربعة 180 مل',
        unit: '40 كاسة',
        category: 'كاسات مربعة',
        icon: Icons.local_cafe,
        color: AppColors.factoryPurple),

    // ═══ طرود ═══
    WaterProduct(
        id: 'w_pack_1500',
        name: 'طرد قناني',
        unit: '6 × 1.5 لتر',
        category: 'طرود',
        icon: Icons.inventory_2,
        color: AppColors.refillGreen),
    WaterProduct(
        id: 'w_pack_600',
        name: 'طرد قناني',
        unit: '16 × 600 مل',
        category: 'طرود',
        icon: Icons.inventory_2,
        color: AppColors.refillGreen),
    WaterProduct(
        id: 'w_pack_330_16',
        name: 'طرد قناني',
        unit: '16 × 330 مل',
        category: 'طرود',
        icon: Icons.inventory_2,
        color: AppColors.refillGreen),
    WaterProduct(
        id: 'w_pack_330_20',
        name: 'طرد قناني',
        unit: '20 × 330 مل',
        category: 'طرود',
        icon: Icons.inventory_2,
        color: AppColors.refillGreen),
  ];

  static WaterProduct byId(String id) => products.firstWhere((p) => p.id == id);

  static const List<String> categories = [
    'استبدال',
    'مرة واحدة',
    'فارغة أردنية',
    'فارغة سعودية',
    'كاسات مدورة',
    'كاسات مربعة',
    'طرود'
  ];
}
