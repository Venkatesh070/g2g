import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/constants/app_constants.dart';
import 'package:good_grab/infrastructure/models/user_model.dart';
import 'package:good_grab/infrastructure/shared/common_functions.dart';
import 'package:good_grab/infrastructure/shared/pref_manager.dart';
import 'package:good_grab/infrastructure/shared/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/firebase_messaging.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/permission_fun.dart';


class IntroController extends GetxController {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var isSkip = false.obs;

  @override
  void onInit() {
    isSkip.value = Get.arguments??true;
    Future.delayed(Duration.zero, () async {
      await getFcmToken();
    });
   super.onInit();
  }

  ///gmail
  Future<void> signInWithGmail() async {
    ProgressDialog progressDialog = ProgressDialog();
    progressDialog.show();
    try {
      if(await _googleSignIn.isSignedIn()){
        _googleSignIn.signOut();
      }
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if(googleUser != null){
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,
      );
      if(credential != null){
        await _firebaseAuth.signInWithCredential(credential);
        var fcmToken = await PrefManager.getString(AppConstants.fcmToken);
        if(fcmToken.toString().isEmpty){
          fcmToken = await getFcmToken();
        }
        var appVersion = await CommonFunction.getVersionDetails();
        Map<String, dynamic> params = {};
        params['social_id'] = googleUser.id;
        params['username'] = googleUser.displayName??'User';
        params['email'] = googleUser.email??'';
        params['device_type'] = CommonFunction.getDeviceType();
        params['login_type'] = "Google";
        params['device_token'] = fcmToken;
        params["version"] = appVersion;
        ApiResponseModel<UserModel> userModel = await DioClient.base().funSocialLoginApi(params);
        if (userModel.success! && userModel.data != null && userModel.data!.user != null) {
          progressDialog.dismiss();
          successLogin(userModel.data!);
        }
        else{
          progressDialog.dismiss();
          errorScreen(error:userModel.message!);
        }
      }}
      else{
        progressDialog.dismiss();
        // errorScreen(error:'something_went_wrong'.tr);
      }
    } on FirebaseAuthException catch (authException) {
      progressDialog.dismiss();
      print(authException.message);
      errorScreen(error:handleFirebaseException(authException.code));
    } on PlatformException catch (authException){

      progressDialog.dismiss();
      errorScreen(error:handleFirebaseException(authException.code));
    }on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      errorScreen(error:handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
    }
    catch (exception) {
      progressDialog.dismiss();
      print(exception);
      errorScreen(error:'something_went_wrong'.tr);
    }
  }


  ///apple

  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple() async {
    ProgressDialog progressDialog = ProgressDialog();
    progressDialog.show();
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
          webAuthenticationOptions: WebAuthenticationOptions(
              clientId: 'com.good.grab.applesignin', redirectUri: Uri.parse('https://appentus.com/callbacks/sign_in_with_apple')));
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
      if(oauthCredential != null){
        await _firebaseAuth.signInWithCredential(oauthCredential);
        var fcmToken = await PrefManager.getString(AppConstants.fcmToken);
        if(fcmToken.toString().isEmpty){
          fcmToken = await getFcmToken();
        }
        var appVersion = await CommonFunction.getVersionDetails();
        Map<String, dynamic> params = {};
        params['social_id'] = _firebaseAuth.currentUser!.uid;
        params['username'] = _firebaseAuth.currentUser!.displayName??'User';
        params['email'] = _firebaseAuth.currentUser!.email??'';
        params['device_type'] = CommonFunction.getDeviceType();
        params['login_type'] = "Apple";
        params['device_token'] = fcmToken;
        params["version"] = appVersion;
        print("map data ${params}");
        ApiResponseModel<UserModel> userModel = await DioClient.base().funSocialLoginApi(params);
        if (userModel.success! && userModel.data != null && userModel.data!.user != null) {
          progressDialog.dismiss();
          successLogin(userModel.data!);
        }
        else{
          progressDialog.dismiss();
          errorScreen(error:userModel.message!);
        }
      }
      else{
        progressDialog.dismiss();
        errorScreen(error:'something_went_wrong'.tr);
      }
    } on FirebaseAuthException catch (authException) {
      progressDialog.dismiss();
      print(authException.message);
      errorScreen(error:handleFirebaseException(authException.code));
    } on PlatformException catch (authException){
      progressDialog.dismiss();
      errorScreen(error:handleFirebaseException(authException.code));
    }on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      errorScreen(error:handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
    }
    catch (exception) {
      progressDialog.dismiss();
      print("exception:- ${exception}");
      print("exception:- ${exception.runtimeType}");
      if(exception.runtimeType.toString() == "SignInWithAppleAuthorizationException"){

      }else{
        errorScreen(error:'something_went_wrong'.tr);
      }

    }
  }


  successLogin(UserModel userModel){
    PrefManager.putString(AppConstants.userProfile, json.encode(userModel.user));
    PrefManager.putString(AppConstants.deviceId, userModel.user!.deviceId.toString());
    PrefManager.putInt(AppConstants.userId, userModel.user!.id);
    PrefManager.putString(AppConstants.accessToken, userModel.user!.accessToken);
    PrefManager.putBool(AppConstants.loggedIn, true);
    navigateScreen();
  }



  navigateScreen() async {
    var locationStatus = await getLocationPermissionStatus();
    var notificationStatus = await getNotificationPermissionStatus();
    if (locationStatus == 1 && notificationStatus == 1) {
      Get.offAllNamed(Routes.home, arguments: {'permission': 1});
    } else {
      Get.offAllNamed(Routes.allowPermission);
    }
  }


  getUniqueID() async {
    var deviceUniqueId = await PrefManager.getString(AppConstants.deviceId);
    print(deviceUniqueId);
    if(deviceUniqueId.isEmpty){
       deviceUniqueId = generateNonce();
      PrefManager.putString(AppConstants.deviceId, deviceUniqueId.toString());
    }
    navigateScreen();
  }


}
