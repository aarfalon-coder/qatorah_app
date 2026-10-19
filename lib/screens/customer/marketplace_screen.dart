import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/ads/ad_type_badge.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/models/region_model.dart';
import 'package:qatorah_app/screens/marketplace/ad_details_screen.dart'; // ✅ استيراد شاشة التفاصيل

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  Governorate? _selectedGov;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('السوق', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: Consumer<AdvertisementManager>(
        builder: (context, mgr, _) {
          if (mgr.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.goldLight));

          final visible = mgr.allAds.where((a) => a.isDisplayable).toList();
          final filtered = _selectedGov == null ? visible : visible.where((a) => a.visibleTo(_selectedGov)).toList();
          final premiumAds = filtered.where((a) => a.type == AdType.premium).toList();
          final freeAds = filtered.where((a) => a.type == AdType.free).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildGovFilter(),
              const SizedBox(height: 20),
              _sectionTitle('⭐ عروض مميزة (بريميوم)', AppColors.goldLight),
              const SizedBox(height: 10),
              if (premiumAds.isEmpty) _emptyBox('لا توجد عروض مميزة معتمدة حالياً'),
              ...premiumAds.map((a) => _adCard(context, mgr, a, AppColors.goldLight)),
              const SizedBox(height: 24),
              _sectionTitle('🛒 سوق الخدمات المجاني', AppColors.crystalBlue),
              const SizedBox(height: 10),
              if (freeAds.isEmpty) _emptyBox('لا توجد إعلانات مجانية حالياً'),
              ...freeAds.map((a) => _adCard(context, mgr, a, AppColors.crystalBlue)),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGovFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Governorate?>(
          value: _selectedGov, isExpanded: true, dropdownColor: const Color(0xFF1A1F2E), style: const TextStyle(color: Colors.white, fontSize: 14), icon: const Icon(Icons.expand_more, color: AppColors.goldLight),
          items: [
            const DropdownMenuItem(value: null, child: Row(children: [Icon(Icons.public, size: 16, color: AppColors.crystalBlue), SizedBox(width: 8), Text('كل المحافظات')])),
            ...Governorate.values.map((g) => DropdownMenuItem(value: g, child: Text(g.displayName))),
          ],
          onChanged: (v) => setState(() => _selectedGov = v),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, Color color) => Row(children: [Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 8), Text(text, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold))]);
  Widget _emptyBox(String msg) => Container(padding: const EdgeInsets.all(20), alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12)), child: Text(msg, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)));

  // ✅ البطاقة المحدثة (صورة + نقر + إحصائيات)
  Widget _adCard(BuildContext context, AdvertisementManager mgr, AdvertisementModel ad, Color accent) {
    return GestureDetector(
      onTap: () {
        mgr.trackClick(ad.id); // ✅ زيادة عداد النقرات
        Navigator.push(context, MaterialPageRoute(builder: (_) => AdDetailsScreen(ad: ad))); // ✅ فتح شاشة التفاصيل
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // ✅ عرض الصورة المصغرة
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ad.images.isNotEmpty 
                    ? Image.file(File(ad.images.first), width: 60, height: 60, fit: BoxFit.cover)
                    : Container(width: 60, height: 60, color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.white24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [AdTypeBadge(type: ad.type, compact: true), const Spacer(), Text('${ad.remainingDays} يوم', style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold))]),
                      const SizedBox(height: 6),
                      Text(ad.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(ad.publisher.userName, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(ad.description, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.white54),
                const SizedBox(width: 4),
                Text(ad.region.displayName, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                const Spacer(),
                const Icon(Icons.visibility, size: 14, color: Colors.white38),
                const SizedBox(width: 4),
                Text('${ad.stats.views}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                const SizedBox(width: 12),
                const Icon(Icons.touch_app, size: 14, color: Colors.white38),
                const SizedBox(width: 4),
                Text('${ad.stats.clicks}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}