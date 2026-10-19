import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class WalletBalanceCard extends StatelessWidget {
  final double balance;
  final int points;
  final VoidCallback? onRecharge;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.points,
    this.onRecharge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.refillGreen.withValues(alpha: 0.3),
            AppColors.refillGreen.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.refillGreen.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.refillGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet, color: AppColors.refillGreen, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('رصيد المحفظة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '${balance.toStringAsFixed(2)} د.أ',
                  style: const TextStyle(color: AppColors.refillGreen, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: AppColors.goldLight, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$points نقطة مكافأة',
                      style: const TextStyle(color: AppColors.goldLight, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onRecharge != null)
            ElevatedButton(
              onPressed: onRecharge,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.refillGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('شحن', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}