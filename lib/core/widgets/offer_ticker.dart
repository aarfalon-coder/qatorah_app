import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OfferTicker extends StatefulWidget {
  const OfferTicker({this.isGuest = false, super.key});

  final bool isGuest;

  @override
  State<OfferTicker> createState() => _OfferTickerState();
}

class _OfferTickerState extends State<OfferTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final bannerWidth = math.min(viewportWidth * 0.9, 560.0);
        return ClipRect(
          child: SizedBox(
            width: viewportWidth,
            height: 58,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final x =
                    (viewportWidth + bannerWidth) * (1 - _controller.value) -
                        bannerWidth;
                return Transform.translate(
                  offset: Offset(x, 0),
                  child: child,
                );
              },
              child: _buildBanner(bannerWidth),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner(double width) {
    return Container(
      key: const ValueKey('offer-ticker-banner'),
      width: width,
      height: 52,
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.crystalBlue.withValues(alpha: 0.52),
            const Color(0xFF78D9FF).withValues(alpha: 0.30),
            AppColors.deepNavy.withValues(alpha: 0.68),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
        boxShadow: [
          BoxShadow(
            color: AppColors.crystalBlue.withValues(alpha: 0.24),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          const Icon(
            Icons.campaign_rounded,
            color: Color(0xFFBDEEFF),
            size: 23,
          ),
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 26,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.isGuest
                  ? 'تصفح التطبيق • سجّل الدخول من القائمة لاستخدام الخدمات'
                  : 'عروض بيع مميزة • محطات ومكنات ومعدات • أضف إعلانك أو ابحث عن طلبك',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
