import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/notification_manager.dart';

class AdminNotificationsTab extends StatefulWidget {
  const AdminNotificationsTab({super.key});

  @override
  State<AdminNotificationsTab> createState() => _AdminNotificationsTabState();
}

class _AdminNotificationsTabState extends State<AdminNotificationsTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;
  bool _sendToAll = true;
  final _targetUserIdController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _targetUserIdController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final success = await context.read<NotificationManager>().sendNotification(
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      userId: _sendToAll ? 'all' : _targetUserIdController.text.trim(),
      icon: _sendToAll ? 'campaign' : 'notifications_active',
      colorHex: _sendToAll ? '#FFD700' : '#F44336', // ذهبي للعامة، أحمر للخاص
    );

    setState(() => _isSending = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم إرسال الإشعار بنجاح!'),
          backgroundColor: AppColors.refillGreen,
        ),
      );
      _titleController.clear();
      _messageController.clear();
      _targetUserIdController.clear();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(' فشل إرسال الإشعار'),
          backgroundColor: AppColors.plumberRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📢 إرسال إشعار جديد',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // حقل العنوان
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'عنوان الإشعار',
                  labelStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                validator: (val) => val!.isEmpty ? 'أدخل العنوان' : null,
              ),
            ),
            const SizedBox(height: 16),

            // حقل الرسالة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: TextFormField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'نص الرسالة',
                  labelStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                validator: (val) => val!.isEmpty ? 'أدخل نص الرسالة' : null,
              ),
            ),
            const SizedBox(height: 20),

            // خيار الإرسال للكل أو لمستخدم محدد
            SwitchListTile(
              title: const Text('إرسال لجميع المستخدمين', style: TextStyle(color: Colors.white)),
              subtitle: Text(_sendToAll ? 'سيصل الإشعار لكل من يستخدم التطبيق' : 'أدخل معرف المستخدم المستهدف أدناه', 
                  style: const TextStyle(color: Colors.white54)),
              value: _sendToAll,
              activeThumbColor: AppColors.goldLight,
              onChanged: (val) => setState(() => _sendToAll = val),
            ),

            if (!_sendToAll) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.plumberRed),
                ),
                child: TextFormField(
                  controller: _targetUserIdController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'معرف المستخدم (User ID)',
                    labelStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 20),

            // زر الإرسال
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldLight,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSending
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black))
                    : const Text(' إرسال الإشعار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}