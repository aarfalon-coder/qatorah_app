import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class MaintenanceRequestScreen extends StatefulWidget {
  const MaintenanceRequestScreen({super.key});

  @override
  State<MaintenanceRequestScreen> createState() => _MaintenanceRequestScreenState();
}

class _MaintenanceRequestScreenState extends State<MaintenanceRequestScreen> {
  String _selectedType = 'plumber';
  final _descCtrl = TextEditingController();
  String _urgency = 'normal';

  final List<Map<String, dynamic>> _types = [
    {'id': 'plumber', 'label': 'سباك', 'icon': Icons.plumbing, 'color': AppColors.crystalBlue},
    {'id': 'electrician', 'label': 'كهربائي', 'icon': Icons.electrical_services, 'color': AppColors.goldLight},
    {'id': 'technician', 'label': 'فني محطات', 'icon': Icons.build_circle, 'color': AppColors.maintenanceOrange},
    {'id': 'engineer', 'label': 'مهندس صيانة', 'icon': Icons.engineering, 'color': AppColors.factoryPurple},
    {'id': 'lab', 'label': 'فني مختبر مياه', 'icon': Icons.science, 'color': AppColors.refillGreen},
    {'id': 'plc', 'label': 'مبرمج PLC', 'icon': Icons.memory, 'color': AppColors.waterBlue},
    {'id': 'parts', 'label': 'قطع صيانة', 'icon': Icons.handyman, 'color': AppColors.plumberRed},
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_descCtrl.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اكتب وصفاً للمشكلة (10 أحرف على الأقل)'),
          backgroundColor: AppColors.plumberRed,
        ),
      );
      return;
    }
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ تم إرسال طلب الصيانة - سيتم التواصل معك قريباً'),
        backgroundColor: AppColors.refillGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('طلب صيانة',
            style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نوع الصيانة',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _types.map((t) {
                final isSelected = _selectedType == t['id'];
                final color = t['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = t['id'] as String),
                  child: Container(
                    width: 110,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.2) : const Color(0xFF1A1F2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? color : Colors.white.withValues(alpha: 0.1), width: isSelected ? 2 : 1),
                    ),
                    child: Column(
                      children: [
                        Icon(t['icon'] as IconData, color: isSelected ? color : Colors.white54, size: 28),
                        const SizedBox(height: 6),
                        Text(t['label'] as String,
                            style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('درجة الاستعجال',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                _urgencyBtn('normal', 'عادي', Icons.schedule, AppColors.crystalBlue),
                const SizedBox(width: 10),
                _urgencyBtn('urgent', 'مستعجل', Icons.warning, AppColors.goldLight),
                const SizedBox(width: 10),
                _urgencyBtn('emergency', 'طارئ', Icons.emergency, AppColors.plumberRed),
              ],
            ),
            const SizedBox(height: 24),
            const Text('وصف المشكلة',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: TextField(
                controller: _descCtrl,
                maxLines: 5,
                maxLength: 500,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'اشرح المشكلة بتفصيل...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                  counterStyle: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send),
                label: const Text('إرسال الطلب',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maintenanceOrange,
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

  Widget _urgencyBtn(String id, String label, IconData icon, Color color) {
    final isSelected = _urgency == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _urgency = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : const Color(0xFF1A1F2E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.white54, size: 20),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: isSelected ? color : Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}