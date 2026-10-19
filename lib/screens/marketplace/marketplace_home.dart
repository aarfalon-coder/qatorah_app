import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/ads/ad_type_badge.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/models/region_model.dart';

/// ═══════════════════════════════════════════════════════════
///  شاشة السوق — مربوطة بنظام الإعلانات
///  تعرض: ⭐ البريميوم (بعد موافقة الأدمن) + 🛒 المجاني (فوري)
/// ═══════════════════════════════════════════════════════════

class MarketplaceHomeScreen extends StatefulWidget {
  const MarketplaceHomeScreen({super.key});

  @override
  State<MarketplaceHomeScreen> createState() => _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends State<MarketplaceHomeScreen> {
  Governorate? _selectedGov; // null = كل المحافظات

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('السوق',
            style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: Consumer<AdvertisementManager>(
        builder: (context, mgr, _) {
          if (mgr.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.goldLight));
          }

          // الإعلانات الصالحة للعرض فقط (نشطة + ضمن المدة)
          final visible = mgr.allAds.where((a) => a.isDisplayable).toList();

          // فلتر المحافظة
          final filtered = _selectedGov == null
              ? visible
              : visible.where((a) => a.visibleTo(_selectedGov)).toList();

          final premiumAds =
              filtered.where((a) => a.type == AdType.premium).toList();
          final freeAds =
              filtered.where((a) => a.type == AdType.free).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ═══ فلتر المحافظة ═══
              _buildGovFilter(),
              const SizedBox(height: 20),

              // ═══ قسم البريميوم ═══
              _sectionTitle('⭐ عروض مميزة (بريميوم)', AppColors.goldLight),
              const SizedBox(height: 10),
              if (premiumAds.isEmpty) _emptyBox('لا توجد عروض مميزة معتمدة حالياً'),
              ...premiumAds.map((a) => _adCard(a, AppColors.goldLight)),

              const SizedBox(height: 24),

              // ═══ قسم السوق المجاني ═══
              _sectionTitle('🛒 سوق الخدمات المجاني', AppColors.crystalBlue),
              const SizedBox(height: 10),
              if (freeAds.isEmpty) _emptyBox('لا توجد إعلانات مجانية حالياً'),
              ...freeAds.map((a) => _adCard(a, AppColors.crystalBlue)),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  // ═══ فلتر المحافظات ═══
  Widget _buildGovFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Governorate?>(
          value: _selectedGov,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1F2E),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: const Icon(Icons.expand_more, color: AppColors.goldLight),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Row(children: [
                Icon(Icons.public, size: 16, color: AppColors.crystalBlue),
                SizedBox(width: 8),
                Text('كل المحافظات'),
              ]),
            ),
            ...Governorate.values.map((g) => DropdownMenuItem(
                  value: g,
                  child: Text(g.displayName),
                )),
          ],
          onChanged: (v) => setState(() => _selectedGov = v),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _emptyBox(String msg) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(msg, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
    );
  }

  // ═══ بطاقة الإعلان ═══
  Widget _adCard(AdvertisementModel ad, Color accent) {
    return Container(
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
              AdTypeBadge(type: ad.type, compact: true),
              const SizedBox(width: 8),
              Expanded(
                child: Text(ad.title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(ad.description,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, height: 1.4),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.store, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Expanded(
                child: Text(ad.publisher.userName,
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ),
              const Icon(Icons.location_on, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text(ad.region.displayName,
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.visibility, size: 14, color: Colors.white38),
              const SizedBox(width: 4),
              Text('${ad.stats.views}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(width: 12),
              const Icon(Icons.touch_app, size: 14, color: Colors.white38),
              const SizedBox(width: 4),
              Text('${ad.stats.clicks}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const Spacer(),
              Text('${ad.remainingDays} يوم متبقي',
                  style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}