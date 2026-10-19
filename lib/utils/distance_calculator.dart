import 'dart:math';

class DistanceCalculator {
  static double calculateDistance({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const double earthRadius = 6371;
    double dLat = _toRadians(lat2 - lat1);
    double dLng = _toRadians(lng2 - lng1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
               cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
               sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static int estimateDeliveryTime({
    required double distanceKm,
    double averageSpeedKmh = 40,
  }) {
    double timeHours = distanceKm / averageSpeedKmh;
    return (timeHours * 60).round() + 15;
  }

  static double calculateDeliveryCost({
    required double distanceKm,
    double basePrice = 2.0,
    double pricePerKm = 0.5,
  }) {
    return basePrice + (distanceKm * pricePerKm);
  }

  static double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
