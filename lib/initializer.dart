import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'infrastructure/config/build_config.dart';
import 'infrastructure/config/env_config.dart';
import 'infrastructure/config/environment.dart';

import 'infrastructure/firebase/push_firebase_notification.dart';
//first

class Initializer {
  static Future<void> init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      EnvConfig devConfig = EnvConfig(
        appName: "Good To Grab",
        baseUrl: '',
        baseUrlGooglePlace: '',
        shouldCollectCrashLog: true,
      );
      BuildConfig.instantiate(
        envType: Environment.development,
        envConfig: devConfig,
      );
      _initScreenPreference();
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      AppNotification().init();
    } catch (err) {
      rethrow;
    }
  }

  static void _initScreenPreference() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
