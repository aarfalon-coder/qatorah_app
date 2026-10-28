import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/auth_manager.dart';

class AdDetailsScreen extends StatefulWidget {
  final String adId;
  final Map<String, dynamic> initialData;

  const AdDetailsScreen({
    super.key,
    required this.adId,
    required this.initialData,
  });

  @override
  State<AdDetailsScreen> createState() => _AdDetailsScreenState();
}

class _AdDetailsScreenState extends State<AdDetailsScreen> {
  final _commentCtrl = TextEditingController();
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _incrementViews();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _incrementViews() async {
    await FirebaseFirestore.instance
        .collection('marketplace_ads')
        .doc(widget.adId)
        .update({'views': FieldValue.increment(1)});
  }

  Future<void> _checkIfLiked() async {
    final userId = AuthManager.firebaseUid;
    if (userId == null) return;
    
    final doc = await FirebaseFirestore.instance
        .collection('marketplace_likes')
        .doc(widget.adId)
        .collection('user_likes')
        .doc(userId)
        .get();
        
    setState(() {
      _isLiked = doc.exists;
    });
  }

  Future<void> _toggleLike() async {
    final userId = AuthManager.firebaseUid;
    if (userId == null) return;

    final likeRef = FirebaseFirestore.instance
        .collection('marketplace_likes')
        .doc(widget.adId)
        .collection('user_likes')
        .doc(userId);

    if (_isLiked) {
      await likeRef.delete();
      await FirebaseFirestore.instance
          .collection('marketplace_ads')
          .doc(widget.adId)
          .update({'likes': FieldValue.increment(-1)});
    } else {
      await likeRef.set({'userId': userId, 'createdAt': FieldValue.serverTimestamp()});
      await FirebaseFirestore.instance
          .collection('marketplace_ads')
          .doc(widget.adId)
          .update({'likes': FieldValue.increment(1)});
    }
    setState(() => _isLiked = !_isLiked);
  }

  Future<void> _addComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    final userId = AuthManager.firebaseUid;

    await FirebaseFirestore.instance
        .collection('marketplace_ads')
        .doc(widget.adId)
        .collection('comments')
        .add({
      'user_id': userId,
      'user_name': AuthManager.firstName,
      'text': _commentCtrl.text.trim(),
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _commentCtrl.clear();
  }

  Future<void> _callSeller(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _deleteAd() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text('حذف الإعلان', style: TextStyle(color: Colors.white)),
        content: const Text('هل أنت متأكد من حذف هذا الإعلان نهائياً؟', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.plumberRed),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('marketplace_ads').doc(widget.adId).delete();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الإعلان بنجاح'), backgroundColor: AppColors.refillGreen),
        );
      }
    }
  }

  // ✅ الدالة الجديدة لتكبير الصورة
  void _showZoomedImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero, // لجعل النافذة تملأ الشاشة
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const CircularProgressIndicator(color: AppColors.goldLight),
                  errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.white54, size: 50),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = AuthManager.firebaseUid == widget.initialData['seller_id'];
    final isAdmin = AuthManager.adminLevel >= 4;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('marketplace_ads').doc(widget.adId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.goldLight));
          
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final currentImages = List<String>.from(data['images'] ?? []);
          final likes = data['likes'] ?? 0;
          final views = data['views'] ?? 0;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFF1A1F2E),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  if (isOwner || isAdmin)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.plumberRed),
                      onPressed: _deleteAd,
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      currentImages.isNotEmpty
                          ? PageView.builder(
                              controller: _pageController,
                              itemCount: currentImages.length,
                              onPageChanged: (index) => setState(() => _currentPage = index),
                              itemBuilder: (context, index) {
                                // ✅ تم إضافة GestureDetector هنا لتفعيل التكبير عند الضغط
                                return GestureDetector(
                                  onTap: () => _showZoomedImage(currentImages[index]),
                                  child: CachedNetworkImage(
                                    imageUrl: currentImages[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.goldLight)),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.broken_image, size: 60, color: Colors.white24),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(color: Colors.grey[800], child: const Icon(Icons.image, size: 60, color: Colors.white24)),
                      
                      if (currentImages.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(currentImages.length, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 12 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index ? AppColors.goldLight : Colors.white54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),
                      
                      if (data['isGuaranteed'] == true)
                        Positioned(
                          top: 60,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.refillGreen,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified_user, color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text('كفالة قطوره', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              data['title'] ?? 'بدون عنوان',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            data['price'] != null && data['price'] > 0 ? '${data['price']} د.أ' : 'قابل للتفاوض',
                            style: const TextStyle(color: AppColors.goldLight, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1F2E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.goldLight,
                              child: Icon(Icons.store, color: Color(0xFF0A0E1A)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['seller_name'] ?? 'بائع',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['governorate'] ?? 'الأردن',
                                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.phone, color: AppColors.refillGreen),
                                  onPressed: () => _callSeller(data['seller_phone']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.message, color: AppColors.crystalBlue),
                                  onPressed: () async {
                                    final uri = Uri.parse("https://wa.me/${data['seller_phone'].replaceAll(RegExp(r'\D'), '')}");
                                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text('التفاصيل', style: TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(
                        data['description'] ?? 'لا يوجد وصف',
                        style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleLike,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: _isLiked ? AppColors.plumberRed.withValues(alpha: 0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.plumberRed.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: AppColors.plumberRed, size: 20),
                                  const SizedBox(width: 8),
                                  Text('$likes', style: const TextStyle(color: AppColors.plumberRed, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              const Icon(Icons.visibility, color: Colors.white54, size: 20),
                              const SizedBox(width: 6),
                              Text('$views', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      const Text('التعليقات', style: TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
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
                            onTap: _addComment,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(color: AppColors.goldLight, shape: BoxShape.circle),
                              child: const Icon(Icons.send, color: Color(0xFF0A0E1A)),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('marketplace_ads')
                            .doc(widget.adId)
                            .collection('comments')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox.shrink();
                          final comments = snapshot.data!.docs;
                          
                          if (comments.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              alignment: Alignment.center,
                              child: const Text('لا توجد تعليقات بعد. كن أول من يعلّق!', style: TextStyle(color: Colors.white38, fontSize: 13)),
                            );
                          }

                          return Column(
                            children: comments.map((doc) {
                              final c = doc.data() as Map<String, dynamic>;
                              return _buildCommentItem(c);
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> c) {
    return Container(
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
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.crystalBlue.withValues(alpha: 0.2),
                child: const Icon(Icons.person, size: 16, color: AppColors.crystalBlue),
              ),
              const SizedBox(width: 8),
              Text(c['user_name'] ?? 'مستخدم', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              if (c['createdAt'] != null)
                Text(_timeAgo((c['createdAt'] as Timestamp).toDate()), style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Text(c['text'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
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