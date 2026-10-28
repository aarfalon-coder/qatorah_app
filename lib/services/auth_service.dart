import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth,
        _firestore = firestore;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _database => _firestore ?? FirebaseFirestore.instance;
  User? get currentUser => _firebaseAuth.currentUser;
  bool get isSignedIn => currentUser != null;

  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    required void Function(String message) onFailure,
    int? forceResendingToken,
  }) async {
    _requireFirebase();
    try {
      await _firebaseAuth.setSettings(forceRecaptchaFlow: true);
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

  Future<UserCredential> signInWithPhoneCredential({
    required PhoneAuthCredential credential,
    Map<String, Object?>? profile,
  }) async {
    _requireFirebase();
    try {
      final result = await _firebaseAuth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) {
        throw const AuthServiceException('تعذّر إكمال تسجيل الدخول.');
      }
      if (profile != null) await saveUserProfile(user, profile);
      return result;
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_authErrorMessage(error));
    }
  }

  // ✅ هنا الحل: استخدام merge: true لتحديث البيانات إذا كان المستخدم موجوداً
  Future<void> saveUserProfile(User user, Map<String, Object?> profile) async {
    _requireFirebase();
    try {
      final userRef = _database.collection('users').doc(user.uid);
      await userRef.set({
        ...profile,
        'phoneNumber': user.phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // ✅ يسمح بالتحديث الآمن دون أخطاء
      debugPrint('✅ تم حفظ/تحديث بيانات المستخدم في Firestore بنجاح');
    } on FirebaseException catch (error) {
      throw AuthServiceException('تعذّر حفظ بيانات الحساب (${error.code}).');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    _requireFirebase();
    try {
      final doc = await _database.collection('users').doc(uid).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } on FirebaseException catch (error) {
      throw AuthServiceException('تعذّر تحميل بيانات الحساب (${error.code}).');
    }
  }

  Future<void> signOut() async {
    _requireFirebase();
    await _firebaseAuth.signOut();
  }

  String _authErrorMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-phone-number' =>
        'رقم الهاتف غير صحيح. استخدم مفتاح الدولة مثل +962.',
      'too-many-requests' =>
        'تم طلب رموز كثيرة. انتظر قليلاً ثم حاول مرة أخرى.',
      'invalid-verification-code' => 'رمز التحقق غير صحيح.',
      'session-expired' => 'انتهت صلاحية الرمز. اطلب رمزاً جديداً.',
      'network-request-failed' => 'تعذّر الاتصال بالإنترنت.',
      _ => 'تعذّر إكمال المصادقة (${error.code}).',
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
