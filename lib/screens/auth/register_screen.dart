import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/screens/auth/otp_verification_screen.dart';
import 'package:qatorah_app/screens/auth/provider_register_screen.dart';
import 'package:qatorah_app/screens/customer/customer_home.dart';
import 'package:qatorah_app/screens/customer/terms_screen.dart';
import 'package:qatorah_app/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
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

    setState(() => _isLoading = true);

    try {
      final rawPhone = _phoneCtrl.text.trim();
      final phone = rawPhone.startsWith('+')
          ? rawPhone
          : rawPhone.startsWith('0')
              ? '+962${rawPhone.substring(1)}'
              : '+962$rawPhone';

      await _authService.sendPhoneVerificationCode(
        phoneNumber: phone,
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phone: phone,
                name: _nameCtrl.text.trim(),
                role: UserRole.customer, // ✅ مُصلَح: Enum بدل String
                verificationId: verificationId,
              ),
            ),
          );
        },
        onAutoVerified: (credential) async {
          await _handleSuccess(credential, phone);
        },
        onFailure: (message) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تنبيه: $message'),
              backgroundColor: AppColors.plumberRed,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ غير متوقع: $e'),
          backgroundColor: AppColors.plumberRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSuccess(dynamic credential, String phone) async {
    await _authService.signInWithPhoneCredential(
      credential: credential,
      profile: {
        'firstName': _nameCtrl.text.trim(),
        'role':
            'customer', // ✅ داخل Map: يبقى String (لأنه يُرسل إلى Firestore)
      },
    );
    if (!mounted) return;
    final user = _authService.currentUser;
    await AuthManager.login(
      firstName: _nameCtrl.text.trim(),
      phone: phone,
      role: UserRole.customer, // ✅ مُصلَح: Enum بدل String
      firebaseUid: user?.uid,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'سجل معنا',
          style: TextStyle(
              color: AppColors.goldLight, fontWeight: FontWeight.bold),
        ),
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
                  const SizedBox(height: 20),
                  const Icon(Icons.person_add,
                      size: 70, color: AppColors.goldLight),
                  const SizedBox(height: 10),
                  const Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  _buildField(
                    _nameCtrl,
                    'الاسم الكامل',
                    Icons.person,
                    validator: (v) => v!.isEmpty ? 'أدخل الاسم' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    _phoneCtrl,
                    'رقم الهاتف',
                    Icons.phone,
                    keyboard: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'أدخل رقم الهاتف' : null,
                  ),
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
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _agreedToTerms = !_agreedToTerms),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'أوافق على الاتفاقية وشروط الاستخدام',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      height: 1.5),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const TermsScreen()),
                                  ),
                                  child: const Text(
                                    '← اقرأ الاتفاقية',
                                    style: TextStyle(
                                      color: AppColors.goldLight,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GoldButton(
                    text: _isLoading ? 'جاري المعالجة...' : 'إتمام التسجيل',
                    icon: Icons.send,
                    onPressed:
                        (_isLoading || !_agreedToTerms) ? () {} : _register,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.goldLight.withValues(alpha: 0.2),
                          AppColors.goldLight.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.goldLight.withValues(alpha: 0.5),
                          width: 2),
                    ),
                    child: TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProviderRegisterScreen()),
                      ),
                      icon: const Icon(Icons.business_center,
                          color: AppColors.goldLight, size: 24),
                      label: const Text(
                        'سجل كمزود خدمة (يتطلب وثائق)',
                        style: TextStyle(
                            color: AppColors.goldLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'لديك حساب بالفعل؟ سجل دخول',
                      style: TextStyle(color: AppColors.crystalBlue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    bool obscure = false,
    bool canToggle = false,
    bool isObscured = false,
    VoidCallback? onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboard,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: AppColors.goldLight),
        suffixIcon: canToggle
            ? IconButton(
                icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.goldLight),
                onPressed: onToggle,
              )
            : null,
        filled: true,
        fillColor: AppColors.navyDark.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.goldDark.withValues(alpha: 0.5)),
        ),
      ),
      validator: validator,
    );
  }
}
