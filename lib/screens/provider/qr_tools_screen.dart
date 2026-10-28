import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/services/payment_service.dart';

class ProviderQrToolsScreen extends StatefulWidget {
  const ProviderQrToolsScreen({super.key});

  @override
  State<ProviderQrToolsScreen> createState() => _ProviderQrToolsScreenState();
}

class _ProviderQrToolsScreenState extends State<ProviderQrToolsScreen> {
  final PaymentService _paymentService = PaymentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isProcessing = false;
  Map<String, dynamic>? _scannedData;
  String? _errorMessage;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || _scannedData != null) return;

    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        try {
          final decoded = jsonDecode(barcode.rawValue!) as Map<String, dynamic>;
          
          if (decoded.containsKey('orderId')) {
            setState(() {
              _scannedData = decoded;
              _errorMessage = null;
            });
            _cameraController.stop();
            _fetchOrderDetails(decoded['orderId'] as String);
            return;
          } else {
            setState(() => _errorMessage = 'كود QR غير صالح لنظام الدفع');
          }
        } catch (e) {
          setState(() => _errorMessage = 'تنسيق كود QR غير معروف');
        }
      }
    }
  }

  Future<void> _fetchOrderDetails(String requestId) async {
    setState(() => _isProcessing = true);
    try {
      final details = await _paymentService.getPaymentRequestDetails(requestId);
      if (details != null && mounted) {
        setState(() {
          _scannedData = {..._scannedData!, ...details};
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isProcessing = false;
          _scannedData = null;
        });
        _cameraController.start();
      }
    }
  }

  Future<void> _confirmPayment() async {
    if (_scannedData == null || _scannedData!['requestId'] == null) return;

    setState(() => _isProcessing = true);
    try {
      final providerId = _auth.currentUser?.uid;
      if (providerId == null) throw Exception('المزود غير مسجل الدخول');

      await _paymentService.completePaymentTransaction(
        requestId: _scannedData!['requestId'] as String,
        providerId: providerId,
      );

      if (mounted) {
        Navigator.pop(context);
        _showSuccessAndReviewDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isProcessing = false;
        });
        _cameraController.start();
      }
    }
  }

  void _showSuccessAndReviewDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تمت العملية بنجاح! ✅', style: TextStyle(color: AppColors.refillGreen)),
        content: const Text('تم حرق الكود وتحديث الأرصدة. يمكنك الآن تقييم العميل.', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لاحقاً', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight, foregroundColor: const Color(0xFF0A0E1A)),
            child: const Text('تقييم الآن'),
          ),
        ],
      ),
    );
  }

  void _resetScanner() {
    setState(() {
      _scannedData = null;
      _errorMessage = null;
    });
    _cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مسح كود الدفع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A0E1A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFF0A0E1A),
        child: Column(
          children: [
            Expanded(
              child: _scannedData == null && _errorMessage == null
                  ? MobileScanner(
                      controller: _cameraController,
                      onDetect: _onDetect,
                    )
                  : Center(
                      child: _errorMessage != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.plumberRed, size: 60),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _resetScanner,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('مسح كود جديد'),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.crystalBlue, foregroundColor: Colors.white),
                                )
                              ],
                            )
                          : _buildOrderDetails(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    final amount = (_scannedData!['amount'] as num).toDouble();
    final service = _scannedData!['serviceType'] as String;
    final method = _scannedData!['paymentMethod'] as String;
    final commission = (_scannedData!['commission'] as num).toDouble();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.refillGreen.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: AppColors.refillGreen, size: 50),
          ),
          const SizedBox(height: 20),
          const Text('تفاصيل طلب الدفع', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _detailRow('نوع الخدمة', service, AppColors.crystalBlue),
          const Divider(color: Colors.white24, height: 24),
          _detailRow('طريقة الدفع', method == 'wallet' ? 'من رصيد العميل' : 'دفع كاش', AppColors.goldLight),
          const Divider(color: Colors.white24, height: 24),
          _detailRow('المبلغ الإجمالي', '${amount.toStringAsFixed(2)} د.أ', Colors.white, isTotal: true),
          const Divider(color: Colors.white24, height: 24),
          _detailRow('عمولة التطبيق (5%)', '${commission.toStringAsFixed(2)} د.أ', AppColors.plumberRed),
          const Divider(color: Colors.white24, height: 24),
          _detailRow('صافي رصيدك', '${(amount - commission).toStringAsFixed(2)} د.أ', AppColors.refillGreen, isTotal: true),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _confirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.refillGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isProcessing
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('تأكيد استلام الدفع وحرق الكود', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isProcessing ? null : _resetScanner,
            child: const Text('إلغاء ومسح كود آخر', style: TextStyle(color: Colors.white54)),
          )
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, Color valueColor, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: valueColor, fontSize: isTotal ? 20 : 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}