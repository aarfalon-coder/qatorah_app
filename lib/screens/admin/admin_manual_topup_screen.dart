import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class AdminManualTopupScreen extends StatefulWidget {
  const AdminManualTopupScreen({super.key});

  @override
  State<AdminManualTopupScreen> createState() => _AdminManualTopupScreenState();
}

class _AdminManualTopupScreenState extends State<AdminManualTopupScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneOrIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _couponCodeController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool _isSearching = false;
  bool _isSaving = false;
  Map<String, dynamic>? _foundUser;

  Future<void> _searchUser() async {
    final query = _phoneOrIdController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _foundUser = null;
    });

    try {
      // البحث برقم الهاتف أولاً
      var snapshot = await _db.collection('users').where('phone', isEqualTo: query).limit(1).get();
      
      // إذا لم يوجد، نبحث بمعرف المستخدم (UID)
      if (snapshot.docs.isEmpty) {
        final doc = await _db.collection('users').doc(query).get();
        if (doc.exists) {
          final data = doc.data()!;
          data['id'] = doc.id;
          _foundUser = data;
        }
      } else {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        _foundUser = data;
      }

      setState(() => _isSearching = false);
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في البحث: $e'), backgroundColor: AppColors.plumberRed),
        );
      }
    }
  }

  Future<void> _processTopup() async {
    if (!_formKey.currentState!.validate() || _foundUser == null) return;

    setState(() => _isSaving = true);
    final userId = _foundUser!['id'];
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final reason = _reasonController.text.trim().isEmpty ? 'شحن يدوي من الأدمن' : _reasonController.text.trim();

    try {
      await _db.runTransaction((transaction) async {
        // 1. زيادة رصيد المستخدم
        final userRef = _db.collection('users').doc(userId);
        transaction.update(userRef, {
          'walletBalance': FieldValue.increment(amount),
        });

        // 2. تسجيل المعاملة في السجل
        transaction.set(_db.collection('transactions').doc(), {
          'userId': userId,
          'type': 'admin_topup',
          'amount': amount,
          'description': reason,
          'adminId': 'super_admin', // يمكن استبداله بمعرف الأدمن الحالي
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم إضافة الرصيد بنجاح!'), backgroundColor: AppColors.refillGreen),
        );
        // إعادة تعيين الحقول
        _amountController.clear();
        _reasonController.clear();
        _couponCodeController.clear();
        setState(() => _foundUser = null);
        _phoneOrIdController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في إضافة الرصيد: $e'), backgroundColor: AppColors.plumberRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شحن رصيد مستخدم يدوياً', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A0E1A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFF0A0E1A),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'أدخل رقم هاتف المستخدم أو المعرف (UID) للبحث عنه',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneOrIdController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف أو UID',
                        labelStyle: TextStyle(color: Colors.white54),
                        prefixIcon: Icon(Icons.search, color: AppColors.goldLight),
                        filled: true,
                        fillColor: Color(0xFF1A1F2E),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                      ),
                      validator: (value) => value!.isEmpty ? 'يرجى الإدخال' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSearching ? null : _searchUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.crystalBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSearching
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('بحث', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              if (_foundUser != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.refillGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.refillGreen.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.refillGreen, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            _foundUser!['name'] ?? 'مستخدم بدون اسم',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('رقم الهاتف: ${_foundUser!['phone'] ?? 'غير متوفر'}', style: const TextStyle(color: Colors.white70)),
                      Text('الرصيد الحالي: ${(_foundUser!['walletBalance'] ?? 0.0).toStringAsFixed(2)} د.أ', style: const TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                const Text('تفاصيل الشحن', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'المبلغ المراد إضافته (د.أ)',
                    labelStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.account_balance_wallet, color: AppColors.goldLight),
                    filled: true,
                    fillColor: Color(0xFF1A1F2E),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'يرجى إدخال المبلغ';
                    if (double.tryParse(value) == null || double.parse(value) <= 0) return 'مبلغ غير صالح';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _reasonController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'سبب الشحن (اختياري)',
                    hintText: 'مثال: تعويض عن خطأ، مكافأة ولاء...',
                    labelStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.note, color: AppColors.goldLight),
                    filled: true,
                    fillColor: Color(0xFF1A1F2E),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                  ),
                ),
                
                // ملاحظة: إضافة الكوبون تتطلب منطقاً مختلفاً قليلاً (إنشاء وثيقة في مجموعة coupons)، 
                // لذا ركزنا هنا على شحن الرصيد المباشر وهو الأكثر طلباً وأماناً.
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _processTopup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.refillGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('تأكيد إضافة الرصيد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else if (_phoneOrIdController.text.isNotEmpty && !_isSearching) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.plumberRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.plumberRed.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.plumberRed, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'لم يتم العثور على مستخدم بهذا الرقم أو المعرف. تأكد من صحة البيانات.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}