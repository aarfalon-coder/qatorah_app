import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

/// ═══════════════════════════════════════════════════════════
/// NotificationService — إدارة الإشعارات الفورية
/// ═══════════════════════════════════════════════════════════

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted notification permission');
      } else {
        debugPrint('⚠️ User declined notification permission');
        return;
      }

      _fcmToken = await _fcm.getToken();
      debugPrint('📱 FCM Token: $_fcmToken');

      _fcm.onTokenRefresh.listen((token) {
        _fcmToken = token;
        debugPrint('🔄 FCM Token refreshed: $token');
      });

      await _initLocalNotifications();
      _setupListeners();
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  void _setupListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Foreground message: ${message.notification?.title}');
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? 'قطوره',
          body: message.notification!.body ?? '',
          payload: message.data['route'],
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('👆 User tapped notification: ${message.data}');
      _handleNotificationRoute(message.data);
    });

    _fcm.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationRoute(message.data);
      }
    });
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'qatorah_channel',
      'قطوره - الإشعارات',
      channelDescription: 'إشعارات الطلبات والتنبيهات',
      importance: Importance.high,
      priority: Priority.high,
      color: AppColors.goldLight,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('👆 Local notification tapped: ${response.payload}');
  }

  void _handleNotificationRoute(Map<String, dynamic> data) {
    final route = data['route'];
    debugPrint('🧭 Navigate to: $route');
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing: $e');
    }
  }

  Future<void> notifyNewOrder(String providerId, String orderId) async {
    await showLocalNotification(
      title: '🛒 طلب جديد',
      body: 'لديك طلب جديد رقم: $orderId',
      payload: '/orders/$orderId',
    );
  }

  Future<void> notifyOrderStatus(
      String customerId, String orderId, String status) async {
    await showLocalNotification(
      title: '📦 تحديث الطلب',
      body: 'الطلب $orderId: $status',
      payload: '/orders/$orderId',
    );
  }

  Future<void> notifyAdApproved(String adId) async {
    await showLocalNotification(
      title: '✅ تم اعتماد إعلانك',
      body: 'إعلانك رقم $adId تم نشره بنجاح',
      payload: '/my-ads/$adId',
    );
  }

  Future<void> notifyAdRejected(String adId, String reason) async {
    await showLocalNotification(
      title: '❌ تم رفض إعلانك',
      body: 'السبب: $reason',
      payload: '/my-ads/$adId',
    );
  }

  Future<void> notifyRenewalReminder(String adId, int daysLeft) async {
    await showLocalNotification(
      title: '⏰ تذكير تجديد',
      body: 'إعلانك رقم $adId ينتهي خلال $daysLeft يوم',
      payload: '/my-ads/$adId',
    );
  }

  Future<void> notifyNewReport(String reportId) async {
    await showLocalNotification(
      title: '🚨 بلاغ جديد',
      body: 'يوجد بلاغ جديد #$reportId بحاجة للمراجعة',
      payload: '/admin/reports/$reportId',
    );
  }

  Future<void> notifyPayment(String amount, String description) async {
    await showLocalNotification(
      title: '💰 عملية دفع',
      body: '$description - $amount د.أ',
    );
  }

  Future<void> notifyNewRating(String stars) async {
    await showLocalNotification(
      title: '⭐ تقييم جديد',
      body: 'حصلت على $stars نجوم',
    );
  }
}