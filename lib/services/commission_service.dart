import 'package:cloud_firestore/cloud_firestore.dart';

/// خدمة حساب وتسجيل عمولة 5% في Firestore
class CommissionService {
  static const double commissionRate = 0.05; // 5%

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// حساب العمولة والصافي
  static ({double commission, double providerNet}) calculate(double amount) {
    final commission = amount * commissionRate;
    final providerNet = amount - commission;
    return (commission: commission, providerNet: providerNet);
  }

  /// تسجيل العمولة في collection منفصل (سجل شفاف للأدمن)
  Future<void> logCommission({
    required String orderId,
    required String customerId,
    required String providerId,
    required double amount,
    required double commission,
    required double providerNet,
  }) async {
    await _db.collection('commissions').doc(orderId).set({
      'orderId': orderId,
      'customerId': customerId,
      'providerId': providerId,
      'amount': amount,
      'commission': commission,
      'providerNet': providerNet,
      'rate': commissionRate,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}