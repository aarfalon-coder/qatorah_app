import 'package:flutter/foundation.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // ═══ Getters ═══
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null || AuthManager.isLoggedIn;
  UserRole get role => _currentUser?.role ?? AuthManager.role;
  bool get isProvider => _currentUser?.isProvider ?? AuthManager.isProvider;
  bool get isSuperAdmin =>
      _currentUser?.isSuperAdmin ?? AuthManager.isSuperAdmin;

  // ═══ تسجيل دخول عادي ═══
  Future<bool> login({
    required String firstName,
    required String phone,
    required UserRole role,
    String? id,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // محاكاة اتصال Firebase (سيتم استبداله لاحقاً)
      await Future.delayed(const Duration(milliseconds: 500));

      AuthManager.login(
        firstName: firstName,
        phone: phone,
        role: role,
      );

      _currentUser = UserModel(
        id: id ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
        firstName: firstName,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل تسجيل الدخول: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ═══ تسجيل دخول كمزود ═══
  Future<bool> loginAsProvider({
    required String firstName,
    required String phone,
    required String serviceType,
    UserRole role = UserRole.stationOwner,
    String? id,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      AuthManager.loginAsProvider(
        firstName: firstName,
        phone: phone,
        serviceType: serviceType,
        role: role,
      );

      _currentUser = UserModel(
        id: id ?? 'provider_${DateTime.now().millisecondsSinceEpoch}',
        firstName: firstName,
        phone: phone,
        role: role,
        isProvider: true,
        providerServiceType: serviceType,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل تسجيل دخول المزود: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ═══ تسجيل دخول كأدمن ═══
  Future<bool> loginAsSuperAdmin(
      {int level = AuthManager.levelSuperAdmin}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      AuthManager.loginAsSuperAdmin(level: level);

      _currentUser = UserModel(
        id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
        firstName: 'المدير العام',
        phone: '', // ✅ تم التعديل: إزالة الرقم الوهمي
        role: UserRole.customer,
        isSuperAdmin: true,
        adminLevel: level,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل تسجيل دخول الأدمن: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ═══ تسجيل خروج ═══
  Future<void> logout() async {
    await AuthManager.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ═══ تحديث الملف الشخصي ═══
  void updateProfile({
    String? firstName,
    String? phone,
    String? email,
    String? profileImageUrl,
  }) {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      firstName: firstName,
      phone: phone,
      email: email,
      profileImageUrl: profileImageUrl,
    );

    AuthManager.firstName = _currentUser!.firstName;
    AuthManager.phone = _currentUser!.phone;

    notifyListeners();
  }

  // ═══ تحديث الرصيد ═══
  void updateWalletBalance(double newBalance) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(walletBalance: newBalance);
    notifyListeners();
  }

  // ═══ إضافة نقاط ولاء ═══
  void addLoyaltyPoints(int points) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      loyaltyPoints: _currentUser!.loyaltyPoints + points,
    );
    notifyListeners();
  }

  // ═══ مسح الأخطاء ═══
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
