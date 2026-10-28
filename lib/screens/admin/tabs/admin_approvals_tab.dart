import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';

class AdminApprovalsTab extends StatelessWidget {
  const AdminApprovalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdvertisementManager>(builder: (context, mgr, _) {
      final pending = mgr.pendingReviewAds;
      if (pending.isEmpty) {
        return const Center(child: Text('لا توجد إعلانات معلقة ✅', style: TextStyle(color: Colors.white70)));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pending.length,
        itemBuilder: (context, i) {
          final ad = pending[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text(ad.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => mgr.rejectAd(ad.id, 'مرفوض'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.plumberRed),
                        child: const Text('رفض'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => mgr.approveAd(ad.id),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.refillGreen),
                        child: const Text('اعتماد'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }
}