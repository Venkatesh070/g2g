import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/models/user_model.dart';
import 'package:good_grab/infrastructure/shared/app_exception_handle.dart';
import 'package:good_grab/infrastructure/shared/progress_dialog.dart';


import '../../infrastructure/constants/app_constants.dart';
import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/firebase_messaging.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/permission_fun.dart';
import '../../infrastructure/shared/pref_manager.dart';

class OtpVerifyController extends GetxController {

  var number = ''.obs;
  var screenType = '';
  var countryName = ''.obs;
  var countryCode = ''.obs;

  var otpController = TextEditingController();
  var isFillColor = false.obs;

  Timer? timer;
  var seconds = 60.obs;
  var durationSecond = Duration.zero;

  // firebase
  FirebaseAuth auth = FirebaseAuth.instance;
  var verificationId = ''.obs;

  Map<String,dynamic> params = {};
  var progressLoader = ProgressDialog();

  @override
  void onInit() {
    screenType = Get.arguments['screenType'];
    params = Get.arguments['params'];
    Future.delayed(Duration.zero, ()  {
      if (screenType == 'login' || screenType == 'signup') {
        number.value = params['mobile'];
        countryName.value = params['country_id'];
        countryCode.value = params['country_code'];
        print('countryName ${countryName.value}');
        //sendOtp('+${countryCode.value} ${number.value}');
        sendNumberOtp(number.value);
      } else {
        if(params['login_type'] == 'number'){
          number.value = params['mobile'];
          countryName.value = params['country_id'];
          countryCode.value = params['country_code'];
          //sendOtp('+${countryCode.value} ${number.value}');
          sendNumberOtp(number.value);
        }
        else{
          number.value = params['email'];
          sendEmailOtp(number.value);
        }
      }

    });
    super.onInit();
  }

  resendOtp(){
    otpController.text = '';
    if(screenType == 'login' || screenType == 'signup' || params['login_type'] == 'number'){
      if (seconds.value == 0) {
        //sendOtp('+${countryCode.value} ${number.value}');
        sendNumberOtp(number.value);
      }
    }
    else{
      sendEmailOtp(number.value);
    }
  }

  onChangeText(text) {
    changeButtonColor();
  }

  changeButtonColor() {
    if (otpController.text.length < 6) {
      isFillColor.value = false;
    } else {
      isFillColor.value = true;
    }
  }

  initTimer() {
    seconds.value = 60;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds.value == 0) {
        timer!.cancel();
      } else {
        seconds.value = seconds.value - 1;
      }
    });
  }



  // login/signup
  Future sendOtp(String mobileNumber) async {
    progressLoader.show();
    auth.verifyPhoneNumber(
            phoneNumber: mobileNumber,
            timeout: const Duration(seconds: 60),
            verificationCompleted: (AuthCredential authCredential) async {
              //signupLoginUser(authCredential);
            },
            verificationFailed: (FirebaseAuthException authException) {
              progressLoader.dismiss();
              print(authException.message);
              Get.back();
              errorScreen(error: handleFirebaseException(authException.code));
            },
            codeSent: (String? verificationId, [int? forceResendingToken]) {
              progressLoader.dismiss();
              this.verificationId.value = verificationId!;
              initTimer();
            },
            codeAutoRetrievalTimeout: (String verificationId) {
              progressLoader.dismiss();
              this.verificationId.value = verificationId;
            })
        .catchError((error) {
      progressLoader.dismiss();

      Get.back();
      errorScreen(error: 'something_went_wrong'.tr);
    });
  }

  Future sendNumberOtp(String mobileNumber) async {
    progressLoader.show();
    var nParams = {
      'type' : 'mobile',
      'mobile'  : mobileNumber
    };
    try {
      ApiResponseModel baseModel = await DioClient.base().funSendNOtpApi(nParams);
      if (baseModel.success!) {
        progressLoader.dismiss();
        initTimer();
      }
      else{
        progressLoader.dismiss();
        errorScreen(error: baseModel.message!);
      }
    } on CustomHttpException catch (exception) {
      progressLoader.dismiss();
      errorScreen(error:handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
    } catch (e) {
      progressLoader.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  Future sendEmailOtp(String email) async {
    progressLoader.show();
    var emailParams = {
      'email'  : email
    };
    try {
      ApiResponseModel baseModel = await DioClient.base().funSendOtpApi(emailParams);
      if (baseModel.success!) {
        progressLoader.dismiss();
        initTimer();
      }
      else{
        progressLoader.dismiss();
        errorScreen(error: baseModel.message!);
      }
    } on CustomHttpException catch (exception) {
      progressLoader.dismiss();
      errorScreen(error:handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
    } catch (e) {
      progressLoader.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  Future verifyOtp(code) async {
    if(screenType == 'change' && params['login_type'] == 'email'){
      progressLoader.show();
      await verifyOtpEmail(code);
    }
    else{
      progressLoader.show();
      //AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId.value, smsCode: code);
      //signupLoginUser(credential);
      verifyOtpNumber(code);
    }
  }

  signupLoginUser(credential) async {
    try {
      await auth.signInWithCredential(credential);
      if(screenType == 'change'){
        progressLoader.dismiss();
        var currentUser = await PrefManager.getUser();
        if (currentUser != null) {
          currentUser?.mobile = params['mobile'];
        }
        await PrefManager.putString(AppConstants.userProfile, json.encode(currentUser));
        Get.back();
        Get.back(result:  params);
      }
      else{
        if(params['device_token'].toString().isEmpty){
          params['device_token'] = await getFcmToken();
        }
        ApiResponseModel<UserModel> userModel;
        if(screenType == 'login'){
          userModel = await DioClient.base().funLoginUserApi(params);
        }
        else{
          userModel = await DioClient.base().funSignupUserApi(params);
        }
        if (userModel.success! && userModel.data != null && userModel.data!.user != null ) {
          progressLoader.dismiss();
          successLoginSignup(userModel.data!);
        }
        else{
          progressLoader.dismiss();
          errorScreen(error: userModel.message!);
        }
      }
    } on FirebaseAuthException catch (e) {
      progressLoader.dismiss();
      errorScreen(error:handleFirebaseException(e.code));
    }on CustomHttpException catch (exception) {
      progressLoader.dismiss();
      errorScreen(error:handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
    } catch (e) {
      progressLoader.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  verifyOtpEmail(code) async {
    try {
      var emailParams = {
        'email'  : number.value,
        'otp' :code
      };
      ApiResponseModel baseModel = await DioClient.base().funVerifyOtpApi(emailParams);
      if (baseModel.success!) {
        progressLoader.dismiss();
        Get.back();
        Get.back(result:  params);
      }
      else{
        progressLoader.dismiss();
        errorScreen(error: baseModel.message!);
      }
    }on CustomHttpException catch (exception) {
      progressLoader.dismiss();
      errorScreen(error:handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
    } catch (e) {
      progressLoader.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  verifyOtpNumber(code) async {
    try {
      var emailParams = {
        'mobile'  : number.value,
        'otp' :code
      };
      ApiResponseModel baseModel = await DioClient.base().funVerifyNOtpApi(emailParams);
      if (baseModel.success!) {
        await verifyAndLogin();
      }
      else{
        progressLoader.dismiss();
        errorScreen(error: baseModel.message!);
      }
    }on CustomHttpException catch (exception) {

      progressLoader.dismiss();
      errorScreen(error:handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
    } catch (e) {
      progressLoader.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  verifyAndLogin() async {
    try {
      if(screenType == 'change'){
        progressLoader.dismiss();
        Get.back();
        Get.back(result:  params);
      }
      else{
        if(params['device_token'].toString().isEmpty){
          params['device_token'] = await getFcmToken();
        }
        ApiResponseModel<UserModel> userModel;
        if(screenType == 'login'){
          userModel = await DioClient.base().funLoginUserApi(params);
        }
        else{
          userModel = await DioClient.base().funSignupUserApi(params);
        }
        if (userModel.success! && userModel.data != null && userModel.data!.user != null ) {
          progressLoader.dismiss();
          successLoginSignup(userModel.data!);
        }
        else{
          progressLoader.dismiss();
          errorScreen(error: userModel.message!);
        }
      }
    } on CustomHttpException catch (exception) {
      print("jksdkfj  exception ${exception}");
      progressLoader.dismiss();
      errorScreen(error:handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
    } catch (e) {
      print("jksdkfj ${e}");
      progressLoader.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }


  successLoginSignup(UserModel userModel){
    PrefManager.putString(AppConstants.userProfile, json.encode(userModel.user));
    PrefManager.putString(AppConstants.deviceId, userModel.user!.deviceId.toString());
    PrefManager.putInt(AppConstants.userId, userModel.user!.id);
    PrefManager.putString(AppConstants.accessToken, userModel.user!.accessToken.toString());
    PrefManager.putBool(AppConstants.loggedIn, true);
    navigateScreen();
  }

  navigateScreen() async {
    if (screenType == 'change') {
      Get.back();
      Get.back();
    } else {
      var locationStatus = await getLocationPermissionStatus();
      var notificationStatus = await getNotificationPermissionStatus();
      if (locationStatus == 1 && notificationStatus == 1) {
        Get.offAllNamed(Routes.home, arguments: {'permission': 1});
      } else {
        Get.offAllNamed(Routes.allowPermission);
      }
    }
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }


}
