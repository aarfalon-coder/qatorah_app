import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/profile_manager.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _messageController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = context.read<ProfileManager>().phone;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp() async {
    final url = Uri.parse(
      'https://wa.me/962771453680?text=${Uri.encodeComponent('مرحباً قطوره 👋\nأحتاج مساعدة في التطبيق.')}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showSnack('تعذر فتح واتساب، تأكد من تثبيت التطبيق');
    }
  }

  void _submitTicket() {
    if (_messageController.text.trim().length < 5) {
      _showSnack('الرجاء كتابة رسالة واضحة (5 أحرف على الأقل)');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showSnack('الرجاء إدخال رقم هاتف للتواصل معك');
      return;
    }
    setState(() => _sending = true);
    // لاحقاً: حفظ التذكرة في Firestore
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _sending = false);
      final ticketNo = 'SUP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      _messageController.clear();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تم استلام تذكرتك ✅', style: TextStyle(color: AppColors.refillGreen)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('رقم التذكرة: $ticketNo', style: const TextStyle(color: AppColors.goldLight, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('سيراجعها فريق الدعم وسيتم التواصل معك على الرقم المسجل.', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.refillGreen, foregroundColor: Colors.white),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.navyDark, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('الدعم والمساعدة', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══ 1) واتساب قطوره ═══
            GestureDetector(
              onTap: _launchWhatsApp,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [const Color(0xFF25D366).withValues(alpha: 0.25), const Color(0xFF25D366).withValues(alpha: 0.08)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF25D366).withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.chat, color: Color(0xFF25D366), size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('واتساب قطوره', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('محادثة مباشرة مع الحساب التجاري - بدون حفظ الرقم', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.open_in_new, color: Color(0xFF25D366), size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ═══ 2) الشات الداخلي (لاحقاً) ═══
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
                    child: const Icon(Icons.support_agent, color: Colors.white38, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('شات مباشر مع الإدارة', style: TextStyle(color: Colors.white54, fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('سيصبح متاحاً مع إطلاق لوحة تحكم السوبر أدمن', style: TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Text('قريباً', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ═══ 3) الشكاوي والاقتراحات ═══
            const Text('الشكاوي والاقتراحات', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('اكتب لنا وسنرد عليك على رقمك', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
            const SizedBox(height: 16),

            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'اكتب شكواك أو اقتراحك هنا...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                filled: true,
                fillColor: const Color(0xFF1A1F2E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), 
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))
                ),
                // ✅ تم تصحيح هذا السطر (إزالة const من OutlineInputBorder)
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), 
                  borderSide: const BorderSide(color: AppColors.goldLight)
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم هاتفك للتواصل',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                prefixIcon: const Icon(Icons.phone, color: AppColors.goldLight),
                filled: true,
                fillColor: const Color(0xFF1A1F2E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), 
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))
                ),
                // ✅ تم تصحيح هذا السطر أيضاً
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), 
                  borderSide: const BorderSide(color: AppColors.goldLight)
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _sending ? null : _submitTicket,
                icon: _sending 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.send),
                label: Text(_sending ? 'جاري الإرسال...' : 'إرسال التذكرة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldLight,
                  foregroundColor: const Color(0xFF0A0E1A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}