// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBWivN7OGQmkM_oB8lb9i-G2a0Ubp9RmdM',
    appId: '1:227376723804:web:bf8126dfbfee061833f399',
    messagingSenderId: '227376723804',
    projectId: 'ginraidee-18b44',
    authDomain: 'ginraidee-18b44.firebaseapp.com',
    storageBucket: 'ginraidee-18b44.firebasestorage.app',
    measurementId: 'G-36NBDM2VPL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAAVRsbtpCjqYrifxQ6gUVhUDShGy13i7o',
    appId: '1:227376723804:android:237182f03b7e437233f399',
    messagingSenderId: '227376723804',
    projectId: 'ginraidee-18b44',
    storageBucket: 'ginraidee-18b44.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBVzk1In3QbtKgbMTp9Khjw7KrIQtGJsI0',
    appId: '1:227376723804:ios:bc3292459b35253833f399',
    messagingSenderId: '227376723804',
    projectId: 'ginraidee-18b44',
    storageBucket: 'ginraidee-18b44.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBVzk1In3QbtKgbMTp9Khjw7KrIQtGJsI0',
    appId: '1:227376723804:ios:bc3292459b35253833f399',
    messagingSenderId: '227376723804',
    projectId: 'ginraidee-18b44',
    storageBucket: 'ginraidee-18b44.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBWivN7OGQmkM_oB8lb9i-G2a0Ubp9RmdM',
    appId: '1:227376723804:web:6a35e812d8877d7133f399',
    messagingSenderId: '227376723804',
    projectId: 'ginraidee-18b44',
    authDomain: 'ginraidee-18b44.firebaseapp.com',
    storageBucket: 'ginraidee-18b44.firebasestorage.app',
    measurementId: 'G-RZN6H6PF5H',
  );
}
