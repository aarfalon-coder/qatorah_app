import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/screens/auth/register_screen.dart';
import 'package:qatorah_app/screens/auth/otp_verification_screen.dart';
import 'package:qatorah_app/screens/customer/customer_home.dart';
import 'package:qatorah_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController(); // ✅ فارغ تماماً بدون رقم افتراضي
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isProviderLogin = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginWithPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final rawPhone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    
    // توحيد تنسيق رقم الهاتف
    final formattedPhone = rawPhone.startsWith('+') 
        ? rawPhone 
        : (rawPhone.startsWith('0') ? '+962${rawPhone.substring(1)}' : '+962$rawPhone');

    debugPrint('🔍 محاولة تسجيل دخول: $formattedPhone');

    try {
      // البحث عن المستخدم في Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .limit(1)
          .get();

      debugPrint('📊 عدد النتائج: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        _showErrorMessage('رقم الهاتف غير مسجل في النظام');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final userData = snapshot.docs.first.data();
      final uid = userData['uid'];
      final role = userData['role'];
      final status = userData['status'];
      final storedPassword = userData['password'] ?? '';

      debugPrint(' الدور: $role | الحالة: $status');

      // ✅ التحقق من كلمة المرور لجميع الأدوار
      if (storedPassword != password) {
        _showErrorMessage('كلمة المرور غير صحيحة');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // ✅ دخول الأدمن
      if (role == 'admin') {
        if (status != 'approved') {
          _showErrorMessage('حساب الأدمن غير مفعل');
          if (mounted) setState(() => _isLoading = false);
          return;
        }
        await AuthManager.loginAsSuperAdmin();
        if (mounted) {
          _showSuccessMessage('👑 مرحباً سوبر أدمن');
          _navigateToHome();
        }
        return;
      }

      // ✅ دخول مزود الخدمة
      if (_isProviderLogin) {
        if (role != 'provider') {
          _showErrorMessage('هذا الحساب ليس حساب مزود خدمة');
          if (mounted) setState(() => _isLoading = false);
          return;
        }
        if (status == 'pending') {
          _showErrorMessage('⏳ حسابك لا يزال قيد المراجعة');
          if (mounted) setState(() => _isLoading = false);
          return;
        }
        if (status == 'rejected') {
          _showErrorMessage('❌ تم رفض طلبك');
          if (mounted) setState(() => _isLoading = false);
          return;
        }

        await AuthManager.loginAsProvider(
          firstName: userData['name'] ?? 'مزود خدمة',
          phone: formattedPhone,
          serviceType: userData['serviceType'] ?? 'غير محدد',
          firebaseUid: uid,
        );
        if (mounted) {
          _showSuccessMessage('🏢 مرحباً بك');
          _navigateToHome();
        }
        return;
      }

      // ✅ دخول العميل
      if (role == 'customer') {
        await AuthManager.login(
          firstName: userData['firstName'] ?? userData['name'] ?? 'عميل',
          phone: formattedPhone,
          role: UserRole.customer,
          firebaseUid: uid,
        );
        if (mounted) {
          _showSuccessMessage('👤 مرحباً بك');
          _navigateToHome();
        }
        return;
      }

      _showErrorMessage('نوع الحساب غير معروف: $role');
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الدخول: $e');
      _showErrorMessage('حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final rawPhone = _phoneCtrl.text.trim();
      final formattedPhone = rawPhone.startsWith('+')
          ? rawPhone
          : rawPhone.startsWith('0')
              ? '+962${rawPhone.substring(1)}'
              : '+962$rawPhone';

      await _authService.sendPhoneVerificationCode(
        phoneNumber: formattedPhone,
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phone: formattedPhone,
                name: _isProviderLogin ? 'مزود خدمة' : 'مستخدم',
                role: _isProviderLogin ? UserRole.stationOwner : UserRole.customer,
                verificationId: verificationId,
                isProviderLogin: _isProviderLogin,
              ),
            ),
          );
        },
        onAutoVerified: (credential) async {
          await _authService.signInWithPhoneCredential(
            credential: credential,
            profile: {
              'firstName': _isProviderLogin ? 'مزود خدمة' : 'مستخدم',
              'role': _isProviderLogin ? 'provider' : 'customer',
            },
          );
          if (!mounted) return;
          final user = _authService.currentUser;
          await AuthManager.login(
            firstName: _isProviderLogin ? 'مزود خدمة' : 'مستخدم',
            phone: formattedPhone,
            role: _isProviderLogin ? UserRole.stationOwner : UserRole.customer,
            firebaseUid: user?.uid,
          );
          if (mounted) {
            setState(() => _isLoading = false);
            _navigateToHome();
          }
        },
        onFailure: (message) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showErrorMessage(message);
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorMessage('خطأ: $e');
    }
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
      (route) => false,
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.refillGreen,
        behavior: SnackBarBehavior.floating,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تسجيل الدخول',
          style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 40),
                  const Icon(Icons.lock_outline, size: 80, color: AppColors.goldLight),
                  const SizedBox(height: 20),
                  const Text(
                    'مرحباً بعودتك',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'نوع الدخول:',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('عميل', style: TextStyle(color: Colors.white)),
                          selected: !_isProviderLogin,
                          selectedColor: AppColors.crystalBlue,
                          backgroundColor: AppColors.navyDark.withValues(alpha: 0.5),
                          onSelected: (selected) => setState(() => _isProviderLogin = false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('مزود خدمة', style: TextStyle(color: Colors.white)),
                          selected: _isProviderLogin,
                          selectedColor: AppColors.goldLight,
                          backgroundColor: AppColors.navyDark.withValues(alpha: 0.5),
                          onSelected: (selected) => setState(() => _isProviderLogin = true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // ✅ حقل رقم الهاتف - فارغ تماماً بدون رقم افتراضي
                  TextFormField(
                    controller: _phoneCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      hintText: '0791234567', // ✅ نص تلميحي فقط (يختفي عند الكتابة)
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.phone, color: AppColors.goldLight),
                      filled: true,
                      fillColor: AppColors.navyDark.withValues(alpha: 0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.goldDark.withValues(alpha: 0.5)),
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? 'أدخل رقم الهاتف' : null,
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
                    validator: (v) => v!.isEmpty ? 'أدخل كلمة المرور' : null,
                  ),
                  const SizedBox(height: 24),
                  GoldButton(
                    text: _isLoading ? 'جاري الدخول...' : 'تسجيل الدخول',
                    icon: Icons.login,
                    onPressed: _isLoading ? () {} : _loginWithPassword,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _sendOtp,
                    icon: const Icon(Icons.sms, color: AppColors.crystalBlue),
                    label: const Text(
                      'دخول بكود تحقق (OTP)',
                      style: TextStyle(color: AppColors.crystalBlue, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.crystalBlue),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ليس لديك حساب؟', style: TextStyle(color: Colors.white54, fontSize: 14)),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        ),
                        child: const Text(
                          'سجل معنا',
                          style: TextStyle(color: AppColors.goldLight, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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