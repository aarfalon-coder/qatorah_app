import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class TechniciansListScreen extends StatefulWidget {
  const TechniciansListScreen({super.key});

  @override
  State<TechniciansListScreen> createState() => _TechniciansListScreenState();
}

class _TechniciansListScreenState extends State<TechniciansListScreen> {
  // ✅ هنا سيتم جلب البيانات الحقيقية لاحقاً، مثال:
  // final marketplaceProvider = Provider.of<MarketplaceProvider>(context);
  // final techs = marketplaceProvider.technicians;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'الفنيين المتاحين',
          style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: const Center(
        // ✅ واجهة تحميل نظيفة بدلاً من البيانات الوهمية
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.goldLight),
            SizedBox(height: 16),
            Text(
              'جاري جلب قائمة الفنيين من قاعدة البيانات...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              '(سيتم ربط هذه الشاشة بـ MarketplaceProvider)',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        
        // 💡 ملاحظة: عند جاهزية الـ Provider، استبدل الـ Center أعلاه بـ:
        // ListView.builder(
        //   padding: const EdgeInsets.all(16),
        //   itemCount: techs.length,
        //   itemBuilder: (context, index) => _techCard(context, techs[index]),
        // ),
      ),
    );
  }
}