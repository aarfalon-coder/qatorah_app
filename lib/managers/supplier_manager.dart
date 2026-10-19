class WaterStation {
  final String id;
  final String name;
  final double distanceKm;
  final double rating;
  double deliveryFee;
  final Map<String, double> prices;

  WaterStation({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.rating,
    required this.deliveryFee,
    required this.prices,
  });
}

class Invoice {
  final double productsTotal;
  final double deliveryFee;
  final double commission;
  double get total => productsTotal + deliveryFee + commission;

  Invoice(
      {required this.productsTotal,
      required this.deliveryFee,
      required this.commission});
}

enum SortBy { bestValue, nearest, rating }

class SupplierManager {
  static const double commissionRate = 0.05;
  static String? lastStationId;

  static final List<WaterStation> stations = [
    WaterStation(
      id: 'st1',
      name: 'محطة السلام',
      distanceKm: 1.2,
      rating: 4.9,
      deliveryFee: 1.0,
      prices: {
        'w_ex_20': 1.25,
        'w_ex_10': 0.75,
        'w_one_20': 1.5,
        'w_one_12': 1.0,
        'w_one_5': 0.5,
        'w_empty_jo_20': 3.0,
        'w_empty_jo_12': 2.0,
        'w_empty_sa_20': 3.5,
        'w_empty_sa_25': 4.0,
        'w_cup_r_240_n': 4.0,
        'w_cup_r_240_f': 4.5,
        'w_cup_r_200_n': 3.75,
        'w_cup_r_200_f': 4.25,
        'w_cup_s_180': 3.5,
        'w_pack_1500': 5.5,
        'w_pack_600': 4.0,
        'w_pack_330_16': 3.0,
        'w_pack_330_20': 3.6,
      },
    ),
    WaterStation(
      id: 'st2',
      name: 'محطة الجبل الأخضر',
      distanceKm: 2.5,
      rating: 4.7,
      deliveryFee: 1.5,
      prices: {
        'w_ex_20': 1.1,
        'w_ex_10': 0.7,
        'w_one_20': 1.4,
        'w_one_12': 0.9,
        'w_one_5': 0.45,
        'w_empty_jo_20': 2.75,
        'w_empty_jo_12': 1.75,
        'w_empty_sa_20': 3.25,
        'w_empty_sa_25': 3.75,
        'w_cup_r_240_n': 3.8,
        'w_cup_r_240_f': 4.3,
        'w_cup_r_200_n': 3.5,
        'w_cup_r_200_f': 4.0,
        'w_cup_s_180': 3.25,
        'w_pack_1500': 5.25,
        'w_pack_600': 3.75,
        'w_pack_330_16': 2.8,
        'w_pack_330_20': 3.4,
      },
    ),
    WaterStation(
      id: 'st3',
      name: 'محطة النخيل',
      distanceKm: 3.8,
      rating: 4.5,
      deliveryFee: 0.75,
      prices: {
        'w_ex_20': 1.4,
        'w_ex_10': 0.8,
        'w_one_20': 1.6,
        'w_one_12': 1.1,
        'w_one_5': 0.55,
        'w_empty_jo_20': 3.25,
        'w_empty_jo_12': 2.25,
        'w_empty_sa_20': 3.75,
        'w_empty_sa_25': 4.25,
        'w_cup_r_240_n': 4.2,
        'w_cup_r_240_f': 4.7,
        'w_cup_r_200_n': 3.9,
        'w_cup_r_200_f': 4.4,
        'w_cup_s_180': 3.6,
        'w_pack_1500': 5.75,
        'w_pack_600': 4.2,
        'w_pack_330_16': 3.1,
        'w_pack_330_20': 3.8,
      },
    ),
  ];

  static double priceAt(WaterStation st, String productId) {
    return st.prices[productId] ?? 1.0;
  }

  static Invoice calcInvoice(WaterStation st, Map<String, int> items) {
    double productsTotal = 0;
    items.forEach((id, qty) {
      productsTotal += priceAt(st, id) * qty;
    });
    final commission = (productsTotal + st.deliveryFee) * commissionRate;
    return Invoice(
        productsTotal: productsTotal,
        deliveryFee: st.deliveryFee,
        commission: commission);
  }

  static WaterStation bestValue(Map<String, int> items) {
    WaterStation best = stations.first;
    double bestTotal = double.infinity;
    for (final st in stations) {
      final t = calcInvoice(st, items).total;
      if (t < bestTotal) {
        bestTotal = t;
        best = st;
      }
    }
    return best;
  }

  static List<WaterStation> sorted(Map<String, int> items, SortBy by) {
    final list = List<WaterStation>.from(stations);
    switch (by) {
      case SortBy.bestValue:
        list.sort((a, b) =>
            calcInvoice(a, items).total.compareTo(calcInvoice(b, items).total));
        break;
      case SortBy.nearest:
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case SortBy.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return list;
  }

  static void confirmOrder(WaterStation st) {
    lastStationId = st.id;
  }
}
