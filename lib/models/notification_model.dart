import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationCategory {
  system,        // تحديثات التطبيق، ترحيب، صيانة
  subscription,  // انتهاء أو تجديد الاشتراك
  order,         // تغيير حالة طلب
  offer,         // عروض المنطقة أو الكوبونات
  admin,         // رسائل يدوية من الإدارة
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationCategory category;
  final String icon;
  final String colorHex;
  final bool isRead;
  final DateTime createdAt;
  final String? actionRoute;      // 🆕 مسار التنقل عند النقر
  final Map<String, dynamic>? actionData; // 🆕 بيانات إضافية (مثل رقم الطلب)
  final int priority;             // 🆕 1: عالي، 2: متوسط، 3: منخفض

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.category = NotificationCategory.system,
    this.icon = 'notifications',
    this.colorHex = '#4FC3F7',
    this.isRead = false,
    required this.createdAt,
    this.actionRoute,
    this.actionData,
    this.priority = 2,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      category: _parseCategory(data['category']),
      icon: data['icon'] ?? 'notifications',
      colorHex: data['colorHex'] ?? '#4FC3F7',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      actionRoute: data['actionRoute'],
      actionData: data['actionData'],
      priority: data['priority'] ?? 2,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'title': title,
    'message': message,
    'category': category.name,
    'icon': icon,
    'colorHex': colorHex,
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
    'actionRoute': actionRoute,
    'actionData': actionData,
    'priority': priority,
  };

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id, userId: userId, title: title, message: message,
    category: category, icon: icon, colorHex: colorHex,
    isRead: isRead ?? this.isRead, createdAt: createdAt,
    actionRoute: actionRoute, actionData: actionData, priority: priority,
  );

  static NotificationCategory _parseCategory(String? cat) {
    try { return NotificationCategory.values.byName(cat ?? 'system'); }
    catch (_) { return NotificationCategory.system; }
  }
}