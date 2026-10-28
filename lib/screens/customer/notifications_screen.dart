import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/notification_manager.dart';
import 'package:qatorah_app/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // المقبض العلوي
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // الترويسة
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.crystalBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_active,
                      color: AppColors.crystalBlue),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'الإشعارات',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Consumer<NotificationManager>(
                  builder: (context, mgr, _) => TextButton(
                    onPressed:
                        mgr.unreadCount > 0 ? () => mgr.markAllAsRead() : null,
                    child: Text(
                      'تحديد الكل كمقروء',
                      style: TextStyle(
                        color: mgr.unreadCount > 0
                            ? AppColors.goldLight
                            : Colors.white24,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // قائمة الإشعارات
          Expanded(
            child: Consumer<NotificationManager>(
              builder: (context, mgr, _) {
                if (mgr.isLoading) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.crystalBlue),
                  );
                }

                final notifications = mgr.allNotifications;

                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off,
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد إشعارات حالياً',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ستظهر هنا إشعارات الاشتراك والعروض والتنبيهات',
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) => _buildNotificationCard(
                      context, mgr, notifications[index]),
                );
              },
            ),
          ),

          // زر مسح الكل في الأسفل
          Consumer<NotificationManager>(
            builder: (context, mgr, _) {
              if (mgr.allNotifications.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmClearAll(context, mgr),
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.plumberRed),
                    label: const Text('مسح كل الإشعارات',
                        style: TextStyle(color: AppColors.plumberRed)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.plumberRed),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationManager mgr,
      NotificationModel notification) {
    final color = _getColorFromHex(notification.colorHex);
    final iconData = _getIconFromString(notification.icon);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppColors.plumberRed,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => mgr.deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () async {
          // 1. تحديد كمقروء
          if (!notification.isRead) {
            await mgr.markAsRead(notification.id);
          }
          if (!context.mounted) return;

          // 2. إغلاق النافذة المنبثقة
          Navigator.pop(context);

          // 3. التنقل الذكي (مجهز للمستقبل)
          _handleNotificationRoute(
              notification.actionRoute, notification.actionData);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? const Color(0xFF1A1F2E)
                : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: notification.isRead
                  ? Colors.white.withValues(alpha: 0.05)
                  : color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.plumberRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _timeAgo(notification.createdAt),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🆕 دالة التنقل الذكي عند الضغط على الإشعار
  void _handleNotificationRoute(String? route, Map<String, dynamic>? data) {
    if (route == null) return;

    // TODO: فك التعليق عن أسطر Navigator.push عندما تكون الشاشات جاهزة
    switch (route) {
      case '/subscription':
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
        debugPrint('🔔 تنقل مطلوب إلى: شاشة الاشتراكات');
        break;
      case '/order_details':
        final orderId = data?['orderId'];
        // Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailsScreen(orderId: orderId)));
        debugPrint('🔔 تنقل مطلوب إلى: تفاصيل الطلب رقم $orderId');
        break;
      case '/offers':
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const OffersScreen()));
        debugPrint('🔔 تنقل مطلوب إلى: شاشة العروض');
        break;
      default:
        debugPrint('🔔 مسار غير معروف: $route');
        break;
    }
  }

  void _confirmClearAll(BuildContext context, NotificationManager mgr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text('تأكيد المسح', style: TextStyle(color: Colors.white)),
        content: const Text('هل تريد مسح كل الإشعارات؟',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              mgr.clearAll();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.plumberRed),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  Color _getColorFromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'notifications':
        return Icons.notifications;
      case 'waving_hand':
        return Icons.waving_hand;
      case 'timer':
        return Icons.timer;
      case 'warning_amber_rounded':
        return Icons.warning_amber_rounded;
      case 'local_offer':
        return Icons.local_offer;
      case 'system_update':
        return Icons.system_update;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'check_circle':
        return Icons.check_circle;
      case 'campaign':
        return Icons.campaign;
      case 'local_shipping':
        return Icons.local_shipping;
      default:
        return Icons.notifications;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
    return 'منذ ${(diff.inDays / 30).floor()} شهر';
  }
}
