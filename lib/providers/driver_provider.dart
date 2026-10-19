import 'package:flutter/foundation.dart';
import 'package:qatorah_app/models/driver_model.dart';
import 'package:qatorah_app/models/order_model.dart';
import 'package:qatorah_app/models/delivery_model.dart';
import 'package:qatorah_app/managers/dispatch_manager.dart';

class DriverProvider extends ChangeNotifier {
  DriverModel? _currentDriver;
  List<OrderModel> _availableOrders = [];
  List<DeliveryModel> _myDeliveries = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ═══ Getters ═══
  DriverModel? get currentDriver => _currentDriver;
  List<OrderModel> get availableOrders => List.unmodifiable(_availableOrders);
  List<DeliveryModel> get myDeliveries => List.unmodifiable(_myDeliveries);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _currentDriver?.isOnline ?? false;
  bool get isAvailable => _currentDriver?.isAvailable ?? false;

  // ═══ تعيين السائق الحالي ═══
  void setDriver(DriverModel driver) {
    _currentDriver = driver;
    notifyListeners();
  }

  // ═══ تحديث حالة الاتصال ═══
  void toggleOnline() {
    if (_currentDriver == null) return;
    _currentDriver = _currentDriver!.copyWith(
      isOnline: !_currentDriver!.isOnline,
      lastActiveAt: DateTime.now(),
    );
    notifyListeners();
  }

  // ═══ تحديث حالة التوفر ═══
  void toggleAvailable() {
    if (_currentDriver == null) return;
    _currentDriver = _currentDriver!.copyWith(
      isAvailable: !_currentDriver!.isAvailable,
    );
    notifyListeners();
  }

  // ═══ تحديث الموقع ═══
  void updateLocation(double lat, double lng) {
    if (_currentDriver == null) return;
    _currentDriver = _currentDriver!.copyWith(
      currentLatitude: lat,
      currentLongitude: lng,
      lastLocationUpdate: DateTime.now(),
    );
    notifyListeners();
  }

  // ═══ جلب الطلبات المتاحة ═══
  Future<void> loadAvailableOrders() async {
    if (_currentDriver == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _availableOrders = DispatchManager.findNearbyOrders(
        driverLat: _currentDriver!.currentLatitude,
        driverLng: _currentDriver!.currentLongitude,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل تحميل الطلبات: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══ قبول طلب ═══
  Future<DeliveryModel?> acceptOrder(OrderModel order) async {
    if (_currentDriver == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final delivery = DispatchManager.acceptOrder(
        order: order,
        driver: _currentDriver!,
      );

      if (delivery != null) {
        _myDeliveries.add(delivery);
        _availableOrders.removeWhere((o) => o.id == order.id);

        // تحديث حالة السائق
        _currentDriver = _currentDriver!.copyWith(isAvailable: false);

        _isLoading = false;
        notifyListeners();
        return delivery;
      }

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'فشل قبول الطلب: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ═══ رفض طلب ═══
  void rejectOrder(OrderModel order, String reason) {
    if (_currentDriver == null) return;
    DispatchManager.rejectOrder(order.id, _currentDriver!.id, reason);
    _availableOrders.removeWhere((o) => o.id == order.id);
    notifyListeners();
  }

  // ═══ تحديث حالة التوصيل ═══
  void updateDeliveryStatus(String deliveryId, String newStatus) {
    DispatchManager.updateDeliveryStatus(deliveryId, newStatus);

    final index = _myDeliveries.indexWhere((d) => d.id == deliveryId);
    if (index != -1) {
      final old = _myDeliveries[index];
      _myDeliveries[index] = old.copyWith(status: newStatus);

      if (newStatus == 'delivered' || newStatus == 'cancelled') {
        if (_currentDriver != null) {
          _currentDriver = _currentDriver!.copyWith(isAvailable: true);
        }
      }
    }

    notifyListeners();
  }

  // ═══ إحصائيات السائق ═══
  Map<String, dynamic> getStats() {
    if (_currentDriver == null) {
      return {'deliveries': 0, 'earnings': 0.0, 'rating': 0.0};
    }
    return {
      'deliveries': _currentDriver!.totalDeliveries,
      'earnings': _currentDriver!.totalEarnings,
      'rating': _currentDriver!.rating,
      'balance': _currentDriver!.walletBalance,
    };
  }

  // ═══ إضافة أرباح ═══
  void addEarnings(double amount) {
    if (_currentDriver == null) return;
    _currentDriver = _currentDriver!.copyWith(
      totalEarnings: _currentDriver!.totalEarnings + amount,
      walletBalance: _currentDriver!.walletBalance + amount,
      totalDeliveries: _currentDriver!.totalDeliveries + 1,
    );
    notifyListeners();
  }

  // ═══ مسح الأخطاء ═══
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ═══ خروج ═══
  void logout() {
    _currentDriver = null;
    _availableOrders = [];
    _myDeliveries = [];
    _errorMessage = null;
    notifyListeners();
  }
}