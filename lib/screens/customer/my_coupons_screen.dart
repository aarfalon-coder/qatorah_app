import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/coupon_info_dialog.dart';
import 'package:qatorah_app/managers/coupon_manager.dart';
import 'package:qatorah_app/models/coupon_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCouponsScreen extends StatefulWidget {
  const MyCouponsScreen({super.key});

  @override
  State<MyCouponsScreen> createState() => _MyCouponsScreenState();
}

class _MyCouponsScreenState extends State<MyCouponsScreen> {
  bool _hasSeenInfo = false;

  @override
  void initState() {
    super.initState();
    _checkFirstOpen();
  }

  Future<void> _checkFirstOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('coupon_info_seen') ?? false;
    if (!seen && mounted) {
      Future.delayed(const Duration(milliseconds: 400), () async {
        if (mounted) {
          showCouponBookInfo(context);
          await prefs.setBool('coupon_info_seen', true);
          setState(() => _hasSeenInfo = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('كوبوناتي',
            style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.goldLight),
            tooltip: 'كيف يعمل دفتر الكوبونات؟',
            onPressed: () => showCouponBookInfo(context),
          ),
        ],
      ),
      body: Consumer<CouponManager>(
        builder: (context, couponMgr, _) {
          if (couponMgr.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.goldLight),
            );
          }

          final books = couponMgr.activeBooks;

          if (books.isEmpty) {
            return _buildEmptyState();
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildTotalBalanceCard(couponMgr),
              const SizedBox(height: 24),
              const Text('دفاتر الكوبونات',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...books.map(_buildBookCard),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showBuyOptions(couponMgr),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('شراء دفتر جديد'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.goldLight,
                    side: const BorderSide(color: AppColors.goldLight),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalBalanceCard(CouponManager mgr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.goldLight.withValues(alpha: 0.25),
            AppColors.goldLight.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.goldLight.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.confirmation_number,
                color: AppColors.goldLight, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('إجمالي الكوبونات المتبقية',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '${mgr.totalRemainingCoupons} كوبون',
                  style: const TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(CouponBookModel book) {
    final color = _colorForType(book.type);
    final icon = book.type.icon;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('دفتر ${book.type.label}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '${book.remainingCoupons} كوبون متبقي من ${book.totalCoupons}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('${book.remainingCoupons}',
                    style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: book.totalCoupons == 0
                  ? 0
                  : book.usedCoupons / book.totalCoupons,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ينتهي: ${_formatDate(book.expiresAt)}',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
              ),
              Text(
                'استُخدم: ${book.usedCoupons}',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  book.canUse ? () => _showUseCouponDialog(book) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: const Color(0xFF0A0E1A),
                disabledBackgroundColor: Colors.grey.shade800,
              ),
              child: Text(book.canUse ? 'استخدام كوبون' : 'مستنفد'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_outlined,
                size: 80, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text('لا توجد دفاتر كوبونات',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('اشترِ دفترك الأول واستفد من العروض',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showBuyOptions(context.read<CouponManager>()),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('شراء دفتر جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldLight,
                foregroundColor: const Color(0xFF0A0E1A),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBuyOptions(CouponManager mgr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('اختر نوع الدفتر',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...kCouponBookTypes.map((type) {
              final color = _colorForType(type.type);
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle),
                  child: Icon(type.type.icon, color: color, size: 22),
                ),
                title: Text(type.label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(type.description,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11)),
                trailing: Text('${type.price.toStringAsFixed(0)} د.أ',
                    style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await mgr.buyCouponBook(type);
                  if (result != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    'تم شراء "${type.label}" بنجاح')),
                          ],
                        ),
                        backgroundColor: AppColors.refillGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showUseCouponDialog(CouponBookModel book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('استخدام كوبون',
            style: TextStyle(color: AppColors.goldLight)),
        content: Text(
            'سيتم خصم كوبون واحد من "دفتر ${book.type.label}" عند إتمام الطلب القادم.',
            style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      'تم تفعيل الكوبون ✅ - سيتم تطبيقه على الطلب القادم'),
                  backgroundColor: AppColors.refillGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.refillGreen,
                foregroundColor: Colors.white),
            child: const Text('تفعيل'),
          ),
        ],
      ),
    );
  }

  Color _colorForType(CouponType type) {
    switch (type) {
      case CouponType.water:
        return AppColors.tankCyan;
      case CouponType.gas:
        return const Color(0xFFE65100);
      case CouponType.maintenance:
        return AppColors.maintenanceOrange;
      case CouponType.mixed:
        return AppColors.crystalBlue;
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}