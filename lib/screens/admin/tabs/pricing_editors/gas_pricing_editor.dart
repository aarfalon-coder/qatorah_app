import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class GasPricingEditor extends StatefulWidget {
  final String supplierId;
  final String supplierName;
  final Map<String, dynamic> currentPrices;

  const GasPricingEditor({
    super.key,
    required this.supplierId,
    required this.supplierName,
    required this.currentPrices,
  });

  @override
  State<GasPricingEditor> createState() => _GasPricingEditorState();
}

class _GasPricingEditorState extends State<GasPricingEditor> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late Map<String, TextEditingController> _controllers;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _gasProducts = [
    {'id': 'gas_12kg', 'name': 'أسطوانة غاز 12 كغم', 'icon': Icons.local_fire_department},
    {'id': 'gas_45kg', 'name': 'أسطوانة غاز 45 كغم', 'icon': Icons.local_fire_department},
  ];

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (final product in _gasProducts) {
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
            content: Text('✅ تم حفظ أسعار الغاز بنجاح'),
            backgroundColor: AppColors.refillGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' خطأ: $e'), backgroundColor: AppColors.plumberRed),
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
            Text('تسعير غاز: ${widget.supplierName}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('مزود غاز', style: TextStyle(color: AppColors.maintenanceOrange, fontSize: 12)),
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
              color: AppColors.maintenanceOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.maintenanceOrange.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.maintenanceOrange, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'اترك الحقل فارغاً إذا كان المزود لا يقدم هذا النوع',
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
                Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.maintenanceOrange, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                const Text('أنواع الأسطوانات', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          ..._gasProducts.map((product) {
            final controller = _controllers[product['id']]!;
            return _buildProductRow(
              product['name'],
              'توصيل إلى الموقع',
              product['icon'],
              AppColors.maintenanceOrange,
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
              backgroundColor: AppColors.maintenanceOrange,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('حفظ أسعار الغاز', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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