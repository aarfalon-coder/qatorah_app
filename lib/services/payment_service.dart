import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createPaymentRequest({
    required String customerId,
    required String? beneficiaryId,
    required String serviceType,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      debugPrint('📝 إنشاء طلب دفع في Firestore للعميل: $customerId');
      
      final commission = amount * 0.05;
      final providerPayout = amount - commission;

      final docRef = await _db.collection('payment_requests').add({
        'customerId': customerId,
        'beneficiaryId': beneficiaryId,
        'serviceType': serviceType,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'commission': commission,
        'providerPayout': providerPayout,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': null,
        'providerId': null,
      });

      debugPrint('✅ تم إنشاء طلب الدفع بنجاح! ID: ${docRef.id}');
      return docRef.id;
      
    } catch (e) {
      debugPrint('❌ فشل إنشاء طلب الدفع!');
      debugPrint('   الخطأ: $e');
      throw Exception('فشل إنشاء طلب الدفع: $e');
    }
  }

  Future<Map<String, dynamic>?> getPaymentRequestDetails(String requestId) async {
    try {
      final doc = await _db.collection('payment_requests').doc(requestId).get();
      if (!doc.exists) {
        throw Exception('طلب الدفع غير موجود');
      }
      
      final data = doc.data()!;
      if (data['status'] != 'pending') {
        throw Exception('هذا الكود تم استخدامه مسبقاً أو ملغي');
      }
      
      return {
        'requestId': doc.id,
        ...data,
      };
    } catch (e) {
      debugPrint('❌ فشل جلب تفاصيل الطلب: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> cancelPaymentRequest(String requestId) async {
    try {
      await _db.collection('payment_requests').doc(requestId).update({
        'status': 'cancelled',
        'completedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ تم إلغاء طلب الدفع: $requestId');
    } catch (e) {
      debugPrint('❌ فشل إلغاء طلب الدفع: $e');
      throw Exception('فشل إلغاء طلب الدفع: $e');
    }
  }

  Future<void> completePaymentTransaction({
    required String requestId,
    required String providerId,
  }) async {
    try {
      final requestRef = _db.collection('payment_requests').doc(requestId);

      await _db.runTransaction((transaction) async {
        final requestSnap = await transaction.get(requestRef);
        if (!requestSnap.exists) {
          throw Exception('طلب الدفع غير موجود');
        }

        final requestData = requestSnap.data()!;
        if (requestData['status'] != 'pending') {
          throw Exception('تم استخدام هذا الكود مسبقاً (محترق) أو ملغي');
        }

        final customerId = requestData['customerId'] as String;
        final amount = (requestData['amount'] as num).toDouble();
        final commission = (requestData['commission'] as num).toDouble();
        final providerPayout = (requestData['providerPayout'] as num).toDouble();
        final paymentMethod = requestData['paymentMethod'] as String;

        // 1. حرق الكود فوراً لمنع الاستخدام المزدوج
        transaction.update(requestRef, {
          'status': 'completed',
          'providerId': providerId,
          'completedAt': FieldValue.serverTimestamp(),
        });

        // 2. معالجة الأرصدة بأمان
        if (paymentMethod == 'wallet') {
          final customerRef = _db.collection('users').doc(customerId);
          final customerSnap = await transaction.get(customerRef);
          final currentBalance = (customerSnap.data()?['walletBalance'] ?? 0.0) as double;
          
          if (currentBalance < amount) {
            throw Exception('رصيد العميل غير كافٍ');
          }

          transaction.update(customerRef, {
            'walletBalance': FieldValue.increment(-amount),
          });

          transaction.update(_db.collection('users').doc(providerId), {
            'walletBalance': FieldValue.increment(providerPayout),
          });
        } else if (paymentMethod == 'cash') {
          final providerRef = _db.collection('users').doc(providerId);
          final providerSnap = await transaction.get(providerRef);
          final creditBalance = (providerSnap.data()?['creditBalance'] ?? 0.0) as double;

          if (creditBalance < commission) {
            throw Exception('رصيد الاستخدام لدى الموزع غير كافٍ لخصم العمولة');
          }

          transaction.update(providerRef, {
            'creditBalance': FieldValue.increment(-commission),
            'walletBalance': FieldValue.increment(providerPayout),
          });
        }

        // 3. تسجيل المعاملة في السجل
        transaction.set(_db.collection('transactions').doc(), {
          'requestId': requestId,
          'customerId': customerId,
          'providerId': providerId,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'commission': commission,
          'providerPayout': providerPayout,
          'type': 'qr_payment',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      debugPrint('✅ تم إتمام عملية الدفع وحرق الكود: $requestId');
    } catch (e) {
      debugPrint('❌ فشل إتمام المعاملة: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}