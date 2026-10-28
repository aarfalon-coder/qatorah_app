import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class ProviderManagementTemplate extends StatefulWidget {
  final String role;
  final String title;
  final IconData icon;
  final Color color;

  const ProviderManagementTemplate({
    super.key,
    required this.role,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  State<ProviderManagementTemplate> createState() => _ProviderManagementTemplateState();
}

class _ProviderManagementTemplateState extends State<ProviderManagementTemplate> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleStatus(String userId, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'suspended' : 'active';
    await _db.collection('users').doc(userId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == 'active' ? '✅ تم التفعيل' : '🚫 تم الإيقاف'),
          backgroundColor: newStatus == 'active' ? AppColors.refillGreen : AppColors.plumberRed,
        ),
      );
    }
  }

  Future<void> _toggleAvailability(String userId, bool currentAvailability) async {
    await _db.collection('users').doc(userId).update({
      'isAvailable': !currentAvailability,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!currentAvailability ? '✅ تم السماح باستقبال الطلبات' : '⏸️ تم منع استقبال الطلبات (إجباري)'),
          backgroundColor: !currentAvailability ? AppColors.refillGreen : AppColors.maintenanceOrange,
        ),
      );
    }
  }

  void _editSubscription(String userId, Map<String, dynamic> data) {
    final sub = data['subscription'] as Map<String, dynamic>? ?? {};
    String subType = sub['type'] ?? 'free';
    TextEditingController amountCtrl = TextEditingController(text: sub['amount']?.toString() ?? '');
    TextEditingController percentageCtrl = TextEditingController(text: sub['percentage']?.toString() ?? '');
    DateTime expiryDate = sub['endDate'] is Timestamp ? (sub['endDate'] as Timestamp).toDate() : DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('إدارة اشتراك: ${data['name']}', style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: subType,
                  dropdownColor: const Color(0xFF1A1F2E),
                  decoration: const InputDecoration(labelText: 'نوع الاشتراك', labelStyle: TextStyle(color: Colors.white54)),
                  items: const [
                    DropdownMenuItem(value: 'free', child: Text('مجاني', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'monthly', child: Text('شهري ثابت', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'percentage', child: Text('نسبة من الطلب', style: TextStyle(color: Colors.white))),
                  ],
                  onChanged: (val) => setDialogState(() => subType = val!),
                ),
                if (subType == 'monthly')
                  SizedBox(
                    height: 12,
                    child: TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'المبلغ (د.أ)', labelStyle: TextStyle(color: Colors.white54)),
                    ),
                  ),
                if (subType == 'percentage')
                  SizedBox(
                    height: 12,
                    child: TextField(
                      controller: percentageCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'النسبة (%)', labelStyle: TextStyle(color: Colors.white54)),
                    ),
                  ),
                const SizedBox(height: 16),
                Text('ينتهي في: ${DateFormat('yyyy/MM/dd').format(expiryDate)}', style: const TextStyle(color: Colors.white70)),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(context: context, initialDate: expiryDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
                    if (picked != null) setDialogState(() => expiryDate = picked);
                  },
                  icon: const Icon(Icons.calendar_today, color: AppColors.goldLight),
                  label: const Text('تغيير التاريخ', style: TextStyle(color: AppColors.goldLight)),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _db.collection('users').doc(userId).update({
                  'subscription': {
                    'type': subType,
                    'amount': subType == 'monthly' ? (double.tryParse(amountCtrl.text) ?? 0.0) : 0.0,
                    'percentage': subType == 'percentage' ? (double.tryParse(percentageCtrl.text) ?? 0.0) : 0.0,
                    'endDate': Timestamp.fromDate(expiryDate),
                    'isActive': true,
                  },
                  'status': 'active',
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم حفظ الاشتراك'), backgroundColor: AppColors.refillGreen));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight, foregroundColor: Colors.black),
              child: const Text('حفظ'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0A0A),
        elevation: 0,
        title: Row(children: [
          Icon(widget.icon, color: widget.color),
          const SizedBox(width: 8),
          Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ]),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // ✅ 1. شريط البحث الجديد
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'بحث بالاسم أو رقم الهاتف...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: AppColors.goldLight),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1A1F2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ✅ 2. قائمة البيانات مع الفلترة
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('users').where('role', isEqualTo: widget.role).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.goldLight));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('لا يوجد ${widget.title} مسجلين', style: const TextStyle(color: Colors.white54)));
                }

                // ✅ 3. منطق الفلترة المحلية (سريع وآمن)
                final allDocs = snapshot.data!.docs;
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final phone = (data['phone'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) || phone.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(child: Text('لا توجد نتائج مطابقة لـ "$_searchQuery"', style: const TextStyle(color: Colors.white54)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, i) {
                    final doc = filteredDocs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'pending';
                    final isAvailable = data['isAvailable'] ?? true;
                    final sub = data['subscription'] as Map<String, dynamic>? ?? {};
                    final expiry = sub['endDate'] is Timestamp ? (sub['endDate'] as Timestamp).toDate() : null;
                    final isExpired = expiry != null && expiry.isBefore(DateTime.now());
                    final isSuspended = status == 'suspended';

                    String subText = sub['type'] == 'monthly' ? '${sub['amount']} د.أ/شهر' : (sub['type'] == 'percentage' ? '${sub['percentage']}%' : 'مجاني');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: (isSuspended || isExpired) ? AppColors.plumberRed.withValues(alpha: 0.4) : AppColors.refillGreen.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: (isSuspended || isExpired) ? AppColors.plumberRed.withValues(alpha: 0.2) : AppColors.refillGreen.withValues(alpha: 0.2),
                                child: Icon(isSuspended || isExpired ? Icons.block : Icons.check_circle, color: (isSuspended || isExpired) ? AppColors.plumberRed : AppColors.refillGreen),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['name'] ?? 'مزود بدون اسم', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text(data['phone'] ?? '', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(subText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  if (expiry != null) Text(isExpired ? 'منتهي' : 'ينتهي: ${DateFormat('MM/dd').format(expiry)}', style: TextStyle(color: isExpired ? AppColors.plumberRed : Colors.white54, fontSize: 10)),
                                ],
                              )
                            ],
                          ),
                          const Divider(color: Colors.white24, height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _editSubscription(doc.id, data),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('الاشتراك'),
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.goldLight, side: const BorderSide(color: AppColors.goldLight)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _toggleAvailability(doc.id, isAvailable),
                                  icon: Icon(isAvailable ? Icons.pause : Icons.play_arrow, size: 16),
                                  label: Text(isAvailable ? 'إيقاف' : 'تفعيل'),
                                  style: ElevatedButton.styleFrom(backgroundColor: isAvailable ? AppColors.maintenanceOrange : AppColors.refillGreen, foregroundColor: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _toggleStatus(doc.id, status),
                                  icon: Icon(isSuspended ? Icons.check_circle : Icons.block, size: 16),
                                  label: Text(isSuspended ? 'تفعيل' : 'حظر'),
                                  style: ElevatedButton.styleFrom(backgroundColor: isSuspended ? AppColors.refillGreen : AppColors.plumberRed, foregroundColor: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}