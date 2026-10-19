import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/screens/provider/create_ad_screen.dart';
import 'package:qatorah_app/screens/provider/provider_wallet_screen.dart';
import 'package:qatorah_app/screens/provider/provider_orders_screen.dart';
import 'package:qatorah_app/screens/provider/provider_stats_screen.dart';
import 'package:qatorah_app/screens/provider/provider_profile_screen.dart';
import 'package:qatorah_app/screens/provider/qr_tools_screen.dart';

// ✅ تم إضافة هذا السطر لإصلاح خطأ kMockProviderId غير معرف
const String kMockProviderId = "mock_provider_123";

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardTab(),
    const ProviderOrdersScreen(),
    const ProviderStatsScreen(),
    const ProviderProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.goldLight,
          unselectedItemColor: Colors.white54,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'الطلبات'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'الإحصائيات'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  التبويب الأول: Dashboard (الرئيسية)
// ═══════════════════════════════════════════════════════════
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdvertisementManager>(
      builder: (context, mgr, _) {
        final myAds = mgr.allAds.where((a) => a.publisher.userId == kMockProviderId).toList();
        final activeAds = myAds.where((a) => a.isActive).length;
        final pendingAds = myAds.where((a) => a.isPending).length;
        final totalViews = myAds.fold<int>(0, (sum, a) => sum + a.stats.views);

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══ 1. بطاقة الترحيب والرصيد ═══
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.goldLight.withValues(alpha: 0.25), AppColors.goldLight.withValues(alpha: 0.05)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldLight.withValues(alpha: 0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('مرحباً، ${AuthManager.firstName.isNotEmpty ? AuthManager.firstName : 'مزود خدمة'} 👋',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('رصيدك الحالي', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const Text('150.00 د.أ', style: TextStyle(color: AppColors.goldLight, fontSize: 28, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.goldLight.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance_wallet, color: AppColors.goldLight, size: 32),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ═══ 2. الإحصائيات السريعة ═══
                const Text('نظرة سريعة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard('إعلانات نشطة', '$activeAds', Icons.check_circle, AppColors.refillGreen),
                    const SizedBox(width: 12),
                    _buildStatCard('قيد المراجعة', '$pendingAds', Icons.hourglass_empty, AppColors.goldLight),
                    const SizedBox(width: 12),
                    _buildStatCard('المشاهدات', '$totalViews', Icons.visibility, AppColors.crystalBlue),
                  ],
                ),
                const SizedBox(height: 24),

                // ═══ 3. الإجراءات السريعة ═══
                const Text('إجراءات سريعة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        'إنشاء إعلان', 
                        'انشر إعلانك الجديد', 
                        Icons.add_circle_outline, 
                        AppColors.goldLight,
                        () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAdScreen()));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        'المحفظة', 
                        'سحب وإيداع', 
                        Icons.account_balance_wallet, 
                        AppColors.crystalBlue,
                        () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProviderWalletScreen()));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 🆕 زرار أدوات QR
                _buildActionCard(
                  'أدوات QR', 
                  'مسح كود العميل أو الكوبون', 
                  Icons.qr_code_scanner, 
                  AppColors.refillGreen,
                  () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const QrToolsScreen()));
                  },
                ),
                const SizedBox(height: 24),

                // ═══ 4. آخر الإعلانات ═══
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('إعلاناتي الأخيرة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('عرض الكل', style: TextStyle(color: AppColors.goldLight, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                if (myAds.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(30),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1F2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 50, color: Colors.white.withValues(alpha: 0.3)),
                        const SizedBox(height: 10),
                        const Text('لم تنشر أي إعلانات بعد', style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  )
                else
                  ...myAds.take(3).map((ad) => _buildAdItemCard(ad, context, mgr)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdItemCard(AdvertisementModel ad, BuildContext context, AdvertisementManager mgr) {
    Color statusColor = ad.isActive ? AppColors.refillGreen : (ad.isPending ? AppColors.goldLight : AppColors.plumberRed);
    String statusText = ad.isActive ? 'نشط' : (ad.isPending ? 'قيد المراجعة' : 'مرفوض');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(ad.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: statusColor.withValues(alpha: 0.4))),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.visibility, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text('${ad.stats.views}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(width: 16),
              const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text('${ad.duration.days} يوم', style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const Spacer(),
              if (ad.isPending)
                GestureDetector(
                  onTap: () {
                    mgr.deleteAd(ad.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء الإعلان'), backgroundColor: AppColors.plumberRed));
                  },
                  child: const Icon(Icons.delete_outline, color: AppColors.plumberRed, size: 20),
                ),
            ],
          ),
        ],
      ),
    );
  }
}