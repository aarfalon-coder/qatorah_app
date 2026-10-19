import 'package:flutter/foundation.dart';
import 'package:qatorah_app/models/station_model.dart';
import 'package:qatorah_app/models/product_model.dart';

class StationProvider extends ChangeNotifier {
  StationModel? _currentStation;
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  String _selectedCategory = 'all';
  
  bool _isLoading = false;
  String? _errorMessage;

  // ═══ Getters ═══
  StationModel? get currentStation => _currentStation;
  List<ProductModel> get products => List.unmodifiable(_products);
  List<ProductModel> get filteredProducts => List.unmodifiable(_filteredProducts);
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasStation => _currentStation != null;

  // ═══ تعيين المحطة ═══
  void setStation(StationModel station) {
    _currentStation = station;
    notifyListeners();
  }

  // ═══ تحميل المنتجات ═══
  void loadProducts() {
    _products = [
      ...ProductCatalog.waterProducts,
      ...ProductCatalog.tankProducts,
      ...ProductCatalog.gasProducts,
    ];
    _applyFilters();
  }

  // ═══ فلترة حسب الفئة ═══
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // ═══ تطبيق الفلاتر ═══
  void _applyFilters() {
    if (_selectedCategory == 'all') {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products
          .where((p) => p.category == _selectedCategory)
          .toList();
    }
    notifyListeners();
  }

  // ═══ تحديث سعر منتج ═══
  void updateProductPrice(String productId, double newPrice) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    final old = _products[index];
    _products[index] = ProductModel(
      id: old.id,
      name: old.name,
      type: old.type,
      price: newPrice,
      unit: old.unit,
      icon: old.icon,
      color: old.color,
      category: old.category,
    );
    _applyFilters();
  }

  // ═══ إضافة منتج ═══
  void addProduct(ProductModel product) {
    _products.add(product);
    _applyFilters();
  }

  // ═══ حذف منتج ═══
  void removeProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    _applyFilters();
  }

  // ═══ إحصائيات المحطة ═══
  Map<String, dynamic> getStats() {
    if (_currentStation == null) {
      return {'products': 0, 'orders': 0, 'revenue': 0.0};
    }
    return {
      'products': _products.length,
      'orders': 0,
      'revenue': 0.0,
    };
  }

  // ═══ مسح الأخطاء ═══
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ═══ خروج ═══
  void logout() {
    _currentStation = null;
    _products = [];
    _filteredProducts = [];
    _errorMessage = null;
    notifyListeners();
  }
}