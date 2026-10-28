import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/core/widgets/dashboard_selector.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/screens/auth/provider_pending_screen.dart';
import 'package:qatorah_app/screens/customer/customer_home.dart';
import 'package:qatorah_app/services/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String name;
  final dynamic role;
  final String verificationId;
  final bool isLogin;
  final bool isProviderLogin;
  final Map<String, String>? documentUrls;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.name,
    required this.role,
    required this.verificationId,
    this.isLogin = false,
    this.isProviderLogin = false,
    this.documentUrls,
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

  // ✅ دالة النسخ من الحافظة - محسنة
  Future<void> _pasteCode() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final pastedText = clipboardData?.text?.trim() ?? '';

      // استخراج الأرقام فقط من النص
      final digits = pastedText.replaceAll(RegExp(r'\D'), '');

      if (digits.length >= 6) {
        final code = digits.substring(0, 6);
        for (int i = 0; i < 6; i++) {
          _otpControllers[i].text = code[i];
        }
        _focusNodes[5].requestFocus();

        // التحقق التلقائي بعد اللصق
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _verifyOtp();
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم لصق الكود بنجاح'),
            backgroundColor: AppColors.refillGreen,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الكود الملتصق غير صالح (يجب أن يحتوي على 6 أرقام)'),
            backgroundColor: AppColors.plumberRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل اللصق: $e'),
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

    if (widget.verificationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ في جلسة التحقق، يرجى طلب كود جديد'),
          backgroundColor: AppColors.plumberRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    var signedIn = false;
    var sessionEstablished = false;
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otpCode,
      );

      if (widget.isLogin) {
        final result = await _authService.signInWithPhoneCredential(
          credential: credential,
        );
        signedIn = true;
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
        final userRole = AuthManager.tryParseRole(roleString);
        if (userRole == null) {
          throw const AuthServiceException(
            'نوع الحساب غير معروف. تواصل مع الدعم.',
          );
        }
        if ((userRole != UserRole.customer) != widget.isProviderLogin) {
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
            (userData['name'] ?? userData['firstName'] ?? widget.name)
                .toString();
        if (userRole == UserRole.customer) {
          await AuthManager.login(
            firstName: firstName,
            phone: user.phoneNumber ?? widget.phone,
            role: userRole,
            firebaseUid: user.uid,
            governorateCode: userData['governorate']?.toString(),
          );
        } else {
          await AuthManager.loginAsProvider(
            firstName: firstName,
            phone: user.phoneNumber ?? widget.phone,
            serviceType: roleString,
            role: userRole,
            firebaseUid: user.uid,
          );
        }
        sessionEstablished = true;

        if (userRole != UserRole.customer && status != 'pending') {
          final expiryData = userData['subscriptionExpiryDate'];
          DateTime? subscriptionExpiry;
          if (expiryData is Timestamp) {
            subscriptionExpiry = expiryData.toDate();
          } else if (expiryData is String) {
            subscriptionExpiry = DateTime.tryParse(expiryData);
          }
          final balanceData = userData['walletBalance'];
          final walletBalance =
              balanceData is num ? balanceData.toDouble() : 0.0;
          AuthManager.updateSubscriptionStatus(
              subscriptionExpiry, walletBalance);
        }

        if (!mounted) return;
        Widget nextScreen = status == 'pending' && userRole != UserRole.customer
            ? ProviderPendingScreen(
                providerName: firstName,
                providerRole: roleString,
              )
            : const DashboardSelector();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => nextScreen),
          (route) => false,
        );
        return;
      }

      final roleString = widget.role is String
          ? widget.role
          : widget.role.toString().split('.').last;

      final profileData = <String, dynamic>{
        'name': widget.name,
        'phone': widget.phone,
        'role': roleString,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (roleString != 'customer' &&
          widget.documentUrls != null &&
          widget.documentUrls!.isNotEmpty) {
        profileData['status'] = 'pending';
        profileData['approvedByAdmin'] = false;
        profileData['subscriptionPaid'] = false;
        profileData['documents'] = widget.documentUrls;
        profileData['documentsStatus'] = {
          for (var key in widget.documentUrls!.keys) key: 'pending',
        };
        profileData['createdAt'] = FieldValue.serverTimestamp();
      } else {
        profileData['status'] = 'active';
        profileData['walletBalance'] = 0.0;
        profileData['createdAt'] = FieldValue.serverTimestamp();
      }

      final result = await _authService.signInWithPhoneCredential(
        credential: credential,
        profile: profileData,
      );
      signedIn = true;

      final userRoleEnum = AuthManager.tryParseRole(roleString);
      if (userRoleEnum == null) {
        throw const AuthServiceException('نوع الحساب غير معروف.');
      }

      if (userRoleEnum == UserRole.customer) {
        await AuthManager.login(
          firstName: widget.name,
          phone: widget.phone,
          role: userRoleEnum,
          firebaseUid: result.user?.uid,
        );
      } else {
        await AuthManager.loginAsProvider(
          firstName: widget.name,
          phone: widget.phone,
          serviceType: roleString,
          role: userRoleEnum,
          firebaseUid: result.user?.uid,
        );
      }
      sessionEstablished = true;

      if (!mounted) return;

      Widget nextScreen;
      if (userRoleEnum == UserRole.customer) {
        nextScreen = const CustomerHomeScreen();
      } else {
        nextScreen = ProviderPendingScreen(
            providerName: widget.name, providerRole: roleString);
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
        (route) => false,
      );
    } catch (e) {
      debugPrint('❌ خطأ في التحقق: $e');
      if (signedIn && !sessionEstablished) {
        try {
          await _authService.signOut();
        } on Exception catch (signOutError) {
          debugPrint(
              'Failed to clear incomplete Firebase session: $signOutError');
        }
      }
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
        textInputAction:
            index == 5 ? TextInputAction.done : TextInputAction.next,
        showCursor: true,
        autofillHints: index == 0 ? [AutofillHints.oneTimeCode] : null,
        enableInteractiveSelection: true,
        smartDashesType: SmartDashesType.disabled,
        smartQuotesType: SmartQuotesType.disabled,
        enableSuggestions: false,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        buildCounter: (
          BuildContext context, {
          int? currentLength,
          bool? isFocused,
          int? maxLength,
        }) {
          return const SizedBox.shrink();
        },
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
            } else {
              FocusScope.of(context).unfocus();
            }
          } else {
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }

          if (_getOtpCode().length == 6) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted && _getOtpCode().length == 6) {
                _verifyOtp();
              }
            });
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
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
                const SizedBox(height: 40),

                // ✅ حقول OTP - بدون Directionality لتجنب overflow
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: _buildOtpField(index),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 30),

                // ✅ زر لصق الكود - مفعل 100%
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pasteCode,
                  icon: const Icon(Icons.paste,
                      color: AppColors.crystalBlue, size: 20),
                  label: const Text(
                    'لصق الكود من الرسائل',
                    style: TextStyle(
                        color: AppColors.crystalBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.crystalBlue, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
