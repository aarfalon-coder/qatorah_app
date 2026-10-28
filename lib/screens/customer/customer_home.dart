import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_colors.dart';
import 'package:qatorah_app/core/widgets/ads/ad_carousel_widget.dart';
import 'package:qatorah_app/core/widgets/app_drawer.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/core/widgets/smart_top_bar.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/managers/theme_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/screens/auth/login_screen.dart';
import 'package:qatorah_app/screens/customer/calculator_screen.dart';
import 'package:qatorah_app/screens/customer/customer_id_screen.dart';
import 'package:qatorah_app/screens/customer/drinking_water.dart';
import 'package:qatorah_app/screens/customer/gas_screen.dart';
import 'package:qatorah_app/screens/customer/home_refill_screen.dart';
import 'package:qatorah_app/screens/customer/marketplace_screen.dart';
import 'package:qatorah_app/screens/customer/maintenance_screen.dart';
import 'package:qatorah_app/screens/customer/my_coupons_screen.dart';
import 'package:qatorah_app/screens/customer/notifications_screen.dart';
import 'package:qatorah_app/screens/customer/offers_screen.dart';
import 'package:qatorah_app/screens/customer/parts_store_screen.dart';
import 'package:qatorah_app/screens/customer/tank_screen.dart';
import 'package:qatorah_app/screens/marketplace/ad_details_dialog.dart';
import 'package:qatorah_app/screens/provider_home.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final double _kingdomCardHeight = 60;
  final double _governorateCardHeight = 60;

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2029);

    return Scaffold(
      drawer: AuthManager.isGuest ? null : const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark 
              ? AppGradients.mainBackground 
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF5F7FA), Color(0xFFE2E8F0)],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(textColor),
                const SizedBox(height: 15),
                const SmartTopBar(),
                const SizedBox(height: 18),

                if (!AuthManager.isGuest && (AuthManager.isProvider || AuthManager.role == UserRole.stationOwner)) ...[
                  _buildProviderAccessCard(context),
                  const SizedBox(height: 18),
                ],

                Consumer<AdvertisementManager>(
                  builder: (context, mgr, _) {
                    final kingdomAds = mgr.activeAds.where((a) => a.isDisplayable && (a.scope == AdScope.kingdom || a.type == AdType.qatorah)).toList()..sort((a, b) => a.sortPriority.compareTo(b.sortPriority));
                    if (kingdomAds.isEmpty) return _buildPlaceholderAdCard(title: '🌍 إعلانات المملكة', subtitle: 'أعلن هنا ووصل لجميع مستخدمي قطوره', color: AppColors.crystalBlue, onTap: () => _showAdInquiryDialog(context));
                    return AdCarouselWidget(ads: kingdomAds, title: '🌍 إعلانات المملكة', accentColor: AppColors.crystalBlue, cardHeight: _kingdomCardHeight, onTap: (ad) => _openAdDialog(context, ad));
                  },
                ),
                const SizedBox(height: 16),

                Consumer<AdvertisementManager>(
                  builder: (context, mgr, _) {
                    final governorateAds = mgr.activeAds.where((a) => a.isDisplayable && a.scope == AdScope.governorate && a.type == AdType.premium && a.region.code == AuthManager.currentGovernorateCode).toList()..sort((a, b) => a.sortPriority.compareTo(b.sortPriority));
                    if (governorateAds.isEmpty) return _buildPlaceholderAdCard(title: '📍 إعلانات محافظتك', subtitle: 'أعلن هنا ووصل لعملاء محافظتك', color: AppColors.goldLight, onTap: () => _showAdInquiryDialog(context));
                    return AdCarouselWidget(ads: governorateAds, title: '📍 إعلانات محافظتك', accentColor: AppColors.goldLight, cardHeight: _governorateCardHeight, onTap: (ad) => _openAdDialog(context, ad));
                  },
                ),
                const SizedBox(height: 22),

                _buildServicesGrid(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAdCard({required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(Icons.campaign, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: ThemeHelper.getSecondaryTextColor(context), fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: const Color(0xFF0A0E1A), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('أعلن هنا', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAdInquiryDialog(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeHelper.getCardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('📢 أعلن على قطوره', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('وصل إلى آلاف العملاء في جميع أنحاء المملكة.', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2029), fontSize: 14)),
            const SizedBox(height: 12),
            Text('للاستفسار عن أسعار الإعلانات، يرجى التواصل مع الإدارة.', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B), fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.phone, color: AppColors.refillGreen, size: 18),
                const SizedBox(width: 8),
                Text('0791234567', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2029), fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إغلاق', style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF64748B)))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: AppColors.refillGreen), child: const Text('تواصل واتساب')),
        ],
      ),
    );
  }

  Widget _buildProviderAccessCard(BuildContext context) {
    final isProviderActive = AuthManager.isProvider && AuthManager.isLoggedIn;
    final bool isDark = ThemeManager.isDarkMode;
    return GestureDetector(
      onTap: () {
        if (isProviderActive) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProviderHomeScreen()));
        } else {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: ThemeHelper.getCardColor(context),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('⏳ حسابك قيد المراجعة', style: TextStyle(color: AppColors.goldLight)),
              content: Text('طلبك كمزود خدمة قيد المراجعة من قبل الإدارة.\nيمكنك استخدام التطبيق كعميل في الوقت الحالي.', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B))),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً', style: TextStyle(color: AppColors.goldLight)))],
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: isProviderActive ? [AppColors.goldLight.withValues(alpha: 0.3), AppColors.goldLight.withValues(alpha: 0.1)] : [Colors.orange.withValues(alpha: 0.2), Colors.orange.withValues(alpha: 0.05)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isProviderActive ? AppColors.goldLight : Colors.orange.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: isProviderActive ? AppColors.goldLight.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Icon(isProviderActive ? Icons.store : Icons.hourglass_empty, color: isProviderActive ? AppColors.goldLight : Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isProviderActive ? 'لوحة تحكم المزود' : 'حسابك كمزود قيد المراجعة', style: TextStyle(color: isProviderActive ? AppColors.goldLight : Colors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(isProviderActive ? 'اضغط للدخول وإدارة أعمالك' : 'يمكنك استخدام التطبيق كعميل حالياً', style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87, fontSize: 11)),
                ],
              ),
            ),
            Icon(isProviderActive ? Icons.arrow_forward_ios : Icons.lock_outline, color: isProviderActive ? AppColors.goldLight : Colors.orange, size: 18),
          ],
        ),
      ),
    );
  }

  void _openAdDialog(BuildContext context, AdvertisementModel ad) {
    showDialog(context: context, builder: (_) => AdDetailsDialog(ad: ad));
  }

  Widget _buildHeader(Color textColor) {
    final bool isDark = ThemeManager.isDarkMode;
    return Row(
      children: [
        if (AuthManager.isGuest)
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.refillGreen.withValues(alpha: 0.2), AppColors.refillGreen.withValues(alpha: 0.05)]), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.refillGreen.withValues(alpha: 0.5))),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.login, color: AppColors.refillGreen, size: 18), SizedBox(width: 6), Text('تسجيل الدخول', style: TextStyle(color: AppColors.refillGreen, fontWeight: FontWeight.bold, fontSize: 13))]),
              ),
            ),
          )
        else ...[
          Builder(
            builder: (innerContext) => GestureDetector(
              onTap: () => Scaffold.of(innerContext).openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05), shape: BoxShape.circle, border: Border.all(color: AppColors.crystalBlue.withValues(alpha: 0.5), width: 1.5)),
                child: const Icon(Icons.menu, color: AppColors.crystalBlue, size: 26),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerIdScreen())),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.goldLight.withValues(alpha: 0.25), const Color(0xFFDAA520).withValues(alpha: 0.15)]), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.6))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.badge, color: AppColors.goldLight, size: 17), const SizedBox(width: 6), Text('حسابي', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2029), fontSize: 13, fontWeight: FontWeight.bold)), const SizedBox(width: 6), Icon(Icons.arrow_forward_ios, color: isDark ? Colors.white70 : Colors.black54, size: 11)]),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const NotificationsScreen());
            },
            child: Stack(
              children: [
                Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05), shape: BoxShape.circle, border: Border.all(color: AppColors.crystalBlue.withValues(alpha: 0.5), width: 1.5)), child: const Icon(Icons.notifications_none, color: AppColors.crystalBlue, size: 26)),
                Positioned(top: 0, right: 0, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.plumberRed, shape: BoxShape.circle), constraints: const BoxConstraints(minWidth: 18, minHeight: 18), child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildServicesGrid() {
    final allServices = [
      {'label': 'مياه شرب', 'type': 'water', 'screen': const DrinkingWaterScreen()},
      {'label': 'تنك مياه', 'type': 'tanker', 'screen': const TankScreen()},
      {'label': 'أسطوانة غاز', 'type': 'gas', 'screen': const GasScreen()},
      {'label': 'صيانة', 'type': 'maintenance', 'screen': const MaintenanceScreen()},
      {'label': 'متجر القطع', 'type': 'parts', 'screen': const PartsStoreScreen()},
      {'label': 'عبي باب بيتك', 'type': 'refill', 'screen': const HomeRefillScreen()},
      {'label': 'العروض', 'type': 'offers', 'screen': const OffersScreen()},
      {'label': 'السوق', 'type': 'market', 'screen': const MarketplaceScreen()},
      {'label': 'كوبوناتي', 'type': 'coupons', 'screen': const MyCouponsScreen()},
      {'label': 'حاسبة المياه', 'type': 'calculator', 'screen': const CalculatorScreen()},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: List.generate(allServices.length, (index) {
        final s = allServices[index];
        final iconData = _getServiceIcon(s['type'] as String);
        final color = _getServiceColor(s['type'] as String);

        return _SpringTile(
          index: index,
          child: GlassCard(
            glowColor: color,
            onTap: () {
              if (AuthManager.isGuest) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: ThemeHelper.getCardColor(context),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('🔒 يرجى تسجيل الدخول', style: TextStyle(color: AppColors.goldLight)),
                    content: Text('للاستفادة من خدماتنا، يرجى تسجيل الدخول أولاً.', style: TextStyle(color: ThemeManager.isDarkMode ? Colors.white70 : const Color(0xFF64748B))),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء', style: TextStyle(color: ThemeManager.isDarkMode ? Colors.white54 : const Color(0xFF64748B)))),
                      ElevatedButton(onPressed: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.refillGreen), child: const Text('تسجيل الدخول')),
                    ],
                  ),
                );
                return;
              }
              final screen = s['screen'];
              if (screen != null) Navigator.push(context, MaterialPageRoute(builder: (_) => screen as Widget));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0.2)]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10)],
                  ),
                  child: Icon(iconData, size: 30, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  s['label'] as String,
                  style: TextStyle(color: ThemeHelper.getTextColor(context), fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  IconData _getServiceIcon(String type) {
    switch (type) {
      case 'water': return Icons.water_drop;
      case 'tanker': return Icons.local_shipping;
      case 'gas': return Icons.propane_tank;
      case 'maintenance': return Icons.build_circle;
      case 'parts': return Icons.shopping_bag;
      case 'refill': return Icons.home_repair_service;
      case 'offers': return Icons.local_offer;
      case 'market': return Icons.storefront;
      case 'coupons': return Icons.confirmation_number;
      case 'calculator': return Icons.calculate;
      default: return Icons.category;
    }
  }

  Color _getServiceColor(String type) {
    switch (type) {
      case 'water': return AppColors.waterBlue;
      case 'tanker': return AppColors.tankCyan;
      case 'gas': return const Color(0xFFE65100);
      case 'maintenance': return AppColors.maintenanceOrange;
      case 'parts': return AppColors.maintenanceOrange;
      case 'refill': return AppColors.refillGreen;
      case 'offers': return AppColors.goldDark;
      case 'market': return AppColors.factoryPurple;
      case 'coupons': return AppColors.goldLight;
      case 'calculator': return AppColors.crystalBlue;
      default: return AppColors.crystalBlue;
    }
  }
}

class _SpringTile extends StatefulWidget {
  final Widget child;
  final int index;
  const _SpringTile({required this.child, required this.index});

  @override
  State<_SpringTile> createState() => _SpringTileState();
}

class _SpringTileState extends State<_SpringTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: ScaleTransition(scale: _animation, child: widget.child));
  }
}