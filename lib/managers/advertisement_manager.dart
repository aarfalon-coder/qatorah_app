import 'package:flutter/foundation.dart';
import '../models/advertisement_model.dart';
import '../models/comment_model.dart';
import '../models/region_model.dart';
import '../services/advertisement_service.dart';
import 'auth_manager.dart';

class AdvertisementManager extends ChangeNotifier {
  AdvertisementManager() {
    _publisherId = kMockProviderId;
    _load();
  }

  late String _publisherId;
  String get publisherId => _publisherId;

  void setPublisherId(String id) {
    _publisherId = id;
    _load();
  }

  final AdvertisementService _svc = AdvertisementService.instance;

  List<AdvertisementModel> _all = [];
  List<AdvertisementModel> get allAds => List.unmodifiable(_all);

  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> _load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _all = List<AdvertisementModel>.from(await _svc.fetchAll());
      debugPrint('✅ تم تحميل ${_all.length} إعلان من الخدمة');
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ خطأ في التحميل: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => _load();

  List<AdvertisementModel> get myAds =>
      _all.where((a) => a.publisher.userId == _publisherId).toList();

  List<AdvertisementModel> get myPendingAds =>
      myAds.where((a) => a.isPending).toList();

  List<AdvertisementModel> get myActiveAds =>
      myAds.where((a) => a.isActive).toList();

  List<AdvertisementModel> get myExpiredAds =>
      myAds.where((a) => a.isExpired).toList();

  int get freeAdsThisMonth {
    final now = DateTime.now();
    return myAds
        .where((a) =>
            a.type == AdType.free &&
            a.createdAt.month == now.month &&
            a.createdAt.year == now.year)
        .length;
  }

  bool get canCreateFree => freeAdsThisMonth < AdLimits.freeMonthlyLimit;

  List<AdvertisementModel> get pendingReviewAds =>
      _all.where((a) => a.isPending).toList();

  AdvertisementModel? adById(String id) {
    for (final a in _all) {
      if (a.id == id) return a;
    }
    return null;
  }

  // ═══ إنشاء إعلان (مع scope الجديد) ═══
  Future<AdvertisementModel?> createAd({
    required String title,
    required String description,
    required List<String> images,
    required AdCategory category,
    required Governorate governorate,
    required AdType type,
    required AdScope scope,       // 🆕
    required int durationDays,
    required double price,
  }) async {
    try {
      debugPrint('🚀 بدء إنشاء إعلان جديد: $title');

      final maxImg = AdLimits.maxImages[type] ?? 1;
      final safeImages = images.take(maxImg).toList();

      if (type == AdType.free && !canCreateFree) {
        _error = 'وصلت للحد الشهري (${AdLimits.freeMonthlyLimit} إعلانات مجانية).';
        notifyListeners();
        return null;
      }

      final now = DateTime.now();
      final status = type == AdType.free ? AdStatus.active : AdStatus.pending;
      final priority =
          type == AdType.qatorah ? 1 : (type == AdType.premium ? 2 : 3);

      final ad = AdvertisementModel(
        id: 'ad_${now.millisecondsSinceEpoch}',
        publisher: PublisherInfo(
          userId: _publisherId,
          userName: AuthManager.firstName.isNotEmpty
              ? AuthManager.firstName
              : 'مزود خدمة',
          userRole: AuthManager.providerServiceType,
          userRating: 4.8,
          userPhone: AuthManager.phone,
        ),
        title: title,
        description: description,
        images: safeImages,
        category: category,
        type: type,
        scope: scope,             // 🆕
        pricing: AdPricing(
          amount: price,
          isHeld: type == AdType.premium,
        ),
        region: governorate,
        coverage: Regions.coverageFor(governorate, type.code),
        duration: AdDuration(
          days: durationDays,
          startDate: now,
          endDate: now.add(Duration(days: durationDays)),
        ),
        status: status,
        moderation: const AdModeration(),
        stats: const AdStats(),
        visibility: AdVisibility(
          showInTicker: type != AdType.free,
          priority: priority,
        ),
        reports: const AdReports(),
        createdAt: now,
        updatedAt: now,
      );

      final created = await _svc.create(ad);
      debugPrint('✅ تم حفظ الإعلان في الخدمة: ${created.id}');

      _all.insert(0, created);
      _error = null;
      notifyListeners();

      debugPrint('✅ تم تحديث القائمة، العدد الآن: ${_all.length}');
      debugPrint('✅ إعلاناتي الآن: ${myAds.length}');

      return created;
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء الإعلان: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateAd(AdvertisementModel updated) async {
    final res = await _svc.update(updated.copyWith(updatedAt: DateTime.now()));
    if (res != null) {
      final i = _all.indexWhere((a) => a.id == res.id);
      if (i != -1) _all[i] = res;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteAd(String id) async {
    final ad = adById(id);
    if (ad == null) return false;
    if (ad.pricing.isHeld) {
      _error = 'لا يمكن حذف إعلان مبلغه محجوز.';
      notifyListeners();
      return false;
    }
    final ok = await _svc.delete(id);
    if (ok) {
      _all.removeWhere((a) => a.id == id);
      _error = null;
      notifyListeners();
    }
    return ok;
  }

  Future<bool> cancelPendingAd(String id) async {
    final ad = adById(id);
    if (ad == null || !ad.isPending) return false;
    final updated = ad.copyWith(
      status: AdStatus.cancelled,
      pricing: ad.pricing.copyWith(isHeld: false),
      updatedAt: DateTime.now(),
    );
    return updateAd(updated);
  }

  Future<bool> renewAd(String id) async {
    final ad = adById(id);
    if (ad == null) return false;
    final now = DateTime.now();
    final newEnd = now.add(Duration(days: ad.duration.days));
    final renewed = ad.copyWith(
      status: ad.type == AdType.free ? AdStatus.active : AdStatus.pending,
      pricing: ad.pricing.copyWith(isHeld: ad.type == AdType.premium),
      duration: ad.duration.copyWith(endDate: newEnd, renewalReminded: false),
      updatedAt: now,
    );
    return updateAd(renewed);
  }

  Future<AdvertisementModel?> upgradeToPremium(String id,
      {required double price, required int days}) async {
    final ad = adById(id);
    if (ad == null) return null;
    return createAd(
      title: ad.title,
      description: ad.description,
      images: ad.images,
      category: ad.category,
      governorate: ad.region,
      type: AdType.premium,
      scope: ad.scope,          // 🆕
      durationDays: days,
      price: price,
    );
  }

  Future<bool> approveAd(String id, {String adminId = kMockAdminId}) async {
    final ad = adById(id);
    if (ad == null || !ad.isPending) return false;
    final now = DateTime.now();
    final approved = ad.copyWith(
      status: AdStatus.active,
      pricing: ad.pricing.copyWith(
        isHeld: false,
        transactionId: 'txn_${now.millisecondsSinceEpoch}',
      ),
      moderation: AdModeration(
        reviewedBy: adminId,
        reviewedAt: now,
        notes: 'اعتمد من الإدارة',
      ),
      updatedAt: now,
    );
    return updateAd(approved);
  }

  Future<bool> rejectAd(String id, String reason,
      {String adminId = kMockAdminId}) async {
    final ad = adById(id);
    if (ad == null || !ad.isPending) return false;
    final now = DateTime.now();
    final rejected = ad.copyWith(
      status: AdStatus.rejected,
      pricing: ad.pricing.copyWith(isHeld: false),
      moderation: AdModeration(
        reviewedBy: adminId,
        reviewedAt: now,
        rejectionReason: reason,
      ),
      updatedAt: now,
    );
    return updateAd(rejected);
  }

  Future<void> trackView(String id) async {
    await _svc.incrementView(id);
    final ad = adById(id);
    if (ad != null) {
      final i = _all.indexWhere((a) => a.id == id);
      if (i != -1) {
        _all[i] = ad.copyWith(stats: ad.stats.copyWith(views: ad.stats.views + 1));
        notifyListeners();
      }
    }
  }

  Future<void> trackClick(String id) async {
    await _svc.incrementClick(id);
    final ad = adById(id);
    if (ad != null) {
      final i = _all.indexWhere((a) => a.id == id);
      if (i != -1) {
        _all[i] =
            ad.copyWith(stats: ad.stats.copyWith(clicks: ad.stats.clicks + 1));
        notifyListeners();
      }
    }
  }

  Future<void> reportAd(String id, String reason) async {
    await _svc.addReport(id, reason);
    final ad = adById(id);
    if (ad != null) {
      final i = _all.indexWhere((a) => a.id == id);
      if (i != -1) {
        final newReports = ad.reports.addReport(reason);
        _all[i] = ad.copyWith(
          reports: newReports,
          status: newReports.shouldAutoPause ? AdStatus.expired : ad.status,
        );
        notifyListeners();
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ═══ التفاعلات الاجتماعية ═══
  final Map<String, int> _adLikes = {};
  final Map<String, List<CommentModel>> _adComments = {};

  int getAdLikes(String adId) => _adLikes[adId] ?? 0;
  List<CommentModel> getAdComments(String adId) => _adComments[adId] ?? [];

  void toggleAdLike(String adId) {
    _adLikes[adId] = (_adLikes[adId] ?? 0) + 1;
    notifyListeners();
  }

  void addComment(String adId, String text, String userName) {
    final comments = List<CommentModel>.from(_adComments[adId] ?? []);
    comments.insert(
      0,
      CommentModel(
        id: 'c_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_mock',
        userName: userName,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
    _adComments[adId] = comments;
    notifyListeners();
  }

  void addReply(String adId, String commentId, String text, String userName) {
    final comments = List<CommentModel>.from(_adComments[adId] ?? []);
    final index = comments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      final parent = comments[index];
      final newReplies = List<CommentModel>.from(parent.replies)
        ..add(CommentModel(
          id: 'r_${DateTime.now().millisecondsSinceEpoch}',
          userId: 'user_mock',
          userName: userName,
          text: text,
          createdAt: DateTime.now(),
        ));
      comments[index] = parent.copyWith(replies: newReplies);
      _adComments[adId] = comments;
      notifyListeners();
    }
  }

  void toggleCommentLike(String adId, String commentId) {
    final comments = List<CommentModel>.from(_adComments[adId] ?? []);
    final index = comments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      comments[index] = comments[index].copyWith(likes: comments[index].likes + 1);
      _adComments[adId] = comments;
      notifyListeners();
    }
  }
}