import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_manager.dart';

// ✅ تم تحديث قائمة الأدوار لتطابق النظام الجديد تماماً
enum UserRole {
  customer,
  stationOwner,
  factoryOwner,
  tankerDriver,
  distributionDriver,
  stationTechnician,
  plumber,
  electrician,
  partsProvider,
  gasSupplier, // تمت الإضافة لضمان شمولية الـ Enum
}

class AuthManager extends ChangeNotifier {
  static bool isLoggedIn = false;
  static bool isSuperAdmin = false;
  static bool isGuest = true;
  static int adminLevel = 0;

  static String firstName = '';
  static String phone = '';
  static UserRole role = UserRole.customer;

  static bool isProvider = false;
  static String providerServiceType = '';
  static String? firebaseUid;
  static String currentGovernorateCode = 'amman';

  static bool isSubscriptionActive = true;
  static DateTime? subscriptionExpiryDate;
  static double walletBalance = 0.0;

  static const int levelNone = 0;
  static const int levelViewer = 1;
  static const int levelSupport = 2;
  static const int levelModerator = 3;
  static const int levelManager = 4;
  static const int levelSuperAdmin = 5;

  static bool get canViewDashboard => adminLevel >= levelViewer;
  static bool get canManageUsers => adminLevel >= levelManager;
  static bool get canReviewAds => adminLevel >= levelModerator;
  static bool get canHandleTickets => adminLevel >= levelSupport;
  static bool get canManagePayments => adminLevel >= levelManager;
  static bool get canBanUsers => adminLevel >= levelModerator;
  static bool get canDeleteContent => adminLevel >= levelManager;
  static bool get canManageAdmins => adminLevel >= levelSuperAdmin;
  static bool get hasFullAccess => adminLevel >= levelSuperAdmin;

  static String get adminLevelName {
    switch (adminLevel) {
      case levelViewer:
        return 'مشاهد';
      case levelSupport:
        return 'دعم فني';
      case levelModerator:
        return 'مشرف';
      case levelManager:
        return 'مدير';
      case levelSuperAdmin:
        return 'سوبر أدمن';
      default:
        return 'مستخدم عادي';
    }
  }

  static List<String> get adminPermissions {
    List<String> permissions = [];
    if (canViewDashboard) permissions.add('عرض لوحة التحكم');
    if (canHandleTickets) permissions.add('إدارة التذاكر');
    if (canReviewAds) permissions.add('مراجعة الإعلانات');
    if (canBanUsers) permissions.add('حظر المستخدمين');
    if (canManageUsers) permissions.add('إدارة المستخدمين');
    if (canManagePayments) permissions.add('إدارة المدفوعات');
    if (canDeleteContent) permissions.add('حذف المحتوى');
    if (canManageAdmins) permissions.add('إدارة الأدمنيين');
    return permissions;
  }

  static void setGuestMode(bool guest) {
    isGuest = guest;
  }

  static Future<void> login({
    required String firstName,
    required String phone,
    required UserRole role,
    String? firebaseUid,
    String? governorateCode,
    int? adminLevelParam,
  }) async {
    isLoggedIn = true;
    isGuest = false;
    adminLevel = adminLevelParam ?? levelNone;
    isSuperAdmin = adminLevel >= levelSuperAdmin;

    AuthManager.firstName = firstName;
    AuthManager.phone = phone;
    AuthManager.role = role;
    AuthManager.firebaseUid = firebaseUid;
    AuthManager.currentGovernorateCode = governorateCode ?? 'amman';
    isProvider = false;
    providerServiceType = '';
    isSubscriptionActive = true;
    subscriptionExpiryDate = null;
    walletBalance = 0.0;

    try {
      final profileManager = ProfileManager();
      await profileManager.syncWithAuth();
    } catch (_) {}
    await saveSession();
  }

  static Future<void> loginAsProvider({
    required String firstName,
    required String phone,
    required String serviceType,
    UserRole role = UserRole.stationOwner,
    String? firebaseUid,
  }) async {
    isLoggedIn = true;
    isGuest = false;
    isSuperAdmin = false;
    adminLevel = levelNone;
    AuthManager.firstName = firstName;
    AuthManager.phone = phone;
    AuthManager.role = role;
    AuthManager.firebaseUid = firebaseUid;
    isProvider = true;
    providerServiceType = serviceType;
    isSubscriptionActive = true;
    subscriptionExpiryDate = null;
    walletBalance = 0.0;

    try {
      final profileManager = ProfileManager();
      await profileManager.syncWithAuth();
    } catch (_) {}
    await saveSession();
  }

  static Future<void> loginAsSuperAdmin({int level = levelSuperAdmin}) async {
    isLoggedIn = true;
    isGuest = false;
    adminLevel = level.clamp(levelViewer, levelSuperAdmin).toInt();
    isSuperAdmin = adminLevel >= levelSuperAdmin;
    firstName = 'المدير العام';
    phone = '';
    role = UserRole.customer;
    isProvider = false;
    providerServiceType = '';
    isSubscriptionActive = true;
    subscriptionExpiryDate = null;
    walletBalance = 0.0;
    isProvider = false;
    providerServiceType = '';

    try {
      final profileManager = ProfileManager();
      await profileManager.syncWithAuth();
    } catch (_) {}
    await saveSession();
  }

  static void updateAdminLevel(int newLevel) {
    if (adminLevel == levelSuperAdmin || newLevel <= adminLevel) {
      adminLevel = newLevel;
    }
  }

  static void updateSubscriptionStatus(DateTime? expiryDate, double balance) {
    subscriptionExpiryDate = expiryDate;
    walletBalance = balance;
    if (expiryDate == null) {
      isSubscriptionActive = false;
    } else {
      isSubscriptionActive = expiryDate.isAfter(DateTime.now());
    }
  }

  static void renewSubscription(DateTime newExpiryDate, double newBalance) {
    subscriptionExpiryDate = newExpiryDate;
    walletBalance = newBalance;
    isSubscriptionActive = true;
  }

  static Future<void> saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', isLoggedIn);
      await prefs.setBool('is_guest', isGuest);
      await prefs.setBool('is_super_admin', isSuperAdmin);
      await prefs.setInt('admin_level', adminLevel);
      await prefs.setString('first_name', firstName);
      await prefs.setString('phone', phone);
      await prefs.setString('role', role.name);
      await prefs.setBool('is_provider', isProvider);
      await prefs.setString('provider_service_type', providerServiceType);
      await prefs.setString('governorate_code', currentGovernorateCode);
      if (firebaseUid != null) {
        await prefs.setString('firebase_uid', firebaseUid!);
      } else {
        await prefs.remove('firebase_uid');
      }
      debugPrint('✅ تم حفظ الجلسة (Level: $adminLevel)');
    } catch (e) {
      debugPrint('❌ فشل حفظ الجلسة: $e');
    }
  }

  static Future<bool> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedIn = prefs.getBool('is_logged_in') ?? false;
      if (!loggedIn) {
        isGuest = true;
        debugPrint('ℹ️ لا توجد جلسة محفوظة (زائر)');
        return false;
      }
      isLoggedIn = true;
      isGuest = prefs.getBool('is_guest') ?? false;
      isSuperAdmin = prefs.getBool('is_super_admin') ?? false;
      adminLevel = prefs.getInt('admin_level') ?? 0;
      firstName = prefs.getString('first_name') ?? '';
      phone = prefs.getString('phone') ?? '';
      role = parseRole(prefs.getString('role') ?? 'customer');
      isProvider = prefs.getBool('is_provider') ?? false;
      providerServiceType = prefs.getString('provider_service_type') ?? '';
      currentGovernorateCode = prefs.getString('governorate_code') ?? 'amman';
      firebaseUid = prefs.getString('firebase_uid');
      debugPrint('✅ تم تحميل الجلسة: $firstName (Level: $adminLevel)');
      return true;
    } catch (e) {
      debugPrint('❌ فشل تحميل الجلسة: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    isLoggedIn = false;
    isGuest = true;
    isSuperAdmin = false;
    adminLevel = levelNone;
    firstName = '';
    phone = '';
    role = UserRole.customer;
    isProvider = false;
    providerServiceType = '';
    firebaseUid = null;
    isSubscriptionActive = true;
    subscriptionExpiryDate = null;
    walletBalance = 0.0;
    currentGovernorateCode = 'amman';
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ فشل تسجيل الخروج من Firebase: ${e.code}');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('✅ تم مسح الجلسة');
    } catch (e) {
      debugPrint('❌ فشل مسح الجلسة: $e');
    }
  }

  // ✅ دالة تحويل آمنة 100% تمنع أي انهيار
  static UserRole parseRole(String roleStr) =>
      tryParseRole(roleStr) ?? UserRole.customer;

  static UserRole? tryParseRole(String roleStr) {
    if (roleStr == 'customer') return UserRole.customer;
    if (roleStr == 'stationOwner' || roleStr == 'station_owner') {
      return UserRole.stationOwner;
    }
    if (roleStr == 'factoryOwner' || roleStr == 'factory_owner') {
      return UserRole.factoryOwner;
    }
    if (roleStr == 'tankerDriver' || roleStr == 'tanker_driver') {
      return UserRole.tankerDriver;
    }
    if (roleStr == 'distributionDriver' || roleStr == 'distribution_driver') {
      return UserRole.distributionDriver;
    }
    if (roleStr == 'stationTechnician' || roleStr == 'station_technician') {
      return UserRole.stationTechnician;
    }
    if (roleStr == 'plumber') return UserRole.plumber;
    if (roleStr == 'electrician') return UserRole.electrician;
    if (roleStr == 'partsProvider' || roleStr == 'parts_provider') {
      return UserRole.partsProvider;
    }
    if (roleStr == 'gasSupplier' || roleStr == 'gas_supplier') {
      return UserRole.gasSupplier;
    }
    return null;
  }
}
