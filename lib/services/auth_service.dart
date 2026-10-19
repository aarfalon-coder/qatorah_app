import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firebase_service.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth,
        _firestore = firestore;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _database => _firestore ?? FirebaseFirestore.instance;

  // 🆕 المستخدم الحالي
  User? get currentUser => _firebaseAuth.currentUser;

  // 🆕 هل المستخدم مسجل؟
  bool get isSignedIn => currentUser != null;

  // ═══════════════════════════════════════════
  // 1. إرسال رمز التحقق (OTP)
  // ═══════════════════════════════════════════
  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    required void Function(String message) onFailure,
    int? forceResendingToken,
  }) async {
    _requireFirebase();
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: forceResendingToken,
        verificationCompleted: onAutoVerified,
        verificationFailed: (error) => onFailure(_authErrorMessage(error)),
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_authErrorMessage(error));
    }
  }

  // ═══════════════════════════════════════════
  // 2. تسجيل الدخول باستخدام الرمز
  // ═══════════════════════════════════════════
  Future<UserCredential> signInWithPhoneCredential({
    required PhoneAuthCredential credential,
    Map<String, Object?>? profile,
  }) async {
    _requireFirebase();
    try {
      final result = await _firebaseAuth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) {
        throw const AuthServiceException('تعذّر إكمال تسجيل الدخول. حاول مرة أخرى.');
      }
      if (profile != null) {
        await saveUserProfile(user, profile);
      }
      return result;
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_authErrorMessage(error));
    }
  }

  // ═══════════════════════════════════════════
  // 3. حفظ أو تحديث بيانات المستخدم (عام)
  // ═══════════════════════════════════════════
  Future<void> saveUserProfile(User user, Map<String, Object?> profile) async {
    _requireFirebase();
    try {
      final userRef = _database.collection('users').doc(user.uid);
      final doc = await userRef.get();

      if (!doc.exists) {
        // مستخدم جديد: نضيف تاريخ الإنشاء
        await userRef.set({
          ...profile,
          'phoneNumber': user.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ تم إنشاء حساب مستخدم جديد في Firestore');
      } else {
        // مستخدم موجود: نحدث البيانات فقط
        await userRef.set({
          ...profile,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('✅ تم تحديث بيانات المستخدم في Firestore');
      }
    } on FirebaseException catch (error) {
      throw AuthServiceException(
        'تم توثيق رقم الهاتف، لكن تعذّر حفظ بيانات الحساب (${error.code}).',
      );
    }
  }

  // ═══════════════════════════════════════════
  // 4. 🆕 تسجيل مزود خدمة جديد (مخصص)
  // ═══════════════════════════════════════════
  Future<void> registerProvider({
    required String uid,
    required String name,
    required String phone,
    required String serviceType,
    required String password, // ⚠️ ملاحظة: في الإنتاج يفضل استخدام Hash
  }) async {
    _requireFirebase();
    try {
      await _database.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'phoneNumber': phone,
        'serviceType': serviceType,
        'role': 'provider',
        'status': 'pending', // ⭐ مهم جداً: بانتظار موافقة الأدمن
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ تم تسجيل بيانات مزود الخدمة بنجاح (بانتظار الموافقة)');
    } on FirebaseException catch (error) {
      throw AuthServiceException('فشل حفظ بيانات مزود الخدمة: ${error.code}');
    }
  }

  // ═══════════════════════════════════════════
  // 5. 🆕 جلب بيانات المستخدم للتحقق من الدور والحالة
  // ═══════════════════════════════════════════
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    _requireFirebase();
    try {
      final doc = await _database.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ خطأ في جلب بيانات المستخدم: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════
  // 6. تسجيل الخروج
  // ═══════════════════════════════════════════
  Future<void> signOut() async {
    _requireFirebase();
    await _firebaseAuth.signOut();
    debugPrint('👋 تم تسجيل الخروج بنجاح');
  }

  // ═══════════════════════════════════════════
  // دوال مساعدة (موجودة في كودك الأصلي وممتازة)
  // ═══════════════════════════════════════════
  String _authErrorMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-phone-number' => 'رقم الهاتف غير صحيح. استخدم مفتاح الدولة مثل +962.',
      'too-many-requests' => 'تم طلب رموز كثيرة. انتظر قليلاً ثم حاول مرة أخرى.',
      'quota-exceeded' => 'تجاوز المشروع الحد المسموح لرسائل التحقق.',
      'invalid-verification-code' => 'رمز التحقق غير صحيح.',
      'session-expired' => 'انتهت صلاحية الرمز. اطلب رمزاً جديداً.',
      'network-request-failed' => 'تعذّر الاتصال بالإنترنت. تحقق من الشبكة.',
      'operation-not-allowed' => 'تسجيل الدخول بالهاتف غير مفعّل في إعدادات Firebase.',
      'user-disabled' => 'هذا الحساب موقوف. تواصل مع الدعم.',
      _ => 'تعذّر إكمال المصادقة (${error.code}). حاول مرة أخرى.',
    };
  }

  void _requireFirebase() {
    try {
      FirebaseService.requireInitialized();
    } on FirebaseSetupException catch (error) {
      throw AuthServiceException(error.message);
    }
  }
}

class AuthServiceException implements Exception {
  const AuthServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}