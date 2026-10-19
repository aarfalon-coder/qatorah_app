import 'package:qatorah_app/models/station_model.dart';

class RoutingResult {
  final StationModel station;
  final List<StationModel> skipped;
  const RoutingResult({required this.station, required this.skipped});
}

class ProvidersRouter {
  static final List<StationModel> _stations = [
    StationModel(
      id: 'st1',
      name: 'محطة السلام',
      ownerName: 'أبو أحمد',
      latitude: 31.95,
      longitude: 35.91,
      distanceKm: 1.2,
      radiusKm: 5,
      rating: 4.8,
      subscriptionPlan: SubscriptionPlan.yearly,
      subscriptionExpiresAt: DateTime(2027, 12, 31),
      serviceTypes: ['water', 'tank', 'gas'],
    ),
    StationModel(
      id: 'st2',
      name: 'محطة النور',
      ownerName: 'أبو خالد',
      latitude: 31.96,
      longitude: 35.92,
      distanceKm: 2.0,
      radiusKm: 4,
      rating: 4.5,
      isBlocked: true,
      blockReason: 'مخالفة معايير الجودة',
      subscriptionPlan: SubscriptionPlan.monthly,
      subscriptionExpiresAt: DateTime(2027, 5, 30),
      serviceTypes: ['water'],
    ),
    StationModel(
      id: 'st3',
      name: 'محطة أبو محمد',
      ownerName: 'أبو محمد',
      latitude: 31.94,
      longitude: 35.90,
      distanceKm: 3.5,
      radiusKm: 6,
      rating: 4.6,
      subscriptionPlan: SubscriptionPlan.monthly,
      subscriptionExpiresAt: DateTime(2027, 3, 30),
      serviceTypes: ['water', 'tank', 'gas'],
    ),
  ];

  static List<StationModel> get allStations => List.unmodifiable(_stations);

  static List<StationModel> eligibleStations({String serviceType = 'water'}) {
    final list = _stations
        .where((s) => s.isEligible && s.serviceTypes.contains(serviceType))
        .toList();
    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }

  static RoutingResult? routeAutomatically({
    String serviceType = 'water',
    String? excludeId,
  }) {
    final eligible = eligibleStations(serviceType: serviceType)
        .where((s) => s.id != excludeId)
        .toList();
    if (eligible.isEmpty) return null;
    final skipped = _stations
        .where((s) =>
            s.serviceTypes.contains(serviceType) &&
            !s.isEligible &&
            s.id != excludeId)
        .toList();
    return RoutingResult(station: eligible.first, skipped: skipped);
  }
}
