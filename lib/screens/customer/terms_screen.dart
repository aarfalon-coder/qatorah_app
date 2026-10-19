import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const List<Map<String, dynamic>> _sections = [
    {
      'icon': Icons.info_outline,
      'title': '1. التعريفات',
      'body': 'التطبيق: تطبيق "قطوره" لنظام المياه الذكي للخدمات والتوصيل.\nالمستخدم: أي شخص ينشئ حساباً في التطبيق.\nمزود الخدمة: صاحب محطة، سائق تنك، سيارة غاز، سباك، فني، أو أي جهة تقدم خدمة عبر التطبيق.\nالكوبون: قسيمة رقمية داخل دفتر الكوبونات تستبدل بخدمة واحدة.',
    },
    {
      'icon': Icons.how_to_reg,
      'title': '2. الاشتراك والموافقة',
      'body': 'بمجرد إتمام التسجيل في التطبيق أو استخدام أي من خدماته، فأنت توافق موافقة كاملة وصريحة وغير مشروطة على هذه الشروط والاتفاقية بكامل بنودها، وتقر بصحة البيانات المدخلة ومسؤوليتك عن الحفاظ على سرية حسابك.',
    },
    {
      'icon': Icons.payments,
      'title': '3. الأسعار وطرق الدفع',
      'body': 'جميع الأسعار بالدينار الأردني وتشمل أجور النقل الموضحة قبل تأكيد الدفع.\nطرق الدفع المعتمدة: محفظة قطوره، أو الدفع نقداً عند الاستلام.\nيحق للإدارة تحديث الأسعار، ويُعرض السعر النهائي دائماً قبل إتمام عملية الدفع.',
    },
    {
      'icon': Icons.confirmation_number,
      'title': '4. الكوبونات والعروض',
      'body': 'الكوبونات رقمية وغير قابلة للتحويل إلى نقد أو بين الحسابات.\nدفتر الكوبونات صالح للاستخدام والتعبئة لدى أي محطة مشتركة مع قطوره في جميع أنحاء المملكة.\nالعروض سارية ضمن مدتها وشروطها المعلنة، وتُطبق تلقائياً عند استيفاء الشروط.',
    },
    {
      'icon': Icons.group_add,
      'title': '5. نظام الدعوات والمكافآت',
      'body': 'لكل مستخدم كود دعوة خاص، وتُحتسب الدعوة ناجحة فقط بعد إتمام المدعو أول طلب مدفوع.\nالمكافآت (دفتر كوبونات مجاني، رصيد، إعلانات) تُصرف مرة واحدة لكل مستوى.\nيحق للإدارة إلغاء أي دعوات وهمية أو مكررة وحجب المكافآت المرتبطة بها دون إشعار مسبق.',
    },
    {
      'icon': Icons.lock_outline,
      'title': '6. الخصوصية والبيانات',
      'body': 'نحتفظ ببياناتك (الاسم، الهاتف، الموقع، سجل الطلبات) لغاية تقديم الخدمة وتحسينها فقط.\nلا نبيع بياناتك لأي طرف ثالث، وقد نشارك الحد الأدنى منها مع مزود الخدمة اللازم لتنفيذ طلبك.\nيمكنك طلب حذف حسابك وبياناتك عبر التواصل مع الدعم.',
    },
    {
      'icon': Icons.shield_outlined,
      'title': '7. إخلاء المسؤولية',
      'body': 'قطوره منصة وصل بين العميل ومزود الخدمة، وجودة الخدمة المقدمة ومسؤوليتها تقع على مزود الخدمة.\nالتطبيق غير مسؤول عن تأخير ناتج عن ظروف خارجة عن السيطرة (طقس، طرقات)، مع التزامنا بمتابعة الشكاوي ومعالجتها.',
    },
    {
      'icon': Icons.edit_note,
      'title': '8. التعديلات على الشروط',
      'body': 'يحق لإدارة قطوره تعديل هذه الشروط في أي وقت، ويُنشر التعديل داخل التطبيق.\nاستمرارك باستخدام التطبيق بعد نشر التعديل يُعد موافقة عليه.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('الاتفاقية وشروط الاستخدام', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.goldLight.withValues(alpha: 0.25), AppColors.goldLight.withValues(alpha: 0.08)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.gavel, color: AppColors.goldLight, size: 30),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تنبيه هام', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('بمجرد الاشتراك أو استخدام التطبيق فأنت موافق على جميع البنود أدناه.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('آخر تحديث: 12 أكتوبر 2026', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
          const SizedBox(height: 16),

          ..._sections.map((s) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(s['icon'] as IconData, color: AppColors.goldLight, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(s['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(s['body'] as String, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.5, height: 1.6)),
                  ],
                ),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}