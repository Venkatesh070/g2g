import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:linkrunner/models/lr_user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linkrunner/linkrunner.dart'; // Adjust if the path is incorrect
import 'infrastructure/config/build_config.dart';
import 'infrastructure/config/env_config.dart';
import 'infrastructure/config/environment.dart';
import 'infrastructure/firebase/push_firebase_notification.dart';
import 'infrastructure/constants/app_constants.dart';
import 'infrastructure/shared/pref_manager.dart';
import 'infrastructure/models/user_model.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

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

      /// LinkRunner
      await _initLinkRunner();
      await _handleLinkRunnerUserData();

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

  static Future<void> _initLinkRunner() async {
    try {

      await LinkRunner().init(
          AppConstants.linkrunnerToken,
          Platform.isIOS
              ? AppConstants.linkrunnerIOSSecretKey
              : AppConstants.linkrunnerSecretKey,
          Platform.isIOS
              ? AppConstants.linkrunnerIOSKeyId
              : AppConstants.linkrunnerKeyId,
          false, // disableIdfaCollection (Android safe)
          false);

      debugPrint('[LinkRunner] Initialization successful');
    } catch (e) {
      debugPrint('[LinkRunner] Initialization failed: $e');
    }
  }

  static Future<void> _handleLinkRunnerUserData() async {
    try {
      final user = await PrefManager.getUser();
      if (user != null) {
        await LinkRunner().setUserData(
          userData: LRUserData(
            id: user.id.toString(),
            name: user.username,
            email: user.email,
            phone: user.mobile,
            // Add additional fields if available, e.g., userCreatedAt: user.createdAt
          ),
        );
        debugPrint('LinkRunner user data set for existing user');
      }
    } catch (e) {
      debugPrint('Error setting LinkRunner user data: $e');
    }
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
