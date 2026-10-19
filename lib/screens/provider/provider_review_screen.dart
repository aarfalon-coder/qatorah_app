import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class ProviderReviewScreen extends StatefulWidget {
  final String providerId;
  final String providerName;

  const ProviderReviewScreen({
    super.key,
    required this.providerId,
    required this.providerName,
  });

  @override
  State<ProviderReviewScreen> createState() => _ProviderReviewScreenState();
}

class _ProviderReviewScreenState extends State<ProviderReviewScreen> {
  int _selectedRating = 0;
  final TextEditingController _commentCtrl = TextEditingController();
  final List<String> _selectedTags = [];
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _ratingTags = [
    {'id': 'fast', 'label': 'سريع', 'icon': Icons.speed},
    {'id': 'clean', 'label': 'نظيف', 'icon': Icons.cleaning_services},
    {'id': 'polite', 'label': 'مؤدب', 'icon': Icons.emoji_emotions},
    {'id': 'accurate', 'label': 'دقيق', 'icon': Icons.check_circle},
    {'id': 'good_price', 'label': 'سعر مناسب', 'icon': Icons.attach_money},
    {'id': 'professional', 'label': 'احترافي', 'icon': Icons.workspace_premium},
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      _showSnack('اختر تقييماً أولاً', AppColors.plumberRed);
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: Firebase - حفظ التقييم
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    // العودة للشاشة السابقة
    Navigator.pop(context, true);

    _showSnack('شكراً! تم إرسال تقييمك', AppColors.refillGreen);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  String _getRatingText() {
    switch (_selectedRating) {
      case 1:
        return 'سيء جداً 😞';
      case 2:
        return 'سيء 😕';
      case 3:
        return 'مقبول 😐';
      case 4:
        return 'جيد 😊';
      case 5:
        return 'ممتاز 🤩';
      default:
        return 'اختر تقييمك';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.goldLight),
        title: const Text(
          'تقييم المزود',
          style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═══ معلومات المزود ═══
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.crystalBlue.withValues(alpha: 0.2),
                    AppColors.crystalBlue.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.crystalBlue.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.crystalBlue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.store,
                        color: AppColors.crystalBlue, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('قيّم تجربتك مع',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(widget.providerName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ═══ النجوم ═══
            const Text('ما هو تقييمك؟',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = star),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      star <= _selectedRating
                          ? Icons.star
                          : Icons.star_border,
                      color: AppColors.goldLight,
                      size: 48,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              _getRatingText(),
              style: TextStyle(
                color: _selectedRating > 0
                    ? AppColors.goldLight
                    : Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // ═══ الكلمات المفتاحية ═══
            const Text('ما الذي أعجبك؟ (اختياري)',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _ratingTags.map((tag) {
                final selected = _selectedTags.contains(tag['id']);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedTags.remove(tag['id']);
                      } else {
                        _selectedTags.add(tag['id'] as String);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.crystalBlue.withValues(alpha: 0.2)
                          : const Color(0xFF1A1F2E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.crystalBlue
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tag['icon'] as IconData,
                            color: selected
                                ? AppColors.crystalBlue
                                : Colors.white54,
                            size: 16),
                        const SizedBox(width: 6),
                        Text(tag['label'] as String,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.crystalBlue
                                  : Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ═══ التعليق ═══
            const Text('اترك تعليقاً (اختياري)',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: TextField(
                controller: _commentCtrl,
                maxLines: 4,
                maxLength: 300,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'شاركنا تجربتك...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                  counterStyle: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ═══ زر الإرسال ═══
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldLight,
                  foregroundColor: const Color(0xFF0A0E1A),
                  disabledBackgroundColor: Colors.grey.shade800,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'إرسال التقييم',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}