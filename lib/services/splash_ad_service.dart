import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:qatorah_app/models/splash_ad_model.dart';

/// ═══════════════════════════════════════════════════════════
///  SplashAdService — إدارة إعلانات الاستضافة
/// ═══════════════════════════════════════════════════════════

class SplashAdService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'splash_ads';

  // ═══ إنشاء إعلان جديد ═══
  Future<String> createAd(SplashAdModel ad) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(ad.toMap());
      debugPrint('✅ تم إنشاء الإعلان: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ فشل إنشاء الإعلان: $e');
      throw Exception('فشل إنشاء الإعلان: $e');
    }
  }

  // ═══ جلب كل الإعلانات ═══
  Stream<List<SplashAdModel>> getAllAds() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SplashAdModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ═══ جلب الإعلان النشط (حسب المنطقة والنوع) ═══
  Future<SplashAdModel?> getActiveAd({
    String? userRegion,
    String? userType,
  }) async {
    try {
      final now = DateTime.now();

      // 1. جلب الإعلانات النشطة
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      if (snapshot.docs.isEmpty) return null;

      // 2. فلترة حسب المنطقة والنوع
      final filtered = snapshot.docs.where((doc) {
        final data = doc.data();

        // فحص المنطقة
        final regions = List<String>.from(data['targetRegions'] ?? []);
        if (userRegion != null &&
            regions.isNotEmpty &&
            !regions.contains(userRegion)) {
          return false;
        }

        // فحص النوع
        final types = List<String>.from(data['targetUserTypes'] ?? []);
        if (userType != null &&
            types.isNotEmpty &&
            !types.contains(userType)) {
          return false;
        }

        // فحص الحد الأقصى
        final max = data['maxImpressions'] ?? 0;
        final current = data['currentImpressions'] ?? 0;
        if (max > 0 && current >= max) return false;

        return true;
      }).toList();

      if (filtered.isEmpty) return null;

      // 3. اختيار عشوائي
      filtered.shuffle();
      final selected = filtered.first;

      return SplashAdModel.fromMap(selected.data(), selected.id);
    } catch (e) {
      debugPrint('❌ فشل جلب الإعلان: $e');
      return null;
    }
  }

  // ═══ تحديث إعلان ═══
  Future<void> updateAd(SplashAdModel ad) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(ad.id)
          .update(ad.toMap());
      debugPrint('✅ تم تحديث الإعلان: ${ad.id}');
    } catch (e) {
      debugPrint('❌ فشل تحديث الإعلان: $e');
      throw Exception('فشل تحديث الإعلان: $e');
    }
  }

  // ═══ حذف إعلان ═══
  Future<void> deleteAd(String adId) async {
    try {
      await _firestore.collection(_collection).doc(adId).delete();
      debugPrint('✅ تم حذف الإعلان: $adId');
    } catch (e) {
      debugPrint('❌ فشل حذف الإعلان: $e');
      throw Exception('فشل حذف الإعلان: $e');
    }
  }

  // ═══ تفعيل / إيقاف ═══
  Future<void> toggleAd(String adId, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(adId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ تم ${isActive ? "تفعيل" : "إيقاف"} الإعلان');
    } catch (e) {
      debugPrint('❌ فشل التعديل: $e');
    }
  }

  // ═══ زيادة المشاهدات ═══
  Future<void> incrementImpression(String adId) async {
    try {
      await _firestore.collection(_collection).doc(adId).update({
        'currentImpressions': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('❌ فشل زيادة المشاهدات: $e');
    }
  }

  // ═══ زيادة الضغطات ═══
  Future<void> incrementClick(String adId) async {
    try {
      await _firestore.collection(_collection).doc(adId).update({
        'clicks': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('❌ فشل زيادة الضغطات: $e');
    }
  }

  // ═══ إحصائيات ═══
  Future<Map<String, dynamic>> getStats() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final ads = snapshot.docs
          .map((doc) => SplashAdModel.fromMap(doc.data(), doc.id))
          .toList();

      final activeAds = ads.where((a) => a.isCurrentlyActive).length;
      final totalImpressions =
          ads.fold<int>(0, (acc, a) => acc + a.currentImpressions);
      final totalClicks = ads.fold<int>(0, (acc, a) => acc + a.clicks);

      return {
        'total': ads.length,
        'active': activeAds,
        'impressions': totalImpressions,
        'clicks': totalClicks,
      };
    } catch (e) {
      debugPrint('❌ فشل جلب الإحصائيات: $e');
      return {'total': 0, 'active': 0, 'impressions': 0, 'clicks': 0};
    }
  }
}