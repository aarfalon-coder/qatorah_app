import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/screens/provider/create_ad_screen.dart';
import 'package:qatorah_app/screens/settings/profile_settings_screen.dart';
import 'package:qatorah_app/screens/customer/support_screen.dart';
import 'package:qatorah_app/screens/provider/provider_change_password_screen.dart';
import 'package:qatorah_app/screens/provider/provider_notifications_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardTab(),
          _OrdersTab(),
          _StatsTab(),
          _ProfileTab(),
        ],
      ),
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

// ══════════════════════════════════════════════════════════
//  التبويب 1: الرئيسية (Dashboard)
// ═══════════════════════════════════════════════════════════
class _DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdvertisementManager>(
      builder: (context, mgr, _) {
        final myAds = mgr.allAds.where((a) => a.publisher.userId == 'usr_provider_001').toList();
        final activeAds = myAds.where((a) => a.isActive).length;
        final pendingAds = myAds.where((a) => a.isPending).length;
        final totalViews = myAds.fold<int>(0, (sum, a) => sum + a.stats.views);

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showWalletDetails(context),
                  child: Container(
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
                ),
                const SizedBox(height: 24),

                const Text('نظرة سريعة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard('إعلانات نشطة', '$activeAds', Icons.check_circle, AppColors.refillGreen, () {
                      _showAdsDetails(context, 'النشطة', activeAds);
                    }),
                    const SizedBox(width: 12),
                    _buildStatCard('قيد المراجعة', '$pendingAds', Icons.hourglass_empty, AppColors.goldLight, () {
                      _showAdsDetails(context, 'قيد المراجعة', pendingAds);
                    }),
                    const SizedBox(width: 12),
                    _buildStatCard('المشاهدات', '$totalViews', Icons.visibility, AppColors.crystalBlue, () {
                      _showViewsDetails(context, totalViews);
                    }),
                  ],
                ),
                const SizedBox(height: 24),

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
                          _showWalletDialog(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('إعلاناتي الأخيرة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                
                if (myAds.isEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAdScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.add_circle_outline, size: 50, color: AppColors.goldLight.withValues(alpha: 0.5)),
                          const SizedBox(height: 10),
                          const Text('اضغط لإنشاء أول إعلان', style: TextStyle(color: AppColors.goldLight, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
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
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
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

    return GestureDetector(
      onTap: () => _showAdDetails(context, ad),
      child: Container(
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
                      _showCancelAdDialog(context, mgr, ad);
                    },
                    child: const Icon(Icons.delete_outline, color: AppColors.plumberRed, size: 20),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تفاصيل المحفظة', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet, color: AppColors.goldLight, size: 60),
            const SizedBox(height: 16),
            const Text('الرصيد المتاح', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const Text('150.00 د.أ', style: TextStyle(color: AppColors.goldLight, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            _walletInfoRow('أرباح هذا الشهر', '125.00 د.أ', AppColors.refillGreen),
            _walletInfoRow('مبيعات الإعلانات', '25.00 د.أ', AppColors.crystalBlue),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showWithdrawDialog(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight, foregroundColor: const Color(0xFF0A0E1A)),
            child: const Text('سحب الأرباح'),
          ),
        ],
      ),
    );
  }

  Widget _walletInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAdsDetails(BuildContext context, String type, int count) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('إعلانات $type', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.dashboard, size: 50, color: AppColors.goldLight),
            const SizedBox(height: 16),
            Text('لديك $count إعلان $type', style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 10),
            const Text('اضغط على أي إعلان لعرض التفاصيل', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً', style: TextStyle(color: AppColors.goldLight)),
          ),
        ],
      ),
    );
  }

  void _showViewsDetails(BuildContext context, int views) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تفاصيل المشاهدات', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.visibility, size: 50, color: AppColors.crystalBlue),
            const SizedBox(height: 16),
            Text('إجمالي المشاهدات: $views', style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 10),
            const Text('مشاهدات اليوم: 45', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const Text('مشاهدات الأمس: 38', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً', style: TextStyle(color: AppColors.goldLight)),
          ),
        ],
      ),
    );
  }

  void _showWalletDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('محفظة المزود', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet, color: AppColors.goldLight, size: 50),
            SizedBox(height: 16),
            Text('رصيدك المتاح', style: TextStyle(color: Colors.white70, fontSize: 14)),
            Text('150.00 د.أ', style: TextStyle(color: AppColors.goldLight, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showWithdrawDialog(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight, foregroundColor: const Color(0xFF0A0E1A)),
            child: const Text('سحب الأرباح'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('سحب الأرباح', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('رصيدك المتاح: 150.00 د.أ', style: TextStyle(color: AppColors.goldLight, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'أدخل المبلغ المراد سحبه',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                filled: true,
                fillColor: const Color(0xFF0A0E1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ تم إرسال طلب سحب مبلغ ${amountCtrl.text} د.أ'), backgroundColor: AppColors.refillGreen),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight, foregroundColor: const Color(0xFF0A0E1A)),
            child: const Text('تأكيد السحب'),
          ),
        ],
      ),
    );
  }

  void _showAdDetails(BuildContext context, AdvertisementModel ad) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(ad.title, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ad.description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            _infoRowDash('المشاهدات', '${ad.stats.views}', Icons.visibility),
            _infoRowDash('المدة', '${ad.duration.days} يوم', Icons.calendar_today),
            _infoRowDash('النطاق', ad.scope.label, Icons.location_on),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Widget _infoRowDash(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.goldLight),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showCancelAdDialog(BuildContext context, AdvertisementManager mgr, AdvertisementModel ad) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إلغاء الإعلان', style: TextStyle(color: AppColors.plumberRed)),
        content: Text('هل أنت متأكد من إلغاء إعلان "${ad.title}"؟', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لا', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              mgr.deleteAd(ad.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إلغاء الإعلان'), backgroundColor: AppColors.plumberRed),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.plumberRed),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  التبويب 2: الطلبات
// ═══════════════════════════════════════════════════════════
class _OrdersTab extends StatefulWidget {
  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _orders = [
    {'id': '1', 'customer': 'أحمد محمد', 'service': 'أسطوانة غاز', 'status': 'new', 'time': '12:10 م', 'amount': '12.50 د.أ'},
    {'id': '2', 'customer': 'سارة علي', 'service': 'تنك مياه', 'status': 'progress', 'time': '11:45 ص', 'amount': '8.00 د.أ'},
    {'id': '3', 'customer': 'محمد حسن', 'service': 'صيانة خزان', 'status': 'completed', 'time': '10:30 ص', 'amount': '25.00 د.أ'},
    {'id': '4', 'customer': 'فاطمة أحمد', 'service': 'أسطوانة غاز', 'status': 'cancelled', 'time': 'أمس', 'amount': '12.50 د.أ'},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('all', 'الكل', Icons.list),
                _buildFilterChip('new', 'جديد', Icons.fiber_new),
                _buildFilterChip('progress', 'قيد التنفيذ', Icons.hourglass_empty),
                _buildFilterChip('completed', 'مكتمل', Icons.check_circle),
                _buildFilterChip('cancelled', 'ملغي', Icons.cancel),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _orders.length,
              itemBuilder: (context, index) => _buildOrderCard(_orders[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label, style: TextStyle(color: isSelected ? const Color(0xFF0A0E1A) : Colors.white, fontSize: 12)),
        avatar: Icon(icon, size: 16, color: isSelected ? const Color(0xFF0A0E1A) : Colors.white54),
        onSelected: (selected) => setState(() => _selectedFilter = value),
        backgroundColor: const Color(0xFF1A1F2E),
        selectedColor: AppColors.goldLight,
        checkmarkColor: const Color(0xFF0A0E1A),
        side: BorderSide(color: isSelected ? AppColors.goldLight : Colors.white.withValues(alpha: 0.1)),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (order['status']) {
      case 'new':
        statusColor = AppColors.crystalBlue;
        statusText = 'جديد';
        statusIcon = Icons.fiber_new;
        break;
      case 'progress':
        statusColor = AppColors.goldLight;
        statusText = 'قيد التنفيذ';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'completed':
        statusColor = AppColors.refillGreen;
        statusText = 'مكتمل';
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = AppColors.plumberRed;
        statusText = 'ملغي';
        statusIcon = Icons.cancel;
    }

    return GestureDetector(
      onTap: () => _showOrderDetails(context, order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('طلب #${order['id']}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(order['customer'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.shopping_bag, size: 16, color: Colors.white54),
                const SizedBox(width: 6),
                Text(order['service'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const Spacer(),
                const Icon(Icons.access_time, size: 16, color: Colors.white54),
                const SizedBox(width: 6),
                Text(order['time'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'المبلغ: ${order['amount']}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.goldLight, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showUpdateStatusDialog(context, order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('تحديث الحالة', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('تفاصيل طلب #${order['id']}', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('العميل', order['customer'], Icons.person),
            _infoRow('الخدمة', order['service'], Icons.shopping_bag),
            _infoRow('الوقت', order['time'], Icons.access_time),
            _infoRow('المبلغ', order['amount'], Icons.attach_money),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  // ✅ تم إضافة هذه الدالة هنا لحل خطأ "The method '_infoRow' isn't defined"
  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.goldLight),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('تحديث حالة طلب #${order['id']}', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('الحالة الحالية:', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            Text(order['status'], style: const TextStyle(color: AppColors.goldLight, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('اختر الحالة الجديدة:', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 10),
            _statusButton(ctx, 'جديد', 'new', AppColors.crystalBlue),
            _statusButton(ctx, 'قيد التنفيذ', 'progress', AppColors.goldLight),
            _statusButton(ctx, 'مكتمل', 'completed', AppColors.refillGreen),
            _statusButton(ctx, 'ملغي', 'cancelled', AppColors.plumberRed),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(BuildContext ctx, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('✅ تم تحديث الحالة إلى: $label'), backgroundColor: color),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.2),
            foregroundColor: color,
            side: BorderSide(color: color),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  التبويب 3: الإحصائيات
// ═══════════════════════════════════════════════════════════
class _StatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ملخص الأرباح', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildEarningsCard('اليوم', '45.00', 'د.أ', AppColors.crystalBlue, Icons.today, context),
                const SizedBox(width: 12),
                _buildEarningsCard('الأسبوع', '280.50', 'د.أ', AppColors.goldLight, Icons.date_range, context),
                const SizedBox(width: 12),
                _buildEarningsCard('الشهر', '1,250.00', 'د.أ', AppColors.refillGreen, Icons.calendar_month, context),
              ],
            ),
            const SizedBox(height: 30),

            const Text('أداء الإعلانات', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildStatRow('إجمالي المشاهدات', '1,234', Icons.visibility, AppColors.crystalBlue),
                  const SizedBox(height: 16),
                  _buildStatRow('إجمالي النقرات', '89', Icons.touch_app, AppColors.goldLight),
                  const SizedBox(height: 16),
                  _buildStatRow('معدل التحويل', '7.2%', Icons.trending_up, AppColors.refillGreen),
                  const SizedBox(height: 16),
                  _buildStatRow('الإعلانات النشطة', '3', Icons.check_circle, AppColors.goldLight),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text('أداء الطلبات', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildStatRow('طلبات اليوم', '12', Icons.shopping_bag, AppColors.crystalBlue),
                  const SizedBox(height: 16),
                  _buildStatRow('طلبات مكتملة', '156', Icons.check_circle, AppColors.refillGreen),
                  const SizedBox(height: 16),
                  _buildStatRow('طلبات ملغاة', '8', Icons.cancel, AppColors.plumberRed),
                  const SizedBox(height: 16),
                  _buildStatRow('متوسط التقييم', '4.8 ⭐', Icons.star, AppColors.goldLight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard(String period, String amount, String currency, Color color, IconData icon, BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1A1F2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('أرباح $period', style: const TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 50, color: color),
                  const SizedBox(height: 16),
                  Text('$amount $currency', style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('تفاصيل الأرباح لهذا الفترة', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('حسناً', style: TextStyle(color: AppColors.goldLight)),
                ),
              ],
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(period, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(amount, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(currency, style: TextStyle(color: color, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  التبويب 4: حسابي
// ═══════════════════════════════════════════════════════════
class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.goldLight, width: 3),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.goldLight,
                      child: Icon(Icons.store, size: 50, color: Color(0xFF0A0E1A)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AuthManager.firstName.isNotEmpty ? AuthManager.firstName : 'مزود خدمة',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AuthManager.phone.isNotEmpty ? AuthManager.phone : '0791234567',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      AuthManager.providerServiceType.isNotEmpty ? AuthManager.providerServiceType : 'صاحب محطة',
                      style: const TextStyle(color: AppColors.goldLight, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildProfileOption(Icons.edit, 'تعديل البيانات الشخصية', 'الاسم، الهاتف، الصورة', AppColors.crystalBlue, context, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()));
            }),
            // ✅ تم إزالة const من هنا
            _buildProfileOption(Icons.lock, 'تغيير كلمة المرور', 'تحديث كلمة السر', AppColors.goldLight, context, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProviderChangePasswordScreen()));
            }),
            // ✅ تم إزالة const من هنا
            _buildProfileOption(Icons.notifications, 'إعدادات الإشعارات', 'تخصيص التنبيهات', AppColors.refillGreen, context, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProviderNotificationsScreen()));
            }),
            _buildProfileOption(Icons.help, 'المساعدة والدعم', 'تواصل معنا', AppColors.crystalBlue, context, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
            }),
            _buildProfileOption(Icons.info, 'عن التطبيق', 'الإصدار والشروط', Colors.white54, context, () {
              _showAboutDialog(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle, Color color, BuildContext context, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        trailing: const Icon(Icons.chevron_left, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('عن التطبيق', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info, size: 50, color: Colors.white54),
            SizedBox(height: 16),
            Text('قطوره - نظام المياه الذكي', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('الإصدار 1.0.0', style: TextStyle(color: Colors.white70, fontSize: 12)),
            SizedBox(height: 5),
            Text('المطور: قاسم مطاحن', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً', style: TextStyle(color: AppColors.goldLight)),
          ),
        ],
      ),
    );
  }
}