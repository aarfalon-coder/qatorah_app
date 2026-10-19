import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/ads/ad_type_badge.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/models/comment_model.dart';
import 'package:qatorah_app/models/region_model.dart';

class AdDetailsScreen extends StatefulWidget {
  final AdvertisementModel ad;
  const AdDetailsScreen({super.key, required this.ad});

  @override
  State<AdDetailsScreen> createState() => _AdDetailsScreenState();
}

class _AdDetailsScreenState extends State<AdDetailsScreen> {
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

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Consumer<AdvertisementManager>(
        builder: (context, mgr, _) {
          final likes = mgr.getAdLikes(widget.ad.id);
          final comments = mgr.getAdComments(widget.ad.id);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: const Color(0xFF1A1F2E),
                leading: IconButton(
                  icon: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: Colors.white)),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: widget.ad.images.isNotEmpty
                      ? Image.file(File(widget.ad.images.first), fit: BoxFit.cover)
                      : Container(color: Colors.grey[800], child: const Icon(Icons.image, size: 60, color: Colors.white24)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AdTypeBadge(type: widget.ad.type),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(widget.ad.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1F2E), 
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1))
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.goldLight.withValues(alpha: 0.2),
                              child: const Icon(Icons.store, color: AppColors.goldLight),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                Text(widget.ad.publisher.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('⭐ ${widget.ad.publisher.userRating}  •  ${widget.ad.publisher.userRole}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              ]
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('📞 جاري الاتصال بـ ${widget.ad.publisher.userPhone}...'), backgroundColor: AppColors.refillGreen)
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(color: AppColors.refillGreen, shape: BoxShape.circle),
                                child: const Icon(Icons.phone, color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('التفاصيل', style: TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(widget.ad.description, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6)),
                      
                      const SizedBox(height: 24),
                      const Text('التغطية الجغرافية', style: TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.crystalBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          const Icon(Icons.location_on, color: AppColors.crystalBlue),
                          const SizedBox(width: 8),
                          Expanded(child: Text(Regions.describeCoverage(widget.ad.region, widget.ad.type.code), style: const TextStyle(color: Colors.white70, fontSize: 14))),
                        ]),
                      ),

                      const SizedBox(height: 30),
                      // ═══ زر الإعجاب بالإعلان ═══
                      GestureDetector(
                        onTap: () => mgr.toggleAdLike(widget.ad.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.plumberRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.plumberRed.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite, color: AppColors.plumberRed, size: 20),
                              const SizedBox(width: 8),
                              Text('أعجبني ($likes)', style: const TextStyle(color: AppColors.plumberRed, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      const Text('التعليقات', style: TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      
                      // ═══ إضافة تعليق ═══
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentCtrl,
                              decoration: InputDecoration(
                                hintText: 'اكتب تعليقاً...',
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                                filled: true,
                                fillColor: const Color(0xFF1A1F2E),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              if (_commentCtrl.text.trim().isNotEmpty) {
                                mgr.addComment(widget.ad.id, _commentCtrl.text.trim(), 'أنا');
                                _commentCtrl.clear();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(color: AppColors.goldLight, shape: BoxShape.circle),
                              child: const Icon(Icons.send, color: Color(0xFF0A0E1A)),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ═══ قائمة التعليقات ═══
                      ...comments.map((c) => _buildCommentWidget(context, mgr, c)),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              )
            ],
          );
        }
      )
    );
  }

  Widget _buildCommentWidget(BuildContext context, AdvertisementManager mgr, CommentModel comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 16, backgroundColor: AppColors.crystalBlue.withValues(alpha: 0.2), child: const Icon(Icons.person, size: 16, color: AppColors.crystalBlue)),
                  const SizedBox(width: 8),
                  Text(comment.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  const Spacer(),
                  Text(_timeAgo(comment.createdAt), style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
                ],
              ),
              const SizedBox(height: 8),
              Text(comment.text, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => mgr.toggleCommentLike(widget.ad.id, comment.id),
                    child: Row(children: [
                      const Icon(Icons.favorite_border, size: 16, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text('${comment.likes}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ]),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => setState(() => _replyingToId = comment.id),
                    child: const Row(children: [
                      Icon(Icons.reply, size: 16, color: AppColors.goldLight),
                      SizedBox(width: 4),
                      Text('رد', style: TextStyle(color: AppColors.goldLight, fontSize: 12, fontWeight: FontWeight.bold)),
                    ]),
                  )
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
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (_replyCtrl.text.trim().isNotEmpty) {
                          mgr.addReply(widget.ad.id, comment.id, _replyCtrl.text.trim(), 'أنا');
                          _replyCtrl.clear();
                          setState(() => _replyingToId = null);
                        }
                      },
                      child: const Icon(Icons.send, color: AppColors.goldLight, size: 20),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _replyingToId = null),
                      child: const Icon(Icons.close, color: Colors.white38, size: 20),
                    )
                  ],
                )
              ]
            ],
          ),
        ),
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 24, bottom: 12),
            child: Column(
              children: comment.replies.map((r) => _buildReplyWidget(r)).toList(),
            ),
          )
      ],
    );
  }

  Widget _buildReplyWidget(CommentModel reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border(right: BorderSide(color: AppColors.goldLight.withValues(alpha: 0.5), width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(reply.userName, style: const TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              Text(_timeAgo(reply.createdAt), style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Text(reply.text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
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