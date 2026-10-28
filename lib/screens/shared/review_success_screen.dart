import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class ReviewSuccessScreen extends StatefulWidget {
  final String providerName;
  final int rating;
  final VoidCallback? onDone;

  const ReviewSuccessScreen({
    super.key,
    required this.providerName,
    required this.rating,
    this.onDone,
  });

  @override
  State<ReviewSuccessScreen> createState() => _ReviewSuccessScreenState();
}

class _ReviewSuccessScreenState extends State<ReviewSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller, curve: const Interval(0.4, 1.0)),
    );

    _controller.forward();

    // العودة التلقائية بعد 3 ثواني
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onDone?.call();
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getRatingText() {
    switch (widget.rating) {
      case 1:
        return 'سنحاول التحسين';
      case 2:
        return 'شكراً لملاحظاتك';
      case 3:
        return 'نعدك بالأفضل';
      case 4:
        return 'سعيدون برضاك';
      case 5:
        return 'أنت رائع!';
      default:
        return 'شكراً لك';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ═══ أيقونة النجاح ═══
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.refillGreen.withValues(alpha: 0.3),
                          AppColors.refillGreen.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.refillGreen.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.refillGreen,
                      size: 80,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ═══ العنوان ═══
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'تم إرسال التقييم!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getRatingText(),
                          style: const TextStyle(
                            color: AppColors.goldLight,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ═══ النجوم ═══
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < widget.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.goldLight,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ═══ اسم المزود ═══
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              AppColors.crystalBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.store,
                              color: AppColors.crystalBlue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.providerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ═══ رسالة إضافية ═══
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'تقييمك يساعدنا على تقديم خدمة أفضل 🌟',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ═══ شريط التقدم (يعد 3 ثواني) ═══
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 3),
                          builder: (context, value, _) {
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.1),
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.goldLight),
                              minHeight: 4,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ═══ زر "تم" (اختياري) ═══
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: TextButton(
                      onPressed: () {
                        widget.onDone?.call();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'العودة للرئيسية',
                        style: TextStyle(
                          color: AppColors.crystalBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}