import 'package:flutter/foundation.dart';
import 'package:qatorah_app/models/subscription_model.dart';

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionModel? _currentSubscription;
  List<SubscriptionModel> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ═══ Getters ═══
  SubscriptionModel? get currentSubscription => _currentSubscription;
  List<SubscriptionModel> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasActiveSubscription => _currentSubscription?.isActive ?? false;
  int get daysRemaining => _currentSubscription?.daysRemaining ?? 0;
  int get adsRemaining => _currentSubscription?.adsRemaining ?? 0;

  // ═══ تعيين الاشتراك الحالي ═══
  void setSubscription(SubscriptionModel subscription) {
    _currentSubscription = subscription;
    notifyListeners();
  }

  // ═══ إنشاء اشتراك جديد ═══
  Future<bool> subscribe({
    required String userId,
    required String userName,
    required SubscriptionPlan plan,
    String paymentMethod = 'wallet',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final planData = SubscriptionModel.planPrices[plan]!;
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: planData['days'] as int));

      final subscription = SubscriptionModel(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        userName: userName,
        plan: plan,
        status: SubscriptionStatus.active,
        price: planData['price'] as double,
        startDate: startDate,
        endDate: endDate,
        adsLimit: planData['ads'] as int,
        hasPrioritySupport: plan != SubscriptionPlan.free,
        hasVerifiedBadge: plan != SubscriptionPlan.free,
        hasAdvancedStats: plan == SubscriptionPlan.quarterly || plan == SubscriptionPlan.yearly,
        paymentMethod: paymentMethod,
        isPaid: true,
        createdAt: DateTime.now(),
      );

      _currentSubscription = subscription;
      _history.insert(0, subscription);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل الاشتراك: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ═══ تجديد الاشتراك ═══
  Future<bool> renewSubscription() async {
    if (_currentSubscription == null) return false;

    return subscribe(
      userId: _currentSubscription!.userId,
      userName: _currentSubscription!.userName,
      plan: _currentSubscription!.plan,
      paymentMethod: _currentSubscription!.paymentMethod,
    );
  }

  // ═══ إلغاء الاشتراك ═══
  Future<bool> cancelSubscription(String reason) async {
    if (_currentSubscription == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _currentSubscription = _currentSubscription!.copyWith(
        status: SubscriptionStatus.cancelled,
        cancelledAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل إلغاء الاشتراك: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ═══ استخدام إعلان ═══
  bool useAdSlot() {
    if (_currentSubscription == null) return false;
    if (!_currentSubscription!.isActive) return false;
    if (_currentSubscription!.adsRemaining <= 0 && _currentSubscription!.adsLimit > 0) return false;

    _currentSubscription = _currentSubscription!.copyWith(
      adsUsed: _currentSubscription!.adsUsed + 1,
    );
    notifyListeners();
    return true;
  }

  // ═══ إحصائيات ═══
  Map<String, dynamic> getStats() {
    if (_currentSubscription == null) {
      return {'plan': 'لا يوجد', 'daysRemaining': 0, 'adsRemaining': 0};
    }
    return {
      'plan': _currentSubscription!.planName,
      'daysRemaining': _currentSubscription!.daysRemaining,
      'adsRemaining': _currentSubscription!.adsRemaining,
      'status': _currentSubscription!.statusName,
    };
  }

  // ═══ مسح الأخطاء ═══
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ═══ خروج ═══
  void logout() {
    _currentSubscription = null;
    _history = [];
    _errorMessage = null;
    notifyListeners();
  }
}