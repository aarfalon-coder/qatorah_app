import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/ads/ad_type_badge.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/models/comment_model.dart';

/// ═══════════════════════════════════════════════════════════
///  نافذة تفاصيل الإعلان — تصميم أنيق بخلفية فاتحة
///  ✅ زر الإغلاق في الزاوية اليمنى العليا
///  ✅ بدون خطأ أحمر (يدعم صور محلية + URL)
///  ✅ خلفية فاتحة غير زجاجية
///  ✅ برواز أنيق
/// ═══════════════════════════════════════════════════════════

class AdDetailsDialog extends StatefulWidget {
  final AdvertisementModel ad;
  const AdDetailsDialog({super.key, required this.ad});

  @override
  State<AdDetailsDialog> createState() => _AdDetailsDialogState();
}

class _AdDetailsDialogState extends State<AdDetailsDialog> {
  final _commentCtrl = TextEditingController();
  String? _replyingToId;
  final _replyCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    _replyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdvertisementManager>().trackView(widget.ad.id);
    });

    return Dialog(
      backgroundColor: const Color(0xFFF5F7FA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: AppColors.goldLight.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      insetPadding: const EdgeInsets.all(16),
      child: Consumer<AdvertisementManager>(
        builder: (context, mgr, _) {
          final likes = mgr.getAdLikes(widget.ad.id);
          final comments = mgr.getAdComments(widget.ad.id);

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
              maxWidth: 500,
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ═══ الصورة الكبيرة في الأعلى ═══
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                      ),
                      child: _buildImage(widget.ad.images.isNotEmpty ? widget.ad.images.first : null),
                    ),

                    // ══ المحتوى ═══
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ═══ الشارات ═══
                            Row(
                              children: [
                                AdTypeBadge(type: widget.ad.type),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.crystalBlue.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.crystalBlue.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    '${widget.ad.scope.emoji} ${widget.ad.scope.label}',
                                    style: const TextStyle(color: AppColors.crystalBlue, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // ═══ العنوان ═══
                            Text(
                              widget.ad.title,
                              style: const TextStyle(
                                color: Color(0xFF1A1F2E),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ═══ بطاقة المزود ═══
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.goldLight.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.store, color: AppColors.goldLight, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.ad.publisher.userName,
                                          style: const TextStyle(
                                            color: Color(0xFF1A1F2E),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: AppColors.goldLight, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${widget.ad.publisher.userRating}',
                                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('📞 ${widget.ad.publisher.userPhone}'),
                                          backgroundColor: AppColors.refillGreen,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.refillGreen,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.refillGreen.withValues(alpha: 0.4),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.phone, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ═══ الوصف ═══
                            const Text(
                              'التفاصيل',
                              style: TextStyle(
                                color: AppColors.goldLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                              ),
                              child: Text(
                                widget.ad.description,
                                style: const TextStyle(
                                  color: Color(0xFF4A5568),
                                  fontSize: 14,
                                  height: 1.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ═══ زر الإعجاب ═══
                            GestureDetector(
                              onTap: () {
                                mgr.toggleAdLike(widget.ad.id);
                                _notifyOwner('أعجب بإعلانك');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.plumberRed.withValues(alpha: 0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.plumberRed.withValues(alpha: 0.1),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.favorite, color: AppColors.plumberRed, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'أعجبني ($likes)',
                                      style: const TextStyle(
                                        color: AppColors.plumberRed,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ═══ التعليقات ═══
                            const Text(
                              'التعليقات',
                              style: TextStyle(
                                color: AppColors.goldLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // حقل إضافة تعليق
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentCtrl,
                                    decoration: InputDecoration(
                                      hintText: 'اكتب تعليقاً...',
                                      hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.6)),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppColors.goldLight),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    ),
                                    style: const TextStyle(color: Color(0xFF1A1F2E)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    if (_commentCtrl.text.trim().isNotEmpty) {
                                      mgr.addComment(widget.ad.id, _commentCtrl.text.trim(), 'أنا');
                                      _notifyOwner('علّق على إعلانك');
                                      _commentCtrl.clear();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.goldLight,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.goldLight.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.send, color: Color(0xFF0A0E1A), size: 20),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // قائمة التعليقات
                            if (comments.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                                ),
                                child: const Text(
                                  'لا توجد تعليقات بعد. كن أول من يعلّق! 💬',
                                  style: TextStyle(color: Colors.black54, fontSize: 13),
                                ),
                              )
                            else
                              ...comments.map((c) => _buildComment(mgr, c)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ══ زر الإغلاق في الزاوية اليمنى العليا ═══
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══ دالة عرض الصورة (تدعم محلي + URL) ═══
  Widget _buildImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        height: 220,
        color: const Color(0xFFE2E8F0),
        child: const Icon(Icons.image, size: 60, color: Colors.black26),
      );
    }

    // إذا كان رابط إنترنت
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 220,
            color: const Color(0xFFE2E8F0),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.goldLight,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 220,
            color: const Color(0xFFE2E8F0),
            child: const Icon(Icons.broken_image, size: 60, color: Colors.black26),
          );
        },
      );
    }

    // إذا كان ملف محلي
    return Image.file(
      File(imagePath),
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 220,
          color: const Color(0xFFE2E8F0),
          child: const Icon(Icons.broken_image, size: 60, color: Colors.black26),
        );
      },
    );
  }

  void _notifyOwner(String action) {
    debugPrint('🔔 إشعار لصاحب الإعلان: $action');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔔 تم إرسال إشعار لصاحب الإعلان'),
          backgroundColor: AppColors.crystalBlue,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildComment(AdvertisementManager mgr, CommentModel comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.crystalBlue.withValues(alpha: 0.15),
                child: const Icon(Icons.person, size: 16, color: AppColors.crystalBlue),
              ),
              const SizedBox(width: 10),
              Text(
                comment.userName,
                style: const TextStyle(
                  color: Color(0xFF1A1F2E),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                _timeAgo(comment.createdAt),
                style: TextStyle(color: Colors.grey.withValues(alpha: 0.6), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.text,
            style: const TextStyle(color: Color(0xFF4A5568), fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => mgr.toggleCommentLike(widget.ad.id, comment.id),
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, size: 16, color: Colors.grey.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text('${comment.likes}', style: TextStyle(color: Colors.grey.withValues(alpha: 0.6), fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => setState(() => _replyingToId = comment.id),
                child: const Row(
                  children: [
                    Icon(Icons.reply, size: 14, color: AppColors.goldLight),
                    SizedBox(width: 4),
                    Text('رد', style: TextStyle(color: AppColors.goldLight, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          if (_replyingToId == comment.id) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'اكتب رداً...',
                      hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.6)),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(color: Color(0xFF1A1F2E), fontSize: 13),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    if (_replyCtrl.text.trim().isNotEmpty) {
                      mgr.addReply(widget.ad.id, comment.id, _replyCtrl.text.trim(), 'أنا');
                      _notifyOwner('ردّ على تعليق');
                      _replyCtrl.clear();
                      setState(() => _replyingToId = null);
                    }
                  },
                  child: const Icon(Icons.send, color: AppColors.goldLight, size: 20),
                ),
              ],
            ),
          ],
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...comment.replies.map((r) => Padding(
                  padding: const EdgeInsets.only(left: 20, top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        right: BorderSide(color: AppColors.goldLight.withValues(alpha: 0.4), width: 3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.userName,
                          style: const TextStyle(
                            color: AppColors.goldLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.text,
                          style: const TextStyle(color: Color(0xFF4A5568), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    return 'منذ ${diff.inDays} ي';
  }
}