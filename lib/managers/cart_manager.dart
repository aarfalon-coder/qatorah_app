import 'package:flutter/material.dart';

import '../models/cart_item.dart';

class CartManager {
  static final List<CartItem> _items = [];
  static final ValueNotifier<int> itemCount = ValueNotifier(0);

  static List<CartItem> get items => _items;
  static int get totalItems => itemCount.value;

  static void addItem(CartItem item) {
    _items.add(item);
    _notifyItemsChanged();
  }

  static void removeItem(int index) {
    _items.removeAt(index);
    _notifyItemsChanged();
  }

  static void clear() {
    _items.clear();
    _notifyItemsChanged();
  }

  static void _notifyItemsChanged() {
    itemCount.value = _items.fold(0, (sum, item) => sum + item.quantity);
  }
}
