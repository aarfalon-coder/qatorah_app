import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/models/water_catalog.dart';
// ✅ تم تغيير هذا السطر ليكون مساراً نسبياً مباشراً لتجنب أخطاء الـ Cache في ويندوز
import 'supplier_selection_screen.dart';

class DrinkingWaterScreen extends StatefulWidget {
  const DrinkingWaterScreen({super.key});
  @override
  State<DrinkingWaterScreen> createState() => _DrinkingWaterScreenState();
}

class _DrinkingWaterScreenState extends State<DrinkingWaterScreen> {
  final Map<String, int> _request = {};

  // ✅ قائمة منتجات الثلج (مضافة محلياً)
  final List<Map<String, dynamic>> _iceProducts = const [
    {
      'id': 'ice_block_20',
      'name': 'ثلج قالب 20 كيلو',
      'unit': 'قالب',
      'price': 3.0,
      'icon': Icons.ac_unit,
      'color': AppColors.crystalBlue,
    },
    {
      'id': 'ice_bag_1',
      'name': 'كيس ثلج 1 كيلو',
      'unit': 'كيس',
      'price': 1.0,
      'icon': Icons.ac_unit,
      'color': AppColors.waterBlue,
    },
  ];

  int get _totalItems => _request.values.fold(0, (a, b) => a + b);

  void _setQty(String id, int qty) {
    setState(() {
      if (qty <= 0) {
        _request.remove(id);
      } else {
        _request[id] = qty;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مياه الشرب',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    // ═══ منتجات المياه من الكتالوج ═══
                    for (final cat in WaterCatalog.categories) ...[
                      _categoryChip(cat),
                      const SizedBox(height: 10),
                      ...WaterCatalog.products
                          .where((p) => p.category == cat)
                          .map(_productRow),
                      const SizedBox(height: 14),
                    ],
                    
                    // ═══ ✅ قسم الثلج (مضاف في الأسفل) ═══
                    _categoryChip('الثلج'),
                    const SizedBox(height: 10),
                    ..._iceProducts.map(_iceProductRow),
                    
                    const SizedBox(height: 90),
                  ],
                ),
              ),
              if (_totalItems > 0) _bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String cat) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                  color: AppColors.waterBlue,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(cat,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _productRow(WaterProduct p) {
    final qty = _request[p.id] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: qty > 0
                ? p.color.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                p.color.withValues(alpha: 0.45),
                p.color.withValues(alpha: 0.15)
              ]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(p.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(p.unit,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11)),
              ],
            ),
          ),
          qty == 0
              ? GestureDetector(
                  onTap: () => _setQty(p.id, 1),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: p.color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: p.color)),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _stepBtn(Icons.remove, () => _setQty(p.id, qty - 1)),
                    const SizedBox(width: 8),
                    Text('$qty',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    _stepBtn(Icons.add, () => _setQty(p.id, qty + 1)),
                  ],
                ),
        ],
      ),
    );
  }

  // ✅ دالة جديدة لعرض منتجات الثلج
  Widget _iceProductRow(Map<String, dynamic> ice) {
    final String id = ice['id'];
    final String name = ice['name'];
    final String unit = ice['unit'];
    final Color color = ice['color'];
    final IconData icon = ice['icon'];
    final qty = _request[id] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: qty > 0
                ? color.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                color.withValues(alpha: 0.45),
                color.withValues(alpha: 0.15)
              ]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(unit,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11)),
              ],
            ),
          ),
          qty == 0
              ? GestureDetector(
                  onTap: () => _setQty(id, 1),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: color)),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _stepBtn(Icons.remove, () => _setQty(id, qty - 1)),
                    const SizedBox(width: 8),
                    Text('$qty',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    _stepBtn(Icons.add, () => _setQty(id, qty + 1)),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1430).withValues(alpha: 0.97),
        border: Border(
            top: BorderSide(color: AppColors.waterBlue.withValues(alpha: 0.4))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$_totalItems صنف في الطلب',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12)),
                const Text('اختر المورد المناسب',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SupplierSelectionScreen(
                    items: Map<String, int>.from(_request),
                    onConfirmed: () => setState(() => _request.clear()),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.waterBlue, AppColors.crystalBlue]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('اختيار المورد',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Icon(Icons.store, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}