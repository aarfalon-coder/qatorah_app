import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/screens/provider/create_ad_screen.dart';
import 'package:qatorah_app/screens/provider/provider_wallet_screen.dart';
import 'package:qatorah_app/screens/provider/provider_orders_screen.dart';
import 'package:qatorah_app/screens/provider/provider_stats_screen.dart';
import 'package:qatorah_app/screens/provider/provider_profile_screen.dart';
// تم إزالة استيراد qr_tools_screen مؤقتاً لتجنب خطأ البناء، أو يمكنك إعادته إذا صححت اسم الكلاس
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _currentIndex = 0;
  
  // 🆕 متغيرات التوفر والإشعارات
  bool _isAvailable = true;
  bool _isLoading = true;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  final List<Widget> _screens = [
    const _DashboardTab(),
    const ProviderOrdersScreen(),
    const ProviderStatsScreen(),
    const ProviderProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadAvailabilityStatus();
    _listenForNewOrders();
  }

  // 🆕 1. إعداد الإشعارات
  Future<void> _initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);

    const androidChannel = AndroidNotificationChannel(
      'new_order_channel',
      'طلبات جديدة',
      description: 'إشعارات عند وصول طلب جديد من عميل',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );
    await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(androidChannel);
  }

  //  2. تحميل حالة التوفر من قاعدة البيانات
  Future<void> _loadAvailabilityStatus() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(AuthManager.firebaseUid).get();
    if (doc.exists) {
      setState(() {
        _isAvailable = doc.data()?['isAvailable'] ?? true;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  //  3. تبديل حالة التوفر (متاح / راحة)
  Future<void> _toggleAvailability(bool value) async {
    setState(() => _isAvailable = value);
    await FirebaseFirestore.instance.collection('users').doc(AuthManager.firebaseUid).update({
      'isAvailable': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? '✅ أنت الآن متاح لاستقبال الطلبات' : '⏸️ تم إيقاف استقبال الطلبات (فترة راحة)'),
          backgroundColor: value ? AppColors.refillGreen : AppColors.maintenanceOrange,
        ),
      );
    }
  }

  // 🆕 4. الاستماع للطلبات الجديدة وإطلاق الجرس
  void _listenForNewOrders() {
    FirebaseFirestore.instance
        .collection('orders')
        .where('supplier_id', isEqualTo: AuthManager.firebaseUid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docChanges.isNotEmpty) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added && _isAvailable) {
            _showNewOrderNotification();
          }
        }
      }
    });
  }

  Future<void> _showNewOrderNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'new_order_channel',
      'طلبات جديدة',
      channelDescription: 'إشعارات عند وصول طلب جديد',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'طلب جديد',
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🔔 طلب جديد!',
      'لديك طلب جديد بانتظار الموافقة',
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E1A),
        body: Center(child: CircularProgressIndicator(color: AppColors.goldLight)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0A0A),
        elevation: 0,
        title: const Text('لوحة المزود', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isAvailable ? 'متاح' : 'راحة',
                  style: TextStyle(
                    color: _isAvailable ? AppColors.refillGreen : Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _isAvailable,
                  onChanged: _toggleAvailability,
                  activeThumbColor: AppColors.refillGreen,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ],
      ),
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
        final myAds = mgr.allAds.where((a) => a.publisher.userId == AuthManager.firebaseUid).toList();
        final activeAds = myAds.where((a) => a.isActive).length;
        final pendingAds = myAds.where((a) => a.isPending).length;
        final totalViews = myAds.fold<int>(0, (acc, a) => acc + a.stats.views);

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!AuthManager.isSubscriptionActive) _buildSubscriptionBanner(context),
                if (!AuthManager.isSubscriptionActive) const SizedBox(height: 16),

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
                            Text(
                              'مرحباً، ${AuthManager.firstName.isNotEmpty ? AuthManager.firstName : 'مزود خدمة'} ',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text('رصيدك الحالي', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(
                              '${AuthManager.walletBalance.toStringAsFixed(2)} د.أ',
                              style: const TextStyle(color: AppColors.goldLight, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
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
                          if (!AuthManager.isSubscriptionActive) {
                            _showSubscriptionRequiredDialog(context);
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAdScreen()));
                          }
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
                _buildActionCard(
                  'أدوات QR',
                  'مسح كود العميل أو الكوبون',
                  Icons.qr_code_scanner,
                  AppColors.refillGreen,
                  () {
                    if (!AuthManager.isSubscriptionActive) {
                      _showSubscriptionRequiredDialog(context);
                    } else {
                      // ✅ تم استبدال QrToolsScreen برسالة مؤقتة لضمان نجاح البناء
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ميزة أدوات QR قيد التطوير'), backgroundColor: AppColors.goldLight),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),

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
                    child: const Column(
                      children: [
                        Icon(Icons.inbox, size: 50, color: Colors.white38),
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

  Widget _buildSubscriptionBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.plumberRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.plumberRed.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.plumberRed, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️ اشتراكك منتهي!', style: TextStyle(color: AppColors.plumberRed, fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 4),
                Text('يرجى تجديد الاشتراك لاستقبال الطلبات.', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showRenewSubscriptionDialog(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.plumberRed, foregroundColor: Colors.white),
            child: const Text('تجديد'),
          ),
        ],
      ),
    );
  }

  void _showRenewSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تجديد الاشتراك', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.autorenew, color: AppColors.goldLight, size: 60),
            SizedBox(height: 16),
            Text('سيتم خصم 10 د.أ من محفظتك لتجديد الاشتراك لمدة 30 يوماً.', style: TextStyle(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _renewSubscription(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight, foregroundColor: const Color(0xFF0A0E1A)),
            child: const Text('تأكيد التجديد'),
          ),
        ],
      ),
    );
  }

  Future<void> _renewSubscription(BuildContext context) async {
    try {
      const double renewalPrice = 10.0;
      if (AuthManager.walletBalance < renewalPrice) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ رصيدك غير كافٍ. يرجى شحن المحفظة أولاً.'), backgroundColor: AppColors.plumberRed),
        );
        return;
      }

      final newBalance = AuthManager.walletBalance - renewalPrice;
      final newExpiry = DateTime.now().add(const Duration(days: 30));

      await FirebaseFirestore.instance.collection('users').doc(AuthManager.firebaseUid).update({
        'walletBalance': newBalance,
        'subscriptionExpiryDate': newExpiry.toIso8601String(),
        'subscriptionPaid': true,
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AuthManager.renewSubscription(newExpiry, newBalance);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم تجديد الاشتراك بنجاح لمدة 30 يوماً!'), backgroundColor: AppColors.refillGreen),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' خطأ: $e'), backgroundColor: AppColors.plumberRed),
        );
      }
    }
  }

  void _showSubscriptionRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('⚠️ اشتراك منتهي', style: TextStyle(color: AppColors.plumberRed)),
        content: const Text('يجب تجديد الاشتراك للقيام بهذا الإجراء.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showRenewSubscriptionDialog(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight, foregroundColor: const Color(0xFF0A0E1A)),
            child: const Text('تجديد الآن'),
          ),
        ],
      ),
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