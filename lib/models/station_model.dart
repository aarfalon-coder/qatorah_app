/// نموذج المحطة / مزود الخدمة
enum SubscriptionPlan { none, monthly, quarterly, yearly }

class StationModel {
  final String id;
  final String name;
  final String ownerName;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final double radiusKm;
  final double rating;
  final bool isBlocked;
  final String? blockReason;
  final SubscriptionPlan subscriptionPlan;
  final DateTime? subscriptionExpiresAt;
  final List<String> serviceTypes;

  const StationModel({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.radiusKm,
    required this.rating,
    this.isBlocked = false,
    this.blockReason,
    required this.subscriptionPlan,
    this.subscriptionExpiresAt,
    required this.serviceTypes,
  });

  bool get hasActiveSubscription {
    if (subscriptionPlan == SubscriptionPlan.none) return false;
    final exp = subscriptionExpiresAt;
    if (exp == null) return false;
    return exp.isAfter(DateTime.now());
  }

  bool get isEligible => !isBlocked && hasActiveSubscription;
}
