import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qatorah_app/core/theme/app_colors.dart';
import 'package:qatorah_app/managers/theme_manager.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/models/technician_model.dart';
import 'package:qatorah_app/screens/technician/technician_dashboard_screen.dart'; // ✅ تمت إضافة الاستيراد

class TechnicianVerificationScreen extends StatefulWidget {
  const TechnicianVerificationScreen({super.key});

  @override
  State<TechnicianVerificationScreen> createState() => _TechnicianVerificationScreenState();
}

class _TechnicianVerificationScreenState extends State<TechnicianVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _picker = ImagePicker();

  File? _idImage;
  File? _certificateImage;
  File? _photoImage;
  TechnicianSpecialty _selectedSpecialty = TechnicianSpecialty.plumber;
  bool _isSubmitting = false;
  String? _verificationStatus; // pending, verified, rejected, suspended

  @override
  void initState() {
    super.initState();
    _nameController.text = AuthManager.firstName;
    _phoneController.text = AuthManager.phone;
    _checkExistingProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ✅ التحقق من وجود ملف فني سابق
  Future<void> _checkExistingProfile() async {
    final uid = AuthManager.firebaseUid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('technicians').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _verificationStatus = data['verification_status'] ?? 'pending';
          if (data['specialty'] != null) {
            _selectedSpecialty = TechnicianSpecialty.values.firstWhere(
              (e) => e.name == data['specialty'],
              orElse: () => TechnicianSpecialty.plumber,
            );
          }
        });
      }
    } catch (e) {
      // تجاهل الخطأ في البداية
    }
  }

  Future<void> _pickImage(String type) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (type == 'id') _idImage = File(pickedFile.path);
        if (type == 'certificate') _certificateImage = File(pickedFile.path);
        if (type == 'photo') _photoImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idImage == null || _certificateImage == null || _photoImage == null) {
      _showSnackBar('يرجى رفع جميع الصور المطلوبة', Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uid = AuthManager.firebaseUid;
      if (uid == null) throw Exception('المستخدم غير مسجل دخول');

      // رفع الصور
      final idUrl = await _uploadImage(_idImage!, 'id_$uid');
      final certUrl = await _uploadImage(_certificateImage!, 'cert_$uid');
      final photoUrl = await _uploadImage(_photoImage!, 'photo_$uid');

      // حفظ البيانات في Firestore
      await FirebaseFirestore.instance.collection('technicians').doc(uid).set({
        'user_id': uid,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'specialty': _selectedSpecialty.name,
        'verification_status': 'pending',
        'is_available': true,
        'is_suspended': false,
        'rating': 0.0,
        'review_count': 0,
        'active_requests_count': 0,
        'next_available_time': 'متاح الآن',
        'documents': {
          'id_card': idUrl,
          'certificate': certUrl,
          'photo': photoUrl,
        },
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() => _verificationStatus = 'pending');
      _showSnackBar('تم إرسال الطلب للمراجعة', AppColors.goldLight);
    } catch (e) {
      _showSnackBar('فشل الإرسال: $e', Colors.red);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<String> _uploadImage(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child('technicians/$path.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;

    // ✅ إذا كان الحساب موقوفًا
    if (_verificationStatus == 'suspended') {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF5F7FA),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, size: 80, color: AppColors.plumberRed),
                const SizedBox(height: 24),
                Text('حساب الفني موقوف', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('يرجى التواصل مع الدعم الفني لمعرفة السبب.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ إذا كان معتمدًا، نحوله للوحة التحكم (تم إزالة const من هنا لتجنب الخطأ)
    if (_verificationStatus == 'verified') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TechnicianDashboardScreen()));
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('توثيق حساب الفني', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // حالة الطلب
            if (_verificationStatus == 'pending')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange)),
                child: Row(children: [
                  const Icon(Icons.pending_actions, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(child: Text('طلبك قيد المراجعة من الإدارة. يرجى الانتظار...', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                ]),
              ),
            if (_verificationStatus == 'pending') const SizedBox(height: 24),

            // البيانات الأساسية
            Text('البيانات الشخصية', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('الاسم الكامل', Icons.person, isDark),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: _inputDecoration('رقم الهاتف', Icons.phone, isDark),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 24),

            // التخصص
            Text('التخصص', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<TechnicianSpecialty>(
              initialValue: _selectedSpecialty,
              decoration: _inputDecoration('اختر التخصص', Icons.engineering, isDark),
              items: TechnicianSpecialty.values.map((e) => DropdownMenuItem(value: e, child: Text(e.arabicName))).toList(),
              onChanged: (v) => setState(() => _selectedSpecialty = v!),
            ),
            const SizedBox(height: 24),

            // رفع الملفات
            Text('الأوراق الثبوتية', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildUploadButton('صورة الهوية الشخصية', _idImage, () => _pickImage('id'), isDark),
            const SizedBox(height: 12),
            _buildUploadButton('شهادة الخبرة / المهنة', _certificateImage, () => _pickImage('certificate'), isDark),
            const SizedBox(height: 12),
            _buildUploadButton('صورة شخصية', _photoImage, () => _pickImage('photo'), isDark),
            const SizedBox(height: 32),

            // زر الإرسال
            if (_verificationStatus != 'pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitVerification,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.black) : const Text('إرسال للتوثيق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(String label, File? file, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: file == null ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF1A1F2E) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3))),
        child: Row(children: [
          Icon(file != null ? Icons.check_circle : Icons.upload_file, color: file != null ? AppColors.refillGreen : AppColors.goldLight),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black))),
          if (file != null) const Icon(Icons.image, color: Colors.grey),
        ]),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
      prefixIcon: Icon(icon, color: AppColors.goldLight),
      filled: true,
      fillColor: isDark ? const Color(0xFF1A1F2E) : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.goldLight.withValues(alpha: 0.3))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.goldLight.withValues(alpha: 0.3))),
    );
  }
}