import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';

class AdminAdsTab extends StatefulWidget {
  const AdminAdsTab({super.key});

  @override
  State<AdminAdsTab> createState() => _AdminAdsTabState();
}

class _AdminAdsTabState extends State<AdminAdsTab> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return Consumer<AdvertisementManager>(builder: (context, mgr, _) {
      if (mgr.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.goldLight));
      
      final ads = _filter == 'all' 
          ? mgr.allAds 
          : mgr.allAds.where((a) => _filter == 'pending' ? a.isPending : (_filter == 'active' ? a.isActive : a.isRejected)).toList();
      
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF0A0E1A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _chip('الكل', 'all'),
                _chip('معلقة', 'pending'),
                _chip('نشطة', 'active'),
                _chip('مرفوضة', 'rejected'),
              ],
            ),
          ),
          Expanded(
            child: ads.isEmpty 
              ? const Center(child: Text('لا توجد إعلانات', style: TextStyle(color: Colors.white54))) 
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ads.length,
                  itemBuilder: (context, i) {
                    final ad = ads[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ad.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(ad.description, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 2),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              if (ad.isPending) ...[
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => mgr.rejectAd(ad.id, 'مرفوض'),
                                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.plumberRed),
                                    child: const Text('رفض'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => mgr.approveAd(ad.id),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.refillGreen),
                                    child: const Text('اعتماد'),
                                  ),
                                ),
                              ] else
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => mgr.deleteAd(ad.id),
                                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.plumberRed),
                                    child: const Text('حذف'),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      );
    });
  }

  Widget _chip(String label, String value) {
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _filter == value ? AppColors.crystalBlue.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _filter == value ? AppColors.crystalBlue : Colors.white24),
        ),
        child: Text(label, style: TextStyle(color: _filter == value ? AppColors.crystalBlue : Colors.white54, fontSize: 12)),
      ),
    );
  }
}