import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not configured for this platform yet. '
      'Run flutterfire configure to add native platform settings.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyChJudm_9-zb2NvRRqI2hmeqk5pqYCEomI',
    appId: '1:585446113699:web:9e3d609c39de65f9d71a16',
    messagingSenderId: '585446113699',
    projectId: 'denona-4b33c',
    authDomain: 'denona-4b33c.firebaseapp.com',
    storageBucket: 'denona-4b33c.firebasestorage.app',
  );
}
