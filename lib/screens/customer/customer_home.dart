import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/ads/ad_carousel_widget.dart';
import 'package:qatorah_app/core/widgets/app_drawer.dart';
import 'package:qatorah_app/core/widgets/auth_gate.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/core/widgets/smart_top_bar.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/managers/cart_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/screens/customer/calculator_screen.dart';
import 'package:qatorah_app/screens/customer/cart_screen.dart';
import 'package:qatorah_app/screens/customer/customer_id_screen.dart';
import 'package:qatorah_app/screens/customer/customer_qr_screen.dart'; 
import 'package:qatorah_app/screens/customer/drinking_water.dart';
import 'package:qatorah_app/screens/customer/gas_screen.dart';
import 'package:qatorah_app/screens/customer/home_refill_screen.dart';
import 'package:qatorah_app/screens/customer/marketplace_screen.dart';
import 'package:qatorah_app/screens/customer/maintenance_screen.dart';
import 'package:qatorah_app/screens/customer/my_coupons_screen.dart';
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
    return Scaffold(
      drawer: const AppDrawer(),
      floatingActionButton: (AuthManager.isLoggedIn && AuthManager.isProvider)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProviderHomeScreen()),
                );
              },
              backgroundColor: AppColors.goldLight,
              foregroundColor: const Color(0xFF0A0E1A),
              icon: const Icon(Icons.dashboard, size: 24),
              label: const Text('لوحة التحكم',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              elevation: 8,
            )
          : (AuthManager.isLoggedIn && !AuthManager.isProvider)
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CustomerQrScreen()),
                    );
                  },
                  backgroundColor: AppColors.refillGreen,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.qr_code_2, size: 24),
                  label: const Text('كود الدفع',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  elevation: 8,
                )
              : null,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 15),
                const SmartTopBar(),
                const SizedBox(height: 18),

                Consumer<AdvertisementManager>(
                  builder: (context, mgr, _) {
                    final kingdomAds = mgr.allAds
                        .where((a) =>
                            a.isDisplayable &&
                            (a.scope == AdScope.kingdom ||
                                a.type == AdType.qatorah))
                        .toList()
                      ..sort((a, b) => a.sortPriority.compareTo(b.sortPriority));

                    if (kingdomAds.isEmpty) return const SizedBox.shrink();
                    return AdCarouselWidget(
                      ads: kingdomAds,
                      title: '🌍 إعلانات المملكة',
                      accentColor: AppColors.crystalBlue,
                      cardHeight: _kingdomCardHeight,
                      onTap: (ad) => _openAdDialog(context, ad),
                    );
                  },
                ),
                const SizedBox(height: 16),

                Consumer<AdvertisementManager>(
                  builder: (context, mgr, _) {
                    final governorateAds = mgr.allAds
                        .where((a) =>
                            a.isDisplayable &&
                            a.scope == AdScope.governorate &&
                            a.type == AdType.premium)
                        .toList()
                      ..sort((a, b) => a.sortPriority.compareTo(b.sortPriority));

                    if (governorateAds.isEmpty) return const SizedBox.shrink();
                    return AdCarouselWidget(
                      ads: governorateAds,
                      title: '📍 إعلانات محافظتك',
                      accentColor: AppColors.goldLight,
                      cardHeight: _governorateCardHeight,
                      onTap: (ad) => _openAdDialog(context, ad),
                    );
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

  void _openAdDialog(BuildContext context, AdvertisementModel ad) {
    showDialog(
      context: context,
      builder: (_) => AdDetailsDialog(ad: ad),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Builder(
          builder: (innerContext) => GestureDetector(
            onTap: () => Scaffold.of(innerContext).openDrawer(),
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.crystalBlue.withValues(alpha: 0.5),
                    width: 1.5),
              ),
              child:
                  const Icon(Icons.menu, color: AppColors.crystalBlue, size: 26),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerIdScreen()),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.goldLight.withValues(alpha: 0.25),
                    const Color(0xFFDAA520).withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.goldLight.withValues(alpha: 0.6)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.badge, color: AppColors.goldLight, size: 17),
                  SizedBox(width: 6),
                  Text('حسابي',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 11),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => AuthGate.requireAuth(context,
              action: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CartScreen()))),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.crystalBlue.withValues(alpha: 0.5),
                      width: 1.5),
                ),
                child: const Icon(Icons.shopping_cart,
                    color: AppColors.crystalBlue, size: 26),
              ),
              if (CartManager.totalItems > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: AppColors.plumberRed, shape: BoxShape.circle),
                    constraints:
                        const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text('${CartManager.totalItems}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesGrid() {
    final allServices = [
      {
        'icon': Icons.water_drop,
        'color': AppColors.waterBlue,
        'label': 'مياه شرب',
        'screen': const DrinkingWaterScreen()
      },
      {
        'icon': Icons.opacity,
        'color': AppColors.tankCyan,
        'label': 'تنك مياه',
        'screen': const TankScreen()
      },
      {
        'icon': Icons.local_fire_department,
        'color': const Color(0xFFE65100),
        'label': 'أسطوانة غاز',
        'screen': const GasScreen()
      },
      {
        'icon': Icons.build_circle,
        'color': AppColors.maintenanceOrange,
        'label': 'صيانة',
        'screen': const MaintenanceScreen()
      },
      {
        'icon': Icons.shopping_bag,
        'color': AppColors.maintenanceOrange,
        'label': 'متجر القطع',
        'screen': const PartsStoreScreen()
      },
      {
        'icon': Icons.local_shipping,
        'color': AppColors.refillGreen,
        'label': 'عبي باب بيتك',
        'screen': const HomeRefillScreen()
      },
      {
        'icon': Icons.local_offer,
        'color': AppColors.goldDark,
        'label': 'العروض',
        'screen': const OffersScreen()
      },
      {
        'icon': Icons.storefront,
        'color': AppColors.factoryPurple,
        'label': 'السوق',
        'screen': const MarketplaceScreen()
      },
      {
        'icon': Icons.confirmation_number,
        'color': AppColors.goldLight,
        'label': 'كوبوناتي',
        'screen': const MyCouponsScreen()
      },
      {
        'icon': Icons.calculate,
        'color': AppColors.crystalBlue,
        'label': 'حاسبة المياه',
        'screen': const CalculatorScreen()
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 0.78,
      children: List.generate(allServices.length, (index) {
        final s = allServices[index];
        final color = s['color'] as Color;
        return _SpringTile(
          index: index,
          child: GlassCard(
            glowColor: color,
            onTap: () {
              final screen = s['screen'];
              if (screen != null) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => screen as Widget));
              } else {
                _comingSoon(s['label'] as String);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      color.withValues(alpha: 0.5),
                      color.withValues(alpha: 0.2)
                    ]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: color.withValues(alpha: 0.5), blurRadius: 10)
                    ],
                  ),
                  child:
                      Icon(s['icon'] as IconData, size: 30, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  s['label'] as String,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _comingSoon(String name) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('خدمة $name قريباً جداً 🔜'),
        backgroundColor: AppColors.royalBlue,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }
}

class _SpringTile extends StatefulWidget {
  final Widget child;
  final int index;
  const _SpringTile({required this.child, required this.index});

  @override
  State<_SpringTile> createState() => _SpringTileState();
}

class _SpringTileState extends State<_SpringTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
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
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: widget.child,
      ),
    );
  }
}