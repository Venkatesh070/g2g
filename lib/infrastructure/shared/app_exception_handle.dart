import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'snackbar.util.dart';


handleApiException(code, message, DioException dioError,{required type}) {
  if(type == 'socketError'){
    return 'no_internet_connection'.tr;
  }
  else if (type == 'connectionTimeout') {
    return 'connection_timeout_exception'.tr;
  }
  else {
    return message;
  }
}

handleFirebaseException(errorCode) {
  print(errorCode);
  switch (errorCode) {
    case "user-disabled":
      return "User disabled";
    case "too-many-requests":
      return "firebase_too_many_request".tr;
    case "invalid-phone-number":
      return "firebase_invalid_phone_number".tr;
    case "invalid-verification-code":
      return "firebase_invalid_code".tr;
    case "session-expired":
      return "firebase_session_expired".tr;
    case "quota-exceeded":
      return 'quota exceed';
    case "operation-not-allowed":
      return "operation-not-allowed";
    case "network-request-failed":
      return "no_internet_connection".tr;
    case "network_error":
      return "no_internet_connection".tr;
    default:
      return "something_went_wrong".tr;
  }
}

