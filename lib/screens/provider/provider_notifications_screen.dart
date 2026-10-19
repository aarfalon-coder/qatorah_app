import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class ProviderNotificationsScreen extends StatelessWidget {
  const ProviderNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifs = [
      {'title': 'طلب جديد', 'body': 'وصلك طلب جديد من محمد أحمد', 'time': 'منذ 5 د', 'icon': Icons.shopping_cart, 'color': AppColors.refillGreen, 'unread': true},
      {'title': 'تقييم جديد', 'body': 'قيّمك خالد يوسف بـ 5 نجوم', 'time': 'منذ ساعة', 'icon': Icons.star, 'color': AppColors.goldLight, 'unread': true},
      {'title': 'تم اعتماد إعلانك', 'body': 'إعلان "أسطوانات غاز" تم نشره', 'time': 'منذ 3 ساعات', 'icon': Icons.campaign, 'color': AppColors.crystalBlue, 'unread': false},
      {'title': 'تذكير تجديد', 'body': 'إعلانك ينتهي خلال 3 أيام', 'time': 'أمس', 'icon': Icons.access_time, 'color': AppColors.maintenanceOrange, 'unread': false},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('الإشعارات', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('قراءة الكل', style: TextStyle(color: AppColors.crystalBlue, fontSize: 12)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifs.length,
        itemBuilder: (context, i) {
          final n = notifs[i];
          final isUnread = n['unread'] == true;
          final color = n['color'] as Color;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUnread ? color.withValues(alpha: 0.08) : const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isUnread ? color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: Icon(n['icon'] as IconData, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(n['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          if (isUnread) ...[
                            const SizedBox(width: 6),
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(n['body'] as String, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(n['time'] as String, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}