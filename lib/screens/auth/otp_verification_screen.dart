import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/screens/customer/customer_home.dart';
import 'package:qatorah_app/services/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String name;
  final dynamic role;
  final String verificationId;
  final bool isProviderLogin;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.name,
    required this.role,
    required this.verificationId,
    this.isProviderLogin = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());

  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _getOtpCode() =>
      _otpControllers.map((controller) => controller.text).join();

  void _fillOtp(String code) {
    final digits = code.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 6 ? digits.substring(0, 6) : digits;

    for (int i = 0; i < 6; i++) {
      _otpControllers[i].text = i < limited.length ? limited[i] : '';
    }

    if (limited.isNotEmpty) {
      final nextFocus = limited.length >= 6 ? 5 : limited.length;
      _focusNodes[nextFocus].requestFocus();
    }

    if (limited.length == 6) {
      _verifyOtp();
    }
  }

  Future<void> _pasteCode() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final pastedText = clipboardData?.text?.trim() ?? '';

    final digits = pastedText.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 6) {
      _fillOtp(digits);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الكود الملتصق غير صالح (يجب أن يكون 6 أرقام)'),
          backgroundColor: AppColors.plumberRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final otpCode = _getOtpCode();

    if (otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل الكود كاملاً (6 أرقام)'),
          backgroundColor: AppColors.plumberRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otpCode,
      );

      final result = await _authService.signInWithPhoneCredential(
        credential: credential,
        profile: {
          'firstName': widget.name,
          'role': widget.role.toString().split('.').last,
          'phoneNumber': widget.phone,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      await AuthManager.login(
        firstName: widget.name,
        phone: widget.phone,
        role: widget.role,
        firebaseUid: result.user?.uid,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      String errorMsg = 'حدث خطأ في التحقق';
      if (e.toString().contains('invalid-verification-code')) {
        errorMsg = 'كود التحقق غير صحيح';
      } else if (e.toString().contains('session-expired')) {
        errorMsg = 'انتهت صلاحية الكود، اطلب كوداً جديداً';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.plumberRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        showCursor: true,
        // ✅ إضافة AutofillHints لاقتراح الكود تلقائياً
        autofillHints: index == 0 ? [AutofillHints.oneTimeCode] : null,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.navyDark.withValues(alpha: 0.6),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.goldDark.withValues(alpha: 0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.goldDark.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.goldLight, width: 2.5),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            }
            if (_getOtpCode().length == 6) {
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted && _getOtpCode().length == 6) {
                  _verifyOtp();
                }
              });
            }
          }
        },
        onTap: () {
          _otpControllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _otpControllers[index].text.length,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تأكيد الكود',
          style:
              TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.goldLight.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.sms,
                    size: 60,
                    color: AppColors.goldLight,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'أدخل كود التأكيد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'تم إرسال كود من 6 أرقام إلى\n${widget.phone}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),

                // ✅ AutofillGroup لاقتراح الكود تلقائياً
                AutofillGroup(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildOtpField(index),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                OutlinedButton.icon(
                  onPressed: _pasteCode,
                  icon: const Icon(Icons.paste, color: AppColors.crystalBlue),
                  label: const Text(
                    'لصق الكود من الرسائل',
                    style: TextStyle(
                        color: AppColors.crystalBlue,
                        fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.crystalBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 30),
                GoldButton(
                  text: _isLoading ? 'جاري التحقق...' : 'تأكيد',
                  icon: Icons.check_circle,
                  onPressed: _isLoading ? () {} : _verifyOtp,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم طلب كود جديد'),
                              backgroundColor: AppColors.refillGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                  child: const Text(
                    'إعادة إرسال الكود',
                    style: TextStyle(
                      color: AppColors.crystalBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}