import 'package:flutter/material.dart';

enum ProductType {
  bottle,
  carton,
  pack330,
  half500,
  ml600,
  tank3,
  tank6,
  tank8,
  tank20,
  gas12,
  gas25,
  gasRegulator,
}

class ProductModel {
  final String id;
  final String name;
  final ProductType type;
  final double price;
  final String unit;
  final IconData icon;
  final Color color;
  final String category;

  const ProductModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.unit,
    required this.icon,
    required this.color,
    required this.category,
  });
}

class ProductCatalog {
  static const List<ProductModel> waterProducts = [
    ProductModel(
      id: 'w1',
      name: 'قارورة',
      type: ProductType.bottle,
      price: 1.0,
      unit: 'قارورة 19 لتر',
      icon: Icons.water_drop,
      color: Color(0xFF0288D1),
      category: 'water',
    ),
    ProductModel(
      id: 'w2',
      name: 'كرتونة',
      type: ProductType.carton,
      price: 4.5,
      unit: '12 عبوة × 1.5 لتر',
      icon: Icons.inventory_2,
      color: Color(0xFF4CAF50),
      category: 'water',
    ),
    ProductModel(
      id: 'w3',
      name: 'طرد 330 مل',
      type: ProductType.pack330,
      price: 3.5,
      unit: '24 عبوة',
      icon: Icons.category,
      color: Color(0xFF9C27B0),
      category: 'water',
    ),
    ProductModel(
      id: 'w4',
      name: 'نص 500 مل',
      type: ProductType.half500,
      price: 4.0,
      unit: '24 عبوة',
      icon: Icons.local_bar,
      color: Color(0xFFFF9800),
      category: 'water',
    ),
    ProductModel(
      id: 'w5',
      name: '600 مل',
      type: ProductType.ml600,
      price: 4.5,
      unit: '24 عبوة',
      icon: Icons.sports_bar,
      color: Color(0xFF00BCD4),
      category: 'water',
    ),
  ];

  static const List<ProductModel> tankProducts = [
    ProductModel(
      id: 't3',
      name: 'تنك 3 متر',
      type: ProductType.tank3,
      price: 3.0,
      unit: '3 م³',
      icon: Icons.opacity,
      color: Color(0xFF0288D1),
      category: 'tank',
    ),
    ProductModel(
      id: 't6',
      name: 'تنك 6 متر',
      type: ProductType.tank6,
      price: 5.0,
      unit: '6 م³',
      icon: Icons.opacity,
      color: Color(0xFF4CAF50),
      category: 'tank',
    ),
    ProductModel(
      id: 't8',
      name: 'تنك 8 متر',
      type: ProductType.tank8,
      price: 6.5,
      unit: '8 م³',
      icon: Icons.opacity,
      color: Color(0xFFFF9800),
      category: 'tank',
    ),
    ProductModel(
      id: 't20',
      name: 'تنك 20 متر',
      type: ProductType.tank20,
      price: 14.0,
      unit: '20 م³',
      icon: Icons.opacity,
      color: Color(0xFF9C27B0),
      category: 'tank',
    ),
  ];

  static const List<ProductModel> gasProducts = [
    ProductModel(
      id: 'g12',
      name: 'أسطوانة 12.5 كغ',
      type: ProductType.gas12,
      price: 7.5,
      unit: 'أسطوانة منزلية',
      icon: Icons.propane_tank,
      color: Color(0xFFE65100),
      category: 'gas',
    ),
    ProductModel(
      id: 'g25',
      name: 'أسطوانة 25 كغ',
      type: ProductType.gas25,
      price: 14.0,
      unit: 'أسطوانة كبيرة',
      icon: Icons.propane_tank,
      color: Color(0xFFF44336),
      category: 'gas',
    ),
    ProductModel(
      id: 'g01',
      name: 'منظم غاز',
      type: ProductType.gasRegulator,
      price: 3.5,
      unit: 'منظم + خرطوم',
      icon: Icons.propane,
      color: Color(0xFFFF9800),
      category: 'gas',
    ),
  ];
}
