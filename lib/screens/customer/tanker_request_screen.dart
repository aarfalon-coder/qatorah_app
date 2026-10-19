import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class TankerRequestScreen extends StatefulWidget {
  const TankerRequestScreen({super.key});

  @override
  State<TankerRequestScreen> createState() => _TankerRequestScreenState();
}

class _TankerRequestScreenState extends State<TankerRequestScreen> {
  int _selectedSize = 6;
  final _addressCtrl = TextEditingController();

  final List<Map<String, dynamic>> _sizes = [
    {'size': 3, 'price': 10.0},
    {'size': 4, 'price': 13.0},
    {'size': 6, 'price': 19.0},
    {'size': 8, 'price': 25.0},
    {'size': 10, 'price': 31.0},
    {'size': 20, 'price': 61.0},
  ];

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  double get _price => _sizes.firstWhere((s) => s['size'] == _selectedSize)['price'] as double;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('طلب صهريج', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اختر حجم الصهريج', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
              children: _sizes.map((s) {
                final isSelected = _selectedSize == s['size'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedSize = s['size'] as int),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.tankCyan.withValues(alpha: 0.2) : const Color(0xFF1A1F2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.tankCyan : Colors.white.withValues(alpha: 0.1), width: isSelected ? 2 : 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.opacity, color: isSelected ? AppColors.tankCyan : Colors.white54, size: 26),
                        const SizedBox(height: 6),
                        Text('${s['size']} متر', style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('${s['price']} د.أ', style: TextStyle(color: isSelected ? AppColors.goldLight : Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('عنوان التوصيل', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: TextField(
                controller: _addressCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'اكتب العنوان بالتفصيل...',
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon: Icon(Icons.location_on, color: AppColors.goldLight),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('الإجمالي:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const Spacer(),
                  Text('${_price.toStringAsFixed(0)} د.أ', style: const TextStyle(color: AppColors.goldLight, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_addressCtrl.text.trim().length < 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('اكتب عنوان التوصيل'), backgroundColor: AppColors.plumberRed),
                    );
                    return;
                  }
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.local_shipping),
                label: const Text('اطلب الصهريج الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tankCyan,
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