import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceRequestModel {
  final String id;
  final String customerId;
  final String? technicianId;
  final List<String> images;
  final String textDescription; // ✅ الوصف النصي الإجباري
  final List<Map<String, String>> aiChatHistory; // ✅ سجل محادثة الذكاء الاصطناعي
  final String? aiFinalDiagnosis;
  final String status; // pending, assigned, in_progress, completed, cancelled
  final DateTime createdAt;

  const MaintenanceRequestModel({
    required this.id,
    required this.customerId,
    this.technicianId,
    required this.images,
    required this.textDescription,
    this.aiChatHistory = const [],
    this.aiFinalDiagnosis,
    this.status = 'pending',
    required this.createdAt,
  });

  // ✅ تحويل من Firestore إلى Object
  factory MaintenanceRequestModel.fromMap(Map<String, dynamic> map, String id) {
    List<Map<String, String>> chatHistory = [];
    if (map['ai_chat_history'] != null) {
      for (var item in map['ai_chat_history']) {
        chatHistory.add(Map<String, String>.from(item));
      }
    }

    return MaintenanceRequestModel(
      id: id,
      customerId: map['customer_id'] ?? '',
      technicianId: map['technician_id'],
      images: List<String>.from(map['images'] ?? []),
      textDescription: map['text_description'] ?? 'لا يوجد وصف',
      aiChatHistory: chatHistory,
      aiFinalDiagnosis: map['ai_final_diagnosis'],
      status: map['status'] ?? 'pending',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ✅ تحويل من Object إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'technician_id': technicianId,
      'images': images,
      'text_description': textDescription,
      'ai_chat_history': aiChatHistory,
      'ai_final_diagnosis': aiFinalDiagnosis,
      'status': status,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}