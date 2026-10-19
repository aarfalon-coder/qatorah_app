import 'package:flutter/foundation.dart';
import 'package:qatorah_app/models/transaction_model.dart';

class PaymentManager extends ChangeNotifier {
  double _balance = 50.00; // رصيد مبدئي للتجربة
  final int _points = 120;
  final List<TransactionModel> _transactions = [];

  double get balance => _balance;
  int get points => _points;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  PaymentManager() {
    _seedMockData(); // تحميل بيانات وهمية للتجربة
  }

  void _seedMockData() {
    _transactions.addAll([
      TransactionModel(
        id: 'TXN-001',
        userId: 'user_1',
        type: 'payment',
        amount: 5.5,
        paymentMethod: 'wallet',
        status: 'completed',
        description: 'طلب توصيل أسطوانة غاز',
        referenceId: 'ORD-992',
        balanceBefore: 55.5,
        balanceAfter: 50.0,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      TransactionModel(
        id: 'TXN-002',
        userId: 'user_1',
        type: 'refund',
        amount: 2.0,
        paymentMethod: 'wallet',
        status: 'completed',
        description: 'استرداد مبلغ إعلان مرفوض',
        referenceId: 'AD-112',
        balanceBefore: 48.0,
        balanceAfter: 50.0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
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
      userId: 'user_1', 
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
    notifyListeners(); // تحديث الشاشات فوراً
    return true;
  }

  Future<void> rechargeBalance(double amount) async {
    final double before = _balance;
    _balance += amount;
    
    final txn = TransactionModel(
      id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_1',
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
    notifyListeners();
  }
}