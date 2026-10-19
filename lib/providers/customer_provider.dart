import 'package:flutter/foundation.dart';
import 'package:qatorah_app/models/user_model.dart';
import 'package:qatorah_app/models/order_model.dart';
import 'package:qatorah_app/managers/dispatch_manager.dart';

class CustomerProvider extends ChangeNotifier {
  UserModel? _currentCustomer;
  List<OrderModel> _myOrders = [];
  List<OrderModel> _pendingOrders = [];
  List<OrderModel> _completedOrders = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ═══ Getters ═══
  UserModel? get currentCustomer => _currentCustomer;
  List<OrderModel> get myOrders => List.unmodifiable(_myOrders);
  List<OrderModel> get pendingOrders => List.unmodifiable(_pendingOrders);
  List<OrderModel> get completedOrders => List.unmodifiable(_completedOrders);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalOrders => _myOrders.length;
  int get activeOrdersCount => _pendingOrders.length;

  // ═══ تعيين العميل ═══
  void setCustomer(UserModel customer) {
    _currentCustomer = customer;
    notifyListeners();
  }

  // ═══ إضافة طلب جديد ═══
  Future<bool> createOrder({
    required String serviceType,
    required Map<String, dynamic> details,
    required double latitude,
    required double longitude,
    required String address,
    String locationLabel = '',
    String notes = '',
  }) async {
    if (_currentCustomer == null) {
      _errorMessage = 'يجب تسجيل الدخول أولاً';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final order = OrderModel(
        id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
        customerId: _currentCustomer!.id,
        customerName: _currentCustomer!.firstName,
        customerPhone: _currentCustomer!.phone,
        serviceType: serviceType,
        details: details,
        latitude: latitude,
        longitude: longitude,
        address: address,
        locationLabel: locationLabel,
        notes: notes,
        status: 'pending',
        timestamp: DateTime.now(),
      );

      _myOrders.insert(0, order);
      _pendingOrders.insert(0, order);

      // إضافة للـ Dispatch
      DispatchManager.addOrder(order);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل إنشاء الطلب: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ═══ إلغاء طلب ═══
  Future<bool> cancelOrder(String orderId, String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _myOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _myOrders[index] = _myOrders[index].copyWith(status: 'cancelled');
        _pendingOrders.removeWhere((o) => o.id == orderId);
      }

      DispatchManager.cancelOrder(orderId, reason);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل إلغاء الطلب: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ═══ تحديث حالة الطلب ═══
  void updateOrderStatus(String orderId, String newStatus) {
    final index = _myOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    _myOrders[index] = _myOrders[index].copyWith(status: newStatus);

    if (newStatus == 'completed') {
      _pendingOrders.removeWhere((o) => o.id == orderId);
      _completedOrders.insert(0, _myOrders[index]);
    } else if (newStatus == 'cancelled') {
      _pendingOrders.removeWhere((o) => o.id == orderId);
    }

    notifyListeners();
  }

  // ═══ تحديث المحفظة ═══
  void updateWallet(double newBalance) {
    if (_currentCustomer == null) return;
    _currentCustomer = _currentCustomer!.copyWith(walletBalance: newBalance);
    notifyListeners();
  }

  // ═══ إضافة نقاط ولاء ═══
  void addLoyaltyPoints(int points) {
    if (_currentCustomer == null) return;
    _currentCustomer = _currentCustomer!.copyWith(
      loyaltyPoints: _currentCustomer!.loyaltyPoints + points,
    );
    notifyListeners();
  }

  // ═══ جلب طلبات العميل ═══
  Future<void> loadMyOrders() async {
    if (_currentCustomer == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // سيتم ربطه بـ Firestore لاحقاً
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل تحميل الطلبات: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══ مسح الأخطاء ═══
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ═══ خروج ═══
  void logout() {
    _currentCustomer = null;
    _myOrders = [];
    _pendingOrders = [];
    _completedOrders = [];
    _errorMessage = null;
    notifyListeners();
  }
}