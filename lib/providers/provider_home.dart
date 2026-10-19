import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/screens/provider/create_ad_screen.dart';

// ✅ تم إضافة هذا السطر لإصلاح خطأ kMockProviderId غير معرف
const String kMockProviderId = "mock_provider_123";

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
        children: const [
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

// ═══════════════════════════════════════════════════════════
//  التبويب 1: الرئيسية (Dashboard)
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
                // ═══ بطاقة الترحيب والرصيد ═══
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

                // ═══ الإحصائيات السريعة ═══
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

                // ═══ الإجراءات السريعة ═══
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

                // ═══ إعلاناتي الأخيرة ═══
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('إعلاناتي الأخيرة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                    child: const Column(
                      children: [
                        Icon(Icons.inbox, size: 50, color: Colors.white54),
                        SizedBox(height: 10),
                        Text('لم تنشر أي إعلانات بعد', style: TextStyle(color: Colors.white54)),
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
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
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
              // ✅ تم إصلاح الخطأ: إعادة days بدلاً من inDays لأن النوع هو AdDuration
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
            SizedBox(height: 16),
            Text('سيتم تفعيل السحب الكامل قريباً', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(color: AppColors.goldLight)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  التبويب 2: الطلبات
// ═══════════════════════════════════════════════════════════
class _OrdersTab extends StatefulWidget {
  const _OrdersTab();

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _orders = const [
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

    return Container(
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم تحديث حالة الطلب #${order['id']}'), backgroundColor: AppColors.refillGreen),
                    );
                  },
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
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  التبويب 3: الإحصائيات
// ══════════════════════════════════════════════════════════
class _StatsTab extends StatelessWidget {
  const _StatsTab();

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
                _buildEarningsCard('اليوم', '45.00', 'د.أ', AppColors.crystalBlue, Icons.today),
                const SizedBox(width: 12),
                _buildEarningsCard('الأسبوع', '280.50', 'د.أ', AppColors.goldLight, Icons.date_range),
                const SizedBox(width: 12),
                _buildEarningsCard('الشهر', '1,250.00', 'د.أ', AppColors.refillGreen, Icons.calendar_month),
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

  Widget _buildEarningsCard(String period, String amount, String currency, Color color, IconData icon) {
    return Expanded(
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
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
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
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  التبويب 4: حسابي
// ═══════════════════════════════════════════════════════════
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

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

            _buildProfileOption(Icons.edit, 'تعديل البيانات الشخصية', 'الاسم، الهاتف، الصورة', AppColors.crystalBlue, context),
            _buildProfileOption(Icons.lock, 'تغيير كلمة المرور', 'تحديث كلمة السر', AppColors.goldLight, context),
            _buildProfileOption(Icons.notifications, 'إعدادات الإشعارات', 'تخصيص التنبيهات', AppColors.refillGreen, context),
            _buildProfileOption(Icons.help, 'المساعدة والدعم', 'تواصل معنا', AppColors.crystalBlue, context),
            _buildProfileOption(Icons.info, 'عن التطبيق', 'الإصدار والشروط', Colors.white54, context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle, Color color, BuildContext context) {
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
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.chevron_left, color: Colors.white38),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title قيد التطوير'), backgroundColor: AppColors.navyDark),
          );
        },
      ),
    );
  }
}