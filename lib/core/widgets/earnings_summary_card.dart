import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class EarningsSummaryCard extends StatelessWidget {
  final double totalEarnings;
  final double todayEarnings;
  final double weekEarnings;
  final double monthEarnings;
  final double walletBalance;
  final int totalDeliveries;
  final VoidCallback? onWithdraw;
  final VoidCallback? onViewDetails;

  const EarningsSummaryCard({
    super.key,
    required this.totalEarnings,
    this.todayEarnings = 0.0,
    this.weekEarnings = 0.0,
    this.monthEarnings = 0.0,
    this.walletBalance = 0.0,
    this.totalDeliveries = 0,
    this.onWithdraw,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.refillGreen.withValues(alpha: 0.25),
            AppColors.refillGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.refillGreen.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.refillGreen.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══ العنوان + الرصيد ═══
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.refillGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.refillGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'ملخص الأرباح',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onViewDetails != null)
                IconButton(
                  onPressed: onViewDetails,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.refillGreen,
                    size: 16,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ═══ الرصيد الحالي (كبير) ═══
          const Text(
            'الرصيد الحالي',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '${walletBalance.toStringAsFixed(2)} د.أ',
            style: const TextStyle(
              color: AppColors.refillGreen,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // ═══ الإحصائيات ═══
          Row(
            children: [
              _buildStat('اليوم', todayEarnings, AppColors.crystalBlue),
              const SizedBox(width: 8),
              _buildStat('الأسبوع', weekEarnings, AppColors.goldLight),
              const SizedBox(width: 8),
              _buildStat('الشهر', monthEarnings, AppColors.refillGreen),
            ],
          ),
          const SizedBox(height: 12),

          // ═══ إجمالي التوصيلات ═══
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_shipping,
                  color: Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'إجمالي التوصيلات',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '$totalDeliveries',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'توصيلة',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),

          // ═══ زرار السحب ═══
          if (onWithdraw != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onWithdraw,
                icon: const Icon(Icons.download, size: 18),
                label: const Text(
                  'سحب الأرباح',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.refillGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}