import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';

class WaterOrderScreen extends StatefulWidget {
  const WaterOrderScreen({super.key});

  @override
  State<WaterOrderScreen> createState() => _WaterOrderScreenState();
}

class _WaterOrderScreenState extends State<WaterOrderScreen> {
  int _quantity = 1;
  final TextEditingController _notesCtrl = TextEditingController();
  String _selectedAddress = 'لم يتم تحديد الموقع بعد';
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _isLoading = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  // حساب السعر (1 دينار للجالون)
  double get _totalPrice => _quantity * 1.0;

  void _selectLocation() {
    // محاكاة اختيار الموقع (لاحقاً سنفتح شاشة الخريطة الحقيقية)
    setState(() {
      _selectedAddress = 'إربد، شارع الجامعة';
      _latitude = 32.5556;
      _longitude = 35.8500;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديد الموقع (محاكاة)'),
        backgroundColor: AppColors.crystalBlue,
      ),
    );
  }

  void _confirmOrder() {
    if (_selectedAddress == 'لم يتم تحديد الموقع بعد') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد موقع التوصيل أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.navyDark,
          title: const Text('تأكيد الطلب', style: TextStyle(color: AppColors.goldLight)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الكمية: $_quantity جالون', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              Text('العنوان: $_selectedAddress', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              Text('السعر الإجمالي: $_totalPrice دينار', style: const TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال طلبك بنجاح! ✅'),
                    backgroundColor: AppColors.refillGreen,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight),
              child: const Text('تأكيد', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('طلب مياه شرب', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. اختيار الكمية
                const Text('اختر الكمية', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [1, 2, 3, 5, 10].map((qty) {
                    final isSelected = _quantity == qty;
                    return GestureDetector(
                      onTap: () => setState(() => _quantity = qty),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.crystalBlue : AppColors.navyDark.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? AppColors.goldLight : AppColors.goldDark.withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Text('$qty', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 2. زر تحديد الموقع
                const Text('موقع التوصيل', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GlassCard(
                  glowColor: AppColors.crystalBlue,
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: AppColors.crystalBlue),
                    title: Text(_selectedAddress, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: const Text('اضغط لتحديد الموقع', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    onTap: _selectLocation,
                  ),
                ),
                const SizedBox(height: 24),

                // 3. ملاحظات
                const Text('ملاحظات إضافية (اختياري)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'مثال: اترك الطلب عند الباب',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: AppColors.navyDark.withValues(alpha: 0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.goldDark.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 4. زر التأكيد
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirmOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldLight,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text('تأكيد الطلب - $_totalPrice دينار', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}