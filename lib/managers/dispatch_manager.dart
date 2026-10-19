import 'package:flutter/foundation.dart';
import 'package:qatorah_app/models/order_model.dart';
import 'package:qatorah_app/models/driver_model.dart';
import 'package:qatorah_app/models/delivery_model.dart';
import 'package:qatorah_app/utils/distance_calculator.dart';

class DispatchManager extends ChangeNotifier {
  // ═══ قوائم الطلبات النشطة ═══
  static final List<OrderModel> _pendingOrders = [];
  static final List<OrderModel> _activeOrders = [];
  static final List<DeliveryModel> _activeDeliveries = [];

  // ═══ إعدادات التوزيع ═══
  static const double maxRadiusKm = 15.0;
  static const int maxProvidersPerOrder = 5;
  static const int maxDeliveryAttempts = 3;

  // ═══ Getters ═══
  static List<OrderModel> get pendingOrders => List.unmodifiable(_pendingOrders);
  static List<OrderModel> get activeOrders => List.unmodifiable(_activeOrders);
  static List<DeliveryModel> get activeDeliveries => List.unmodifiable(_activeDeliveries);
  
  static int get pendingCount => _pendingOrders.length;
  static int get activeCount => _activeOrders.length;

  // ═══ إضافة طلب جديد ═══
  static void addOrder(OrderModel order) {
    _pendingOrders.add(order);
  }

  // ═══ إيجاد المزودين القريبين ═══
  static List<DriverModel> findNearbyDrivers({
    required double orderLat,
    required double orderLng,
    required List<DriverModel> allDrivers,
    double radiusKm = maxRadiusKm,
  }) {
    final availableDrivers = allDrivers.where((d) => d.canReceiveOrders).toList();

    final driversWithDistance = availableDrivers.map((driver) {
      final distance = DistanceCalculator.calculateDistance(
        lat1: orderLat,
        lng1: orderLng,
        lat2: driver.currentLatitude,
        lng2: driver.currentLongitude,
      );
      return MapEntry(driver, distance);
    }).toList();

    driversWithDistance.removeWhere((entry) => entry.value > radiusKm);
    driversWithDistance.sort((a, b) => a.value.compareTo(b.value));

    return driversWithDistance
        .take(maxProvidersPerOrder)
        .map((entry) => entry.key)
        .toList();
  }

  // ═══ إيجاد الطلبات القريبة من سائق ═══
  static List<OrderModel> findNearbyOrders({
    required double driverLat,
    required double driverLng,
    double radiusKm = maxRadiusKm,
  }) {
    final nearby = _pendingOrders.where((order) {
      final distance = DistanceCalculator.calculateDistance(
        lat1: driverLat,
        lng1: driverLng,
        lat2: order.latitude,
        lng2: order.longitude,
      );
      return distance <= radiusKm;
    }).toList();

    nearby.sort((a, b) {
      final distA = DistanceCalculator.calculateDistance(
        lat1: driverLat,
        lng1: driverLng,
        lat2: a.latitude,
        lng2: a.longitude,
      );
      final distB = DistanceCalculator.calculateDistance(
        lat1: driverLat,
        lng1: driverLng,
        lat2: b.latitude,
        lng2: b.longitude,
      );
      return distA.compareTo(distB);
    });

    return nearby;
  }

  // ═══ قبول طلب من قبل سائق ═══
  static DeliveryModel? acceptOrder({
    required OrderModel order,
    required DriverModel driver,
  }) {
    if (!driver.canReceiveOrders) {
      debugPrint('❌ السائق غير متاح: ${driver.fullName}');
      return null;
    }

    _pendingOrders.removeWhere((o) => o.id == order.id);
    _activeOrders.add(order);

    final delivery = DeliveryModel(
      id: 'del_${DateTime.now().millisecondsSinceEpoch}',
      orderId: order.id,
      driverId: driver.id,
      providerId: order.customerId,
      customerId: order.customerId,
      status: 'assigned',
      pickupLatitude: driver.currentLatitude,
      pickupLongitude: driver.currentLongitude,
      pickupAddress: 'موقع السائق',
      dropoffLatitude: order.latitude,
      dropoffLongitude: order.longitude,
      dropoffAddress: order.address,
      assignedAt: DateTime.now(),
      createdAt: DateTime.now(),
      deliveryFee: 1.0,
      paymentMethod: 'cash',
    );

    _activeDeliveries.add(delivery);
    return delivery;
  }

  // ═══ تحديث حالة التوصيل ═══
  static void updateDeliveryStatus(String deliveryId, String newStatus) {
    final index = _activeDeliveries.indexWhere((d) => d.id == deliveryId);
    if (index == -1) return;

    final old = _activeDeliveries[index];
    DateTime? pickedUpAt = old.pickedUpAt;
    DateTime? deliveredAt = old.deliveredAt;

    if (newStatus == 'picked_up') pickedUpAt = DateTime.now();
    if (newStatus == 'delivered') deliveredAt = DateTime.now();

    _activeDeliveries[index] = old.copyWith(
      status: newStatus,
      pickedUpAt: pickedUpAt,
      deliveredAt: deliveredAt,
    );

    if (newStatus == 'delivered' || newStatus == 'cancelled') {
      _activeOrders.removeWhere((o) => o.id == old.orderId);
    }
  }

  // ═══ رفض طلب ═══
  static void rejectOrder(String orderId, String driverId, String reason) {
    debugPrint('❌ السائق $driverId رفض الطلب $orderId - السبب: $reason');
  }

  // ═══ إلغاء طلب ═══
  static void cancelOrder(String orderId, String reason) {
    _pendingOrders.removeWhere((o) => o.id == orderId);
    _activeOrders.removeWhere((o) => o.id == orderId);
    _activeDeliveries.removeWhere((d) => d.orderId == orderId);
    debugPrint('🚫 تم إلغاء الطلب $orderId - السبب: $reason');
  }

  // ═══ إحصائيات ═══
  static Map<String, int> getStats() {
    return {
      'pending': _pendingOrders.length,
      'active': _activeOrders.length,
      'deliveries': _activeDeliveries.length,
    };
  }

  // ═══ تنظيف القوائم ═══
  static void clearAll() {
    _pendingOrders.clear();
    _activeOrders.clear();
    _activeDeliveries.clear();
  }
}