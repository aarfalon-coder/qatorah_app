import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/managers/cart_manager.dart';
import 'package:qatorah_app/managers/theme_manager.dart';
import 'package:qatorah_app/managers/profile_manager.dart';
import 'package:qatorah_app/screens/customer/cart_screen.dart';
import 'package:qatorah_app/screens/customer/support_screen.dart';
import 'package:qatorah_app/screens/customer/customer_id_screen.dart';
import 'package:qatorah_app/screens/customer/app_review_screen.dart';
import 'package:qatorah_app/screens/customer/offers_screen.dart';
import 'package:qatorah_app/screens/customer/referral_screen.dart';
import 'package:qatorah_app/screens/customer/terms_screen.dart';
import 'package:qatorah_app/screens/auth/login_screen.dart';
import 'package:qatorah_app/screens/auth/register_screen.dart';
import 'package:qatorah_app/screens/settings/customize_screen.dart';
import 'package:qatorah_app/screens/settings/profile_settings_screen.dart';
import 'package:qatorah_app/screens/splash_screen.dart';
import 'package:qatorah_app/screens/provider_home.dart';
import 'package:qatorah_app/screens/provider/qr_tools_screen.dart';
import 'package:qatorah_app/screens/admin/admin_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _hasRegisteredBefore = false;

  @override
  void initState() {
    super.initState();
    _loadRegistrationStatus();
  }

  Future<void> _loadRegistrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasRegisteredBefore = prefs.getBool('has_registered_before') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = ThemeManager.accentColor;
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        color: const Color(0xFF0A0E1A).withValues(alpha: ThemeManager.bgOpacity),
        child: Column(
          children: [
            _buildHeader(accent),
            const SizedBox(height: 10),
            Expanded(child: _buildList(context, accent)),
            _buildFooter(accent),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color accent) {
    return Consumer<ProfileManager>(
      builder: (context, profile, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 25),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [accent.withValues(alpha: 0.18), Colors.transparent]),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 2.5),
                  boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2)],
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFF10162B),
                  backgroundImage: profile.imageFile != null ? FileImage(profile.imageFile!) : null,
                  child: profile.imageFile == null ? const Icon(Icons.person, color: Colors.white, size: 40) : null,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name.isNotEmpty ? profile.name : (AuthManager.firstName.isNotEmpty ? AuthManager.firstName : 'مرحباً بك'),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('🇯🇴 ', style: TextStyle(fontSize: 13)),
                        Expanded(
                          child: Text(_getRoleName(AuthManager.role), style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, Color accent) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        if (!AuthManager.isLoggedIn) ...[
          if (!_hasRegisteredBefore)
            _buildItem(
              icon: Icons.app_registration,
              iconBg: accent.withValues(alpha: 0.2),
              title: 'تسجيل جديد',
              subtitle: 'سجل كمستخدم أو صاحب خدمة',
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())).then((_) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('has_registered_before', true);
                  if (mounted) setState(() => _hasRegisteredBefore = true);
                });
              },
            ),
          _buildItem(
            icon: Icons.login,
            iconBg: AppColors.refillGreen.withValues(alpha: 0.2),
            title: 'تسجيل الدخول',
            subtitle: 'ادخل إلى حسابك',
            onTap: () => _nav(context, const LoginScreen()),
          ),
          _buildDivider(),
        ],

        if (AuthManager.isLoggedIn) ...[
          _buildItem(
            icon: Icons.badge,
            iconBg: AppColors.goldLight.withValues(alpha: 0.2),
            title: 'حسابي',
            subtitle: 'الرصيد، الهوية الرقمية، والخصومات',
            isBold: true,
            onTap: () => _nav(context, const CustomerIdScreen()),
          ),
          _buildItem(
            icon: Icons.person_outline,
            iconBg: AppColors.crystalBlue.withValues(alpha: 0.2),
            title: 'بياناتي',
            subtitle: 'الاسم، الهاتف، كلمة المرور، والصورة',
            onTap: () => _nav(context, const ProfileSettingsScreen()),
          ),
          _buildItem(
            icon: Icons.shopping_cart,
            iconBg: AppColors.crystalBlue.withValues(alpha: 0.2),
            title: 'سلة التسوق',
            subtitle: CartManager.totalItems > 0 ? '${CartManager.totalItems} عناصر في السلة' : 'السلة فارغة حالياً',
            badge: CartManager.totalItems > 0 ? '${CartManager.totalItems}' : null,
            onTap: () => _nav(context, const CartScreen()),
          ),
          _buildItem(
            icon: Icons.receipt_long,
            iconBg: Colors.white.withValues(alpha: 0.1),
            title: 'طلباتي',
            subtitle: 'تتبع طلباتك السابقة',
            onTap: () => _showMsg(context, 'قيد التطوير'),
          ),
          _buildItem(
            icon: Icons.local_offer,
            iconBg: AppColors.goldLight.withValues(alpha: 0.2),
            title: 'عروض قطوره',
            subtitle: 'أحدث العروض والخصومات',
            onTap: () => _nav(context, const OffersScreen()),
          ),
        ],

        // ✅ أدوات مزود الخدمة
        if (AuthManager.isLoggedIn) ...[
          _buildDivider(),
          _buildSectionHeader('أدوات مزود الخدمة'),
          _buildItem(
            icon: Icons.dashboard,
            iconBg: AppColors.goldLight.withValues(alpha: 0.2),
            title: 'لوحة تحكم المزود',
            subtitle: 'إدارة الطلبات والإعلانات',
            isBold: true,
            onTap: () => _nav(context, const ProviderHomeScreen()),
          ),
          // 🆕 زرار أدوات QR
          _buildItem(
            icon: Icons.qr_code_scanner,
            iconBg: AppColors.refillGreen.withValues(alpha: 0.2),
            title: 'أدوات QR',
            subtitle: 'مسح الكود لتأكيد الطلب أو الكوبون',
            isBold: true,
            onTap: () => _nav(context, const QrToolsScreen()),
          ),
        ],

        _buildDivider(),
        
        // 🆕 ═══ زر السوبر أدمن (يظهر فقط إذا كان isSuperAdmin = true) ═══
        if (AuthManager.isSuperAdmin) ...[
          Container(
            decoration: BoxDecoration(
              color: AppColors.plumberRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.plumberRed.withValues(alpha: 0.4)),
            ),
            child: _buildItem(
              icon: Icons.admin_panel_settings,
              iconBg: AppColors.plumberRed.withValues(alpha: 0.2),
              title: 'لوحة السوبر أدمن',
              subtitle: 'إدارة الإعلانات، المحطات، والكوبونات',
              isBold: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              },
            ),
          ),
        ],

        _buildDivider(),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [accent.withValues(alpha: 0.18), accent.withValues(alpha: 0.05)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: _buildItem(
            icon: Icons.palette,
            iconBg: accent.withValues(alpha: 0.3),
            title: 'تخصيص المظهر',
            subtitle: 'الألوان، الخط، الوضع الليلي، والمزيد',
            onTap: () => _nav(context, const CustomizeScreen()),
          ),
        ),
        _buildItem(
          icon: Icons.headset_mic,
          iconBg: AppColors.tankCyan.withValues(alpha: 0.2),
          title: 'الدعم والمساعدة',
          subtitle: 'واتساب + شكاوي + اقتراحات',
          onTap: () => _nav(context, const SupportScreen()),
        ),
        _buildItem(
          icon: Icons.group_add,
          iconBg: const Color(0xFF25D366).withValues(alpha: 0.2),
          title: 'ادعُ واكسب',
          subtitle: 'شارك قطوره واربح مكافآت حقيقية',
          isBold: true,
          onTap: () => _nav(context, const ReferralScreen()),
        ),

        _buildDivider(),
        _buildItem(
          icon: Icons.rate_review,
          iconBg: AppColors.goldLight.withValues(alpha: 0.2),
          title: 'تقييم التطبيق',
          subtitle: 'شاركنا رأيك لتحسين قطوره',
          onTap: () => _nav(context, const AppReviewScreen()),
        ),
        _buildItem(
          icon: Icons.gavel,
          iconBg: Colors.white.withValues(alpha: 0.1),
          title: 'الاتفاقية وشروط الاستخدام',
          subtitle: 'بمجرد الاشتراك فأنت موافق',
          onTap: () => _nav(context, const TermsScreen()),
        ),
        _buildItem(
          icon: Icons.info_outline,
          iconBg: Colors.white.withValues(alpha: 0.1),
          title: 'عن التطبيق',
          subtitle: 'الإصدار والمطور والتواصل',
          onTap: () => _showAbout(context),
        ),
        _buildDivider(),
        Container(
          decoration: BoxDecoration(
            color: AppColors.plumberRed.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.plumberRed.withValues(alpha: 0.4)),
          ),
          child: _buildItem(
            icon: Icons.logout,
            iconBg: AppColors.plumberRed.withValues(alpha: 0.2),
            title: 'تسجيل الخروج',
            subtitle: 'الخروج من حسابك الحالي',
            isLogout: true,
            onTap: () {
              AuthManager.logout();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SplashScreen()), (route) => false);
            },
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
      child: Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  Widget _buildFooter(Color accent) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1)))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('صنع في الأردن', style: TextStyle(color: Colors.white54, fontSize: 12)),
              SizedBox(width: 6),
              Text('❤️', style: TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🇯🇴 ', style: TextStyle(fontSize: 13)),
              Text('قطوره', style: TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.bold)),
              const Text(' 🇯🇴', style: TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Text('الإصدار 1.0.0', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
    bool isBold = false,
    bool isLogout = false,
  }) {
    final bool glass = ThemeManager.glassEnabled;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: glass ? Colors.white.withValues(alpha: 0.04) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: glass ? 0.08 : 0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: isLogout ? AppColors.plumberRed : Colors.white, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: isLogout ? AppColors.plumberRed : Colors.white, fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11.5)),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppColors.plumberRed, shape: BoxShape.circle),
                  child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                )
              else
                const Icon(Icons.chevron_left, color: Colors.white38, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.customer: return 'مستهلك';
      case UserRole.stationOwner: return 'صاحب محطة';
      case UserRole.factory: return 'مصنع';
      case UserRole.driver: return 'سائق';
      case UserRole.tanker: return 'سائق تنك';
      case UserRole.stationTechnician: return 'فني';
      case UserRole.plumber: return 'سباك';
      default: return 'زائر';
    }
  }

  void _nav(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _showMsg(BuildContext context, String msg) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.navyDark),
    );
  }

  void _showAbout(BuildContext context) {
    Navigator.pop(context);
    final Color accent = ThemeManager.accentColor;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A2C5B), Color(0xFF0E1B3E)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield, color: accent, size: 60),
              const SizedBox(height: 12),
              const Text('قطوره', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('نظام المياه الذكي للخدمات والتوصيل', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
              const SizedBox(height: 18),
              Divider(color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(height: 10),
              _infoRow('الإصدار', '1.0.0', accent),
              _infoRow('المطور', 'قاسم مطاحن', accent),
              _infoRow('رقم التواصل', '00962-771453680', const Color(0xFF4CAF50)),
              _infoRow('الدولة', 'الأردن 🇯🇴', accent),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(12)),
                  child: const Text('حسناً', style: TextStyle(color: Color(0xFF0E1B3E), fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
          Text(value, style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}