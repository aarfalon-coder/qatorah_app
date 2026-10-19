import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/screens/customer/map_picker_screen.dart';

class SupplierSelectionScreen extends StatefulWidget {
  final Map<String, int> items;
  final VoidCallback onConfirmed;

  const SupplierSelectionScreen({
    super.key,
    required this.items,
    required this.onConfirmed,
  });

  @override
  State<SupplierSelectionScreen> createState() => _SupplierSelectionScreenState();
}

class _SupplierSelectionScreenState extends State<SupplierSelectionScreen> {
  String _sortBy = 'best_value';
  bool _isDelivery = true;
  String _address = 'لم يتم تحديد الموقع بعد';
  double? _latitude;
  double? _longitude;
  final TextEditingController _notesCtrl = TextEditingController();

  final List<Map<String, dynamic>> _suppliers = [
    {
      'id': 's1',
      'name': 'محطة النخيل',
      'rating': 4.5,
      'distance': 3.8,
      'delivery': 0.75,
      'price': 1.60,
      'commission': 0.12,
      'best_value': true,
    },
    {
      'id': 's2',
      'name': 'محطة السلام',
      'rating': 4.9,
      'distance': 1.2,
      'delivery': 1.00,
      'price': 1.50,
      'commission': 0.13,
    },
    {
      'id': 's3',
      'name': 'محطة الجبل الأخضر',
      'rating': 4.7,
      'distance': 2.5,
      'delivery': 1.50,
      'price': 1.40,
      'commission': 0.14,
    },
  ];

  List<Map<String, dynamic>> get _sortedSuppliers {
    final list = List<Map<String, dynamic>>.from(_suppliers);
    if (_sortBy == 'best_value') {
      list.sort((a, b) => (a['price'] + a['delivery'] + a['commission'])
          .compareTo(b['price'] + b['delivery'] + b['commission']));
    } else if (_sortBy == 'nearest') {
      list.sort((a, b) => a['distance'].compareTo(b['distance']));
    } else {
      list.sort((a, b) => b['rating'].compareTo(a['rating']));
    }
    return list;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        title: const Text('اختيار المورد',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _sortBtn('best_value', 'الأفضل قيمة', Icons.emoji_events),
                const SizedBox(width: 8),
                _sortBtn('nearest', 'الأقرب', Icons.near_me),
                const SizedBox(width: 8),
                _sortBtn('highest_rated', 'الأعلى تقييماً', Icons.star),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.delivery_dining, color: AppColors.crystalBlue, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isDelivery ? 'توصيل للمنزل' : 'استلام من المحطة',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Switch(
                  value: _isDelivery,
                  onChanged: (val) => setState(() => _isDelivery = val),
                  activeThumbColor: AppColors.crystalBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sortedSuppliers.length,
              itemBuilder: (context, index) {
                final s = _sortedSuppliers[index];
                return _supplierCard(s);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortBtn(String type, String label, IconData icon) {
    final isSelected = _sortBy == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _sortBy = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.crystalBlue.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.crystalBlue : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.crystalBlue : Colors.white54, size: 18),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    color: isSelected ? AppColors.crystalBlue : Colors.white70,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _supplierCard(Map<String, dynamic> s) {
    final total = s['price'] + s['delivery'] + s['commission'];
    final isBest = s['best_value'] == true;

    return GestureDetector(
      onTap: () => _openInvoiceSheet(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isBest ? AppColors.goldLight.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isBest ? AppColors.goldLight.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.crystalBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.store, color: AppColors.crystalBlue, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s['name'],
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white54, size: 14),
                      const SizedBox(width: 4),
                      Text('${s['distance']} كم', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.star, color: AppColors.goldLight, size: 14),
                      const SizedBox(width: 4),
                      Text('${s['rating']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  if (isBest) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.goldLight.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emoji_events, color: AppColors.goldLight, size: 12),
                          SizedBox(width: 4),
                          Text('الأفضل قيمة',
                              style: TextStyle(color: AppColors.goldLight, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${total.toStringAsFixed(2)} د.أ',
                    style: const TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('شامل التوصيل', style: TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openInvoiceSheet(Map<String, dynamic> s) {
    final deliveryFee = _isDelivery ? s['delivery'] : 0.0;
    final total = s['price'] + deliveryFee + s['commission'];
    final totalQty = widget.items.values.fold(0, (a, b) => a + b);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0D1430),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('فاتورة ${s['name']}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _row('قارورة استبدال 10 لتر × $totalQty', '${s['price'].toStringAsFixed(2)} د.أ'),
                    if (_isDelivery) _row('خدمة التوصيل', '${deliveryFee.toStringAsFixed(2)} د.أ'),
                    _row('عمولة التطبيق (5%)', '${s['commission'].toStringAsFixed(2)} د.أ'),
                    const Divider(color: Colors.white24, height: 20),
                    _row('الإجمالي', '${total.toStringAsFixed(2)} د.أ', isTotal: true),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.plumberRed, size: 20),
                        SizedBox(width: 6),
                        Text('موقع التوصيل',
                            style: TextStyle(
                                color: AppColors.goldLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _showLocationOptions(setSheetState),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.plumberRed.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.plumberRed, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(_address,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const Icon(Icons.edit, color: Colors.white54, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.edit_note, color: AppColors.goldLight, size: 20),
                        SizedBox(width: 6),
                        Text('ملاحظات للسائق (اختياري)',
                            style: TextStyle(
                                color: AppColors.goldLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'مثال: الطابق الثالث، شقة رقم 5...',
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.goldLight),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _address == 'لم يتم تحديد الموقع بعد'
                            ? null
                            : () {
                                widget.onConfirmed();
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ تم إرسال الطلب بنجاح!'),
                                    backgroundColor: AppColors.refillGreen,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.refillGreen,
                          disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('تأكيد وإرسال الطلب',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: isTotal ? Colors.white : Colors.white70,
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                color: isTotal ? AppColors.goldLight : Colors.white,
                fontSize: isTotal ? 20 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }

  void _showLocationOptions(StateSetter setSheetState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1430),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text('اختر طريقة تحديد الموقع',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _locOption(
                    icon: Icons.my_location,
                    title: 'موقعي الحالي (GPS)',
                    subtitle: 'استخدام إحداثيات الهاتف',
                    color: AppColors.crystalBlue,
                    onTap: () {
                      Navigator.pop(ctx);
                      setSheetState(() {
                        _address = 'موقعي الحالي - إربد، الأردن';
                        _latitude = 32.5556;
                        _longitude = 35.8500;
                      });
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _locOption(
                    icon: Icons.map,
                    title: 'اختيار من الخريطة',
                    subtitle: 'حدد الموقع يدوياً',
                    color: AppColors.goldLight,
                    onTap: () async {
                      Navigator.pop(ctx);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MapPickerScreen()),
                      );
                      if (result != null && result is Map<String, dynamic>) {
                        setSheetState(() {
                          _address = result['address'] ?? 'موقع محدد';
                          _latitude = result['latitude'];
                          _longitude = result['longitude'];
                        });
                      }
                    },
                  ),
                  const Divider(color: Colors.white24),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text('المواقع المحفوظة',
                        style: TextStyle(
                            color: AppColors.goldLight,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
                  _savedLoc('البيت', 'إربد - حي النصر', Icons.home, setSheetState),
                  _savedLoc('المحل', 'إربد - شارع فلسطين', Icons.store, setSheetState),
                  _savedLoc('المخزن', 'إربد - المنطقة الصناعية', Icons.warehouse, setSheetState),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _locOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
      subtitle:
          Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      onTap: onTap,
    );
  }

  Widget _savedLoc(
      String name, String address, IconData icon, StateSetter setSheetState) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.refillGreen.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.refillGreen, size: 20),
      ),
      title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle:
          Text(address, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
      onTap: () {
        Navigator.pop(context);
        setSheetState(() {
          _address = '$name: $address';
        });
      },
    );
  }
}