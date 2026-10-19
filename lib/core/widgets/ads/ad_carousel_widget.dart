import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/models/advertisement_model.dart';

/// ═══════════════════════════════════════════════════════════
///  شريط الإعلانات المتحرك — نسخة مبسّطة
///  ✅ بدون عنوان الشريط
///  ✅ بدون عدد الإعلانات
///  ✅ بدون "يوم متبقي" و "عرض"
///  ✅ بدون overflow
/// ═══════════════════════════════════════════════════════════

class AdCarouselWidget extends StatefulWidget {
  final List<AdvertisementModel> ads;
  final String title;
  final Color accentColor;
  final double cardHeight;
  final void Function(AdvertisementModel ad)? onTap;

  const AdCarouselWidget({
    super.key,
    required this.ads,
    required this.title,
    this.accentColor = AppColors.goldLight,
    this.cardHeight = 110,
    this.onTap,
  });

  @override
  State<AdCarouselWidget> createState() => _AdCarouselWidgetState();
}

class _AdCarouselWidgetState extends State<AdCarouselWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (widget.ads.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (!mounted || !_pageController.hasClients) return;
        _currentPage = (_currentPage + 1) % widget.ads.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: widget.cardHeight,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.ads.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (context, index) {
          return _buildAdCard(widget.ads[index]);
        },
      ),
    );
  }

  // ✅ بطاقة بسيطة: فقط العنوان + الوصف + شارة النوع
  Widget _buildAdCard(AdvertisementModel ad) {
    return GestureDetector(
      onTap: () => widget.onTap?.call(ad),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.accentColor.withValues(alpha: 0.25),
              widget.accentColor.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.accentColor.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الصف الأول: شارة النوع + العنوان
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ad.type.emoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ad.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // الصف الثاني: الوصف فقط
            Expanded(
              child: Text(
                ad.description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}