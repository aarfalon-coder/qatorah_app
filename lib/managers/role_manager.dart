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
        // ✅ الانتقال المباشر لصفحة إدخال الكود
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