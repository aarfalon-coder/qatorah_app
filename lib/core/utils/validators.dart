class Validators {
  // ═══ التحقق من الاسم ═══
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الاسم';
    }
    if (value.trim().length < 2) {
      return 'الاسم قصير جداً';
    }
    if (value.trim().length > 50) {
      return 'الاسم طويل جداً';
    }
    return null;
  }

  // ═══ التحقق من رقم الهاتف الأردني ═══
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    final phone = value.trim().replaceAll(' ', '').replaceAll('-', '');
    
    // أرقام أردنية: 07XXXXXXXX (10 أرقام)
    if (!RegExp(r'^07[0-9]{8}$').hasMatch(phone)) {
      return 'رقم هاتف غير صالح (مثال: 0791234567)';
    }
    return null;
  }

  // ═══ التحقق من البريد الإلكتروني ═══
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // اختياري
    }
    final email = value.trim();
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'بريد إلكتروني غير صالح';
    }
    return null;
  }

  // ═══ التحقق من كلمة المرور ═══
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  // ═══ التحقق من تأكيد كلمة المرور ═══
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'الرجاء تأكيد كلمة المرور';
    }
    if (value != password) {
      return 'كلمتا المرور غير متطابقتين';
    }
    return null;
  }

  // ═══ التحقق من رمز OTP ═══
  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال رمز التحقق';
    }
    if (value.trim().length != 4 && value.trim().length != 6) {
      return 'رمز التحقق يجب أن يكون 4 أو 6 أرقام';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'رمز التحقق يجب أن يكون أرقاماً فقط';
    }
    return null;
  }

  // ═══ التحقق من رقم اللوحة ═══
  static String? validatePlateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال رقم اللوحة';
    }
    if (value.trim().length < 3) {
      return 'رقم اللوحة قصير جداً';
    }
    return null;
  }

  // ═══ التحقق من رقم الرخصة ═══
  static String? validateLicenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال رقم الرخصة';
    }
    if (value.trim().length < 5) {
      return 'رقم الرخصة قصير جداً';
    }
    return null;
  }

  // ═══ التحقق من كود الإحالة ═══
  static String? validateReferralCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // اختياري
    }
    if (value.trim().length < 4) {
      return 'كود الإحالة قصير جداً';
    }
    return null;
  }

  // ═══ التحقق من كود الكوبون ═══
  static String? validateCouponCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال كود الكوبون';
    }
    if (value.trim().length < 3) {
      return 'كود الكوبون قصير جداً';
    }
    return null;
  }

  // ═══ التحقق من كود QR ═══
  static String? validateQrCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال كود QR';
    }
    if (value.trim().length < 5) {
      return 'كود QR قصير جداً';
    }
    return null;
  }

  // ═══ التحقق من السعر ═══
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال السعر';
    }
    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'السعر يجب أن يكون رقماً';
    }
    if (price <= 0) {
      return 'السعر يجب أن يكون أكبر من صفر';
    }
    if (price > 10000) {
      return 'السعر مرتفع جداً';
    }
    return null;
  }

  // ═══ التحقق من الكمية ═══
  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الكمية';
    }
    final quantity = int.tryParse(value.trim());
    if (quantity == null) {
      return 'الكمية يجب أن تكون رقماً صحيحاً';
    }
    if (quantity <= 0) {
      return 'الكمية يجب أن تكون أكبر من صفر';
    }
    if (quantity > 1000) {
      return 'الكمية مرتفعة جداً';
    }
    return null;
  }

  // ═══ التحقق من الملاحظات ═══
  static String? validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // اختياري
    }
    if (value.trim().length > 500) {
      return 'الملاحظات طويلة جداً (الحد الأقصى 500 حرف)';
    }
    return null;
  }

  // ═══ التحقق من العنوان ═══
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال العنوان';
    }
    if (value.trim().length < 5) {
      return 'العنوان قصير جداً';
    }
    return null;
  }

  // ═══ التحقق من رابط الصورة ═══
  static String? validateImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // اختياري
    }
    if (!value.startsWith('http')) {
      return 'رابط الصورة غير صالح';
    }
    return null;
  }
}