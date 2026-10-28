import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class TankPricingEditor extends StatefulWidget {
  final String supplierId;
  final String supplierName;
  final Map<String, dynamic> currentPrices;

  const TankPricingEditor({
    super.key,
    required this.supplierId,
    required this.supplierName,
    required this.currentPrices,
  });

  @override
  State<TankPricingEditor> createState() => _TankPricingEditorState();
}

class _TankPricingEditorState extends State<TankPricingEditor> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late Map<String, TextEditingController> _controllers;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _tankProducts = [
    {'id': 'tank_3m', 'name': 'تنك 3 متر', 'icon': Icons.water_drop},
    {'id': 'tank_4m', 'name': 'تنك 4 متر', 'icon': Icons.water_drop},
    {'id': 'tank_6m', 'name': 'تنك 6 متر', 'icon': Icons.opacity},
    {'id': 'tank_8m', 'name': 'تنك 8 متر', 'icon': Icons.opacity},
    {'id': 'tank_10m', 'name': 'تنك 10 متر', 'icon': Icons.water},
    {'id': 'tank_20m', 'name': 'تنك 20 متر', 'icon': Icons.water},
  ];

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (final product in _tankProducts) {
      final currentPrice = widget.currentPrices[product['id']];
      _controllers[product['id']] = TextEditingController(
        text: currentPrice != null ? currentPrice.toString() : '',
      );
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _savePrices() async {
    setState(() => _isSaving = true);

    try {
      final newPrices = <String, double>{};
      _controllers.forEach((productId, controller) {
        final text = controller.text.trim();
        if (text.isNotEmpty) {
          final price = double.tryParse(text);
          if (price != null && price >= 0) {
            newPrices[productId] = price;
          }
        }
      });

      await _db.collection('suppliers').doc(widget.supplierId).update({
        'prices': newPrices,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم حفظ أسعار التنك بنجاح'),
            backgroundColor: AppColors.refillGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ: $e'), backgroundColor: AppColors.plumberRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تسعير تنك: ${widget.supplierName}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('مزود تنك مياه', style: TextStyle(color: AppColors.tankCyan, fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _savePrices,
            icon: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.refillGreen, strokeWidth: 2))
                : const Icon(Icons.save, color: AppColors.refillGreen),
            label: Text(_isSaving ? 'جاري...' : 'حفظ', style: const TextStyle(color: AppColors.refillGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0A0E1A),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.tankCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.tankCyan.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.tankCyan, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'اترك الحقل فارغاً إذا كان المزود لا يقدم هذا الحجم',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.tankCyan, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                const Text('أحجام التنك المتاحة', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          ..._tankProducts.map((product) {
            final controller = _controllers[product['id']]!;
            return _buildProductRow(
              product['name'],
              'توصيل إلى الموقع',
              product['icon'],
              AppColors.tankCyan,
              controller,
            );
          }),

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: _isSaving
          ? null
          : FloatingActionButton.extended(
              onPressed: _savePrices,
              backgroundColor: AppColors.tankCyan,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('حفظ أسعار التنك', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
    );
  }

  Widget _buildProductRow(String name, String unit, IconData icon, Color color, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.1)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text(unit, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
                suffixText: 'د.أ',
                suffixStyle: const TextStyle(color: AppColors.goldLight, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0A0E1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}