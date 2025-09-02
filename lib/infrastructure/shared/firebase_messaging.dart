
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:good_grab/infrastructure/shared/pref_manager.dart';

import '../constants/app_constants.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

getFcmToken() async {
  try{
    var fcmToken = await _firebaseMessaging.getToken();
    PrefManager.putString(AppConstants.fcmToken, fcmToken);
    return fcmToken;
  }catch (e){
    return ' ';
  }
}

