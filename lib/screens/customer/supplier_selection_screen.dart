import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/models/water_catalog.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/models/order_model.dart';
import 'package:qatorah_app/services/order_service.dart';

class SupplierSelectionScreen extends StatefulWidget {
  final Map<String, int> cartItems;
  final double latitude;
  final double longitude;
  final String address;

  const SupplierSelectionScreen({
    super.key,
    required this.cartItems,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  State<SupplierSelectionScreen> createState() => _SupplierSelectionScreenState();
}

class _SupplierSelectionScreenState extends State<SupplierSelectionScreen> {
  String? _selectedSupplierId;
  String _paymentMethod = 'cash';
  Map<String, dynamic>? _selectedCoupon;
  bool _isSubmitting = false;

  //  لا توجد بيانات وهمية - كل شيء يُقرأ من Firestore

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر المحطة ومراجعة السعر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      backgroundColor: const Color(0xFF0A0E1A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.waterBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.waterBlue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.handshake, color: AppColors.waterBlue, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'اختر المحطة التي تفضلها. الأسعار تُعرض تلقائياً من لوحة السوبر أدمن.',
                      style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('المحطات المتاحة:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // 🔥 قراءة المحطات الحقيقية من Firestore
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('suppliers')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.waterBlue));
                }
                if (snapshot.hasError) {
                  return Text('خطأ: ${snapshot.error}', style: const TextStyle(color: AppColors.plumberRed));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('لا توجد محطات متاحة حالياً', style: TextStyle(color: Colors.white54));
                }

                final suppliers = snapshot.data!.docs;

                return Column(
                  children: suppliers.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final supplierId = doc.id;
                    final isSelected = _selectedSupplierId == supplierId;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedSupplierId = supplierId),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.waterBlue.withValues(alpha: 0.15) : const Color(0xFF1A1F2E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? AppColors.waterBlue : Colors.transparent, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: AppColors.waterBlue.withValues(alpha: 0.2), shape: BoxShape.circle),
                                  child: const Icon(Icons.store, color: AppColors.waterBlue, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(data['name'] ?? 'محطة', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      Text(data['address'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                if (isSelected) const Icon(Icons.check_circle, color: AppColors.waterBlue, size: 24),
                              ],
                            ),

                            //  عرض أسعار هذه المحطة (من حقل prices في Firestore)
                            if (isSelected && data['prices'] != null) ...[
                              const Divider(color: Colors.white24, height: 24),
                              const Text('تفاصيل الأسعار:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 8),
                              ...widget.cartItems.entries.map((entry) {
                                final product = WaterCatalog.products.firstWhere(
                                  (p) => p.id == entry.key,
                                  orElse: () => WaterProduct(id: entry.key, name: 'صنف', unit: '', category: '', icon: Icons.water_drop, color: Colors.blue)
                                );
                                final pricesMap = Map<String, dynamic>.from(data['prices'] as Map);
                                final price = (pricesMap[entry.key] ?? 0.0).toDouble();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${product.name} (${entry.value}x)', style: const TextStyle(color: Colors.white, fontSize: 14)),
                                      Text('${(price * entry.value).toStringAsFixed(2)} د.أ', style: const TextStyle(color: AppColors.goldLight, fontSize: 14, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // 🔥 ملخص الإجمالي
            if (_selectedSupplierId != null)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('suppliers').doc(_selectedSupplierId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  if (data == null) return const SizedBox.shrink();

                  final pricesMap = Map<String, dynamic>.from(data['prices'] ?? {});
                  double subtotal = 0.0;
                  widget.cartItems.forEach((productId, qty) {
                    subtotal += (pricesMap[productId] ?? 0.0).toDouble() * qty;
                  });

                  final discount = _selectedCoupon != null ? (_selectedCoupon!['discount'] as double) : 0.0;
                  final total = (subtotal - discount).clamp(0.0, 99999.0);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1F2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('المجموع الفرعي:', style: TextStyle(color: Colors.white70)),
                            Text('${subtotal.toStringAsFixed(2)} د.أ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (_selectedCoupon != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('خصم الكوبون', style: TextStyle(color: AppColors.refillGreen)),
                              Text('- ${discount.toStringAsFixed(2)} د.أ', style: const TextStyle(color: AppColors.refillGreen, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                        const Divider(color: Colors.white24, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الإجمالي النهائي:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('${total.toStringAsFixed(2)} د.أ', style: const TextStyle(color: AppColors.goldLight, fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),
            const Text('طريقة الدفع:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _buildPaymentOption('cash', '💵 دفع كاش عند الاستلام', Icons.money),
            const SizedBox(height: 8),
            _buildPaymentOption('wallet', '💳 الدفع عبر المحفظة الإلكترونية', Icons.account_balance_wallet),
            const SizedBox(height: 8),

            // 🔥 زر فتح دفتر الكوبونات الحقيقي من Firestore
            GestureDetector(
              onTap: () => _showCouponBook(context),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _selectedCoupon != null ? AppColors.goldLight.withValues(alpha: 0.15) : const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedCoupon != null ? AppColors.goldLight : Colors.transparent, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.card_giftcard, color: _selectedCoupon != null ? AppColors.goldLight : Colors.white70, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _selectedCoupon != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_selectedCoupon!['title'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                const Text('تم تطبيق الخصم', style: TextStyle(color: AppColors.goldLight, fontSize: 12)),
                              ],
                            )
                          : const Text('️ استخدام كوبون من دفتر الكوبونات', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                    Icon(_selectedCoupon != null ? Icons.check_circle : Icons.chevron_right, color: AppColors.goldLight, size: 24),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 زر التأكيد - معطل حتى يتم اختيار محطة
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: (_selectedSupplierId == null || _isSubmitting) ? null : () => _confirmOrder(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.refillGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text('تأكيد وإرسال الطلب', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔥 دالة عرض دفتر الكوبونات الحقيقي من Firestore
  void _showCouponBook(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0E1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('دفتر الكوبونات', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('coupons')
                      .where('isActive', isEqualTo: true)
                      .where('userId', whereIn: [AuthManager.firebaseUid ?? '', 'all'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.goldLight));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('لا توجد كوبونات متاحة', style: TextStyle(color: Colors.white54)));
                    }

                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        final coupon = doc.data() as Map<String, dynamic>;
                        final isSelected = _selectedCoupon?['id'] == doc.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedCoupon = {'id': doc.id, ...coupon});
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.goldLight.withValues(alpha: 0.15) : const Color(0xFF1A1F2E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? AppColors.goldLight : AppColors.goldLight.withValues(alpha: 0.3), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: AppColors.goldLight.withValues(alpha: 0.2), shape: BoxShape.circle),
                                  child: const Icon(Icons.confirmation_number, color: AppColors.goldLight, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(coupon['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                      Text('خصم: ${coupon['discount'] ?? 0} د.أ', style: const TextStyle(color: AppColors.goldLight, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                if (isSelected) const Icon(Icons.check_circle, color: AppColors.goldLight, size: 24),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              if (_selectedCoupon != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      setState(() => _selectedCoupon = null);
                      Navigator.pop(ctx);
                    },
                    child: const Text('إلغاء تطبيق الكوبون', style: TextStyle(color: AppColors.plumberRed, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.crystalBlue.withValues(alpha: 0.15) : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.crystalBlue : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.crystalBlue : Colors.white70, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ),
            if (isSelected) const Icon(Icons.radio_button_checked, color: AppColors.crystalBlue, size: 22),
            if (!isSelected) const Icon(Icons.radio_button_unchecked, color: Colors.white54, size: 22),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrder() async {
    if (_selectedSupplierId == null) return;
    setState(() => _isSubmitting = true);

    try {
      // 🔥 قراءة بيانات المحطة الحقيقية من Firestore
      final supplierDoc = await FirebaseFirestore.instance.collection('suppliers').doc(_selectedSupplierId).get();
      final supplierData = supplierDoc.data()!;
      final pricesMap = Map<String, dynamic>.from(supplierData['prices'] ?? {});

      List<Map<String, dynamic>> itemsDetails = [];
      double finalTotal = 0.0;

      widget.cartItems.forEach((productId, qty) {
        final product = WaterCatalog.products.firstWhere(
          (p) => p.id == productId,
          orElse: () => WaterProduct(id: productId, name: 'صنف', unit: '', category: '', icon: Icons.water_drop, color: Colors.blue)
        );
        final price = (pricesMap[productId] ?? 0.0).toDouble();
        final itemTotal = price * qty;
        finalTotal += itemTotal;
        itemsDetails.add({
          'product_id': productId,
          'name': product.name,
          'quantity': qty,
          'unit_price': price,
          'total_price': itemTotal,
        });
      });

      // خصم الكوبون
      if (_selectedCoupon != null) {
        finalTotal -= (_selectedCoupon!['discount'] as double);
        finalTotal = finalTotal < 0 ? 0 : finalTotal;
      }

      final newOrder = OrderModel(
        id: '',
        customerId: AuthManager.firebaseUid ?? '',
        customerName: AuthManager.firstName.isNotEmpty ? AuthManager.firstName : 'عميل',
        customerPhone: AuthManager.phone.isNotEmpty ? AuthManager.phone : '',
        serviceType: 'water_delivery',
        details: {
          'items': itemsDetails,
          'supplier_id': _selectedSupplierId,
          'supplier_name': supplierData['name'],
          'payment_method': _paymentMethod,
          'coupon_id': _selectedCoupon?['id'],
          'coupon_title': _selectedCoupon?['title'],
          'final_total': finalTotal,
        },
        latitude: widget.latitude,
        longitude: widget.longitude,
        address: widget.address,
        locationLabel: 'موقع GPS',
        notes: 'طلب عبر اختيار المحطة مباشرة',
        timestamp: DateTime.now(),
      );

      final orderId = await OrderService.createOrder(newOrder).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('انتهت مهلة الاتصال'),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0A0E1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.refillGreen, size: 28),
              SizedBox(width: 8),
              Text('تم إرسال الطلب بنجاح!', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تم توجيه طلبك إلى:', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(' ${supplierData['name']}', style: const TextStyle(color: AppColors.goldLight, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('الإجمالي: ${finalTotal.toStringAsFixed(2)} د.أ', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('رقم الطلب: ${orderId.substring(0, 8)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('حسناً', style: TextStyle(color: AppColors.waterBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ فشل إرسال الطلب: $e'), backgroundColor: AppColors.plumberRed),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}