import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/auth_manager.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final String _referralCode = 'QTR-QASIM-1024';
  final int _successfulInvites = 37;

  String get _appLink => 'https://qatorah.app/download?ref=$_referralCode';

  @override
  Widget build(BuildContext context) {
    final role = AuthManager.role;
    final rewardTiers = _getRewardTiers(role);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ادعُ واكسب', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.goldLight.withValues(alpha: 0.25),
                    AppColors.goldLight.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5), width: 2),
              ),
              child: Column(
                children: [
                  const Icon(Icons.celebration, color: AppColors.goldLight, size: 50),
                  const SizedBox(height: 12),
                  const Text('كلما دعوت أكثر، كلما ربحت أكثر!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'شارك رابطك الخاص مع أصدقائك، وكل شخص يسجل ويكمل أول طلب مدفوع = دعوة ناجحة لصالحك',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('كود الدعوة الخاص بك', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_referralCode, style: const TextStyle(color: AppColors.goldLight, fontSize: 20, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: _referralCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ الكود ✅'), backgroundColor: AppColors.refillGreen, behavior: SnackBarBehavior.floating),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.goldLight.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.copy, color: AppColors.goldLight, size: 16), SizedBox(width: 4), Text('نسخ', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold, fontSize: 12))]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('دعواتك الناجحة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _counterBox('الكل', '$_successfulInvites', Colors.white),
                      _counterBox('10', _successfulInvites >= 10 ? '✅' : '❌', _successfulInvites >= 10 ? AppColors.refillGreen : AppColors.plumberRed),
                      _counterBox('50', _successfulInvites >= 50 ? '✅' : '❌', _successfulInvites >= 50 ? AppColors.refillGreen : AppColors.plumberRed),
                      _counterBox('100', _successfulInvites >= 100 ? '✅' : '❌', _successfulInvites >= 100 ? AppColors.refillGreen : AppColors.plumberRed),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _successfulInvites / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation(AppColors.goldLight),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('$_successfulInvites من 100 للمكافأة الكبرى', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('مكافآتك (حسب دورك)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('دورك: ${_getRoleLabel(role)}', style: const TextStyle(color: AppColors.goldLight, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...rewardTiers.map((tier) {
              final reached = _successfulInvites >= tier['threshold'];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: reached ? AppColors.refillGreen.withValues(alpha: 0.15) : const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: reached ? AppColors.refillGreen.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: reached ? AppColors.refillGreen.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        reached ? Icons.emoji_events : Icons.lock_outline,
                        color: reached ? AppColors.refillGreen : Colors.white38,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${tier['threshold']} دعوة ناجحة', style: TextStyle(color: reached ? Colors.white : Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(tier['reward'] as String, style: TextStyle(color: reached ? AppColors.refillGreen : Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (reached)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.refillGreen, borderRadius: BorderRadius.circular(6)),
                        child: const Text('تم', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _shareOnWhatsApp,
                icon: const Icon(Icons.share, size: 22),
                label: const Text('شارك على واتساب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: _copyLink,
                icon: const Icon(Icons.link),
                label: const Text('نسخ رابط الدعوة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.goldLight,
                  side: const BorderSide(color: AppColors.goldLight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _counterBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
      ],
    );
  }

  List<Map<String, dynamic>> _getRewardTiers(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return [
          {'threshold': 10, 'reward': '🥤 قارورة مياه مجانية'},
          {'threshold': 50, 'reward': '💰 خصم 50% على دفتر كوبونات'},
          {'threshold': 100, 'reward': '📖 دفتر كوبونات مجاني كامل'},
        ];
      case UserRole.stationOwner:
      case UserRole.factoryOwner:
      case UserRole.tankerDriver:
      case UserRole.distributionDriver:
        return [
          {'threshold': 10, 'reward': '💵 2 د.أ رصيد في التطبيق'},
          {'threshold': 50, 'reward': '💵 5 د.أ رصيد في التطبيق'},
          {'threshold': 100, 'reward': '💵 10 د.أ رصيد في التطبيق'},
        ];
      case UserRole.plumber:
      case UserRole.stationTechnician:
      case UserRole.electrician:
      case UserRole.partsProvider:
      case UserRole.gasSupplier:
        return [
          {'threshold': 10, 'reward': '📌 إعلان مبوب مجاني أسبوع'},
          {'threshold': 50, 'reward': '📌 إعلان مبوب مجاني شهر'},
          {'threshold': 100, 'reward': '⭐ إعلان بريميوم مجاني شهر'},
        ];
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.customer: return 'عميل';
      case UserRole.stationOwner: return 'صاحب محطة';
      case UserRole.factoryOwner: return 'مصنع';
      case UserRole.tankerDriver: return 'سائق تنك';
      case UserRole.distributionDriver: return 'سائق توزيع';
      case UserRole.stationTechnician: return 'فني';
      case UserRole.plumber: return 'سباك';
      case UserRole.electrician: return 'كهربائي';
      case UserRole.partsProvider: return 'مزود قطع غيار';
      case UserRole.gasSupplier: return 'مزود غاز';
    }
  }

  void _shareOnWhatsApp() {
    final message = '''
🚰 انضم معي لتطبيق قطوره!
نظام المياه الذكي للخدمات والتوصيل في الأردن 🇯🇴

💧 طلب مياه وتنكات
🔥 أسطوانات غاز
🔧 سباكين وفنيين
🚛 توصيل سريع

سجّل من رابطي الخاص وادعمني، واحصل على مزايا خاصة 🎁
👇 $_appLink

--
📱 أُرسلت هذه الدعوة من تطبيق قطوره على هاتفي
''';
    SharePlus.instance.share(ShareParams(text: message));
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _appLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الرابط ✅'), backgroundColor: AppColors.refillGreen, behavior: SnackBarBehavior.floating),
    );
  }
}