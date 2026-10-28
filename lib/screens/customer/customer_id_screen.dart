import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/profile_manager.dart';
import 'package:qatorah_app/screens/account_statement_screen.dart';
import 'package:qatorah_app/screens/customer/payment_history_screen.dart';
import 'package:qatorah_app/screens/customer/wallet_screen.dart';
import 'package:qatorah_app/services/payment_service.dart';

class CustomerIdScreen extends StatefulWidget {
  const CustomerIdScreen({super.key});

  @override
  State<CustomerIdScreen> createState() => _CustomerIdScreenState();
}

class _CustomerIdScreenState extends State<CustomerIdScreen> {
  final PaymentService _paymentService = PaymentService();

  final double _currentBalance = 45.50;

  List<Map<String, dynamic>> _pendingOrders = [];
  bool _isLoadingOrders = true;

  String? _paymentQrData;
  String? _paymentServiceName;
  double? _paymentAmount;
  String? _currentRequestId;
  bool _isGeneratingQr = false;

  @override
  void initState() {
    super.initState();
    _fetchPendingOrders();
  }

  Future<void> _fetchPendingOrders() async {
    setState(() => _isLoadingOrders = true);
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getString('user_id') ??
            prefs.getString('uid') ??
            prefs.getString('userId') ??
            '';
      }

      if (userId.isNotEmpty) {
        final snapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('customerId', isEqualTo: userId)
            .where('status', isEqualTo: 'pending')
            .get();

        setState(() {
          _pendingOrders = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
          _isLoadingOrders = false;
        });
      } else {
        setState(() => _isLoadingOrders = false);
      }
    } catch (e) {
      debugPrint('خطأ في جلب الطلبات المعلقة: $e');
      setState(() => _isLoadingOrders = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A3E), Color(0xFF2D1B69), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildProfileSection(),
                const SizedBox(height: 24),
                _buildDigitalIdCard(),
                const SizedBox(height: 24),
                _buildBalanceCard(),
                const SizedBox(height: 24),
                const Text('الفواتير والطلبات المعلقة',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _isLoadingOrders
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.goldLight))
                    : _pendingOrders.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: _pendingOrders
                                .map((order) => _buildPendingOrderCard(order))
                                .toList(),
                          ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 12),
                const Text('خدمات أخرى',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildServiceOption(
                  icon: Icons.build_circle,
                  title: 'دفع قيمة خدمة / صيانة',
                  subtitle: 'أدخل المبلغ المتفق عليه مع الفني أو المزود',
                  color: AppColors.maintenanceOrange,
                  price: 'ادفع',
                  onTap: () => _showCustomAmountDialog(),
                ),
                const SizedBox(height: 10),
                _buildServiceOption(
                  icon: Icons.receipt_long,
                  title: 'كشف الحساب',
                  subtitle: 'عرض المعاملات والمستحقات',
                  color: AppColors.crystalBlue,
                  price: 'عرض',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AccountStatementScreen())),
                ),
                const SizedBox(height: 10),
                _buildServiceOption(
                  icon: Icons.payment,
                  title: 'سجل المدفوعات',
                  subtitle: 'عرض جميع عمليات الدفع',
                  color: AppColors.refillGreen,
                  price: 'عرض',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PaymentHistoryScreen())),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingOrderCard(Map<String, dynamic> order) {
    final String serviceType = order['serviceType'] ?? 'خدمة';
    final double amount =
        (order['totalAmount'] ?? order['amount'] ?? 0.0).toDouble();
    final String details = order['details'] ??
        (order['quantity'] != null ? '${order['quantity']} وحدة' : '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.goldLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt,
                    color: AppColors.goldLight, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(serviceType,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    if (details.isNotEmpty)
                      Text(details,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12)),
                  ],
                ),
              ),
              Text('${amount.toStringAsFixed(2)} د.أ',
                  style: const TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _generateRealPaymentQr(
                  amount, serviceType, 'wallet',
                  orderId: order['id']),
              icon: const Icon(Icons.qr_code_2, size: 20),
              label: const Text('دفع عبر QR Code',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.refillGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white54, size: 40),
            SizedBox(height: 12),
            Text('لا توجد طلبات معلقة للدفع حالياً',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            Text('جميع فواتيرك مسددة',
                style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showCustomAmountDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descController =
        TextEditingController(text: 'خدمة / صيانة');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('دفع قيمة خدمة',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'وصف الخدمة',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'المبلغ (د.أ)',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('إلغاء', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isEmpty) return;
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount <= 0) return;

              Navigator.pop(ctx);
              _generateRealPaymentQr(amount, descController.text, 'wallet');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maintenanceOrange,
                foregroundColor: Colors.white),
            child: const Text('توليد كود الدفع',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _generateRealPaymentQr(
      double amount, String serviceName, String paymentMethod,
      {String? orderId}) async {
    setState(() => _isGeneratingQr = true);
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getString('user_id') ??
            prefs.getString('uid') ??
            prefs.getString('userId') ??
            'user_${DateTime.now().millisecondsSinceEpoch}';
      }

      final requestId = await _paymentService.createPaymentRequest(
        customerId: userId,
        beneficiaryId: null,
        serviceType: serviceName,
        amount: amount,
        paymentMethod: paymentMethod,
      );
      if (!mounted) return;

      final qrPayload = jsonEncode({
        "orderId": requestId,
        "originalOrderId": orderId,
      });

      setState(() {
        _paymentQrData = qrPayload;
        _paymentServiceName = serviceName;
        _paymentAmount = amount;
        _currentRequestId = requestId;
        _isGeneratingQr = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء طلب الدفع بنجاح! اعرض الكود للبائع.'),
          backgroundColor: AppColors.refillGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (orderId != null) {
        FirebaseFirestore.instance.collection('orders').doc(orderId).update({
          'paymentStatus': 'awaiting_qr_payment',
          'paymentRequestId': requestId,
        }).catchError((e) => debugPrint('فشل تحديث حالة الطلب: $e'));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGeneratingQr = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: AppColors.plumberRed,
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  Widget _buildDigitalIdCard() {
    return Consumer<ProfileManager>(
      builder: (context, profile, child) {
        final isPaymentMode = _paymentQrData != null;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color:
                    isPaymentMode ? AppColors.refillGreen : AppColors.goldLight,
                width: 2),
          ),
          child: Column(
            children: [
              if (isPaymentMode) ...[
                const Icon(Icons.qr_code_2,
                    color: AppColors.refillGreen, size: 40),
                const SizedBox(height: 12),
                const Text('طلب دفع قيد الانتظار',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_paymentServiceName ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text('${_paymentAmount?.toStringAsFixed(2) ?? '0.00'} د.أ',
                    style: const TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
              ] else ...[
                CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    child: const Icon(Icons.person,
                        color: Colors.white, size: 40)),
                const SizedBox(height: 16),
                Text(
                    profile.name.isNotEmpty
                        ? profile.name
                        : 'QASIM ABU AL-BARA',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('ID: 8B-2024-JO',
                        style: TextStyle(
                            color: AppColors.goldLight,
                            fontWeight: FontWeight.bold))),
                const SizedBox(height: 20),
              ],
              GestureDetector(
                onTap: isPaymentMode ? null : () {/* Dialog logic */},
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isPaymentMode
                              ? AppColors.refillGreen
                              : AppColors.goldLight,
                          width: 2)),
                  child: _isGeneratingQr
                      ? const SizedBox(
                          height: 120,
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.goldLight)))
                      : QrImageView(
                          data: isPaymentMode
                              ? _paymentQrData!
                              : 'QATORAH|CUST-1001|${profile.name}',
                          version: QrVersions.auto,
                          size: isPaymentMode ? 220.0 : 120.0,
                          backgroundColor: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                  isPaymentMode
                      ? 'اطلب من البائع مسح هذا الكود'
                      : 'اضغط على الكود لتكبيره',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              if (isPaymentMode) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton.icon(
                            onPressed: () => SharePlus.instance.share(ShareParams(
                                text:
                                    'ادفع قيمة: $_paymentServiceName بمبلغ $_paymentAmount د.أ\nكود: $_currentRequestId')),
                            icon: const Icon(Icons.share),
                            label: const Text('مشاركة'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.crystalBlue,
                                foregroundColor: Colors.white))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: ElevatedButton.icon(
                            onPressed: () async {
                              if (_currentRequestId != null) {
                                await _paymentService
                                    .cancelPaymentRequest(_currentRequestId!);
                              }
                              setState(() {
                                _paymentQrData = null;
                                _paymentServiceName = null;
                                _paymentAmount = null;
                                _currentRequestId = null;
                              });
                            },
                            icon: const Icon(Icons.cancel),
                            label: const Text('إلغاء'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.plumberRed,
                                foregroundColor: Colors.white))),
                  ],
                )
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() =>
      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('حسابي',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
      ]);

  Widget _buildProfileSection() {
    return Consumer<ProfileManager>(
        builder: (context, profile, child) => Row(children: [
              Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.goldLight, width: 2)),
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 30)),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        profile.name.isNotEmpty
                            ? profile.name
                            : 'قاسم أبو البراء',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(profile.email.isNotEmpty ? profile.email : 'عميل مميز',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ])),
            ]));
  }

  Widget _buildBalanceCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WalletScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.refillGreen.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الرصيد المتبقي',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text('${_currentBalance.toStringAsFixed(2)} د.أ',
                    style: const TextStyle(
                        color: AppColors.refillGreen,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('اضغط للدخول إلى المحفظة',
                    style: TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.refillGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_wallet,
                  color: AppColors.refillGreen, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceOption(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required String price,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11))
                ])),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(price,
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
