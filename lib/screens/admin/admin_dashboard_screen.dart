import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/auth_manager.dart';

// استيراد التبويبات المفصولة
import 'tabs/admin_overview_tab.dart';
import 'tabs/admin_approvals_tab.dart';
import 'tabs/admin_accounting_tab.dart';
import 'tabs/admin_admins_tab.dart';
import 'tabs/admin_providers_tab.dart';
import 'tabs/admin_stations_tab.dart';
import 'tabs/admin_pricing_tab.dart';
import 'tabs/admin_coupons_tab.dart';
import 'tabs/admin_ads_tab.dart';
import 'tabs/admin_splash_ads_tab.dart';
import 'tabs/admin_notifications_tab.dart';
import 'tabs/admin_marketplace_ads_tab.dart'; // ✅ إعلانات السوق
import 'tabs/admin_content_review_tab.dart';  // ✅ تمت الإضافة: استيراد تبويب المراجعة الجديد
import 'tabs/admin_technicians_tab.dart';     // ✅ تمت الإضافة: استيراد تبويب إدارة الفنيين

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 14, // ✅ تمت الزيادة من 13 إلى 14 بسبب إضافة تبويب إدارة الفنيين
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A0A0A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.plumberRed),
            tooltip: 'رجوع',
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.plumberRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.admin_panel_settings,
                    color: AppColors.plumberRed, size: 22),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'لوحة السوبر أدمن',
                      style: TextStyle(
                        color: AppColors.plumberRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      AuthManager.adminLevelName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.plumberRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.plumberRed.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '👑 ${AuthManager.firstName.isNotEmpty ? AuthManager.firstName : 'المدير'}',
                    style: const TextStyle(
                      color: AppColors.plumberRed,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.plumberRed),
                tooltip: 'خروج من اللوحة',
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: AppColors.plumberRed,
            unselectedLabelColor: Colors.white54,
            indicatorColor: AppColors.plumberRed,
            indicatorWeight: 3,
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'نظرة عامة'),
              Tab(icon: Icon(Icons.approval), text: 'الموافقات'),
              Tab(icon: Icon(Icons.account_balance_wallet), text: 'المحاسبة'),
              Tab(icon: Icon(Icons.admin_panel_settings), text: 'الأدمنيين'),
              Tab(icon: Icon(Icons.groups), text: 'المزودين'),
              Tab(icon: Icon(Icons.store), text: 'المحطات'),
              Tab(icon: Icon(Icons.price_change), text: 'التسعير'),
              Tab(icon: Icon(Icons.confirmation_number), text: 'الكوبونات'),
              Tab(icon: Icon(Icons.campaign), text: 'إعلانات المناطق'),
              Tab(icon: Icon(Icons.image), text: 'إعلان استضافة'),
              Tab(icon: Icon(Icons.notifications_active), text: 'الإشعارات'),
              Tab(icon: Icon(Icons.storefront), text: 'إعلانات السوق'), // ✅ تم تعديل الأيقونة
              Tab(icon: Icon(Icons.shield), text: 'مراجعة المحتوى'),    // ✅ تمت الإضافة: التبويب الجديد
              Tab(icon: Icon(Icons.engineering), text: 'إدارة الفنيين'), // ✅ تمت الإضافة: تبويب إدارة الفنيين
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminOverviewTab(),
            AdminApprovalsTab(),
            AdminAccountingTab(),
            AdminAdminsTab(),
            AdminProvidersTab(),
            AdminStationsTab(),
            AdminPricingTab(),
            AdminCouponsTab(),
            AdminAdsTab(),
            AdminSplashAdsTab(),
            AdminNotificationsTab(),
            AdminMarketplaceAdsTab(), // ✅ الشاشة الجديدة
            AdminContentReviewTab(),  // ✅ تمت الإضافة: الويدجت الجديد
            AdminTechniciansTab(),    // ✅ تمت الإضافة: ويدجت إدارة الفنيين
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('خروج من اللوحة',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'هل أنت متأكد من الخروج من لوحة السوبر أدمن؟\n(ستبقى مسجل دخول كعميل عادي)',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.plumberRed),
            child: const Text('خروج'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      AuthManager.isSuperAdmin = false;
      AuthManager.adminLevel = 0;
      AuthManager.isLoggedIn = true;
      await AuthManager.saveSession();
      if (context.mounted) Navigator.pop(context);
    }
  }
}