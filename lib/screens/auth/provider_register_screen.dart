import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/screens/auth/otp_verification_screen.dart';
import 'package:qatorah_app/screens/auth/provider_pending_screen.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/models/region_model.dart';
import 'package:qatorah_app/services/auth_service.dart';

class ProviderRegisterScreen extends StatefulWidget {
  const ProviderRegisterScreen({super.key});

  @override
  State<ProviderRegisterScreen> createState() => _ProviderRegisterScreenState();
}

class _ProviderRegisterScreenState extends State<ProviderRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  String _selectedRole = 'station_owner';
  Governorate? _selectedGovernorate;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  final Map<String, String> _documentUrls = {};
  final Map<String, bool> _isUploading = {};

  final List<Map<String, String>> _roles = [
    {'value': 'station_owner', 'label': 'صاحب محطة تعبئة'},
    {'value': 'factory_owner', 'label': 'صاحب مصنع مياه'},
    {'value': 'tanker_driver', 'label': 'سائق تنك'},
    {'value': 'distribution_driver', 'label': 'سائق توصيل'},
    {'value': 'gas_supplier', 'label': 'مزود غاز'},
    {'value': 'plumber', 'label': 'سباك / صيانة'},
    {'value': 'electrician', 'label': 'فني كهرباء'},
    {'value': 'station_technician', 'label': 'فني محطات'},
    {'value': 'parts_provider', 'label': 'مزود قطع غيار'},
  ];

  final Map<String, List<Map<String, String>>> _roleDocuments = {
    'station_owner': [
      {'id': 'station_exterior', 'label': 'صورة المحطة من الخارج'},
      {'id': 'commercial_register', 'label': 'السجل التجاري'},
      {'id': 'health_certificate', 'label': 'الشهادة الصحية'},
      {'id': 'id_card', 'label': 'صورة الهوية الشخصية'},
    ],
    'factory_owner': [
      {'id': 'factory_license', 'label': 'رخصة المصنع'},
      {'id': 'commercial_register', 'label': 'السجل التجاري'},
      {'id': 'health_certificate', 'label': 'الشهادة الصحية'},
      {'id': 'id_card', 'label': 'صورة الهوية الشخصية'},
    ],
    'tanker_driver': [
      {'id': 'tanker_license', 'label': 'رخصة التنك'},
      {'id': 'tanker_photo', 'label': 'صورة التنك'},
      {'id': 'id_card', 'label': 'صورة الهوية الشخصية'},
    ],
    'distribution_driver': [
      {'id': 'car_photo', 'label': 'صورة السيارة'},
      {'id': 'driving_license', 'label': 'رخصة القيادة'},
      {'id': 'id_card', 'label': 'صورة الهوية الشخصية'},
      {'id': 'personal_photo', 'label': 'صورة شخصية'},
    ],
    'gas_supplier': [
      {'id': 'gas_license', 'label': 'رخصة الغاز'},
      {'id': 'warehouse_photo', 'label': 'صورة المستودع'},
      {'id': 'id_card', 'label': 'صورة الهوية الشخصية'},
      {'id': 'safety_certificate', 'label': 'شهادة السلامة'},
    ],
    'plumber': [
      {'id': 'profession_certificate', 'label': 'شهادة المهنة'},
      {'id': 'id_card', 'label': 'صورة الهوية الشخصية'},
      {'id': 'personal_photo', 'label': 'صورة شخصية'},
      {'id': 'practice_license', 'label': 'رخصة المزاولة'},
    ],
    'electrician': [
      {'id': 'profession_certificate', 'label': 'شهادة المهنة'},
      {'id': 'id_card', 'label': 'صورة الهوية الشخصية'},
      {'id': 'personal_photo', 'label': 'صورة شخصية'},
      {'id': 'practice_license', 'label': 'رخصة المزاولة'},
    ],
    'station_technician': [
      {'id': 'profession_certificate', 'label': 'شهادة المهنة'},
      {'id': 'id_card', 'label': 'صورة الهوية الشخصية'},
      {'id': 'personal_photo', 'label': 'صورة شخصية'},
      {'id': 'practice_license', 'label': 'رخصة المزاولة'},
    ],
    'parts_provider': [
      {'id': 'commercial_register', 'label': 'السجل التجاري'},
      {'id': 'store_photo', 'label': 'صورة المحل'},
      {'id': 'id_card', 'label': 'صورة الهوية الشخصية'},
    ],
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadDocument(String docId, String docLabel) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploading[docId] = true);

    try {
      final cleanPhone = _phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
      final ref = FirebaseStorage.instance
          .ref()
          .child('providers_pending/${cleanPhone}_$docId.jpg');
      final uploadTask = await ref.putFile(File(image.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      setState(() {
        _documentUrls[docId] = downloadUrl;
        _isUploading[docId] = false;
      });
    } catch (e) {
      setState(() => _isUploading[docId] = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('فشل رفع الصورة: $e'),
              backgroundColor: AppColors.plumberRed),
        );
      }
    }
  }

  Future<void> _registerProvider() async {
    if (!_formKey.currentState!.validate() || !_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول والموافقة على الشروط'),
          backgroundColor: AppColors.plumberRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedGovernorate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار المحافظة'),
          backgroundColor: AppColors.plumberRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final requiredDocs = _roleDocuments[_selectedRole] ?? [];
    for (var doc in requiredDocs) {
      if (_documentUrls[doc['id']] == null ||
          _documentUrls[doc['id']]!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('يرجى رفع جميع الوثائق المطلوبة: ${doc['label']}'),
            backgroundColor: AppColors.plumberRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final rawPhone = _phoneCtrl.text.trim();
      final phone = rawPhone.startsWith('+')
          ? rawPhone
          : rawPhone.startsWith('0')
              ? '+962${rawPhone.substring(1)}'
              : '+962$rawPhone';

      debugPrint('📲 جاري إرسال OTP للرقم: $phone');

      await _authService.sendPhoneVerificationCode(
        phoneNumber: phone,
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() => _isLoading = false);

          debugPrint('✅ تم إرسال OTP، الانتقال لشاشة التحقق');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phone: phone,
                name: _nameCtrl.text.trim(),
                role: _selectedRole,
                verificationId: verificationId,
                documentUrls: _documentUrls,
              ),
            ),
          );
        },
        onAutoVerified: (credential) async {
          debugPrint('🔄 تم التحقق التلقائي');
          await _saveProviderData(credential);
        },
        onFailure: (message) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل إرسال OTP: $message'),
              backgroundColor: AppColors.plumberRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: $e'),
          backgroundColor: AppColors.plumberRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveProviderData(dynamic credential) async {
    try {
      final rawPhone = _phoneCtrl.text.trim();
      final phone = rawPhone.startsWith('+')
          ? rawPhone
          : (rawPhone.startsWith('0')
              ? '+962${rawPhone.substring(1)}'
              : '+962$rawPhone');
      final requiredDocs = _roleDocuments[_selectedRole] ?? [];

      final result = await _authService.signInWithPhoneCredential(
        credential: credential,
        profile: {
          'name': _nameCtrl.text.trim(),
          'phone': phone,
          'governorate': _selectedGovernorate!.displayName,
          'area': _selectedGovernorate!.displayName,
          'role': _selectedRole,
          'status': 'pending',
          'approvedByAdmin': false,
          'subscriptionPaid': false,
          'documents': _documentUrls,
          'documentsStatus': {
            for (var doc in requiredDocs) doc['id']!: 'pending',
          },
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      final uid = result.user?.uid;
      debugPrint('✅ تم تسجيل مزود الخدمة بنجاح، UID: $uid');

      if (!mounted) return;

      // ✅ الحل الجذري والمضمون: مطابقة يدوية آمنة 100% تمنع الانهيار نهائياً
      UserRole userRoleEnum = UserRole.customer;
      switch (_selectedRole) {
        case 'station_owner':
          userRoleEnum = UserRole.stationOwner;
          break;
        case 'factory_owner':
          userRoleEnum = UserRole.factoryOwner;
          break;
        case 'tanker_driver':
          userRoleEnum = UserRole.tankerDriver;
          break;
        case 'distribution_driver':
          userRoleEnum = UserRole.distributionDriver;
          break;
        case 'gas_supplier':
          userRoleEnum = UserRole.gasSupplier;
          break;
        case 'plumber':
          userRoleEnum = UserRole.plumber;
          break;
        case 'electrician':
          userRoleEnum = UserRole.electrician;
          break;
        case 'station_technician':
          userRoleEnum = UserRole.stationTechnician;
          break;
        case 'parts_provider':
          userRoleEnum = UserRole.partsProvider;
          break;
        default:
          userRoleEnum = UserRole.customer;
          break;
      }

      await AuthManager.loginAsProvider(
        firstName: _nameCtrl.text.trim(),
        phone: phone,
        serviceType: _selectedRole,
        role: userRoleEnum,
        firebaseUid: uid,
      );
      AuthManager.setGuestMode(false);
      await AuthManager.saveSession();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('✅ تم إرسال طلبك بنجاح! سيتم مراجعة وثائقك وتفعيل حسابك.'),
          backgroundColor: AppColors.refillGreen,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => ProviderPendingScreen(
            providerName: _nameCtrl.text.trim(),
            providerRole: _selectedRole,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('❌ خطأ في حفظ بيانات مزود الخدمة: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الحفظ: $e'),
          backgroundColor: AppColors.plumberRed,
        ),
      );
    }
  }

  Widget _buildDocumentCard(String docId, String label) {
    final isUploaded = _documentUrls[docId] != null;
    final isUploading = _isUploading[docId] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded
              ? AppColors.refillGreen
              : AppColors.goldLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUploaded
                  ? AppColors.refillGreen.withValues(alpha: 0.2)
                  : AppColors.goldLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUploaded ? Icons.check_circle : Icons.upload_file,
              color: isUploaded ? AppColors.refillGreen : AppColors.goldLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  isUploaded ? 'تم الرفع بنجاح ✅' : 'اضغط لرفع الصورة',
                  style: TextStyle(
                    color: isUploaded ? AppColors.refillGreen : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isUploading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.goldLight),
            )
          else
            IconButton(
              icon: Icon(isUploaded ? Icons.edit : Icons.add_a_photo,
                  color: AppColors.goldLight),
              onPressed: () => _pickAndUploadDocument(docId, label),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requiredDocs = _roleDocuments[_selectedRole] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'سجل معنا شريك نجاح',
          style: TextStyle(
              color: AppColors.goldLight, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.business_center,
                      size: 70, color: AppColors.goldLight),
                  const SizedBox(height: 10),
                  const Text(
                    'سجل معنا شريك نجاح',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'سيتم مراجعة طلبك ووثائقك وتفعيل حسابك من قبل الإدارة',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل / اسم المنشأة',
                      prefixIcon:
                          Icon(Icons.person, color: AppColors.goldLight),
                      filled: true,
                      fillColor: Color(0xFF1A1F2E),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none),
                    ),
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone, color: AppColors.goldLight),
                      filled: true,
                      fillColor: Color(0xFF1A1F2E),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none),
                    ),
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Governorate>(
                    initialValue: _selectedGovernorate,
                    dropdownColor: const Color(0xFF1A1F2E),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'محافظة مكان العمل',
                      prefixIcon:
                          Icon(Icons.location_on, color: AppColors.goldLight),
                      filled: true,
                      fillColor: Color(0xFF1A1F2E),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none),
                    ),
                    items: Governorate.values.map((g) {
                      return DropdownMenuItem(
                        value: g,
                        child: Text(g.displayName),
                      );
                    }).toList(),
                    validator: (v) => v == null ? 'يرجى اختيار المحافظة' : null,
                    onChanged: (val) =>
                        setState(() => _selectedGovernorate = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    dropdownColor: const Color(0xFF1A1F2E),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'نوع الخدمة / المهنة',
                      prefixIcon:
                          Icon(Icons.category, color: AppColors.goldLight),
                      filled: true,
                      fillColor: Color(0xFF1A1F2E),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none),
                    ),
                    items: _roles.map((role) {
                      return DropdownMenuItem(
                        value: role['value'],
                        child: Text(role['label']!),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedRole = val!),
                  ),
                  const SizedBox(height: 16),
                  if (requiredDocs.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'الوثائق المطلوبة للتسجيل',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...requiredDocs.map(
                        (doc) => _buildDocumentCard(doc['id']!, doc['label']!)),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.navyDark.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _agreedToTerms
                            ? AppColors.refillGreen.withValues(alpha: 0.6)
                            : AppColors.goldDark.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _agreedToTerms,
                            onChanged: (v) =>
                                setState(() => _agreedToTerms = v ?? false),
                            activeColor: AppColors.refillGreen,
                            checkColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'أوافق على اتفاقية مزودي الخدمة وشروط العمل وأن جميع الوثائق المرفقة صحيحة',
                            style: TextStyle(
                                color: Colors.white, fontSize: 13, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GoldButton(
                    text:
                        _isLoading ? 'جاري المعالجة...' : 'إرسال طلب الانضمام',
                    icon: Icons.send,
                    onPressed: _isLoading ? () {} : _registerProvider,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('العودة للتسجيل كعميل',
                        style: TextStyle(color: AppColors.crystalBlue)),
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
