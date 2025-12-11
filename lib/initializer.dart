import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'infrastructure/config/build_config.dart';
import 'infrastructure/config/env_config.dart';
import 'infrastructure/config/environment.dart';
import 'infrastructure/firebase/push_firebase_notification.dart';

class Initializer {
  static final FacebookAppEvents _fbAppEvents = FacebookAppEvents();

  static Future<void> init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      /// Environment
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

      /// Firebase
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      /// Crashlytics
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      /// Meta Auto-Log (REQUIRED for fb_mobile_install)
      await _fbAppEvents.setAutoLogAppEventsEnabled(true);

      /// Analytics
      await _handleAnalyticsEvents();

      /// Notifications
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

  /// Custom first_install logic (internal only)
  static Future<void> _handleAnalyticsEvents() async {
    final analytics = FirebaseAnalytics.instance;
    final prefs = await SharedPreferences.getInstance();

    final firstInstall = prefs.getBool('has_installed') ?? false;

    if (!firstInstall) {
      await analytics.logEvent(name: 'first_install');
      await _fbAppEvents.logEvent(name: 'first_install');

      await prefs.setBool('has_installed', true);
    }

    await analytics.logAppOpen();
    await _fbAppEvents.logEvent(name: 'app_open');
  }
}
