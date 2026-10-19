import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/role_manager.dart';
import 'package:qatorah_app/screens/customer/customer_home.dart';
// ✅ هذا هو السطر المصحح (بدون مجلد provider/)
import 'package:qatorah_app/screens/provider_home.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الشعار والعنوان
                  const Icon(
                    Icons.water_drop,
                    color: AppColors.goldLight,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'قطوره',
                    style: TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'منصة الخدمات المنزلية',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // عنوان الاختيار
                  const Text(
                    'اختر نوع حسابك',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // زر العميل
                  _buildRoleButton(
                    context,
                    icon: Icons.person,
                    title: 'عميل',
                    subtitle: 'طلب مياه، غاز، تنك، صيانة',
                    color: AppColors.crystalBlue,
                    onTap: () => _selectRole(context, RoleManager.customer),
                  ),
                  const SizedBox(height: 16),

                  // زر المزود
                  _buildRoleButton(
                    context,
                    icon: Icons.store,
                    title: 'مزود خدمة',
                    subtitle: 'إدارة الطلبات، السائقين، الأرباح',
                    color: AppColors.goldLight,
                    onTap: () => _selectRole(context, RoleManager.provider),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _selectRole(BuildContext context, String role) async {
    await RoleManager.setRole(role);
    
    if (!context.mounted) return;

    // الانتقال للشاشة المناسبة
    if (role == RoleManager.customer) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
      );
    } else if (role == RoleManager.provider) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProviderHomeScreen()),
      );
    }
  }
}

