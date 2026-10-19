import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole {
  customer,
  stationOwner,
  factory,
  driver,
  tanker,
  stationTechnician,
  plumber,
}

class AuthManager extends ChangeNotifier {
  // ═══ حالة المصادقة ═══
  static bool isLoggedIn = false;
  static bool isSuperAdmin = false;

  // ═══ نظام الصلاحيات الهرمي (5 مستويات) ═══
  static int adminLevel = 0;

  // ═══ بيانات المستخدم ═══
  static String firstName = '';
  static String phone = '';
  static UserRole role = UserRole.customer;

  // ═══ بيانات مزود الخدمة ═══
  static bool isProvider = false;
  static String providerServiceType = '';

  // ═══ Firebase UID ═══
  static String? firebaseUid;

  // ═══ ثوابت مستويات الصلاحيات ═══
  static const int LEVEL_NONE = 0;
  static const int LEVEL_VIEWER = 1;
  static const int LEVEL_SUPPORT = 2;
  static const int LEVEL_MODERATOR = 3;
  static const int LEVEL_MANAGER = 4;
  static const int LEVEL_SUPER_ADMIN = 5;

  // ═══ التحقق من الصلاحيات ═══
  static bool get canViewDashboard => adminLevel >= LEVEL_VIEWER;
  static bool get canManageUsers => adminLevel >= LEVEL_MANAGER;
  static bool get canReviewAds => adminLevel >= LEVEL_MODERATOR;
  static bool get canHandleTickets => adminLevel >= LEVEL_SUPPORT;
  static bool get canManagePayments => adminLevel >= LEVEL_MANAGER;
  static bool get canBanUsers => adminLevel >= LEVEL_MODERATOR;
  static bool get canDeleteContent => adminLevel >= LEVEL_MANAGER;
  static bool get canManageAdmins => adminLevel >= LEVEL_SUPER_ADMIN;
  static bool get hasFullAccess => adminLevel >= LEVEL_SUPER_ADMIN;

  static String get adminLevelName {
    switch (adminLevel) {
      case LEVEL_VIEWER: return 'مشاهد';
      case LEVEL_SUPPORT: return 'دعم فني';
      case LEVEL_MODERATOR: return 'مشرف';
      case LEVEL_MANAGER: return 'مدير';
      case LEVEL_SUPER_ADMIN: return 'سوبر أدمن';
      default: return 'مستخدم عادي';
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

  // ═══ تسجيل دخول كمستخدم عادي ═══
  static Future<void> login({
    required String firstName,
    required String phone,
    required UserRole role,
    String? firebaseUid,
  }) async {
    isLoggedIn = true;
    isSuperAdmin = false;
    adminLevel = LEVEL_NONE;
    AuthManager.firstName = firstName;
    AuthManager.phone = phone;
    AuthManager.role = role;
    AuthManager.firebaseUid = firebaseUid;
    isProvider = false;
    providerServiceType = '';
    await saveSession();
  }

  // ═══ تسجيل دخول كمزود خدمة ═══
  static Future<void> loginAsProvider({
    required String firstName,
    required String phone,
    required String serviceType,
    String? firebaseUid,
  }) async {
    isLoggedIn = true;
    isSuperAdmin = false;
    adminLevel = LEVEL_NONE;
    AuthManager.firstName = firstName;
    AuthManager.phone = phone;
    role = UserRole.stationOwner;
    AuthManager.firebaseUid = firebaseUid;
    isProvider = true;
    providerServiceType = serviceType;
    await saveSession();
  }

  // ═══ تسجيل الدخول كأدمن ═══
  static Future<void> loginAsSuperAdmin({int level = LEVEL_SUPER_ADMIN}) async {
    isLoggedIn = true;
    isSuperAdmin = true;
    adminLevel = level;
    firstName = 'المدير العام';
    phone = '000000000';
    role = UserRole.customer;
    isProvider = false;
    providerServiceType = '';
    await saveSession();
  }

  // ═══ تغيير مستوى الصلاحية ═══
  static void updateAdminLevel(int newLevel) {
    if (adminLevel == LEVEL_SUPER_ADMIN || newLevel <= adminLevel) {
      adminLevel = newLevel;
    }
  }

  // ═══ حفظ الجلسة ═══
  static Future<void> saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', isLoggedIn);
      await prefs.setBool('is_super_admin', isSuperAdmin);
      await prefs.setInt('admin_level', adminLevel);
      await prefs.setString('first_name', firstName);
      await prefs.setString('phone', phone);
      await prefs.setString('role', role.name);
      await prefs.setBool('is_provider', isProvider);
      await prefs.setString('provider_service_type', providerServiceType);
      if (firebaseUid != null) {
        await prefs.setString('firebase_uid', firebaseUid!);
      }
      debugPrint('✅ تم حفظ الجلسة');
    } catch (e) {
      debugPrint('❌ فشل حفظ الجلسة: $e');
    }
  }

  // ═══ تحميل الجلسة ═══
  static Future<bool> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedIn = prefs.getBool('is_logged_in') ?? false;
      if (!loggedIn) {
        debugPrint('ℹ️ لا توجد جلسة محفوظة');
        return false;
      }
      isLoggedIn = true;
      isSuperAdmin = prefs.getBool('is_super_admin') ?? false;
      adminLevel = prefs.getInt('admin_level') ?? 0;
      firstName = prefs.getString('first_name') ?? '';
      phone = prefs.getString('phone') ?? '';
      role = _parseRole(prefs.getString('role') ?? 'customer');
      isProvider = prefs.getBool('is_provider') ?? false;
      providerServiceType = prefs.getString('provider_service_type') ?? '';
      firebaseUid = prefs.getString('firebase_uid');
      debugPrint('✅ تم تحميل الجلسة: $firstName ($role)');
      return true;
    } catch (e) {
      debugPrint('❌ فشل تحميل الجلسة: $e');
      return false;
    }
  }

  // ═══ تسجيل الخروج ═══
  static Future<void> logout() async {
    isLoggedIn = false;
    isSuperAdmin = false;
    adminLevel = LEVEL_NONE;
    firstName = '';
    phone = '';
    role = UserRole.customer;
    isProvider = false;
    providerServiceType = '';
    firebaseUid = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('✅ تم مسح الجلسة');
    } catch (e) {
      debugPrint('❌ فشل مسح الجلسة: $e');
    }
  }

  // ═══ تحويل String → UserRole ═══
  static UserRole _parseRole(String roleStr) {
    switch (roleStr) {
      case 'stationOwner': return UserRole.stationOwner;
      case 'factory': return UserRole.factory;
      case 'driver': return UserRole.driver;
      case 'tanker': return UserRole.tanker;
      case 'stationTechnician': return UserRole.stationTechnician;
      case 'plumber': return UserRole.plumber;
      default: return UserRole.customer;
    }
  }
}