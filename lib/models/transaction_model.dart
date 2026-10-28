import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String type; // 'payment', 'recharge', 'refund', 'commission'
  final double amount;
  final String paymentMethod;
  final String status; // 'completed', 'pending', 'failed'
  final String description;

  final String? orderId;
  final String? adId;
  final String? referenceId;

  final String? customerId;
  final String? providerId;
  final double commission;
  final double providerNet;

  final double balanceBefore;
  final double balanceAfter;

  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.description,
    this.orderId,
    this.adId,
    this.referenceId,
    this.customerId,
    this.providerId,
    this.commission = 0.0,
    this.providerNet = 0.0,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? 'payment',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'unknown',
      status: json['status'] ?? 'pending',
      description: json['description'] ?? '',
      orderId: json['orderId'] as String?,
      adId: json['adId'] as String?,
      referenceId: json['referenceId'] as String?,
      customerId: json['customerId'] as String?,
      providerId: json['providerId'] as String?,
      commission: (json['commission'] ?? 0).toDouble(),
      providerNet: (json['providerNet'] ?? 0).toDouble(),
      balanceBefore: (json['balanceBefore'] ?? 0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0).toDouble(),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'description': description,
      'orderId': orderId,
      'adId': adId,
      'referenceId': referenceId,
      'customerId': customerId,
      'providerId': providerId,
      'commission': commission,
      'providerNet': providerNet,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}