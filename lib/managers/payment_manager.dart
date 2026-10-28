import 'package:flutter/foundation.dart';
import 'package:qatorah_app/models/transaction_model.dart';

class PaymentManager extends ChangeNotifier {
  double _balance = 0.0; // ✅ تم التعديل: البدء من الصفر
  final int _points = 0;       // ✅ تم التعديل
  String _userId = '';   // ✅ تمت الإضافة: لتخزين معرف المستخدم الحقيقي
  final List<TransactionModel> _transactions = [];

  double get balance => _balance;
  int get points => _points;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  PaymentManager() {
    // ✅ تم حذف _seedMockData() تماماً
  }

  // ✅ دالة جديدة لربط المستخدم الحالي (تُستدعى عند تسجيل الدخول)
  void setUser(String userId) {
    _userId = userId;
    // TODO: هنا سيتم استدعاء دالة جلب الرصيد والحركات من Firestore
    // _loadUserDataFromFirebase();
    notifyListeners();
  }

  Future<bool> processPayment({
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    if (_balance < amount) {
      return false; // رصيد غير كافٍ
    }

    final double before = _balance;
    _balance -= amount;
    
    final txn = TransactionModel(
      id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      userId: _userId.isNotEmpty ? _userId : 'guest', // ✅ استخدام المعرف الحقيقي
      type: 'payment',
      amount: amount,
      paymentMethod: 'wallet',
      status: 'completed',
      description: description,
      referenceId: referenceId,
      balanceBefore: before,
      balanceAfter: _balance,
      createdAt: DateTime.now(),
    );

    _transactions.insert(0, txn);
    
    // TODO: Firebase - حفظ المعاملة وتحديث الرصيد في Firestore
    // await FirebaseService.saveTransaction(txn);
    // await FirebaseService.updateUserBalance(_userId, _balance);

    notifyListeners();
    return true;
  }

  Future<void> rechargeBalance(double amount) async {
    final double before = _balance;
    _balance += amount;
    
    final txn = TransactionModel(
      id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      userId: _userId.isNotEmpty ? _userId : 'guest', // ✅ استخدام المعرف الحقيقي
      type: 'recharge',
      amount: amount,
      paymentMethod: 'card', 
      status: 'completed',
      description: 'شحن رصيد المحفظة',
      balanceBefore: before,
      balanceAfter: _balance,
      createdAt: DateTime.now(),
    );

    _transactions.insert(0, txn);
    
    // TODO: Firebase - حفظ المعاملة وتحديث الرصيد في Firestore

    notifyListeners();
  }
}