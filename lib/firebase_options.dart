// File tam thoi de project compile duoc.
// Cach dung dung nhat: chay `flutterfire configure --project=shopappthuchanht5`
// de FlutterFire CLI sinh lai file nay bang config that tu Firebase.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions chua cau hinh cho Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions khong ho tro platform nay.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAaYnUAhM16VaPqiovJ3hho2v0CSu08KQY',
    appId: '1:1090784921011:web:746e000673a6bf0012b7c6',
    messagingSenderId: '1090784921011',
    projectId: 'shopappthuchanht5',
    authDomain: 'shopappthuchanht5.firebaseapp.com',
    storageBucket: 'shopappthuchanht5.firebasestorage.app',
    measurementId: 'G-1QJSY0PKRT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_ANDROID_API_KEY',
    appId: 'REPLACE_WITH_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'shopappthuchanht5',
    storageBucket: 'shopappthuchanht5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'shopappthuchanht5',
    storageBucket: 'shopappthuchanht5.appspot.com',
    iosBundleId: 'com.example.bai2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'shopappthuchanht5',
    storageBucket: 'shopappthuchanht5.appspot.com',
    iosBundleId: 'com.example.bai2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_WITH_WINDOWS_API_KEY',
    appId: 'REPLACE_WITH_WINDOWS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'shopappthuchanht5',
    authDomain: 'shopappthuchanht5.firebaseapp.com',
    storageBucket: 'shopappthuchanht5.appspot.com',
  );
}
