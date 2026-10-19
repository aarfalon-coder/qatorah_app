import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qatorah_app/models/order_model.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// حفظ طلب جديد في Firestore
  static Future<String> createOrder(OrderModel order) async {
    try {
      // إنشاء مرجع لمستند جديد في مجموعة 'orders'
      DocumentReference docRef = _firestore.collection('orders').doc();
      
      // إضافة معرف المستند للكائن قبل الحفظ
      final orderWithId = OrderModel(
        id: docRef.id,
        customerId: order.customerId,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        serviceType: order.serviceType,
        details: order.details,
        latitude: order.latitude,
        longitude: order.longitude,
        address: order.address,
        locationLabel: order.locationLabel,
        notes: order.notes,
        status: order.status,
        timestamp: order.timestamp,
      );

      // حفظ البيانات في Firestore
      await docRef.set(orderWithId.toMap());
      
      return docRef.id; // إرجاع معرف الطلب للنجاح
    } catch (e) {
      throw Exception('فشل في حفظ الطلب: $e');
    }
  }
}