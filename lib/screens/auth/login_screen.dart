import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/core/widgets/dashboard_selector.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/screens/auth/register_screen.dart';
import 'package:qatorah_app/screens/auth/otp_verification_screen.dart';
import 'package:qatorah_app/screens/auth/provider_pending_screen.dart';
import 'package:qatorah_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
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

    final email = _phoneCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;

    if (!email.contains('@')) {
      _showErrorMessage('تسجيل الدخول برقم الهاتف يتم عبر رمز التحقق فقط.');
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    if (password.isEmpty) {
      _showErrorMessage('أدخل كلمة المرور.');
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      await _handleAdminLoginByEmail(email, password);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAdminLoginByEmail(String email, String password) async {
    var firebaseSignedIn = false;
    var sessionEstablished = false;
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      firebaseSignedIn = true;
      final user = credential.user;
      if (user == null) {
        throw StateError('Firebase Auth returned no user after sign-in.');
      }

      final adminProfile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final profile = adminProfile.data();
      if (!adminProfile.exists || profile?['role'] != 'admin') {
        await FirebaseAuth.instance.signOut();
        firebaseSignedIn = false;
        _showErrorMessage('هذا الحساب غير مخوّل بالدخول إلى لوحة الإدارة.');
        return;
      }
      final status = profile?['status']?.toString();
      if (status == 'suspended' ||
          status == 'rejected' ||
          status == 'disabled') {
        await FirebaseAuth.instance.signOut();
        firebaseSignedIn = false;
        _showErrorMessage('هذا الحساب الإداري موقوف.');
        return;
      }

      final storedLevel = profile?['adminLevel'];
      final adminLevel = storedLevel is num
          ? storedLevel
              .toInt()
              .clamp(AuthManager.levelNone, AuthManager.levelSuperAdmin)
              .toInt()
          : AuthManager.levelViewer;
      await AuthManager.loginAsSuperAdmin(level: adminLevel);
      AuthManager.firstName =
          (profile?['name'] ?? profile?['firstName'] ?? 'المدير العام')
              .toString();
      AuthManager.firebaseUid = user.uid;
      await AuthManager.saveSession();
      sessionEstablished = true;

      if (mounted) {
        _showSuccessMessage('مرحباً بك');
        _navigateToHome();
      }
    } on FirebaseAuthException catch (error) {
      _showErrorMessage(_getAuthError(error));
    } catch (error) {
      debugPrint('Admin sign-in failed: $error');
      _showErrorMessage('تعذّر إكمال تسجيل الدخول. حاول مرة أخرى.');
    } finally {
      if (firebaseSignedIn && !sessionEstablished) {
        try {
          await FirebaseAuth.instance.signOut();
        } on FirebaseAuthException catch (error) {
          debugPrint('Failed to clear incomplete admin session: ${error.code}');
        }
      }
    }
  }

  String _getAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'البريد غير مسجل في Firebase Auth';
        case 'wrong-password':
          return 'كلمة المرور غير صحيحة';
        case 'invalid-email':
          return 'البريد غير صالح';
        default:
          return e.message ?? 'خطأ غير معروف';
      }
    }
    return e.toString();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final expectedProvider = _isProviderLogin;

    try {
      final rawPhone = _phoneCtrl.text.trim();
      if (rawPhone.contains('@')) {
        _showErrorMessage('أدخل رقم الهاتف لإرسال رمز التحقق.');
        if (mounted) setState(() => _isLoading = false);
        return;
      }
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
                name: expectedProvider ? 'مزود خدمة' : 'مستخدم',
                role: expectedProvider
                    ? UserRole.stationOwner
                    : UserRole.customer,
                verificationId: verificationId,
                isLogin: true,
                isProviderLogin: expectedProvider,
              ),
            ),
          );
        },
        onAutoVerified: (credential) async {
          await _completePhoneLogin(
            credential: credential,
            phone: formattedPhone,
            expectedProvider: expectedProvider,
          );
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

  Future<void> _completePhoneLogin({
    required PhoneAuthCredential credential,
    required String phone,
    required bool expectedProvider,
  }) async {
    var firebaseSignedIn = false;
    var sessionEstablished = false;
    try {
      final result = await _authService.signInWithPhoneCredential(
        credential: credential,
      );
      firebaseSignedIn = true;
      final user = result.user;
      if (user == null) {
        throw const AuthServiceException('تعذّر تحديد الحساب بعد التحقق.');
      }

      final userData = await _authService.getUserData(user.uid);
      if (userData == null) {
        throw const AuthServiceException(
          'لا يوجد حساب مسجل بهذا الرقم. أنشئ حساباً أولاً.',
        );
      }

      final roleString = userData['role']?.toString() ?? '';
      final role = AuthManager.tryParseRole(roleString);
      if (role == null) {
        throw const AuthServiceException(
            'نوع الحساب غير معروف. تواصل مع الدعم.');
      }
      if ((role != UserRole.customer) != expectedProvider) {
        throw const AuthServiceException(
          'نوع الحساب لا يطابق خيار الدخول المحدد.',
        );
      }

      final status = userData['status']?.toString();
      if (status == 'suspended' ||
          status == 'rejected' ||
          status == 'disabled') {
        throw const AuthServiceException('هذا الحساب موقوف أو مرفوض.');
      }

      final firstName =
          (userData['name'] ?? userData['firstName'] ?? 'مستخدم').toString();
      if (role == UserRole.customer) {
        await AuthManager.login(
          firstName: firstName,
          phone: user.phoneNumber ?? phone,
          role: role,
          firebaseUid: user.uid,
          governorateCode: userData['governorate']?.toString(),
        );
      } else {
        await AuthManager.loginAsProvider(
          firstName: firstName,
          phone: user.phoneNumber ?? phone,
          serviceType: roleString,
          role: role,
          firebaseUid: user.uid,
        );
      }
      sessionEstablished = true;

      if (role != UserRole.customer && status == 'pending') {
        if (!mounted) return;
        _showSuccessMessage('حسابك قيد المراجعة.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => ProviderPendingScreen(
              providerName: firstName,
              providerRole: roleString,
            ),
          ),
          (route) => false,
        );
        return;
      }

      if (role != UserRole.customer) {
        final expiryData = userData['subscriptionExpiryDate'];
        DateTime? subscriptionExpiry;
        if (expiryData is Timestamp) {
          subscriptionExpiry = expiryData.toDate();
        } else if (expiryData is String) {
          subscriptionExpiry = DateTime.tryParse(expiryData);
        }
        final balanceData = userData['walletBalance'];
        final walletBalance = balanceData is num ? balanceData.toDouble() : 0.0;
        AuthManager.updateSubscriptionStatus(subscriptionExpiry, walletBalance);
      }

      if (!mounted) return;
      _showSuccessMessage('تم تسجيل الدخول بنجاح.');
      _navigateToHome();
    } catch (error) {
      if (firebaseSignedIn && !sessionEstablished) {
        try {
          await _authService.signOut();
        } on Exception catch (signOutError) {
          debugPrint(
              'Failed to clear incomplete Firebase session: $signOutError');
        }
      }
      if (mounted) {
        _showErrorMessage(
          error is AuthServiceException
              ? error.message
              : 'تعذّر إكمال تسجيل الدخول. تحقق من اتصالك وحاول مجدداً.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DashboardSelector()),
      (route) => false,
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: AppColors.refillGreen,
          behavior: SnackBarBehavior.floating),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: AppColors.plumberRed,
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول',
            style: TextStyle(
                color: AppColors.goldLight, fontWeight: FontWeight.bold)),
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
                  const Icon(Icons.lock_outline,
                      size: 80, color: AppColors.goldLight),
                  const SizedBox(height: 20),
                  const Text('مرحباً بعودتك',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  const Text('نوع الدخول:',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('عميل',
                              style: TextStyle(color: Colors.white)),
                          selected: !_isProviderLogin,
                          selectedColor: AppColors.crystalBlue,
                          backgroundColor:
                              AppColors.navyDark.withValues(alpha: 0.5),
                          onSelected: (selected) =>
                              setState(() => _isProviderLogin = false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('مزود خدمة',
                              style: TextStyle(color: Colors.white)),
                          selected: _isProviderLogin,
                          selectedColor: AppColors.goldLight,
                          backgroundColor:
                              AppColors.navyDark.withValues(alpha: 0.5),
                          onSelected: (selected) =>
                              setState(() => _isProviderLogin = true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _phoneCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف / البريد الإلكتروني',
                      hintText: '0791234567 أو admin@example.com',
                      hintStyle:
                          TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon:
                          const Icon(Icons.person, color: AppColors.goldLight),
                      filled: true,
                      fillColor: AppColors.navyDark.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.goldDark.withValues(alpha: 0.5)),
                      ),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'أدخل رقم الهاتف أو البريد' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    style: const TextStyle(color: Colors.white),
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور (للمسؤولين)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon:
                          const Icon(Icons.lock, color: AppColors.goldLight),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.goldLight),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: AppColors.navyDark.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.goldDark.withValues(alpha: 0.5)),
                      ),
                    ),
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
                    label: const Text('دخول بكود تحقق (OTP)',
                        style: TextStyle(
                            color: AppColors.crystalBlue,
                            fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.crystalBlue),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ليس لديك حساب؟',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 14)),
                      TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen())),
                        child: const Text('سجل معنا',
                            style: TextStyle(
                                color: AppColors.goldLight,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
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
