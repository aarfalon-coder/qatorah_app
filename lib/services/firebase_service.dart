import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;
  static String? _initializationErrorCode;

  static bool get isInitialized => _initialized;
  static bool get isAuthenticated =>
      _initialized && Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;
  static String? get initializationErrorCode => _initializationErrorCode;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _initialized = true;
      _initializationErrorCode = null;
    } on FirebaseException catch (error, stackTrace) {
      _initializationErrorCode = error.code;
      debugPrint('Firebase initialization failed (${error.code}): $stackTrace');
    } on PlatformException catch (error, stackTrace) {
      _initializationErrorCode = error.code;
      debugPrint(
        'Firebase platform initialization failed '
        '(${error.code}): ${error.message}\n$stackTrace',
      );
    }
  }

  static void markAsInitialized() {
    _initialized = true;
    _initializationErrorCode = null;
  }

  static void requireInitialized() {
    if (!_initialized || Firebase.apps.isEmpty) {
      throw const FirebaseSetupException();
    }
  }
}

class FirebaseSetupException implements Exception {
  const FirebaseSetupException();

  String get message =>
      'إعداد Firebase غير مكتمل. شغّل flutterfire configure ثم أعد تشغيل التطبيق.';
}