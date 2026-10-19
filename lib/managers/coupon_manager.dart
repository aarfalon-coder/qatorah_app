import 'package:flutter/foundation.dart';
import '../models/coupon_model.dart';
// import '../services/firebase_service.dart'; // ??????

/// ═══════════════════════════════════════════════════════════
/// CouponManager — إدارة الكوبونات والدفاتر
/// ═══════════════════════════════════════════════════════════

class CouponManager extends ChangeNotifier {
  // FirebaseService ????? ?????? - ?????? Mock

  // ═══ البيانات المحلية (Mock - لاحقاً من Firestore) ═══
  final List<CouponBookModel> _myBooks = [];
  final List<CouponModel> _myCoupons = [];

  String _customerId = '';
  String _customerName = '';

  bool _isLoading = false;
  String? _error;

  // ═══ Getters ═══
  List<CouponBookModel> get myBooks => List.unmodifiable(_myBooks);
  List<CouponModel> get myCoupons => List.unmodifiable(_myCoupons);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CouponBookModel> get activeBooks =>
      _myBooks.where((b) => b.isActive && !b.isExpired).toList();

  List<CouponBookModel> get expiredBooks =>
      _myBooks.where((b) => !b.isActive || b.isExpired).toList();

  int get totalRemainingCoupons =>
      activeBooks.fold(0, (sum, b) => sum + b.remainingCoupons);

  int get totalCoupons =>
      _myBooks.fold(0, (sum, b) => sum + b.totalCoupons);

  // ═══ تعيين المستخدم الحالي ═══
  void setCustomer(String id, String name) {
    _customerId = id;
    _customerName = name;
    _loadMyCoupons();
  }

  // ═══ تحميل كوبوناتي (Mock) ═══
  Future<void> _loadMyCoupons() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Firebase - لاحقاً نجلب من Firestore
      // الآن: بيانات تجريبية
      if (_myBooks.isEmpty && _customerId.isNotEmpty) {
        _myBooks.addAll(_mockBooks());
      }
      _error = null;
    } catch (e) {
      _error = 'فشل تحميل الكوبونات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══ شراء دفتر كوبونات ═══
  Future<CouponBookModel?> buyCouponBook(CouponBookType bookType) async {
    if (_customerId.isEmpty) {
      _error = 'يجب تسجيل الدخول أولاً';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final bookId = 'BOOK-${now.millisecondsSinceEpoch}';

      // 1. إنشاء الدفتر
      final book = CouponBookModel(
        id: bookId,
        customerId: _customerId,
        customerName: _customerName,
        type: bookType.type,
        totalCoupons: bookType.totalCoupons,
        remainingCoupons: bookType.totalCoupons,
        price: bookType.price,
        purchasedAt: now,
        expiresAt: now.add(Duration(days: bookType.validDays)),
        isActive: true,
      );

      // 2. إنشاء الكوبونات
      for (int i = 1; i <= bookType.totalCoupons; i++) {
        final coupon = CouponModel(
          id: 'CPN-$bookId-$i',
          bookId: bookId,
          customerId: _customerId,
          type: bookType.type,
          value: _couponValue(bookType.type),
          qrCode: 'QR-$bookId-$i-${now.millisecondsSinceEpoch}',
          status: CouponStatus.active,
          createdAt: now,
        );
        _myCoupons.add(coupon);
      }

      // 3. إضافة الدفتر
      _myBooks.insert(0, book);

      // TODO: Firebase - حفظ في Firestore
      // await _firebase.saveCouponBook(book);
      // await _firebase.saveCoupons(coupons);

      _error = null;
      notifyListeners();
      return book;
    } catch (e) {
      _error = 'فشل شراء الدفتر: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double _couponValue(CouponType type) {
    switch (type) {
      case CouponType.water:
        return 1.0; // 1 دينار
      case CouponType.gas:
        return 7.0; // 7 دنانير
      case CouponType.maintenance:
        return 5.0; // 5 دنانير
      case CouponType.mixed:
        return 2.5;
    }
  }

  // ═══ استخدام كوبون (من قبل المحطة) ═══
  Future<bool> useCoupon({
    required String couponId,
    required String stationId,
  }) async {
    final index = _myCoupons.indexWhere((c) => c.id == couponId);
    if (index == -1) {
      _error = 'الكوبون غير موجود';
      notifyListeners();
      return false;
    }

    final coupon = _myCoupons[index];
    if (!coupon.isActive) {
      _error = 'الكوبون مستخدم أو منتهي';
      notifyListeners();
      return false;
    }

    try {
      // 1. تحديث الكوبون
      final used = coupon.copyWith(
        status: CouponStatus.used,
        usedAt: DateTime.now(),
        usedAtStation: stationId,
      );
      _myCoupons[index] = used;

      // 2. خصم من الدفتر
      final bookIndex = _myBooks.indexWhere((b) => b.id == coupon.bookId);
      if (bookIndex != -1) {
        final book = _myBooks[bookIndex];
        final newRemaining = book.remainingCoupons - 1;
        _myBooks[bookIndex] = book.copyWith(
          remainingCoupons: newRemaining,
          isActive: newRemaining > 0,
        );
      }

      // TODO: Firebase - تحديث في Firestore
      // await _firebase.updateCoupon(used);

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل استخدام الكوبون: $e';
      notifyListeners();
      return false;
    }
  }

  // ═══ حذف دفتر (للمرحلة الإدارية) ═══
  Future<bool> deleteBook(String bookId) async {
    try {
      _myBooks.removeWhere((b) => b.id == bookId);
      _myCoupons.removeWhere((c) => c.bookId == bookId);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل حذف الدفتر: $e';
      notifyListeners();
      return false;
    }
  }

  // ═══ تنظيف الأخطاء ═══
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ═══ بيانات تجريبية (Mock) ═══
  List<CouponBookModel> _mockBooks() {
    final now = DateTime.now();
    return [
      CouponBookModel(
        id: 'BOOK-DEMO-001',
        customerId: _customerId,
        customerName: _customerName,
        type: CouponType.water,
        totalCoupons: 10,
        remainingCoupons: 7,
        price: 5.0,
        purchasedAt: now.subtract(const Duration(days: 15)),
        expiresAt: now.add(const Duration(days: 75)),
        isActive: true,
      ),
      CouponBookModel(
        id: 'BOOK-DEMO-002',
        customerId: _customerId,
        customerName: _customerName,
        type: CouponType.gas,
        totalCoupons: 5,
        remainingCoupons: 5,
        price: 35.0,
        purchasedAt: now.subtract(const Duration(days: 3)),
        expiresAt: now.add(const Duration(days: 87)),
        isActive: true,
      ),
    ];
  }

  // ═══ تحقق من وجود دفتر ═══
  bool hasActiveBook(CouponType type) {
    return activeBooks.any((b) => b.type == type && b.canUse);
  }

  // ═══ استخدام كوبون من نوع معين ═══
  CouponModel? getFirstActiveCoupon(CouponType type) {
    try {
      return _myCoupons.firstWhere(
        (c) => c.type == type && c.isActive,
      );
    } catch (_) {
      return null;
    }
  }
}