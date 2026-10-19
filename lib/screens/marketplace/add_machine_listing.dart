import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class AddMachineListingScreen extends StatefulWidget {
  const AddMachineListingScreen({super.key});

  @override
  State<AddMachineListingScreen> createState() => _AddMachineListingScreenState();
}

class _AddMachineListingScreenState extends State<AddMachineListingScreen> {
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'filter';

  final _categories = [
    {'id': 'filter', 'label': 'فلاتر'},
    {'id': 'pump', 'label': 'مضخات'},
    {'id': 'machine', 'label': 'ماكينات'},
    {'id': 'parts', 'label': 'قطع غيار'},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('املأ الحقول المطلوبة'), backgroundColor: AppColors.plumberRed),
      );
      return;
    }
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم إضافة الإعلان'), backgroundColor: AppColors.refillGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('إضافة ماكينة', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الفئة', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _categories.map((c) => GestureDetector(
                onTap: () => setState(() => _category = c['id'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _category == c['id'] ? AppColors.factoryPurple.withValues(alpha: 0.2) : const Color(0xFF1A1F2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _category == c['id'] ? AppColors.factoryPurple : Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Text(c['label'] as String, style: TextStyle(color: _category == c['id'] ? AppColors.factoryPurple : Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            _field(_titleCtrl, 'اسم الماكينة', Icons.title),
            const SizedBox(height: 12),
            _field(_priceCtrl, 'السعر (د.أ)', Icons.attach_money, keyboard: TextInputType.number),
            const SizedBox(height: 12),
            _field(_descCtrl, 'الوصف', Icons.description, maxLines: 4),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.publish),
                label: const Text('نشر الإعلان', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.factoryPurple,
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

  Widget _field(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1, TextInputType? keyboard}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: AppColors.factoryPurple),
        filled: true,
        fillColor: const Color(0xFF1A1F2E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.factoryPurple)),
      ),
    );
  }
}