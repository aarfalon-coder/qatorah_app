import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qatorah_app/screens/customer/customer_home.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/models/splash_ad_model.dart';
import 'package:qatorah_app/services/splash_ad_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashAdScreen extends StatefulWidget {
  final SplashAdModel ad;
  final VoidCallback? onFinished;

  const SplashAdScreen({super.key, required this.ad, this.onFinished});

  @override
  State<SplashAdScreen> createState() => _SplashAdScreenState();
}

class _SplashAdScreenState extends State<SplashAdScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _canSkip = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.ad.durationSeconds;
    SplashAdService().incrementImpression(widget.ad.id);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _canSkip = true);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        if (mounted) _goNext();
      } else {
        if (mounted) setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
      (route) => false,
    );
  }

  Future<void> _openLink() async {
    if (widget.ad.targetUrl == null || widget.ad.targetUrl!.isEmpty) return;
    SplashAdService().incrementClick(widget.ad.id);
    final uri = Uri.tryParse(widget.ad.targetUrl!);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildMedia(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, color: AppColors.goldLight, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '$_remainingSeconds ث',
                    style: const TextStyle(color: AppColors.goldLight, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          if (_canSkip)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: GestureDetector(
                onTap: _goNext,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('تخطي', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.close, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.goldLight.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'إعلان',
                          style: TextStyle(color: AppColors.blackDeep, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.ad.advertiserName,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.ad.title,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (widget.ad.description != null && widget.ad.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.ad.description!,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                    ),
                  ],
                  if (widget.ad.targetUrl != null && widget.ad.targetUrl!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openLink,
                        icon: const Icon(Icons.open_in_new, size: 20),
                        label: Text(
                          widget.ad.callToAction ?? 'زيارة',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          foregroundColor: Colors.white,
                          side: BorderSide(color: AppColors.goldLight.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _goNext,
                      icon: const Icon(Icons.arrow_forward, size: 20),
                      label: const Text(
                        'متابعة للتطبيق',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldLight,
                        foregroundColor: AppColors.blackDeep,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia() {
    if (widget.ad.mediaType == 'video') {
      return _buildImageFallback();
    }
    return _buildImageFallback();
  }

  Widget _buildImageFallback() {
    return CachedNetworkImage(
      imageUrl: widget.ad.mediaUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.blackDeep,
        child: const Center(child: CircularProgressIndicator(color: AppColors.goldLight)),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.blackDeep,
        child: const Center(child: Icon(Icons.broken_image, color: Colors.white24, size: 80)),
      ),
    );
  }
}