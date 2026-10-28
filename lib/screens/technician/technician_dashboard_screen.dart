import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qatorah_app/core/theme/app_colors.dart';
import 'package:qatorah_app/managers/theme_manager.dart';
import 'package:qatorah_app/managers/auth_manager.dart';

class TechnicianDashboardScreen extends StatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  State<TechnicianDashboardScreen> createState() => _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
  bool _isAvailable = true;
  int _activeCount = 0;
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTechnicianStats();
  }

  Future<void> _loadTechnicianStats() async {
    final uid = AuthManager.firebaseUid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('technicians').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _isAvailable = doc.data()?['is_available'] ?? true;
          _activeCount = doc.data()?['active_requests_count'] ?? 0;
          _rating = (doc.data()?['rating'] ?? 0.0).toDouble();
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  // ✅ دالة تبديل حالة التوفر (مصلحة وتعمل 100%)
  Future<void> _toggleAvailability(bool value) async {
    final uid = AuthManager.firebaseUid;
    if (uid == null) return;
    
    // تحديث فايربيس فوراً
    await FirebaseFirestore.instance.collection('technicians').doc(uid).update({
      'is_available': value,
      'next_available_time': value ? 'متاح الآن' : 'في راحة',
    });
    
    setState(() => _isAvailable = value);
    _showSnackBar(
      value ? 'أصبحت متاحاً للعمل الآن' : 'تم تغيير حالتك إلى: في راحة', 
      value ? AppColors.refillGreen : Colors.orange
    );
  }

  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('maintenance_requests').doc(requestId).update({'status': newStatus});
      
      // إذا اكتمل الطلب، نطلب التقييم
      if (newStatus == 'completed') {
        _showRatingDialog(requestId);
      }
      
      _showSnackBar('تم تحديث حالة الطلب بنجاح', AppColors.refillGreen);
    } catch (e) {
      _showSnackBar('فشل التحديث: $e', Colors.red);
    }
  }

  // ✅ نافذة التقييم بعد إكمال الطلب
  void _showRatingDialog(String requestId) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: ThemeManager.isDarkMode ? const Color(0xFF1A1F2E) : Colors.white,
          title: const Text('قيّم الفني', style: TextStyle(color: AppColors.goldLight)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('كم كانت جودة الخدمة؟', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(index < selectedRating ? Icons.star : Icons.star_border, color: AppColors.goldLight, size: 32),
                  onPressed: () => setDialogState(() => selectedRating = index + 1),
                )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'اكتب تعليقك (اختياري)',
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('لاحقاً', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _submitRating(requestId, selectedRating, commentController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight),
              child: const Text('إرسال', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRating(String requestId, int rating, String comment) async {
    try {
      final uid = AuthManager.firebaseUid;
      final techDoc = await FirebaseFirestore.instance.collection('maintenance_requests').doc(requestId).get();
      final technicianId = techDoc.data()?['technician_id'];
      
      if (technicianId != null) {
        // 1. حفظ التقييم في مجموعة منفصلة
        await FirebaseFirestore.instance.collection('technician_reviews').add({
          'technician_id': technicianId,
          'customer_id': uid,
          'request_id': requestId,
          'rating': rating,
          'comment': comment,
          'created_at': FieldValue.serverTimestamp(),
        });
        
        // 2. تحديث متوسط تقييم الفني
        final techRef = FirebaseFirestore.instance.collection('technicians').doc(technicianId);
        final techDocSnap = await techRef.get();
        final currentRating = techDocSnap.data()?['rating'] ?? 0.0;
        final currentCount = techDocSnap.data()?['review_count'] ?? 0;
        
        final newCount = currentCount + 1;
        final newRating = ((currentRating * currentCount) + rating) / newCount;
        
        await techRef.update({
          'rating': newRating,
          'review_count': newCount,
        });
        
        // 3. تحديث الطلب نفسه
        await FirebaseFirestore.instance.collection('maintenance_requests').doc(requestId).update({
          'review': {'rating': rating, 'comment': comment, 'reviewed_at': FieldValue.serverTimestamp()},
        });
        
        _showSnackBar('شكراً لتقييمك!', AppColors.refillGreen);
      }
    } catch (e) {
      _showSnackBar('فشل إرسال التقييم: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('لوحة تحكم الفني', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1️⃣ زر التبديل الرئيسي (متاح / راحة) - مصلوح 100%
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isAvailable ? AppColors.refillGreen.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _isAvailable ? AppColors.refillGreen : Colors.orange),
            ),
            child: Row(
              children: [
                Icon(_isAvailable ? Icons.check_circle : Icons.pause_circle, color: _isAvailable ? AppColors.refillGreen : Colors.orange, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isAvailable ? 'أنت متاح للعمل الآن' : 'أنت في راحة حالياً',
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _isAvailable ? 'سيتم توجيه طلبات الصيانة الجديدة إليك' : 'لن تصلك أي طلبات جديدة حتى تعود',
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isAvailable,
                  onChanged: _toggleAvailability,
                  activeThumbColor: AppColors.refillGreen,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2️⃣ الإحصائيات السريعة
          Row(
            children: [
              Expanded(child: _buildStatCard('الطلبات النشطة', '$_activeCount', Icons.list_alt, AppColors.crystalBlue, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('التقييم', '$_rating', Icons.star, AppColors.goldLight, isDark)),
            ],
          ),
          const SizedBox(height: 24),

          // 3️⃣ قائمة الطلبات الموجهة للفني
          Text('طلبات الصيانة الموكلة إليك', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('maintenance_requests')
                .where('technician_id', isEqualTo: AuthManager.firebaseUid)
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.goldLight));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 60, color: isDark ? Colors.white24 : Colors.black26),
                        const SizedBox(height: 12),
                        Text('لا توجد طلبات حالياً', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                      ],
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'pending';
                  final description = data['text_description'] ?? 'لا يوجد وصف';
                  final createdAt = (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
                  
                  Color statusColor = status == 'completed' ? AppColors.refillGreen : (status == 'in_progress' ? Colors.orange : AppColors.goldLight);
                  String statusText = status == 'completed' ? 'مكتمل' : (status == 'in_progress' ? 'جاري العمل' : 'جديد');
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1F2E) : Colors.white, 
                      borderRadius: BorderRadius.circular(12), 
                      border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3))
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.build, color: AppColors.goldLight, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('طلب #${doc.id.substring(0, 6)}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)), 
                              child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold))
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(description, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                        const SizedBox(height: 8),
                        Text('التاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(createdAt)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 16),
                        
                        // أزرار تغيير الحالة
                        if (status == 'assigned')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _updateRequestStatus(doc.id, 'in_progress'), 
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                              child: const Text('بدء العمل على الطلب', style: TextStyle(fontWeight: FontWeight.bold))
                            ),
                          )
                        else if (status == 'in_progress')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _updateRequestStatus(doc.id, 'completed'), 
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.refillGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                              child: const Text('إنهاء الطلب وتسليمه', style: TextStyle(fontWeight: FontWeight.bold))
                            ),
                          )
                        else if (status == 'completed')
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: AppColors.refillGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Text('✅ تم الانتهاء من هذا الطلب بنجاح', style: TextStyle(color: AppColors.refillGreen, fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: color.withValues(alpha: 0.3))
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}