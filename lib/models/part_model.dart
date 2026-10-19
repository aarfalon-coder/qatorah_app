import 'package:flutter/material.dart';

class PartModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final IconData icon;
  final Color color;

  const PartModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class PartsCatalog {
  static const List<PartModel> all = [
    PartModel(
        id: 'p1',
        name: 'فلتر مياه',
        price: 12.0,
        description: 'فلتر كربون نشط',
        icon: Icons.filter_alt,
        color: Color(0xFF0288D1)),
    PartModel(
        id: 'p2',
        name: 'خرطوم توصيل',
        price: 5.5,
        description: 'خرطوم مرن 2 متر',
        icon: Icons.water,
        color: Color(0xFF4CAF50)),
    PartModel(
        id: 'p3',
        name: 'مضخة مياه',
        price: 45.0,
        description: 'مضخة كهربائية',
        icon: Icons.settings,
        color: Color(0xFFE65100)),
    PartModel(
        id: 'p4',
        name: 'صنبور نحاس',
        price: 8.0,
        description: 'صنبور عالي الجودة',
        icon: Icons.opacity,
        color: Color(0xFF795548)),
    PartModel(
        id: 'p5',
        name: 'خزان 100 لتر',
        price: 35.0,
        description: 'خزان بلاستيك معزول',
        icon: Icons.storage,
        color: Color(0xFF5E35B1)),
    PartModel(
        id: 'p6',
        name: 'محبس نحاس',
        price: 4.5,
        description: 'محبس تحكم بالتدفق',
        icon: Icons.toggle_on,
        color: Color(0xFF00897B)),
    PartModel(
        id: 'p7',
        name: 'طقم وصلات',
        price: 6.0,
        description: '10 وصلات متنوعة',
        icon: Icons.link,
        color: Color(0xFF6D4C41)),
    PartModel(
        id: 'p8',
        name: 'منظم ضغط',
        price: 18.0,
        description: 'منظم ضغط المياه',
        icon: Icons.speed,
        color: Color(0xFFC62828)),
  ];
}
