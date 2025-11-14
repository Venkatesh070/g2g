import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
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
 
      /// ✅ Environment Setup
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
 
      /// ✅ Screen Orientation Lock
      _initScreenPreference();
 
      /// ✅ Initialize Firebase
      await Firebase.initializeApp();
 
      /// ✅ Setup Background Notification Handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
 
      /// ✅ Setup Crashlytics
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
 
      /// ✅ Initialize Facebook SDK
      await _initializeFacebookSDK();
 
      /// ✅ Setup Analytics (Firebase + Meta)
      await _handleAnalyticsEvents();
 
      /// ✅ Initialize Push Notifications
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
 
  /// ✅ Initialize Facebook SDK
static Future<void> _initializeFacebookSDK() async {
  try {
    await _fbAppEvents.setAutoLogAppEventsEnabled(true);
    debugPrint('✅ Facebook App Events initialized (auto-log enabled)');
  } catch (e) {
    debugPrint('⚠️ Facebook SDK init failed: $e');
  }
}
 
 
  /// ✅ Logs install (once) and app open (every launch)
  static Future<void> _handleAnalyticsEvents() async {
    final analytics = FirebaseAnalytics.instance;
    final prefs = await SharedPreferences.getInstance();
 
    final hasInstalled = prefs.getBool('has_installed') ?? false;
 
    if (!hasInstalled) {
      /// ✅ Firebase: first_install
      await analytics.logEvent(
        name: 'first_install',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
          'platform': 'flutter',
        },
      );
 
      /// ✅ Facebook: first_install
      await _fbAppEvents.logEvent(
        name: 'first_install',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
          'platform': 'flutter',
        },
      );
 
      await prefs.setBool('has_installed', true);
      debugPrint('🔥 Logged first_install (Firebase + Facebook)');
    }
 
    /// ✅ Always log app open (Firebase + Facebook)
    await analytics.logAppOpen();
    await _fbAppEvents.logEvent(name: 'app_open');
    debugPrint('📲 Logged app_open (Firebase + Facebook)');
  }
}