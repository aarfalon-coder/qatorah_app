import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/auth_manager.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('حسابي', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ═══ 1. صورة واسم المزود ═══
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.goldLight, width: 3),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.goldLight,
                      child: Icon(Icons.store, size: 50, color: Color(0xFF0A0E1A)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AuthManager.firstName.isNotEmpty ? AuthManager.firstName : 'مزود خدمة',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AuthManager.phone.isNotEmpty ? AuthManager.phone : '0791234567',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      AuthManager.providerServiceType.isNotEmpty ? AuthManager.providerServiceType : 'صاحب محطة',
                      style: const TextStyle(color: AppColors.goldLight, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ═══ 2. خيارات الحساب ═══
            _buildProfileOption(Icons.edit, 'تعديل البيانات الشخصية', 'الاسم، الهاتف، الصورة', AppColors.crystalBlue, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('شاشة تعديل البيانات قيد التطوير'), backgroundColor: AppColors.navyDark),
              );
            }),
            _buildProfileOption(Icons.lock, 'تغيير كلمة المرور', 'تحديث كلمة السر', AppColors.goldLight, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('شاشة تغيير كلمة المرور قيد التطوير'), backgroundColor: AppColors.navyDark),
              );
            }),
            _buildProfileOption(Icons.notifications, 'إعدادات الإشعارات', 'تخصيص التنبيهات', AppColors.refillGreen, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('شاشة الإشعارات قيد التطوير'), backgroundColor: AppColors.navyDark),
              );
            }),
            _buildProfileOption(Icons.help, 'المساعدة والدعم', 'تواصل معنا', AppColors.crystalBlue, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('شاشة المساعدة قيد التطوير'), backgroundColor: AppColors.navyDark),
              );
            }),
            _buildProfileOption(Icons.info, 'عن التطبيق', 'الإصدار والشروط', Colors.white54, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('شاشة المعلومات قيد التطوير'), backgroundColor: AppColors.navyDark),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        trailing: const Icon(Icons.chevron_left, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}