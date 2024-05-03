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
    apiKey: 'AIzaSyBcdQTP6kqcIyH0vi18aw0amhJ_DKfhiNo',
    appId: '1:836537707228:web:b2efec2b988c1be24c2219',
    messagingSenderId: '836537707228',
    projectId: 'iot2020-e605e',
    authDomain: 'iot2020-e605e.firebaseapp.com',
    databaseURL: 'https://iot2020-e605e.firebaseio.com',
    storageBucket: 'iot2020-e605e.appspot.com',
    measurementId: 'G-64EJ4XW070',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBC2rmZRDdQnaQkpbWQNFILy87sDAniq2w',
    appId: '1:836537707228:android:8c83455e3b8462494c2219',
    messagingSenderId: '836537707228',
    projectId: 'iot2020-e605e',
    databaseURL: 'https://iot2020-e605e.firebaseio.com',
    storageBucket: 'iot2020-e605e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDVGzc_G0DwqDZvb1qg1fYIX0qBqMRVe2M',
    appId: '1:836537707228:ios:8c8c1f53f73ffd9a4c2219',
    messagingSenderId: '836537707228',
    projectId: 'iot2020-e605e',
    databaseURL: 'https://iot2020-e605e.firebaseio.com',
    storageBucket: 'iot2020-e605e.appspot.com',
    iosBundleId: 'com.example.adminIsiApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDVGzc_G0DwqDZvb1qg1fYIX0qBqMRVe2M',
    appId: '1:836537707228:ios:8c8c1f53f73ffd9a4c2219',
    messagingSenderId: '836537707228',
    projectId: 'iot2020-e605e',
    databaseURL: 'https://iot2020-e605e.firebaseio.com',
    storageBucket: 'iot2020-e605e.appspot.com',
    iosBundleId: 'com.example.adminIsiApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBcdQTP6kqcIyH0vi18aw0amhJ_DKfhiNo',
    appId: '1:836537707228:web:acbf2e5d859569584c2219',
    messagingSenderId: '836537707228',
    projectId: 'iot2020-e605e',
    authDomain: 'iot2020-e605e.firebaseapp.com',
    databaseURL: 'https://iot2020-e605e.firebaseio.com',
    storageBucket: 'iot2020-e605e.appspot.com',
    measurementId: 'G-BD1F1RPBGY',
  );

}