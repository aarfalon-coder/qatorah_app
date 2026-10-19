import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/screens/customer/customer_home.dart';
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
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();
  
  String _selectedServiceType = 'صاحب محطة';
  bool _isLoading = false;
  bool _obscurePassword = true; // ✅ متغير لإظهار/إخفاء كلمة المرور

  XFile? _idImage;
  XFile? _licenseImage;
  XFile? _extraImage;
  XFile? _profileImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String _getExtraDocLabel() {
    switch (_selectedServiceType) {
      case 'صاحب محطة': return 'آخر شهادة صحية للمحطة';
      case 'صاحب مصنع مياه': return 'رخصة المصنع وشهادة جودة المياه';
      case 'مزود مواد خام لمصانع المياه': return 'شهادات جودة المواد وسجل تجاري';
      case 'فني محطات': return 'شهادات خبرة فنية أو دورات تدريبية';
      case 'كهربائي': return 'رخصة مزاولة مهنة كهرباء';
      case 'سباك': return 'رخصة مزاولة مهنة سباكة';
      case 'مبرمج + صيانة ماكنات': return 'شهادات برمجة أو صيانة معتمدة';
      case 'خدمات تنظيف الخزانات والآبار وتعقيم المحطات': return 'شهادات تعقيم وصور لمعدات العمل';
      default: return 'وثيقة إضافية تثبت المهنة';
    }
  }

  Future<void> _openCamera(Function(XFile?) onImagePicked) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        onImagePicked(pickedFile);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage('حدث خطأ أثناء فتح الكاميرا: $e');
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_idImage == null || _licenseImage == null || _extraImage == null || _profileImage == null) {
      _showErrorMessage('يرجى التقاط جميع الصور المطلوبة للمتابعة');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rawPhone = _phoneCtrl.text.trim();
      final formattedPhone = rawPhone.startsWith('+') 
          ? rawPhone 
          : (rawPhone.startsWith('0') ? '+962${rawPhone.substring(1)}' : '+962$rawPhone');
      
      final password = _passwordCtrl.text.trim();
      final name = _nameCtrl.text.trim();
      final serviceType = _selectedServiceType;

      final auth = FirebaseAuth.instance;
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: 'provider_${formattedPhone.replaceAll('+', '')}@qatorah.app',
        password: password,
      );

      final uid = userCredential.user!.uid;

      await _authService.registerProvider(
        uid: uid,
        name: name,
        phone: formattedPhone,
        serviceType: serviceType,
        password: password,
      );

      await AuthManager.loginAsProvider(
        firstName: name,
        phone: formattedPhone,
        serviceType: serviceType,
        firebaseUid: uid,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
      
      _showPendingApprovalDialog();

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String msg = 'فشل التسجيل';
      if (e.code == 'email-already-in-use') {
        msg = 'رقم الهاتف هذا مسجل مسبقاً. يرجى تسجيل الدخول.';
      } else if (e.code == 'weak-password') {
        msg = 'كلمة المرور ضعيفة جداً (يجب أن تكون 6 أحرف على الأقل).';
      } else if (e.code == 'invalid-email') {
        msg = 'تنسيق رقم الهاتف غير صحيح.';
      } else {
        msg = e.message ?? 'حدث خطأ غير متوقع';
      }
      _showErrorMessage(msg);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorMessage('حدث خطأ: $e');
    }
  }

  void _showPendingApprovalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.goldLight.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: const Icon(Icons.pending_actions, color: AppColors.goldLight, size: 48),
              ),
              const SizedBox(height: 20),
              const Text('تم استلام طلبك بنجاح!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                'بصفتك: $_selectedServiceType\nحسابك الآن "بانتظار موافقة الإدارة".\nيمكنك تصفح التطبيق كعميل ريثما يتم تفعيل حسابك.', 
                textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 24),
              GoldButton(
                text: 'حسناً، انتقل للتطبيق',
                icon: Icons.check,
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
                    (route) => false,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.plumberRed,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildImagePickerBox(String label, XFile? image, Function(XFile?) onImageSelected) {
    return GestureDetector(
      onTap: () => _openCamera(onImageSelected),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.navyDark.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: image != null ? AppColors.refillGreen : AppColors.goldDark.withValues(alpha: 0.5), 
            style: BorderStyle.solid,
            width: image != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: image != null ? AppColors.refillGreen.withValues(alpha: 0.2) : AppColors.goldLight.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                image != null ? Icons.check_circle : Icons.camera_alt, 
                color: image != null ? AppColors.refillGreen : AppColors.goldLight, 
                size: 28
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    image != null ? 'تم التقاط: ${image.name}' : 'اضغط هنا لفتح الكاميرا', 
                    style: TextStyle(
                      color: image != null ? AppColors.refillGreen : Colors.white54, 
                      fontSize: 12,
                      fontWeight: image != null ? FontWeight.bold : FontWeight.normal
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (image != null)
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.plumberRed, size: 20),
                onPressed: () => onImageSelected(null),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل مزود خدمة', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      extendBodyBehindAppBar: false,
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
                  const Text('البيانات الأساسية', style: TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('الاسم الكامل', Icons.person),
                    validator: (v) => v!.isEmpty ? 'الاسم مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('رقم الهاتف', Icons.phone),
                    validator: (v) => v!.isEmpty ? 'رقم الهاتف مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  // ✅ حقل كلمة المرور مع زر الإظهار/الإخفاء
                  TextFormField(
                    controller: _passwordCtrl,
                    style: const TextStyle(color: Colors.white),
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.lock, color: AppColors.goldLight),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.goldLight,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: AppColors.navyDark.withValues(alpha: 0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.goldDark.withValues(alpha: 0.5)),
                      ),
                    ),
                    validator: (v) => v!.length < 6 ? '6 أحرف على الأقل' : null,
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('تفاصيل الخدمة والوثائق', style: TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.navyDark.withValues(alpha: 0.5), 
                      borderRadius: BorderRadius.circular(12), 
                      border: Border.all(color: AppColors.goldDark.withValues(alpha: 0.5))
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedServiceType,
                      dropdownColor: AppColors.navyDark,
                      style: const TextStyle(color: Colors.white),
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none, 
                        prefixIcon: Icon(Icons.work, color: AppColors.goldLight)
                      ),
                      items: const [
                        DropdownMenuItem(value: 'صاحب محطة', child: Row(children: [Icon(Icons.store, color: AppColors.goldLight, size: 20), SizedBox(width: 10), Text('صاحب محطة')])),
                        DropdownMenuItem(value: 'صاحب مصنع مياه', child: Row(children: [Icon(Icons.factory, color: AppColors.goldLight, size: 20), SizedBox(width: 10), Text('صاحب مصنع مياه')])),
                        DropdownMenuItem(value: 'مزود مواد خام لمصانع المياه', child: Row(children: [Icon(Icons.inventory_2, color: AppColors.goldLight, size: 20), SizedBox(width: 10), Text('مزود مواد خام')])),
                        DropdownMenuItem(value: 'فني محطات', child: Row(children: [Icon(Icons.engineering, color: AppColors.goldLight, size: 20), SizedBox(width: 10), Text('فني محطات')])),
                        DropdownMenuItem(value: 'كهربائي', child: Row(children: [Icon(Icons.electrical_services, color: AppColors.goldLight, size: 20), SizedBox(width: 10), Text('كهربائي')])),
                        DropdownMenuItem(value: 'سباك', child: Row(children: [Icon(Icons.plumbing, color: AppColors.goldLight, size: 20), SizedBox(width: 10), Text('سباك')])),
                        DropdownMenuItem(value: 'مبرمج + صيانة ماكنات', child: Row(children: [Icon(Icons.memory, color: AppColors.goldLight, size: 20), SizedBox(width: 10), Text('مبرمج + صيانة ماكنات')])),
                        DropdownMenuItem(value: 'صاحب محطة متنقلة', child: Row(children: [Icon(Icons.local_shipping, color: AppColors.goldLight, size: 20), SizedBox(width: 10), Text('صاحب محطة متنقلة')])),
                        DropdownMenuItem(value: 'سيارة غاز', child: Row(children: [Icon(Icons.local_fire_department, color: AppColors.goldLight, size: 20), SizedBox(width: 10), Text('سيارة غاز')])),
                        DropdownMenuItem(value: 'تنك مياه', child: Row(children: [Icon(Icons.water_drop, color: AppColors.goldLight, size: 20), SizedBox(width: 10), Text('تنك مياه')])),
                        DropdownMenuItem(value: 'خدمات تنظيف الخزانات والآبار وتعقيم المحطات', child: Row(children: [Icon(Icons.cleaning_services, color: AppColors.goldLight, size: 20), SizedBox(width: 10), Text('خدمات تنظيف وتعقيم')])),
                      ],
                      onChanged: (v) => setState(() => _selectedServiceType = v!),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _buildImagePickerBox('1. صورة الهوية الشخصية', _idImage, (img) => setState(() => _idImage = img)),
                  const SizedBox(height: 12),
                  _buildImagePickerBox('2. رخصة مزاولة المهنة / المحطة', _licenseImage, (img) => setState(() => _licenseImage = img)),
                  const SizedBox(height: 12),
                  _buildImagePickerBox('3. ${_getExtraDocLabel()}', _extraImage, (img) => setState(() => _extraImage = img)),
                  const SizedBox(height: 12),
                  _buildImagePickerBox('4. صورة شخصية واضحة', _profileImage, (img) => setState(() => _profileImage = img)),

                  const SizedBox(height: 30),
                  GoldButton(
                    text: _isLoading ? 'جاري رفع البيانات...' : 'إرسال طلب الانضمام',
                    icon: Icons.send,
                    onPressed: _isLoading ? () {} : _submitRegistration,
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: AppColors.goldLight),
      filled: true,
      fillColor: AppColors.navyDark.withValues(alpha: 0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.goldDark.withValues(alpha: 0.5))),
    );
  }
}