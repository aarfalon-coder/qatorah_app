import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/services/qr_service.dart';

class CustomerQrScreen extends StatefulWidget {
  const CustomerQrScreen({super.key});

  @override
  State<CustomerQrScreen> createState() => _CustomerQrScreenState();
}

class _CustomerQrScreenState extends State<CustomerQrScreen> {
  String _qrData = '';
  String _qrLabel = 'جاري التحميل...';
  String? _orderId;
  double? _orderAmount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveOrder();
  }

  Future<void> _loadActiveOrder() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() {
          _qrLabel = 'يرجى تسجيل الدخول';
          _isLoading = false;
        });
        return;
      }

      // جلب آخر طلب نشط (pending/paid)
      final snap = await FirebaseFirestore.instance
          .collection('orders')
          .where('customerId', isEqualTo: uid)
          .where('status', whereIn: ['pending', 'accepted', 'in_progress'])
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final order = snap.docs.first;
        final data = order.data();
        setState(() {
          _orderId = order.id;
          _orderAmount = (data['amount'] ?? data['price'] ?? 0).toDouble();
          _qrData = QrService.generateOrderQr(order.id);
          _qrLabel = 'كود دفع الطلب #${order.id.substring(0, order.id.length > 6 ? 6 : order.id.length)}';
          _isLoading = false;
        });
      } else {
        // ما في طلب نشط → نعرض بطاقة الهوية
        setState(() {
          _qrData = QrService.generateUserQr(uid);
          _qrLabel = 'بطاقتي الرقمية';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _qrLabel = 'خطأ في التحميل: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'بطاقة العميل الرقمية',
          style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.goldLight),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadActiveOrder();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.goldLight))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1F2E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _orderId != null ? Icons.receipt_long : Icons.person,
                          color: AppColors.waterBlue,
                          size: 55,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _qrLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_orderAmount != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'المبلغ: ${_orderAmount!.toStringAsFixed(2)} د.أ',
                            style: const TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'أبرز هذا الكود لمزود الخدمة',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.goldLight, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldLight.withValues(alpha: 0.4),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: 220.0,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF0A0E1A),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF0A0E1A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_orderId != null)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check_circle, size: 20),
                        label: const Text(
                          'تم الدفع بنجاح',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.refillGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}