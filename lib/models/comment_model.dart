import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;
  final int likes;
  final List<CommentModel> replies;
  
  // حقول جديدة لدعم نظام الإبلاغ
  final bool isReported;
  final String? reportReason;
  final int reportCount;

  const CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    this.likes = 0,
    this.replies = const [],
    this.isReported = false,
    this.reportReason,
    this.reportCount = 0,
  });

  CommentModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? text,
    DateTime? createdAt,
    int? likes,
    List<CommentModel>? replies,
    bool? isReported,
    String? reportReason,
    int? reportCount,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      replies: replies ?? this.replies,
      isReported: isReported ?? this.isReported,
      reportReason: reportReason ?? this.reportReason,
      reportCount: reportCount ?? this.reportCount,
    );
  }

  factory CommentModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return CommentModel(
      id: documentId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'مستخدم',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: data['likes'] ?? 0,
      replies: (data['replies'] as List?)
          ?.map((e) => CommentModel.fromFirestore(e as Map<String, dynamic>, ''))
          .toList() ?? [],
      isReported: data['isReported'] ?? false,
      reportReason: data['reportReason'],
      reportCount: data['reportCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'replies': replies.map((e) => e.toFirestore()).toList(),
      'isReported': isReported,
      'reportReason': reportReason,
      'reportCount': reportCount,
    };
  }
}