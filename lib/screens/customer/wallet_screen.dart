import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/services/payment_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final PaymentService _paymentService = PaymentService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  double _balance = 0.0;
  double _creditBalance = 0.0;
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
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
        _userId = userId;
        final doc = await _db.collection('users').doc(userId).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _balance = (data['walletBalance'] ?? 0.0).toDouble();
            _creditBalance = (data['creditBalance'] ?? 0.0).toDouble();
            _isLoading = false;
          });
        } else {
          await _db.collection('users').doc(userId).set({
            'walletBalance': 0.0,
            'creditBalance': 0.0,
            'createdAt': FieldValue.serverTimestamp(),
          });
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('خطأ في تحميل بيانات المستخدم: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshBalance() async {
    if (_userId == null) return;
    try {
      final doc = await _db.collection('users').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _balance = (data['walletBalance'] ?? 0.0).toDouble();
          _creditBalance = (data['creditBalance'] ?? 0.0).toDouble();
        });
      }
    } catch (e) {
      debugPrint('خطأ في تحديث الرصيد: $e');
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.goldLight))
              : RefreshIndicator(
                  onRefresh: _refreshBalance,
                  color: AppColors.goldLight,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildBalanceCard(),
                        const SizedBox(height: 24),
                        _buildCreditCard(),
                        const SizedBox(height: 24),
                        const Text('شحن الرصيد',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildChargeOption(
                          icon: Icons.qr_code_2,
                          title: 'شحن عبر QR (من الموزع)',
                          subtitle: 'اعرض الكود للموزع ليمسحه ويشحن رصيدك',
                          color: AppColors.refillGreen,
                          onTap: () => _showTopupQrDialog(),
                        ),
                        const SizedBox(height: 12),
                        _buildChargeOption(
                          icon: Icons.credit_card,
                          title: 'شحن عبر بطاقة قطوره',
                          subtitle: 'أدخل كود البطاقة و PIN',
                          color: AppColors.goldLight,
                          onTap: () => _showScratchCardDialog(),
                        ),
                        const SizedBox(height: 12),
                        _buildChargeOption(
                          icon: Icons.account_balance,
                          title: 'تحويل بنكي',
                          subtitle: 'حوّل وأرسل صورة الإيصال',
                          color: AppColors.crystalBlue,
                          onTap: () => _showBankTransferDialog(),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 12),
                        const Text('سجل المعاملات',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildTransactionsList(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle),
            child:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
        ),
        const Text('المحفظة',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: _refreshBalance,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle),
            child: const Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.crystalBlue.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Text('الرصيد القابل للسحب',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Text('${_balance.toStringAsFixed(2)} د.أ',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('يمكنك سحب هذا الرصيد أو استخدامه للدفع',
              style: TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCreditCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB8860B), Color(0xFFDAA520)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.goldLight.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.stars, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('رصيد الاستخدام (Credit)',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text('${_creditBalance.toStringAsFixed(2)} د.أ',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('يُستخدم لدفع العمولات فقط - غير قابل للسحب',
              style: TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildChargeOption(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_userId == null) {
      return const Center(
          child: Text('سجل الدخول لعرض المعاملات',
              style: TextStyle(color: Colors.white54)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('transactions')
          .where('userId', isEqualTo: _userId)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.goldLight));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16)),
            child: const Center(
                child: Column(children: [
              Icon(Icons.receipt_long, color: Colors.white54, size: 40),
              SizedBox(height: 12),
              Text('لا توجد معاملات بعد',
                  style: TextStyle(color: Colors.white70))
            ])),
          );
        }
        return Column(
            children: snapshot.data!.docs
                .map((doc) =>
                    _buildTransactionItem(doc.data() as Map<String, dynamic>))
                .toList());
      },
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> data) {
    final amount = (data['amount'] ?? 0.0).toDouble();
    final type = data['type'] ?? 'unknown';
    final timestamp = data['timestamp'] as Timestamp?;
    final isIncome = type == 'topup' || type == 'refund';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: (isIncome ? AppColors.refillGreen : AppColors.plumberRed)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? AppColors.refillGreen : AppColors.plumberRed,
                size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getTransactionTypeName(type),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                    timestamp != null
                        ? _formatDate(timestamp.toDate())
                        : 'غير محدد',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11)),
              ],
            ),
          ),
          Text('${isIncome ? '+' : '-'}${amount.toStringAsFixed(2)} د.أ',
              style: TextStyle(
                  color:
                      isIncome ? AppColors.refillGreen : AppColors.plumberRed,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getTransactionTypeName(String type) {
    switch (type) {
      case 'topup':
        return 'شحن رصيد';
      case 'payment':
        return 'دفع خدمة';
      case 'qr_payment':
        return 'دفع عبر QR';
      case 'refund':
        return 'استرداد';
      default:
        return 'معاملة';
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

  void _showTopupQrDialog() {
    final TextEditingController amountController = TextEditingController();

    showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setDialogState) {
              String? localQrData;
              double? localAmount;
              String? localRequestId;

              return AlertDialog(
                backgroundColor: const Color(0xFF1A1F2E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Text('شحن عبر QR',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          'أدخل المبلغ المراد شحنه، ثم اعرض الكود للموزع',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          suffixText: 'د.أ',
                          suffixStyle:
                              const TextStyle(color: AppColors.goldLight),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (amountController.text.isEmpty) return;
                          final amount =
                              double.tryParse(amountController.text) ?? 0.0;
                          if (amount <= 0) return;

                          if (_userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('يجب تسجيل الدخول أولاً'),
                                    backgroundColor: AppColors.plumberRed));
                            return;
                          }

                          try {
                            final requestId =
                                await _paymentService.createPaymentRequest(
                              customerId: _userId!,
                              beneficiaryId: _userId!,
                              serviceType: 'wallet_topup',
                              amount: amount,
                              paymentMethod: 'cash',
                            );
                            if (!ctx.mounted) return;
                            final qrPayload = jsonEncode({
                              "orderId": requestId,
                              "type": "topup",
                              "amount": amount
                            });

                            setDialogState(() {
                              localQrData = qrPayload;
                              localAmount = amount;
                              localRequestId = requestId;
                            });
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                  content: Text('خطأ: $e'),
                                  backgroundColor: AppColors.plumberRed));
                            }
                          }
                        },
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('توليد كود الشحن'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.refillGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12)),
                      ),
                      if (localQrData != null) ...[
                        const SizedBox(height: 20),
                        Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16)),
                            child: QrImageView(
                                data: localQrData!,
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white)),
                        const SizedBox(height: 12),
                        Text(
                            'المبلغ: ${localAmount?.toStringAsFixed(2) ?? '0.00'} د.أ',
                            style: const TextStyle(
                                color: AppColors.goldLight,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('اطلب من الموزع مسح هذا الكود',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child: ElevatedButton.icon(
                                    onPressed: () => SharePlus.instance.share(
                                        ShareParams(
                                            text:
                                                'أرجو شحن رصيدي بمبلغ ${localAmount?.toStringAsFixed(2) ?? '0.00'} د.أ\nكود الشحن: $localRequestId')),
                                    icon: const Icon(Icons.share, size: 18),
                                    label: const Text('مشاركة',
                                        style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.crystalBlue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10)))),
                            const SizedBox(width: 8),
                            Expanded(
                                child: ElevatedButton.icon(
                                    onPressed: () => setDialogState(() {
                                          localQrData = null;
                                          localAmount = null;
                                          localRequestId = null;
                                        }),
                                    icon: const Icon(Icons.close, size: 18),
                                    label: const Text('إلغاء',
                                        style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.plumberRed,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10)))),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('إغلاق',
                          style: TextStyle(color: Colors.white54)))
                ],
              );
            },
          );
        });
  }

  void _showScratchCardDialog() {
    final TextEditingController codeController = TextEditingController();
    final TextEditingController pinController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1F2E),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('شحن عبر بطاقة قطوره',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.credit_card,
                    color: AppColors.goldLight, size: 50),
                const SizedBox(height: 16),
                const Text('أدخل كود البطاقة و PIN',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                TextField(
                    controller: codeController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        hintText: 'كود البطاقة',
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none))),
                const SizedBox(height: 12),
                TextField(
                    controller: pinController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        hintText: 'PIN',
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none))),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  child: const Text('إلغاء',
                      style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (codeController.text.isEmpty ||
                            pinController.text.isEmpty) {
                          return;
                        }
                        setDialogState(() => isLoading = true);
                        try {
                          await _redeemScratchCard(codeController.text.trim(),
                              pinController.text.trim());
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('تم شحن الرصيد بنجاح!'),
                                  backgroundColor: AppColors.refillGreen));
                          await _refreshBalance();
                        } catch (e) {
                          if (ctx.mounted) {
                            setDialogState(() => isLoading = false);
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                content: Text('خطأ: $e'),
                                backgroundColor: AppColors.plumberRed));
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldLight,
                    foregroundColor: const Color(0xFF0A0E1A),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12)),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Color(0xFF0A0E1A), strokeWidth: 2))
                    : const Text('شحن الآن',
                        style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _redeemScratchCard(String code, String pin) async {
    if (_userId == null) throw Exception('يجب تسجيل الدخول أولاً');
    final snapshot = await _db
        .collection('topup_cards')
        .where('code', isEqualTo: code)
        .where('pin', isEqualTo: pin)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      throw Exception('الكود غير صحيح أو مستخدم مسبقاً');
    }

    final cardDoc = snapshot.docs.first;
    final cardData = cardDoc.data();
    final amount = (cardData['amount'] ?? 0.0).toDouble();

    await _db.runTransaction((transaction) async {
      transaction.update(cardDoc.reference, {
        'status': 'used',
        'usedBy': _userId,
        'usedAt': FieldValue.serverTimestamp()
      });
      transaction.update(_db.collection('users').doc(_userId),
          {'walletBalance': FieldValue.increment(amount)});
      transaction.set(_db.collection('transactions').doc(), {
        'userId': _userId,
        'type': 'topup',
        'amount': amount,
        'description': 'شحن عبر بطاقة قطوره: $code',
        'cardId': cardDoc.id,
        'timestamp': FieldValue.serverTimestamp()
      });
    });
  }

  void _showBankTransferDialog() {
    showDialog(
      context: context,
      builder: (ctx) => FutureBuilder<DocumentSnapshot>(
        future: _db.collection('app_settings').doc('bank_info').get(),
        builder: (ctx, snapshot) {
          // ✅ بيانات آمنة في حال لم يقم الأدمن بإعدادها بعد (بدلاً من أرقام وهمية)
          final bankName = snapshot.hasData && snapshot.data!.exists
              ? (snapshot.data!['bankName'] ?? 'يرجى التواصل مع الإدارة')
              : 'يرجى التواصل مع الإدارة';
          final accountNumber = snapshot.hasData && snapshot.data!.exists
              ? (snapshot.data!['accountNumber'] ?? 'غير متوفر')
              : 'غير متوفر';
          final beneficiaryName = snapshot.hasData && snapshot.data!.exists
              ? (snapshot.data!['beneficiaryName'] ?? 'غير متوفر')
              : 'غير متوفر';
          final iban = snapshot.hasData && snapshot.data!.exists
              ? (snapshot.data!['iban'] ?? 'غير متوفر')
              : 'غير متوفر';
          final whatsappNumber = snapshot.hasData && snapshot.data!.exists
              ? (snapshot.data!['whatsappNumber'] ?? '')
              : '';

          return AlertDialog(
            backgroundColor: const Color(0xFF1A1F2E),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('تحويل بنكي',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  const CircularProgressIndicator(color: AppColors.goldLight)
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0E1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bankInfoRow('اسم البنك', bankName),
                        const SizedBox(height: 12),
                        _bankInfoRow('رقم الحساب', accountNumber),
                        const SizedBox(height: 12),
                        _bankInfoRow('اسم المستفيد', beneficiaryName),
                        const SizedBox(height: 12),
                        _bankInfoRow('IBAN', iban),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'بعد إتمام التحويل، يرجى إرسال صورة الإيصال عبر واتساب ليتم شحن رصيدك يدوياً من قبل الإدارة.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إغلاق',
                    style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton.icon(
                onPressed: whatsappNumber.isNotEmpty
                    ? () => _openWhatsApp(whatsappNumber)
                    : null,
                icon: const Icon(Icons.message, color: Color(0xFF25D366)),
                label: const Text('إرسال الإيصال',
                    style: TextStyle(
                        color: Color(0xFF25D366), fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final Uri whatsappUri = Uri.parse(
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent('مرحباً، أود إرسال إيصال تحويل بنكي لشحن رصيد تطبيق قطوره.')}");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('لا يمكن فتح تطبيق واتساب. تأكد من تثبيته.'),
              backgroundColor: AppColors.plumberRed),
        );
      }
    }
  }

  Widget _bankInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Flexible(
          child: Text(value,
              style: const TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
