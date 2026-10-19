import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:qatorah_app/models/transaction_model.dart';
import 'package:qatorah_app/services/commission_service.dart';

/// خدمة الدفع والمحاسبة المربوطة بـ Firestore
class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ إتمام عملية دفع (Atomic Transaction)
  /// - يحدّث حالة الطلب
  /// - يحسب العمولة 5%
  /// - يسجّل الحركة في transactions
  /// - يسجّل العمولة في commissions
  Future<TransactionModel?> completeOrderPayment({
    required String orderId,
    required String providerId,
    required String customerId,
    required double amount,
    String paymentMethod = 'cash_qr',
  }) async {
    try {
      final orderRef = _db.collection('orders').doc(orderId);
      final txRef = _db.collection('transactions').doc();

      final calc = CommissionService.calculate(amount);

      await _db.runTransaction((transaction) async {
        final orderSnap = await transaction.get(orderRef);
        if (!orderSnap.exists) {
          throw 'الطلب غير موجود';
        }
        final data = orderSnap.data()!;
        if ((data['status'] ?? '').toString() == 'completed') {
          throw 'هذا الطلب مكتمل مسبقاً';
        }

        // 1. تحديث حالة الطلب
        transaction.update(orderRef, {
          'status': 'completed',
          'paymentMethod': paymentMethod,
          'commission': calc.commission,
          'providerNet': calc.providerNet,
          'completedAt': FieldValue.serverTimestamp(),
        });

        // 2. تسجيل الحركة المالية
        transaction.set(txRef, {
          'userId': customerId,
          'type': 'payment',
          'amount': amount,
          'paymentMethod': paymentMethod,
          'status': 'completed',
          'description': 'دفع طلب $orderId',
          'orderId': orderId,
          'customerId': customerId,
          'providerId': providerId,
          'commission': calc.commission,
          'providerNet': calc.providerNet,
          'balanceBefore': 0.0,
          'balanceAfter': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      // 3. تسجيل العمولة (منفصل عشان الشفافية)
      await CommissionService().logCommission(
        orderId: orderId,
        customerId: customerId,
        providerId: providerId,
        amount: amount,
        commission: calc.commission,
        providerNet: calc.providerNet,
      );

      debugPrint('✅ تم إتمام الدفع. عمولة: ${calc.commission}, صافي المزود: ${calc.providerNet}');

      return TransactionModel(
        id: txRef.id,
        userId: customerId,
        type: 'payment',
        amount: amount,
        paymentMethod: paymentMethod,
        status: 'completed',
        description: 'دفع طلب $orderId',
        orderId: orderId,
        customerId: customerId,
        providerId: providerId,
        commission: calc.commission,
        providerNet: calc.providerNet,
        balanceBefore: 0.0,
        balanceAfter: 0.0,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ فشل الدفع: $e');
      return null;
    }
  }

  /// جلب سجل معاملات المستخدم
  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    final snap = await _db
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => TransactionModel.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }
}