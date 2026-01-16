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
import '../../presentation/survey/survey_controller.dart';
import '../models/survey_model.dart';
import 'dart:convert';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message");
  //var newData = json.decode(message.data['body']);

  // For background surveys, we might want to store them in PrefManager
  // so they can be picked up when the app opens.
  dynamic surveyDataRaw = message.data['payload'] ?? message.data;
  if (surveyDataRaw is String) {
    try {
      surveyDataRaw = jsonDecode(surveyDataRaw);
    } catch (_) {}
  }

  if (surveyDataRaw is Map &&
      (surveyDataRaw['survey_id'] != null || surveyDataRaw['id'] != null)) {
    await PrefManager.putString(
        AppConstants.activeSurvey, jsonEncode(surveyDataRaw));
  }
}

class AppNotification {
  Future<void> init() async {
    // Register SurveyController
    Get.put(SurveyController());

    // for notification request  in ios
    await enableIOSNotifications();

    await setFirebasePushNotification();

    await registerNotificationListeners();

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    final firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((value) async {
      print('Token: $value');
      await PrefManager.putString(AppConstants.fcmToken, value);
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

        // Handle Survey / Order Picked Notification when app killed and opened via notification
        if (initialMessage.data['type'] == 'order_picked' || initialMessage.data['type'] == 'order_pick') {
          _handleOrderPickedNotification(initialMessage.data);
        } else {
          _handleSurveyNotification(initialMessage.data);
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
            message:
                message.notification?.body ?? 'Your order has been confirmed!',
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
            message:
                message.notification?.body ?? 'Your order has been cancelled!',
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

        // Handle Survey / Order Picked Notification
        if (message.data['type'] == 'order_picked' || message.data['type'] == 'order_pick') {
          _handleOrderPickedNotification(message.data);
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

        if (message.data['type'] == 'order_confirmed' ||
            message.data['type'] == 'order_cancelled') {
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

        // Handle Survey / Order Picked Notification when app opened from notification
        if (message.data['type'] == 'order_picked' || message.data['type'] == 'order_pick') {
          _handleOrderPickedNotification(message.data);
        } else {
          _handleSurveyNotification(message.data);
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

  _handleSurveyNotification(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    final surveyData = _extractSurveyData(data);
    if (surveyData != null) {
      SurveyModel survey = SurveyModel.fromJson(surveyData);
      if (Get.isRegistered<SurveyController>()) {
        Get.find<SurveyController>().startSurvey(survey);
      }
    }
  }

  _handleOrderPickedNotification(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    try {
      // Try to get order_id (various keys) from top level, then payload
      int? orderId = int.tryParse(
          (data['order_id'] ?? data['Order_id'] ?? data['orderId'] ?? data['id'])
              .toString());
      
      dynamic payloadRaw = data['payload'];
      if (payloadRaw is String) {
        try {
          var decoded = jsonDecode(payloadRaw);
          if (orderId == null && decoded is Map) {
            orderId = int.tryParse(
                (decoded['order_id'] ??
                        decoded['Order_id'] ??
                        decoded['orderId'] ??
                        decoded['id'])
                    .toString());
          }
        } catch (_) {}
      } else if (payloadRaw is Map) {
        if (orderId == null) {
          orderId = int.tryParse(
              (payloadRaw['order_id'] ??
                      payloadRaw['Order_id'] ??
                      payloadRaw['orderId'] ??
                      payloadRaw['id'])
                  .toString());
        }
      }

      final surveyData = _extractSurveyData(data);
      SurveyModel? survey = surveyData != null ? SurveyModel.fromJson(surveyData) : null;
      
      int? surveyId = _extractSurveyId(data);

      if (Get.isRegistered<SurveyController>()) {
        Get.find<SurveyController>().onOrderPicked(orderId, pickedSurveyId: surveyId, survey: survey);
      }
    } catch (e) {
      print("Error in _handleOrderPickedNotification: $e");
    }
  }

  int? _extractSurveyId(Map<String, dynamic> data) {
    try {
      dynamic payloadRaw = data['payload'] ?? data;
      Map<String, dynamic>? payloadMap;

      if (payloadRaw is String) {
        try {
          payloadMap = jsonDecode(payloadRaw);
        } catch (_) {
          return null;
        }
      } else if (payloadRaw is Map) {
        payloadMap = Map<String, dynamic>.from(payloadRaw);
      }

      if (payloadMap == null) return null;

      // Prioritize survey object from logs
      if (payloadMap['survey'] is Map) {
        var surveyObj = payloadMap['survey'];
        int? id = int.tryParse((surveyObj['survey_id'] ?? surveyObj['id']).toString());
        if (id != null) return id;
      }
      
      // Fallback to top-level survey_id, id
      return int.tryParse((payloadMap['survey_id'] ?? 
                           payloadMap['id']).toString());
    } catch (_) {}
    return null;
  }

  Map<String, dynamic>? _extractSurveyData(Map<String, dynamic> data) {
    try {
      dynamic payloadRaw = data['payload'] ?? data;
      Map<String, dynamic>? payloadMap;

      if (payloadRaw is String) {
        try {
          payloadMap = jsonDecode(payloadRaw);
        } catch (_) {
          return null;
        }
      } else if (payloadRaw is Map) {
        payloadMap = Map<String, dynamic>.from(payloadRaw);
      }

      if (payloadMap == null) return null;

      // Check for nested 'survey' object (as seen in logs)
      Map<String, dynamic>? surveyData;
      if (payloadMap['survey'] is Map) {
        surveyData = Map<String, dynamic>.from(payloadMap['survey']);
        // Merge survey_type or survey_code if they exist in the wrapper
        if (surveyData['survey_id'] == null && payloadMap['survey_type'] != null) {
          surveyData['survey_id'] = payloadMap['survey_type'];
        }
        if (surveyData['survey_code'] == null && payloadMap['survey_code'] != null) {
          surveyData['survey_code'] = payloadMap['survey_code'];
        }
        // Merge order_id if it exists in the wrapper payload
        if (surveyData['Order_id'] == null &&
            surveyData['order_id'] == null &&
            payloadMap['Order_id'] != null) {
          surveyData['Order_id'] = payloadMap['Order_id'];
        }
        if (surveyData['order_id'] == null &&
            surveyData['Order_id'] == null &&
            payloadMap['order_id'] != null) {
          surveyData['order_id'] = payloadMap['order_id'];
        }
        if (surveyData['order_id'] == null &&
            surveyData['Order_id'] == null &&
            payloadMap['orderId'] != null) {
          surveyData['orderId'] = payloadMap['orderId'];
        }
      } else if (payloadMap['survey_id'] != null || payloadMap['id'] != null) {
        // Survey data is flat in the payload
        surveyData = payloadMap;
      }

      if (surveyData != null) {
        // Ensure questions are decoded if stringified
        if (surveyData['questions'] is String) {
          try {
            surveyData['questions'] = jsonDecode(surveyData['questions']);
          } catch (_) {}
        }
        return surveyData;
      }
    } catch (e) {
      print("Error extracting survey data: $e");
    }
    return null;
  }

  navigateToNotificationScreen(data, Map<String, dynamic> data2) {}
}
