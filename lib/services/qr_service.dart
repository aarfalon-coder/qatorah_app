import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// خدمة معالجة رموز QR مربوطـة بـ Firestore
class QrService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ═══ توليد الرموز ═══
  static String generateOrderQr(String orderId) => 'ORD-$orderId';
  static String generateCouponQr(String couponId) => 'CPN-$couponId';
  static String generateUserQr(String userId) => 'USR-$userId';

  // ═══ التحقق الأساسي ═══
  static bool isValidQrCode(String code) =>
      code.isNotEmpty && code.length >= 5;

  static String getQrType(String code) {
    if (code.startsWith('ORD-') || code.startsWith('ord_')) return 'order';
    if (code.startsWith('CPN-') || code.startsWith('cpn_')) return 'coupon';
    if (code.startsWith('USR-') || code.startsWith('usr_')) return 'user';
    if (code.startsWith('DEL-') || code.startsWith('del_')) return 'delivery';
    return 'unknown';
  }

  static String extractId(String code) {
    final idx = code.indexOf('-');
    if (idx > 0) return code.substring(idx + 1);
    return code;
  }

  // ═══ معالجة الطلب (التحقق الحقيقي) ═══
  static Future<Map<String, dynamic>> processOrderQr(String code) async {
    try {
      final orderId = extractId(code);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return {'valid': false, 'message': 'المستخدم غير مسجل الدخول'};
      }

      final doc = await _db.collection('orders').doc(orderId).get();
      if (!doc.exists) {
        return {'valid': false, 'message': 'الطلب غير موجود'};
      }

      final data = doc.data()!;
      final status = (data['status'] ?? 'pending').toString();
      final providerId = data['providerId']?.toString();

      if (status == 'completed' || status == 'paid') {
        return {
          'valid': false,
          'message': 'هذا الطلب مكتمل مسبقاً',
          'order': data,
        };
      }

      // ✅ تحقق: المزود لازم يكون صاحب الطلب
      if (providerId != null && providerId.isNotEmpty && providerId != uid) {
        return {
          'valid': false,
          'message': 'هذا الطلب لا يخصك',
        };
      }

      return {
        'valid': true,
        'type': 'order',
        'orderId': orderId,
        'amount': (data['amount'] ?? data['price'] ?? 0).toDouble(),
        'customerId': data['customerId']?.toString(),
        'providerId': providerId,
        'order': data,
      };
    } catch (e) {
      debugPrint('❌ فشل معالجة الطلب: $e');
      return {'valid': false, 'message': 'حدث خطأ: $e'};
    }
  }

  // ═══ معالجة الكوبون ═══
  static Future<Map<String, dynamic>> processCouponQr(String code) async {
    try {
      final couponId = extractId(code);
      final doc = await _db.collection('coupons').doc(couponId).get();
      if (!doc.exists) {
        return {'valid': false, 'message': 'الكوبون غير موجود'};
      }
      final data = doc.data()!;
      if (data['isUsed'] == true) {
        return {'valid': false, 'message': 'الكوبون مستخدم مسبقاً'};
      }
      return {
        'valid': true,
        'type': 'coupon',
        'couponId': couponId,
        'discount': (data['discount'] ?? 0).toDouble(),
        'coupon': data,
      };
    } catch (e) {
      return {'valid': false, 'message': 'خطأ في الكوبون: $e'};
    }
  }

  // ═══ معالجة هوية العميل ═══
  static Future<Map<String, dynamic>> processUserQr(String code) async {
    try {
      final userId = extractId(code);
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) {
        return {'valid': false, 'message': 'العميل غير موجود'};
      }
      return {
        'valid': true,
        'type': 'user',
        'userId': userId,
        'user': doc.data(),
      };
    } catch (e) {
      return {'valid': false, 'message': 'خطأ في العميل: $e'};
    }
  }

  // ═══ المعالج الرئيسي ═══
  static Future<Map<String, dynamic>> processQrCode(String code) async {
    if (!isValidQrCode(code)) {
      return {'valid': false, 'message': 'رمز غير صالح'};
    }
    switch (getQrType(code)) {
      case 'order':
        return processOrderQr(code);
      case 'coupon':
        return processCouponQr(code);
      case 'user':
        return processUserQr(code);
      default:
        return {'valid': false, 'message': 'نوع الرمز غير معروف'};
    }
  }
}