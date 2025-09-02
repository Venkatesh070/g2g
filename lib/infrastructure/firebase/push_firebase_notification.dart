
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../constants/app_constants.dart';
import '../navigation/routes.dart';
import '../shared/pref_manager.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message");
  //var newData = json.decode(message.data['body']);
}

class AppNotification {

  Future<void> init() async{
    // for notification request  in ios
    await enableIOSNotifications();

    await setFirebasePushNotification();

    await registerNotificationListeners();

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    final firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((value) async {
      print('Token: $value');
      await PrefManager.putString(AppConstants.fcmToken,value);
    });

    if (initialMessage != null) {
      //  Utils.successSnackBar(initialMessage.notification!.title);
      print('// App received a notification when it was killed');
    }
  }

  setFirebasePushNotification() async {
    AndroidNotificationChannel channel = androidNotificationChannel();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification android = message.notification!.android!;
      if (message != null && message.data.isNotEmpty) {
        print("notification_onMessageOpenedApp1 ${message.data.toString()}");
        /// Handle navigation or other actions here

         if (message.data['type'] == 'order_place') {
           print("notification_onMessageOpenedApp2 ");

           // Get.toNamed(Routes.orderDetails, arguments: {
           //   'orderId': int.parse(message.data['body']['orderId']),
           //   'currency': message.data['body']['currency'],
           //   'resId': int.parse(message.data['body']['resId']),
           //   'orderStatus': message.data['body']['pending_pick_up'],
           // });
         }
      }
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                // channel.description,
                icon: android.smallIcon,
              ),
            ));
      }
    });
  }

  registerNotificationListeners() async {
    AndroidNotificationChannel channel = androidNotificationChannel();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    var androidSettings =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSSettings = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (message != null && message.data.isNotEmpty) {
        print("notification_onMessageOpenedApp ${message.data.toString()}");
        /// Handle navigation or other actions here
        /// For example:
        /// if (message.data['type'] == 'profile_update') {
        ///  Get.offNamed(Routes.EDIT_PROFILE);
        /// }
      }
    });


    var initializationSettings =
    InitializationSettings(android: androidSettings, iOS: iOSSettings);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) => {
        print("notification_details $details"),
        // print(details.notificationResponseType),
        // print(details.payload),
        // if (details.payload == 'profile_update')
        //   {Get.toNamed(Routes.EDIT_PROFILE)}

      },
    );
  }

  enableIOSNotifications() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true,
      );
    }
  }

  androidNotificationChannel() {
    return const AndroidNotificationChannel(
      'Good To Grab', // title
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      playSound: true,
      importance: Importance.max,
    );
  }

   navigateToNotificationScreen(data, Map<String, dynamic> data2) {}
}
