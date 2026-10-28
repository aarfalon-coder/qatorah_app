import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/models/region_model.dart';

class AddMachineListing extends StatefulWidget {
  const AddMachineListing({super.key});

  @override
  State<AddMachineListing> createState() => _AddMachineListingState();
}

class _AddMachineListingState extends State<AddMachineListing> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  
  String _selectedType = 'for_sale'; // 'for_sale' or 'wanted'
  Governorate? _selectedGov;
  bool _isGuaranteed = false;
  bool _isUploading = false;

  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // تعبئة رقم الهاتف تلقائياً من بيانات المستخدم
    _phoneCtrl.text = AuthManager.phone;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
        // حد أقصى 10 صور
        if (_images.length > 10) {
          _images.removeRange(10, _images.length);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إضافة صورة واحدة على الأقل للإعلان'), backgroundColor: AppColors.plumberRed),
      );
      return;
    }
    if (_selectedGov == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار المحافظة'), backgroundColor: AppColors.plumberRed),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final userId = AuthManager.firebaseUid;
      final adId = FirebaseFirestore.instance.collection('marketplace_ads').doc().id;
      final List<String> imageUrls = [];

      // 1. رفع الصور إلى Firebase Storage
      for (int i = 0; i < _images.length; i++) {
        final file = _images[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i${path.extension(file.path)}';
        final ref = FirebaseStorage.instance.ref().child('marketplace_ads/$userId/$adId/$fileName');
        
        final uploadTask = await ref.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // 2. حفظ بيانات الإعلان في Firestore
      await FirebaseFirestore.instance.collection('marketplace_ads').doc(adId).set({
        'adId': adId,
        'seller_id': userId,
        'seller_name': AuthManager.firstName,
        'seller_phone': _phoneCtrl.text.trim(),
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
        'type': _selectedType,
        'governorate': _selectedGov!.displayName,
        'images': imageUrls,
        'isGuaranteed': _isGuaranteed,
        'status': 'pending', // بانتظار موافقة الأدمن
        'views': 0,
        'likes': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم إرسال إعلانك بنجاح! سيتم مراجعته ونشره قريباً.'),
          backgroundColor: AppColors.refillGreen,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context); // العودة لشاشة السوق

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء رفع الإعلان: $e'), backgroundColor: AppColors.plumberRed),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        title: const Text('إضافة إعلان جديد', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // نوع الإعلان
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedType = 'for_sale'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedType == 'for_sale' ? AppColors.goldLight : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('معروض للبيع', textAlign: TextAlign.center, style: TextStyle(color: _selectedType == 'for_sale' ? const Color(0xFF0A0E1A) : Colors.white54, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedType = 'wanted'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedType == 'wanted' ? AppColors.goldLight : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('مطلوب للشراء', textAlign: TextAlign.center, style: TextStyle(color: _selectedType == 'wanted' ? const Color(0xFF0A0E1A) : Colors.white54, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // العنوان
                  TextFormField(
                    controller: _titleCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'عنوان الإعلان',
                      prefixIcon: Icon(Icons.title, color: AppColors.goldLight),
                      filled: true, fillColor: Color(0xFF1A1F2E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                    ),
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  // السعر
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'السعر المتوقع (د.أ) - اتركه فارغاً للتفاوض',
                      prefixIcon: Icon(Icons.attach_money, color: AppColors.goldLight),
                      filled: true, fillColor: Color(0xFF1A1F2E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // المحافظة
                  DropdownButtonFormField<Governorate>(
                    initialValue: _selectedGov,
                    dropdownColor: const Color(0xFF1A1F2E),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'المحافظة',
                      prefixIcon: Icon(Icons.location_on, color: AppColors.goldLight),
                      filled: true, fillColor: Color(0xFF1A1F2E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                    ),
                    items: Governorate.values.map((g) => DropdownMenuItem(value: g, child: Text(g.displayName))).toList(),
                    validator: (v) => v == null ? 'مطلوب' : null,
                    onChanged: (val) => setState(() => _selectedGov = val),
                  ),
                  const SizedBox(height: 16),

                  // الوصف
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'تفاصيل الإعلان (الحالة، السنة، العيوب، إلخ)',
                      prefixIcon: Icon(Icons.description, color: AppColors.goldLight),
                      filled: true, fillColor: Color(0xFF1A1F2E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                    ),
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  // رقم الهاتف
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف للتواصل',
                      prefixIcon: Icon(Icons.phone, color: AppColors.goldLight),
                      filled: true, fillColor: Color(0xFF1A1F2E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                    ),
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 24),

                  // خيار كفالة قطوره
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _isGuaranteed ? AppColors.refillGreen.withValues(alpha: 0.1) : const Color(0xFF1A1F2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _isGuaranteed ? AppColors.refillGreen : Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(_isGuaranteed ? Icons.verified_user : Icons.shield_outlined, color: _isGuaranteed ? AppColors.refillGreen : Colors.white54, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('تفعيل كفالة قطوره', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(
                                _isGuaranteed ? 'سيقوم مهندسونا بفحص السلعة وضمان حقك' : 'خدمة اختيارية للفحص والضمان',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isGuaranteed,
                          onChanged: (val) => setState(() => _isGuaranteed = val),
                          activeThumbColor: AppColors.refillGreen,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // رفع الصور
                  const Text('صور الإعلان (حد أقصى 10)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3), style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: AppColors.goldLight, size: 32),
                          SizedBox(height: 8),
                          Text('اضغط لإضافة صور من المعرض', style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    ),
                  ),
                  if (_images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(image: FileImage(_images[index]), fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: AppColors.plumberRed, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // زر الإرسال
                  _isUploading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.goldLight))
                      : GoldButton(
                          text: 'نشر الإعلان',
                          icon: Icons.send,
                          onPressed: _submitAd,
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}