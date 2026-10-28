import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/advertisement_model.dart';
import '../models/comment_model.dart';
import '../models/region_model.dart';
import 'auth_manager.dart';

class AdvertisementManager extends ChangeNotifier {
  AdvertisementManager() {
    _initStream();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<AdvertisementModel> _all = [];
  
  // 🆕 getters منفصلة حسب الحاجة
  List<AdvertisementModel> get allAds => List.unmodifiable(_all);
  
  // 🆕 للإعلانات النشطة فقط (للعملاء)
  List<AdvertisementModel> get activeAds => _all.where((a) => a.isActive).toList();
  
  // 🆕 للإعلانات المعطلة (للأدمن)
  List<AdvertisementModel> get inactiveAds => _all.where((a) => !a.isActive).toList();

  bool _loading = true;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;

  // ═══ الاستماع المباشر لـ Firebase (Real-time) ═══
  void _initStream() {
    _db.collection('advertisements').snapshots().listen((snapshot) {
      _all = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AdvertisementModel.fromMap(data);
      }).toList();
      _loading = false;
      _error = null;
      debugPrint('✅ تم تحميل ${_all.length} إعلان من Firebase (Real-time)');
      debugPrint('  ↳ النشطة: ${activeAds.length} | المعطلة: ${inactiveAds.length}');
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _loading = false;
      debugPrint('❌ خطأ في تحميل الإعلانات: $e');
      notifyListeners();
    });
  }

  // ═══ تحديث يدوي (اختياري) ═══
  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    try {
      final snapshot = await _db.collection('advertisements').get();
      _all = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AdvertisementModel.fromMap(data);
      }).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ═══ عمليات القراءة ═══

  List<AdvertisementModel> get myAds {
    final uid = AuthManager.firebaseUid;
    if (uid == null || uid.isEmpty) return [];
    return _all.where((a) => a.publisher.userId == uid).toList();
  }

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

  // ═══ إنشاء إعلان (مربوط بـ Firebase) ═══
  Future<AdvertisementModel?> createAd({
    required String title,
    required String description,
    required List<String> images,
    required AdCategory category,
    required Governorate governorate,
    required AdType type,
    required AdScope scope,
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
      const status = AdStatus.pending;
      final priority = type == AdType.qatorah ? 1 : (type == AdType.premium ? 2 : 3);

      final ad = AdvertisementModel(
        id: '', 
        publisher: PublisherInfo(
          userId: AuthManager.firebaseUid ?? '',
          userName: AuthManager.firstName.isNotEmpty ? AuthManager.firstName : 'مزود خدمة',
          userRole: AuthManager.providerServiceType,
          userRating: 4.8,
          userPhone: AuthManager.phone,
        ),
        title: title,
        description: description,
        images: safeImages,
        category: category,
        type: type,
        scope: scope,
        pricing: AdPricing(amount: price, isHeld: type == AdType.premium),
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
        visibility: AdVisibility(showInTicker: type != AdType.free, priority: priority),
        reports: const AdReports(),
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _db.collection('advertisements').add(ad.toMap());
      debugPrint('✅ تم حفظ الإعلان في Firebase: ${docRef.id}');
      return ad;
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء الإعلان: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ═══ تحديث إعلان ═══
  Future<bool> updateAd(AdvertisementModel updated) async {
    try {
      await _db.collection('advertisements').doc(updated.id).set(
        updated.toMap(),
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في تحديث الإعلان: $e');
      return false;
    }
  }

  // ═══ حذف إعلان ═══
  Future<bool> deleteAd(String id) async {
    try {
      final ad = adById(id);
      if (ad == null) return false;
      if (ad.pricing.isHeld) {
        _error = 'لا يمكن حذف إعلان مبلغه محجوز.';
        notifyListeners();
        return false;
      }
      await _db.collection('advertisements').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في حذف الإعلان: $e');
      return false;
    }
  }

  // ═══ إلغاء إعلان معلق ═══
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

  // ═══ تجديد إعلان ═══
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

  // ═══ ترقية إلى بريميوم ═══
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
      scope: ad.scope,
      durationDays: days,
      price: price,
    );
  }

  // ═══ اعتماد إعلان (للسوبر أدمن) ═══
  Future<bool> approveAd(String id, {String adminId = 'admin'}) async {
    final ad = adById(id);
    if (ad == null || !ad.isPending) return false;
    final now = DateTime.now();
    final approved = ad.copyWith(
      status: AdStatus.active,
      pricing: ad.pricing.copyWith(
        isHeld: false,
        transactionId: 'txn_${now.millisecondsSinceEpoch}',
      ),
      moderation: AdModeration(reviewedBy: adminId, reviewedAt: now, notes: 'اعتمد من الإدارة'),
      updatedAt: now,
    );
    return updateAd(approved);
  }

  // ═══ رفض إعلان (للسوبر أدمن) ═══
  Future<bool> rejectAd(String id, String reason, {String adminId = 'admin'}) async {
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

  // 🆕 تفعيل/إيقاف إعلان يدوياً (من لوحة الأدمن)
  Future<bool> toggleAdActiveStatus(String id, bool isActive) async {
    try {
      await _db.collection('advertisements').doc(id).update({
        'status': isActive ? 'active' : 'inactive',
        'updatedAt': Timestamp.now(),
      });
      debugPrint('✅ تم ${isActive ? "تفعيل" : "إيقاف"} الإعلان: $id');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في تغيير حالة الإعلان: $e');
      return false;
    }
  }

  // ═══ إحصائيات ═══
  Future<void> trackView(String id) async {
    await _db.collection('advertisements').doc(id).update({'stats.views': FieldValue.increment(1)});
  }

  Future<void> trackClick(String id) async {
    await _db.collection('advertisements').doc(id).update({'stats.clicks': FieldValue.increment(1)});
  }

  Future<void> reportAd(String id, String reason) async {
    await _db.collection('advertisements').doc(id).update({
      'reports.count': FieldValue.increment(1),
      'reports.reasons': FieldValue.arrayUnion([reason]),
    });
  }

  // ═══════════════════════════════════════════════════════════
  // 🆕 التفاعلات الاجتماعية (مربوطة بـ Firebase بشكل نهائي)
  // ═══════════════════════════════════════════════════════════
  final Map<String, int> _adLikes = {};
  final Map<String, List<CommentModel>> _adComments = {};

  int getAdLikes(String adId) => _adLikes[adId] ?? 0;
  List<CommentModel> getAdComments(String adId) => _adComments[adId] ?? [];

  void toggleAdLike(String adId) {
    _adLikes[adId] = (_adLikes[adId] ?? 0) + 1;
    notifyListeners();
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

  // 🆕 جلب التعليقات من Firebase
  Future<void> loadComments(String adId) async {
    try {
      final snapshot = await _db
          .collection('advertisements')
          .doc(adId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .get();
      
      _adComments[adId] = snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc.data(), doc.id))
          .toList();
      notifyListeners();
      debugPrint('✅ تم تحميل ${_adComments[adId]?.length ?? 0} تعليق للإعلان $adId');
    } catch (e) {
      debugPrint('❌ خطأ في جلب التعليقات: $e');
      _adComments[adId] = [];
      notifyListeners();
    }
  }

  // 🆕 إضافة تعليق وحفظه في Firebase
  Future<void> addComment(String adId, String text, String userName) async {
    try {
      final newId = 'c_${DateTime.now().millisecondsSinceEpoch}';
      final newComment = CommentModel(
        id: newId,
        userId: AuthManager.firebaseUid ?? 'guest',
        userName: userName,
        text: text,
        createdAt: DateTime.now(),
      );

      // التحديث الفوري للواجهة (Optimistic Update)
      final comments = List<CommentModel>.from(_adComments[adId] ?? []);
      comments.insert(0, newComment);
      _adComments[adId] = comments;
      notifyListeners();

      // الحفظ النهائي في Firebase
      await _db
          .collection('advertisements')
          .doc(adId)
          .collection('comments')
          .doc(newId)
          .set(newComment.toFirestore());
      
      debugPrint('✅ تم حفظ التعليق في Firebase: $newId');
    } catch (e) {
      debugPrint('❌ خطأ في إضافة التعليق: $e');
    }
  }

  // 🆕 إضافة رد وحفظه في Firebase
  Future<void> addReply(String adId, String commentId, String text, String userName) async {
    try {
      final comments = List<CommentModel>.from(_adComments[adId] ?? []);
      final index = comments.indexWhere((c) => c.id == commentId);
      
      if (index != -1) {
        final parent = comments[index];
        final newReplyId = 'r_${DateTime.now().millisecondsSinceEpoch}';
        final newReply = CommentModel(
          id: newReplyId,
          userId: AuthManager.firebaseUid ?? 'guest',
          userName: userName,
          text: text,
          createdAt: DateTime.now(),
        );

        final newReplies = List<CommentModel>.from(parent.replies)..add(newReply);
        final updatedParent = parent.copyWith(replies: newReplies);
        comments[index] = updatedParent;
        _adComments[adId] = comments;
        notifyListeners();

        // حفظ الرد في Firebase
        await _db
            .collection('advertisements')
            .doc(adId)
            .collection('comments')
            .doc(commentId)
            .update({
          'replies': FieldValue.arrayUnion([newReply.toFirestore()]),
        });
        
        debugPrint('✅ تم حفظ الرد في Firebase: $newReplyId');
      }
    } catch (e) {
      debugPrint('❌ خطأ في إضافة الرد: $e');
    }
  }

  // 🆕 الإبلاغ عن تعليق (تحديث فوري + حفظ في Firebase)
  Future<void> reportComment(String adId, String commentId, String reason) async {
    try {
      // أ. التحديث المحلي الفوري (ليظهر للمستخدم فوراً)
      final comments = List<CommentModel>.from(_adComments[adId] ?? []);
      final index = comments.indexWhere((c) => c.id == commentId);
      
      if (index != -1) {
        comments[index] = comments[index].copyWith(
          isReported: true,
          reportReason: reason,
          reportCount: comments[index].reportCount + 1,
        );
        _adComments[adId] = comments;
        notifyListeners();
      }

      // ب. الحفظ النهائي في Firestore
      await _db
          .collection('advertisements')
          .doc(adId)
          .collection('comments')
          .doc(commentId)
          .update({
        'isReported': true,
        'reportReason': reason,
        'reportCount': FieldValue.increment(1),
      });
      
      debugPrint('✅ تم الإبلاغ عن التعليق وحفظه في Firebase بنجاح: $commentId');
    } catch (e) {
      debugPrint('❌ خطأ في الإبلاغ عن التعليق: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}