import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/ads/ad_type_badge.dart';
import 'package:qatorah_app/core/widgets/ads/ad_status_badge.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/screens/provider/create_ad_screen.dart';
import 'package:qatorah_app/screens/provider/ad_stats_screen.dart';

class MyAdsScreen extends StatelessWidget {
  const MyAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('إعلاناتي', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.goldLight),
          bottom: const TabBar(
            labelColor: AppColors.goldLight,
            unselectedLabelColor: Colors.white54,
            indicatorColor: AppColors.goldLight,
            tabs: [Tab(text: 'نشطة'), Tab(text: 'قيد المراجعة'), Tab(text: 'منتهية')],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAdScreen())),
          backgroundColor: AppColors.goldLight,
          foregroundColor: const Color(0xFF0A0E1A),
          icon: const Icon(Icons.add),
          label: const Text('إعلان جديد', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Consumer<AdvertisementManager>(
          builder: (context, mgr, _) {
            if (mgr.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.goldLight));
            }
            return TabBarView(
              children: [
                _buildList(context, mgr, mgr.myActiveAds),
                _buildList(context, mgr, mgr.myPendingAds),
                _buildList(context, mgr, mgr.myExpiredAds),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, AdvertisementManager mgr, List<AdvertisementModel> ads) {
    if (ads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text('لا توجد إعلانات هنا', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ads.length,
      itemBuilder: (context, i) => _adCard(context, mgr, ads[i]),
    );
  }

  Widget _adCard(BuildContext context, AdvertisementManager mgr, AdvertisementModel ad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56, height: 56,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                child: ad.images.isNotEmpty
                    ? Image.file(File(ad.images.first), fit: BoxFit.cover)
                    : const Icon(Icons.image, color: Colors.white24, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ad.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 4, children: [
                      AdTypeBadge(type: ad.type, compact: true),
                      AdStatusBadge(status: ad.status),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _miniStat(Icons.visibility, '${ad.stats.views}'),
              _miniStat(Icons.touch_app, '${ad.stats.clicks}'),
              _miniStat(Icons.calendar_today, '${ad.remainingDays} يوم'),
            ],
          ),
          const SizedBox(height: 12),
          _actions(context, mgr, ad),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String val) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Row(children: [
        Icon(icon, size: 14, color: Colors.white54),
        const SizedBox(width: 4),
        Text(val, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }

  Widget _actions(BuildContext context, AdvertisementManager mgr, AdvertisementModel ad) {
    return Row(
      children: [
        _smallBtn(context, Icons.bar_chart, 'إحصائيات', AppColors.crystalBlue, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AdStatsScreen(ad: ad)));
        }),
        const Spacer(),
        if (ad.isPending)
          _smallBtn(context, Icons.block, 'إلغاء', AppColors.plumberRed, () => _confirm(context, 'إلغاء طلب المراجعة وفك الحجز؟', () async {
            await mgr.cancelPendingAd(ad.id);
            _snack(context, 'تم إلغاء الطلب وفك الحجز');
          })),
        if (ad.type == AdType.free && ad.isActive)
          _smallBtn(context, Icons.arrow_upward, 'ترقية', AppColors.goldLight, () => _confirm(context, 'ترقية هذا الإعلان لبريميوم؟', () async {
            final r = await mgr.upgradeToPremium(ad.id, price: 25, days: 30);
            _snack(context, r != null ? '⏳ تم إنشاء نسخة بريميوم بانتظار المراجعة' : 'تعذرت الترقية');
          })),
        if (ad.isExpired)
          _smallBtn(context, Icons.refresh, 'تجديد', AppColors.refillGreen, () async {
            final ok = await mgr.renewAd(ad.id);
            _snack(context, ok ? 'تم التجديد' : 'تعذر التجديد');
          }),
        _smallBtn(context, Icons.delete_outline, 'حذف', AppColors.plumberRed, () => _confirm(context, 'حذف الإعلان نهائياً؟', () async {
          final ok = await mgr.deleteAd(ad.id);
          _snack(context, ok ? 'تم الحذف' : (mgr.error ?? 'لا يمكن حذف إعلان محجوز'));
        })),
      ],
    );
  }

  Widget _smallBtn(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  void _confirm(BuildContext context, String msg, VoidCallback onYes) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1F2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 15)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('تراجع', style: TextStyle(color: Colors.white54))),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); onYes(); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight, foregroundColor: const Color(0xFF0A0E1A)), child: const Text('تأكيد')),
      ],
    ));
  }

  void _snack(BuildContext context, String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.navyDark, behavior: SnackBarBehavior.floating));
  }
}
