import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class TankerSettingsScreen extends StatefulWidget {
  const TankerSettingsScreen({super.key});

  @override
  State<TankerSettingsScreen> createState() => _TankerSettingsScreenState();
}

class _TankerSettingsScreenState extends State<TankerSettingsScreen> {
  bool _isAvailable = true;
  bool _notifications = true;
  String _radius = '10';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('إعدادات الصهريج', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(_isAvailable ? Icons.check_circle : Icons.cancel, color: _isAvailable ? AppColors.refillGreen : AppColors.plumberRed, size: 24),
                const SizedBox(width: 12),
                const Expanded(child: Text('متاح لاستقبال الطلبات', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                Switch(value: _isAvailable, activeColor: AppColors.refillGreen, onChanged: (v) => setState(() => _isAvailable = v)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications, color: AppColors.goldLight, size: 24),
                const SizedBox(width: 12),
                const Expanded(child: Text('الإشعارات', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                Switch(value: _notifications, activeColor: AppColors.goldLight, onChanged: (v) => setState(() => _notifications = v)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('نطاق الخدمة (كم)', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: ['5', '10', '20', '50'].map((r) => Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _radius = r),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _radius == r ? AppColors.tankCyan.withValues(alpha: 0.2) : const Color(0xFF1A1F2E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _radius == r ? AppColors.tankCyan : Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Center(child: Text('$r', style: TextStyle(color: _radius == r ? AppColors.tankCyan : Colors.white70, fontSize: 15, fontWeight: FontWeight.bold))),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم حفظ الإعدادات'), backgroundColor: AppColors.refillGreen));
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: const Text('حفظ الإعدادات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tankCyan,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}