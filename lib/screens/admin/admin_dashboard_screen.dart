import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/screens/admin/splash_ads/splash_ads_management_screen.dart';

/// ═══════════════════════════════════════════════════════════
///  لوحة السوبر أدمن — غرفة القيادة (War Room)
/// ═══════════════════════════════════════════════════════════

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
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
          // ✅ التصحيح هنا: إضافة Flexible و TextOverflow.ellipsis لمنع التسرب
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
                    '👑 ${AuthManager.firstName.isNotEmpty ? AuthManager.firstName : 'قاسم'}',
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
              Tab(icon: Icon(Icons.store), text: 'المحطات'),
              Tab(icon: Icon(Icons.confirmation_number), text: 'الكوبونات'),
              Tab(icon: Icon(Icons.campaign), text: 'إعلان استضافة'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OverviewTab(),
            _ApprovalsTab(),
            _AccountingTab(),
            _AdminsTab(),
            _StationsTab(),
            _CouponsTab(),
            _SplashAdsTab(),
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

    if (confirm == true && mounted) {
      AuthManager.isSuperAdmin = false;
      AuthManager.adminLevel = 0;
      AuthManager.isLoggedIn = true;
      await AuthManager.saveSession();

      if (mounted) Navigator.pop(context);
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  التبويب 1: نظرة عامة
// ═══════════════════════════════════════════════════════════
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdvertisementManager>(
      builder: (context, mgr, _) {
        final totalAds = mgr.allAds.length;
        final pendingAds = mgr.pendingReviewAds.length;
        final activeAds = mgr.allAds.where((a) => a.isActive).length;
        final premiumAds =
            mgr.allAds.where((a) => a.type == AdType.premium).length;
        final freeAds = mgr.allAds.where((a) => a.type == AdType.free).length;
        final totalRevenue = mgr.allAds
            .where((a) => a.type == AdType.premium && a.isActive)
            .fold<double>(0, (sum, a) => sum + a.pricing.amount);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.plumberRed.withValues(alpha: 0.3),
                      AppColors.goldLight.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.plumberRed.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up,
                            color: AppColors.goldLight, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'أهلاً بك يا قاسم 👑',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'إمبراطوريتك الرقمية اليوم:',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _bigStat('إجمالي الإعلانات', '$totalAds',
                            AppColors.crystalBlue),
                        _bigStat('قيد المراجعة', '$pendingAds',
                            AppColors.plumberRed),
                        _bigStat('الإيرادات المحجوزة',
                            '${totalRevenue.toInt()} د.أ', AppColors.goldLight),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'تفصيل الإعلانات',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _miniStat('نشطة', '$activeAds',
                        AppColors.refillGreen, Icons.check_circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _miniStat('بريميوم', '$premiumAds',
                        AppColors.goldLight, Icons.star),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _miniStat('مجانية', '$freeAds',
                        AppColors.crystalBlue, Icons.card_giftcard),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'تنبيهات حية',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (pendingAds > 0)
                GestureDetector(
                  onTap: () => DefaultTabController.of(context).animateTo(1),
                  child: _alertCard(
                    'يوجد $pendingAds إعلان بانتظار موافقتك',
                    'اضغط هنا للذهاب لتبويب "الموافقات"',
                    AppColors.plumberRed,
                    Icons.warning,
                  ),
                )
              else
                _alertCard(
                  'كل شيء تحت السيطرة ✅',
                  'لا توجد إعلانات معلقة حالياً',
                  AppColors.refillGreen,
                  Icons.verified_user,
                ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 ملخص النظام',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _infoRow('عدد المحطات المسجلة', '200 (قريباً)'),
                    _infoRow('عدد المستخدمين النشطين', '20,000+ (الشهر الأول)'),
                    _infoRow('الكوبونات المصدرة', '1,000+ (محطة واحدة)'),
                    _infoRow('نسبة السيطرة على السوق', '95% 🏆'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bigStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
      ],
    );
  }

  Widget _miniStat(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _alertCard(String title, String subtitle, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  التبويب 2: الموافقات
// ═══════════════════════════════════════════════════════════
class _ApprovalsTab extends StatelessWidget {
  const _ApprovalsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdvertisementManager>(
      builder: (context, mgr, _) {
        final pending = mgr.pendingReviewAds;

        if (pending.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified,
                    size: 80,
                    color: AppColors.refillGreen.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد إعلانات بانتظار المراجعة',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'كل شيء مُعتمد ✅',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pending.length,
          itemBuilder: (context, i) => _pendingCard(context, mgr, pending[i]),
        );
      },
    );
  }

  Widget _pendingCard(
      BuildContext context, AdvertisementManager mgr, AdvertisementModel ad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '⭐ بريميوم',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${ad.pricing.amount.toInt()} د.أ',
                style: const TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ad.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ad.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text(ad.publisher.userName,
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.location_on, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text(ad.region.displayName,
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 12)),
              const Spacer(),
              Text('${ad.duration.days} يوم',
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rejectDialog(context, mgr, ad),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('رفض'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.plumberRed.withValues(alpha: 0.2),
                    foregroundColor: AppColors.plumberRed,
                    side: const BorderSide(color: AppColors.plumberRed),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await mgr.approveAd(ad.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ تم اعتماد "${ad.title}"'),
                          backgroundColor: AppColors.refillGreen,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('اعتماد (خصم المبلغ)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.refillGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _rejectDialog(
      BuildContext context, AdvertisementManager mgr, AdvertisementModel ad) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('رفض الإعلان', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: reasonCtrl,
          decoration: InputDecoration(
            hintText: 'سبب الرفض (سيظهر للمزود)',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            filled: true,
            fillColor: const Color(0xFF0A0E1A),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('تراجع', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await mgr.rejectAd(
                  ad.id,
                  reasonCtrl.text.isNotEmpty
                      ? reasonCtrl.text
                      : 'مرفوض من الإدارة');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ تم رفض "${ad.title}"'),
                    backgroundColor: AppColors.plumberRed,
                  ),
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.plumberRed),
            child: const Text('تأكيد الرفض'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  التبويب 3: المحاسبة
// ═══════════════════════════════════════════════════════════
class _AccountingTab extends StatefulWidget {
  const _AccountingTab();

  @override
  State<_AccountingTab> createState() => _AccountingTabState();
}

class _AccountingTabState extends State<_AccountingTab> {
  final double _totalRevenue = 12500.00;
  double _pendingWithdrawals = 450.00;

  final List<Map<String, dynamic>> _withdrawalRequests = [
    {
      'id': 'W001',
      'provider': 'محطة السلام',
      'amount': 150.00,
      'date': 'اليوم',
      'status': 'pending'
    },
    {
      'id': 'W002',
      'provider': 'سباك أحمد',
      'amount': 45.00,
      'date': 'أمس',
      'status': 'pending'
    },
    {
      'id': 'W003',
      'provider': 'مصنع الجبل',
      'amount': 300.00,
      'date': 'منذ يومين',
      'status': 'approved'
    },
  ];

  void _processWithdrawal(int index, bool approve) {
    setState(() {
      if (approve) {
        _withdrawalRequests[index]['status'] = 'approved';
        _pendingWithdrawals -= _withdrawalRequests[index]['amount'];
      } else {
        _withdrawalRequests.removeAt(index);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(approve
            ? '✅ تم اعتماد السحب وتحويل المبلغ'
            : '❌ تم رفض طلب السحب'),
        backgroundColor:
            approve ? AppColors.refillGreen : AppColors.plumberRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.goldLight.withValues(alpha: 0.2),
                AppColors.goldLight.withValues(alpha: 0.05),
              ]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.goldLight.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إجمالي الإيرادات',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${_totalRevenue.toStringAsFixed(2)} د.أ',
                          style: const TextStyle(
                              color: AppColors.refillGreen,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('سحوبات معلقة',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${_pendingWithdrawals.toStringAsFixed(2)} د.أ',
                          style: const TextStyle(
                              color: AppColors.plumberRed,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ]),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('طلبات السحب المعلقة',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_withdrawalRequests
              .where((w) => w['status'] == 'pending')
              .isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(12)),
              child: const Text('لا توجد طلبات سحب معلقة حالياً ✅',
                  style: TextStyle(color: Colors.white54)),
            )
          else
            ..._withdrawalRequests
                .asMap()
                .entries
                .where((e) => e.value['status'] == 'pending')
                .map((entry) {
              final req = entry.value;
              final index = entry.key;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(req['provider'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text('${req['amount']} د.أ',
                            style: const TextStyle(
                                color: AppColors.goldLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('تاريخ الطلب: ${req['date']}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _processWithdrawal(index, false),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.plumberRed
                                    .withValues(alpha: 0.2),
                                foregroundColor: AppColors.plumberRed),
                            child: const Text('رفض الطلب'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _processWithdrawal(index, true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.refillGreen,
                                foregroundColor: Colors.white),
                            child: const Text('اعتماد وتحويل'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  التبويب 4: الأدمنيين
// ═══════════════════════════════════════════════════════════
class _AdminsTab extends StatefulWidget {
  const _AdminsTab();

  @override
  State<_AdminsTab> createState() => _AdminsTabState();
}

class _AdminsTabState extends State<_AdminsTab> {
  final List<Map<String, dynamic>> _admins = [
    {
      'name': 'قاسم مطاحن',
      'phone': '0791453680',
      'level': 5,
      'role': 'سوبر أدمن',
      'status': 'نشط'
    },
    {
      'name': 'ميار الدعم',
      'phone': '0781112233',
      'level': 2,
      'role': 'دعم فني',
      'status': 'نشط'
    },
    {
      'name': 'رانسي المشرفة',
      'phone': '0779998877',
      'level': 3,
      'role': 'مشرفة',
      'status': 'نشط'
    },
  ];

  void _showAddAdminDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    int selectedLevel = 2;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('إضافة أدمن جديد',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: selectedLevel,
                dropdownColor: const Color(0xFF1A1F2E),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'مستوى الصلاحية',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
                items: const [
                  DropdownMenuItem(value: 2, child: Text('مستوى 2: دعم فني')),
                  DropdownMenuItem(value: 3, child: Text('مستوى 3: مشرف')),
                  DropdownMenuItem(value: 4, child: Text('مستوى 4: مدير')),
                ],
                onChanged: (val) =>
                    setDialogState(() => selectedLevel = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء',
                  style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                  setState(() => _admins.add({
                        'name': nameCtrl.text,
                        'phone': phoneCtrl.text,
                        'level': selectedLevel,
                        'role': selectedLevel == 2
                            ? 'دعم فني'
                            : (selectedLevel == 3 ? 'مشرف' : 'مدير'),
                        'status': 'نشط'
                      }));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ تم إضافة الأدمن بنجاح'),
                      backgroundColor: AppColors.refillGreen,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldLight,
                foregroundColor: const Color(0xFF0A0E1A),
              ),
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAdminDialog,
        backgroundColor: AppColors.goldLight,
        foregroundColor: const Color(0xFF0A0E1A),
        icon: const Icon(Icons.add),
        label: const Text('إضافة أدمن',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _admins.length,
        itemBuilder: (context, index) {
          final admin = _admins[index];
          final isSuper = admin['level'] == 5;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isSuper
                      ? AppColors.goldLight.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isSuper
                      ? AppColors.goldLight.withValues(alpha: 0.2)
                      : AppColors.crystalBlue.withValues(alpha: 0.2),
                  child: Icon(Icons.person,
                      color: isSuper
                          ? AppColors.goldLight
                          : AppColors.crystalBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(admin['name'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(admin['phone'],
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12)),
                      Text(admin['role'],
                          style: const TextStyle(
                              color: AppColors.goldLight, fontSize: 11)),
                    ],
                  ),
                ),
                if (!isSuper)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.plumberRed),
                    onPressed: () {
                      setState(() => _admins.removeAt(index));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم حذف الأدمن'),
                          backgroundColor: AppColors.plumberRed,
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  التبويب 5: المحطات
// ═══════════════════════════════════════════════════════════
class _StationsTab extends StatefulWidget {
  const _StationsTab();

  @override
  State<_StationsTab> createState() => _StationsTabState();
}

class _StationsTabState extends State<_StationsTab> {
  final List<Map<String, dynamic>> _stations = List.generate(
      10,
      (i) => {
            'name': 'محطة ${i + 1}',
            'area': 'إربد',
            'orders': (i + 1) * 50,
            'banned': false
          });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stations.length,
      itemBuilder: (context, i) {
        final st = _stations[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: st['banned']
                ? AppColors.plumberRed.withValues(alpha: 0.1)
                : const Color(0xFF1A1F2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: st['banned']
                    ? AppColors.plumberRed
                    : Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: st['banned']
                      ? AppColors.plumberRed.withValues(alpha: 0.2)
                      : AppColors.refillGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    st['banned'] ? Icons.block : Icons.store,
                    color: st['banned']
                        ? AppColors.plumberRed
                        : AppColors.refillGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(st['name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Text(st['area'],
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${st['orders']} طلب',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        st['banned'] = !st['banned'];
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(st['banned']
                              ? '🚫 تم حظر المحطة'
                              : '✅ تم إلغاء حظر المحطة'),
                          backgroundColor: st['banned']
                              ? AppColors.plumberRed
                              : AppColors.refillGreen,
                        ),
                      );
                    },
                    child: Text(
                      st['banned'] ? 'إلغاء الحظر' : 'حظر',
                      style: TextStyle(
                        color: st['banned']
                            ? AppColors.refillGreen
                            : AppColors.plumberRed,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  التبويب 6: الكوبونات
// ═══════════════════════════════════════════════════════════
class _CouponsTab extends StatefulWidget {
  const _CouponsTab();

  @override
  State<_CouponsTab> createState() => _CouponsTabState();
}

class _CouponsTabState extends State<_CouponsTab> {
  final List<Map<String, dynamic>> _coupons = [
    {
      'code': 'QATORAH20',
      'discount': '20%',
      'uses': 150,
      'maxUses': 500,
      'isActive': true
    },
    {
      'code': 'WELCOME10',
      'discount': '10%',
      'uses': 45,
      'maxUses': 100,
      'isActive': true
    },
    {
      'code': 'EXPIRED05',
      'discount': '5%',
      'uses': 500,
      'maxUses': 500,
      'isActive': false
    },
  ];

  void _showAddCouponDialog() {
    final codeCtrl = TextEditingController();
    final discountCtrl = TextEditingController();
    final maxUsesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة كوبون جديد',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(
                  labelText: 'كود الكوبون',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                ),
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            TextField(
                controller: discountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'نسبة الخصم (%)',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                ),
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            TextField(
                controller: maxUsesCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الحد الأقصى للاستخدام',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                ),
                style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              if (codeCtrl.text.isNotEmpty && discountCtrl.text.isNotEmpty) {
                setState(() {
                  _coupons.add({
                    'code': codeCtrl.text.toUpperCase(),
                    'discount': '${discountCtrl.text}%',
                    'uses': 0,
                    'maxUses': int.tryParse(maxUsesCtrl.text) ?? 100,
                    'isActive': true,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ تم إضافة الكوبون بنجاح'),
                    backgroundColor: AppColors.refillGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldLight,
              foregroundColor: const Color(0xFF0A0E1A),
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCouponDialog,
        backgroundColor: AppColors.goldLight,
        foregroundColor: const Color(0xFF0A0E1A),
        icon: const Icon(Icons.add),
        label: const Text('كوبون جديد',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _coupons.length,
        itemBuilder: (context, i) {
          final cp = _coupons[i];
          final isActive = cp['isActive'];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isActive
                      ? AppColors.refillGreen.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.refillGreen.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.confirmation_number,
                      color: isActive
                          ? AppColors.refillGreen
                          : Colors.white54),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cp['code'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text(
                          'خصم ${cp['discount']} • تم استخدامه ${cp['uses']} / ${cp['maxUses']} مرة',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(isActive ? Icons.toggle_on : Icons.toggle_off,
                      size: 32,
                      color: isActive
                          ? AppColors.refillGreen
                          : Colors.white38),
                  onPressed: () {
                    setState(() => cp['isActive'] = !cp['isActive']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(isActive
                              ? 'تم إيقاف الكوبون'
                              : 'تم تفعيل الكوبون'),
                          backgroundColor: isActive
                              ? AppColors.plumberRed
                              : AppColors.refillGreen),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.plumberRed),
                  onPressed: () {
                    setState(() => _coupons.removeAt(i));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حذف الكوبون'),
                        backgroundColor: AppColors.plumberRed,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  التبويب 7: إعلان استضافة
// ═══════════════════════════════════════════════════════════
class _SplashAdsTab extends StatelessWidget {
  const _SplashAdsTab();

  @override
  Widget build(BuildContext context) {
    return const SplashAdsManagementScreen();
  }
}