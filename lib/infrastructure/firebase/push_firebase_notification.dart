
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../constants/app_constants.dart';
import '../navigation/routes.dart';
import '../shared/pref_manager.dart';
import '../../infrastructure/shared/snackbar.util.dart';
import '../../presentation/order_details/order_details_controller.dart';
import '../../presentation/notification/notification_controller.dart';
import '../../presentation/home/home_controller.dart';

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
      if (initialMessage.data.isNotEmpty) {
        if (initialMessage.data['type'] == 'order_confirmed') {
          var orderId = initialMessage.data['order_id'];
          if (orderId != null) {
            Future.delayed(const Duration(seconds: 1), () {
              Get.toNamed(Routes.orderDetails, arguments: {
                'orderId': int.tryParse(orderId.toString()) ?? 0,
                'resId': 0,
                'currency': '₹',
                'orderStatus': '',
              });
            });
          }
        }
      }
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
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (message.data.isNotEmpty) {
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

         if (message.data['type'] == 'order_confirmed') {
           var orderId = message.data['order_id'];
           
           SnackBarUtil.showOrderConfirmation(
             message: message.notification?.body ?? 'Your order has been confirmed!',
             onOrderDetails: () {
               Get.back(); // close dialog
               if (Get.isRegistered<HomeController>()) {
                 Get.find<HomeController>().onSelectIndex(2); // Orders tab
               }
             },
             onOrdersHistory: () {
               Get.back(); // close dialog
               if (Get.isRegistered<HomeController>()) {
                 Get.find<HomeController>().onSelectIndex(2); // Orders tab
               }
             },
             onCancel: () {
               Get.back(); // close dialog
             },
           );
           
           // Real-time UI refresh
           if (orderId != null) {
              int id = int.tryParse(orderId.toString()) ?? 0;
              if (Get.isRegistered<OrderDetailsController>()) {
                var controller = Get.find<OrderDetailsController>();
                if (controller.orderId == id) {
                  controller.getOrderDetails();
                }
              }
           }
           
           if (Get.isRegistered<HomeController>()) {
              var homeController = Get.find<HomeController>();
              homeController.currentPage.value = 1;
              homeController.orderList.clear();
              homeController.getOrdersList();
           }

           if (Get.isRegistered<NotificationController>()) {
              Get.find<NotificationController>().onInit();
           }
         }

         if (message.data['type'] == 'order_cancelled') {
           var orderId = message.data['order_id'];

           SnackBarUtil.showOrderCancellation(
             message: message.notification?.body ?? 'Your order has been cancelled!',
             onOrderDetails: () {
               Get.back(); // close dialog
               if (Get.isRegistered<HomeController>()) {
                 Get.find<HomeController>().onSelectIndex(2); // Orders tab
               }
             },
             onCancel: () {
               Get.back(); // close dialog
             },
           );

           // Real-time UI refresh
           if (orderId != null) {
             int id = int.tryParse(orderId.toString()) ?? 0;
             if (Get.isRegistered<OrderDetailsController>()) {
               var controller = Get.find<OrderDetailsController>();
               if (controller.orderId == id) {
                 controller.getOrderDetails();
               }
             }
           }

           if (Get.isRegistered<HomeController>()) {
             var homeController = Get.find<HomeController>();
             homeController.currentPage.value = 1;
             homeController.orderList.clear();
             homeController.getOrdersList();
           }

           if (Get.isRegistered<NotificationController>()) {
             Get.find<NotificationController>().onInit();
           }
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
        print("notification_onMessageOpenedApp ${message.data}");
        /// Handle navigation or other actions here
        
        if (message.data['type'] == 'order_confirmed' || message.data['type'] == 'order_cancelled') {
           var orderId = message.data['order_id'];
           if (orderId != null) {
              Get.toNamed(Routes.orderDetails, arguments: {
                'orderId': int.tryParse(orderId.toString()) ?? 0,
                'resId': 0, // Fallback if not provided
                'currency': '₹',
                'orderStatus': '',
              });
           }
        }
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
