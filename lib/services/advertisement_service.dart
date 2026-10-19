import 'dart:async';
import '../models/advertisement_model.dart';
import '../models/region_model.dart';

/// ═══════════════════════════════════════════════════════════
///  Advertisement Service (Mock)
///  تخزين مؤقت في الذاكرة يحاكي Firestore.
/// ═══════════════════════════════════════════════════════════

const String kMockProviderId = 'usr_provider_001';
const String kMockAdminId = 'admin_super_001';

class AdvertisementService {
  AdvertisementService._internal() {
    _seed();
  }
  static final AdvertisementService instance = AdvertisementService._internal();

  final List<AdvertisementModel> _store = [];

  // ═══ بيانات تجريبية أولية ═══
  void _seed() {
    final now = DateTime.now();
    AdvertisementModel build({
      required String id,
      required String pubId,
      required String pubName,
      required String pubRole,
      required String title,
      required String desc,
      required AdType type,
      required AdStatus status,
      required Governorate gov,
      required AdCategory cat,
      required int days,
      required double price,
      required int views,
      required int clicks,
      AdScope scope = AdScope.governorate,
      bool mine = false,
    }) {
      final start = now.subtract(Duration(days: type == AdType.free ? 2 : 5));
      return AdvertisementModel(
        id: id,
        publisher: PublisherInfo(
          userId: pubId,
          userName: pubName,
          userRole: pubRole,
          userRating: 4.8,
          userPhone: '0790000000',
        ),
        title: title,
        description: desc,
        images: const [
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
        ],
        category: cat,
        type: type,
        scope: scope,
        pricing: AdPricing(
          amount: price,
          isHeld: type == AdType.premium && status == AdStatus.pending,
        ),
        region: gov,
        coverage: Regions.coverageFor(gov, type.code),
        duration: AdDuration(
          days: days,
          startDate: start,
          endDate: start.add(Duration(days: days)),
        ),
        status: status,
        moderation: const AdModeration(),
        stats: AdStats(views: views, clicks: clicks),
        visibility: AdVisibility(
          showInTicker: type != AdType.free,
          priority: type == AdType.qatorah ? 1 : (type == AdType.premium ? 2 : 3),
        ),
        reports: const AdReports(),
        createdAt: start,
        updatedAt: start,
      );
    }

    _store.addAll([
      // ── إعلانات المزود الحالي ──
      build(
        id: 'ad_mine_1',
        pubId: kMockProviderId,
        pubName: 'محطة النور',
        pubRole: 'station_owner',
        title: 'أسطوانات غاز منزلية — توصيل فوري',
        desc: 'نوفر أسطوانات 12 كغم و 50 كغم مع توصيل مجاني داخل إربد.',
        type: AdType.premium,
        status: AdStatus.active,
        gov: Governorate.irbid,
        cat: AdCategory.gas,
        days: 30,
        price: 25,
        views: 234,
        clicks: 45,
        scope: AdScope.kingdom,
        mine: true,
      ),
      build(
        id: 'ad_mine_2',
        pubId: kMockProviderId,
        pubName: 'محطة النور',
        pubRole: 'station_owner',
        title: 'تنك مياه شرب 6 متر',
        desc: 'مياه صحية معتمدة، تعبئة سريعة خلال ساعة.',
        type: AdType.free,
        status: AdStatus.active,
        gov: Governorate.irbid,
        cat: AdCategory.water,
        days: 7,
        price: 0,
        views: 56,
        clicks: 9,
        scope: AdScope.governorate,
        mine: true,
      ),
      build(
        id: 'ad_mine_3',
        pubId: kMockProviderId,
        pubName: 'محطة النور',
        pubRole: 'station_owner',
        title: 'صيانة دورية للخزانات',
        desc: 'تنظيف وتعقيم خزانات المياه بمواد آمنة.',
        type: AdType.premium,
        status: AdStatus.pending,
        gov: Governorate.irbid,
        cat: AdCategory.maintenance,
        days: 30,
        price: 25,
        views: 0,
        clicks: 0,
        scope: AdScope.governorate,
        mine: true,
      ),

      // ─ إعلانات مزودين آخرين ──
      build(
        id: 'ad_other_1',
        pubId: 'usr_station_002',
        pubName: 'محطة السلام',
        pubRole: 'station_owner',
        title: 'مياه معدنية بالجملة والتجزئة',
        desc: 'أفضل الأسعار في عمان والزرقاء.',
        type: AdType.premium,
        status: AdStatus.active,
        gov: Governorate.amman,
        cat: AdCategory.water,
        days: 30,
        price: 25,
        views: 512,
        clicks: 88,
        scope: AdScope.governorate,
      ),
      build(
        id: 'ad_other_2',
        pubId: 'usr_plumber_003',
        pubName: 'فني السباكة أحمد',
        pubRole: 'plumber',
        title: 'سباك محترف — تدخل سريع',
        desc: 'إصلاح تسريبات وتركيبات فورية بالعقبة.',
        type: AdType.free,
        status: AdStatus.active,
        gov: Governorate.aqaba,
        cat: AdCategory.maintenance,
        days: 7,
        price: 0,
        views: 31,
        clicks: 4,
        scope: AdScope.governorate,
      ),
      build(
        id: 'ad_qatorah_1',
        pubId: 'system',
        pubName: 'قطوره',
        pubRole: 'platform',
        title: '🎉 عرض الإطلاق: خصم 20% على أول دفتر كوبونات',
        desc: 'لجميع مستخدمي قطوره الجدد — ساري حتى نهاية الشهر.',
        type: AdType.qatorah,
        status: AdStatus.active,
        gov: Governorate.amman,
        cat: AdCategory.other,
        days: 365,
        price: 0,
        views: 1200,
        clicks: 340,
        scope: AdScope.kingdom,
      ),
    ]);
  }

  // ═══ عمليات القراءة ═══
  Future<List<AdvertisementModel>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_store);
  }

  Future<List<AdvertisementModel>> fetchByPublisher(String publisherId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.where((a) => a.publisher.userId == publisherId).toList();
  }

  Future<List<AdvertisementModel>> fetchVisibleTo(Governorate? gov) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store
        .where((a) => a.isDisplayable && a.visibleTo(gov))
        .toList()
      ..sort((a, b) => a.sortPriority.compareTo(b.sortPriority));
  }

  Future<List<AdvertisementModel>> fetchTickerFor(Governorate? gov) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store
        .where((a) => a.isDisplayable && a.eligibleForTicker && a.visibleTo(gov))
        .toList()
      ..sort((a, b) => a.sortPriority.compareTo(b.sortPriority));
  }

  Future<List<AdvertisementModel>> fetchPendingReview() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.where((a) => a.isPending).toList();
  }

  // ═══ عمليات الكتابة ═══
  Future<AdvertisementModel> create(AdvertisementModel ad) async {
    await Future.delayed(const Duration(milliseconds: 350));
    _store.insert(0, ad);
    return ad;
  }

  Future<AdvertisementModel?> update(AdvertisementModel ad) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final i = _store.indexWhere((a) => a.id == ad.id);
    if (i == -1) return null;
    _store[i] = ad;
    return ad;
  }

  Future<bool> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final before = _store.length;
    _store.removeWhere((a) => a.id == id);
    return _store.length < before;
  }

  Future<void> incrementView(String id) async {
    final i = _store.indexWhere((a) => a.id == id);
    if (i != -1) {
      _store[i] = _store[i].copyWith(
        stats: _store[i].stats.copyWith(views: _store[i].stats.views + 1),
      );
    }
  }

  Future<void> incrementClick(String id) async {
    final i = _store.indexWhere((a) => a.id == id);
    if (i != -1) {
      _store[i] = _store[i].copyWith(
        stats: _store[i].stats.copyWith(clicks: _store[i].stats.clicks + 1),
      );
    }
  }

  Future<void> addReport(String id, String reason) async {
    final i = _store.indexWhere((a) => a.id == id);
    if (i != -1) {
      _store[i] = _store[i].copyWith(reports: _store[i].reports.addReport(reason));
    }
  }
}