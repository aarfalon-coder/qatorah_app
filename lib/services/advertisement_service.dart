import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/advertisement_model.dart';
import '../models/region_model.dart';

// ✅ تم حذف kMockProviderId و kMockAdminId تماماً لأنهما غير مستخدمين

class AdvertisementService {
  AdvertisementService._internal();
  static final AdvertisementService instance = AdvertisementService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'advertisements';

  // ═══ عمليات القراءة (Firebase) ═══
  Future<List<AdvertisementModel>> fetchAll() async {
    final snapshot = await _db.collection(_collection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AdvertisementModel.fromMap(data);
    }).toList();
  }

  Future<List<AdvertisementModel>> fetchByPublisher(String publisherId) async {
    final snapshot = await _db.collection(_collection)
        .where('publisher.userId', isEqualTo: publisherId)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AdvertisementModel.fromMap(data);
    }).toList();
  }

  Future<List<AdvertisementModel>> fetchVisibleTo(Governorate? gov) async {
    final all = await fetchAll();
    return all
        .where((a) => a.isDisplayable && a.visibleTo(gov))
        .toList()
      ..sort((a, b) => a.sortPriority.compareTo(b.sortPriority));
  }

  Future<List<AdvertisementModel>> fetchTickerFor(Governorate? gov) async {
    final all = await fetchAll();
    return all
        .where((a) => a.isDisplayable && a.eligibleForTicker && a.visibleTo(gov))
        .toList()
      ..sort((a, b) => a.sortPriority.compareTo(b.sortPriority));
  }

  Future<List<AdvertisementModel>> fetchPendingReview() async {
    final snapshot = await _db.collection(_collection)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AdvertisementModel.fromMap(data);
    }).toList();
  }

  // ═══ عمليات الكتابة (Firebase) ═══
  Future<AdvertisementModel> create(AdvertisementModel ad) async {
    final docRef = _db.collection(_collection).doc();
    final newAd = AdvertisementModel(
      id: docRef.id,
      publisher: ad.publisher,
      title: ad.title,
      description: ad.description,
      images: ad.images,
      category: ad.category,
      type: ad.type,
      scope: ad.scope,
      pricing: ad.pricing,
      region: ad.region,
      coverage: ad.coverage,
      duration: ad.duration,
      status: ad.status,
      moderation: ad.moderation,
      stats: ad.stats,
      visibility: ad.visibility,
      reports: ad.reports,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await docRef.set(newAd.toMap());
    return newAd;
  }

  Future<AdvertisementModel?> update(AdvertisementModel ad) async {
    await _db.collection(_collection).doc(ad.id).set(ad.toMap(), SetOptions(merge: true));
    return ad;
  }

  Future<bool> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
    return true;
  }

  Future<void> incrementView(String id) async {
    await _db.collection(_collection).doc(id).update({
      'stats.views': FieldValue.increment(1),
    });
  }

  Future<void> incrementClick(String id) async {
    await _db.collection(_collection).doc(id).update({
      'stats.clicks': FieldValue.increment(1),
    });
  }

  Future<void> addReport(String id, String reason) async {
    await _db.collection(_collection).doc(id).update({
      'reports.count': FieldValue.increment(1),
      'reports.reasons': FieldValue.arrayUnion([reason]),
    });
  }
}