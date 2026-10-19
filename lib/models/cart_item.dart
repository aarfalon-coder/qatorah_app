import 'package:flutter/material.dart';

class CartItem {
  final String name;
  final String type;
  final int quantity;
  final double price;
  final Color color;
  final IconData icon;

  CartItem({
    required this.name,
    required this.type,
    required this.quantity,
    required this.price,
    required this.color,
    required this.icon,
  });

  double get total => price * quantity;
}
