import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'auth_manager.dart';

class NotificationManager extends ChangeNotifier {
  NotificationManager() {
    _initStream();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get allNotifications => List.unmodifiable(_notifications);
  
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  
  int get unreadCount => unreadNotifications.length;

  bool _loading = false;
  bool get isLoading => _loading;

  void _initStream() {
    final userId = AuthManager.firebaseUid;
    if (userId == null || userId.isEmpty) {
      _notifications = [];
      notifyListeners();
      return;
    }

    _db.collection('notifications')
        .where('userId', whereIn: [userId, 'all'])
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
      _loading = false;
      debugPrint('✅ تم تحميل ${_notifications.length} إشعار للمستخدم $userId');
      notifyListeners();
    }, onError: (e) {
      debugPrint('❌ خطأ في تحميل الإشعارات: $e');
      _loading = false;
      notifyListeners();
    });
  }

  void reloadForCurrentUser() {
    _initStream();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحديد كمقروء: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final batch = _db.batch();
      for (final n in unreadNotifications) {
        batch.update(_db.collection('notifications').doc(n.id), {'isRead': true});
      }
      await batch.commit();
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ خطأ في تحديد الكل كمقروء: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).delete();
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ خطأ في الحذف: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final batch = _db.batch();
      for (final n in _notifications) {
        batch.delete(_db.collection('notifications').doc(n.id));
      }
      await batch.commit();
      _notifications = [];
      notifyListeners();
    } catch (e) {
      debugPrint('❌ خطأ في المسح: $e');
    }
  }

  Future<void> sendWelcomeNotification(String userId, String firstName) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: '👋 مرحباً $firstName!',
        message: 'أهلاً بك في قطوره. استكشف خدماتنا واحصل على أفضل عروض المياه والصيانة.',
        category: NotificationCategory.system, // ✅ تم التصحيح هنا من type إلى category
        icon: 'waving_hand',
        colorHex: '#4FC3F7',
        createdAt: DateTime.now(),
      );
      await _db.collection('notifications').add(notification.toFirestore());
    } catch (e) {
      debugPrint('❌ خطأ في إرسال الترحيب: $e');
    }
  }

  Future<void> checkSubscriptionReminder(String userId) async {
    final expiry = AuthManager.subscriptionExpiryDate;
    if (expiry == null) return;

    final daysLeft = expiry.difference(DateTime.now()).inDays;
    
    if (daysLeft == 7) {
      await _db.collection('notifications').add({
        'userId': userId,
        'title': '⏰ اشتراكك ينتهي قريباً',
        'message': 'يتبقى 7 أيام على انتهاء اشتراكك. جدد الآن لتجنب انقطاع الخدمة.',
        'category': 'subscription',
        'icon': 'timer',
        'colorHex': '#FF9800',
        'isRead': false,
        'createdAt': Timestamp.now(),
        'actionRoute': '/subscription',
      });
    }
    
    if (daysLeft <= 0) {
      await _db.collection('notifications').add({
        'userId': userId,
        'title': '⚠️ انتهى اشتراكك',
        'message': 'اشتراكك في قطوره قد انتهى. يرجى تجديد الاشتراك للاستمرار.',
        'category': 'subscription',
        'icon': 'warning_amber_rounded',
        'colorHex': '#F44336',
        'isRead': false,
        'createdAt': Timestamp.now(),
        'actionRoute': '/subscription',
      });
    }
  }

  Future<bool> sendNotification({
    required String title,
    required String message,
    String userId = 'all',
    String icon = 'campaign',
    String colorHex = '#FFD700',
  }) async {
    try {
      await _db.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'category': 'admin',
        'icon': icon,
        'colorHex': colorHex,
        'isRead': false,
        'createdAt': Timestamp.now(),
      });
      debugPrint('✅ تم إرسال الإشعار بنجاح إلى: $userId');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في إرسال الإشعار: $e');
      return false;
    }
  }
}