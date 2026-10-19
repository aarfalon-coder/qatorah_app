import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not supported');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDvVymbvODQnFM9roYDNOFGQk6erdvpL4Y',
    appId: '1:325812686674:android:49697777b4dc45863c748b',
    messagingSenderId: '325812686674',
    projectId: 'qatora-56dcd',
    storageBucket: 'qatora-56dcd.firebasestorage.app',
  );
}
