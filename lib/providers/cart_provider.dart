import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String serviceType;
  
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.serviceType,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  
  List<CartItem> get items => _items;
  
  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
  
  int get itemCount => _items.length;
  
  void addItem(CartItem item) {
    _items.add(item);
    notifyListeners();
  }
  
  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }
  
  void updateQuantity(String itemId, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      if (newQuantity <= 0) {
        removeItem(itemId);
      } else {
        _items[index] = CartItem(
          id: _items[index].id,
          name: _items[index].name,
          price: _items[index].price,
          quantity: newQuantity,
          serviceType: _items[index].serviceType,
        );
        notifyListeners();
      }
    }
  }
  
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
