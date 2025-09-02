import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/models/create_intent_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../infrastructure/constants/app_constants.dart';
import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/pref_manager.dart';

class PaymentStatusController extends GetxController {
  var createIntentData = CreateIntentModel().obs;
  var pDescription =
      'It may take a few seconds for the transaction to be finalized, so please do not refresh the page or go back. \n\n We appreciate your patience and understanding during the process'.obs;

  var orderNumber = '';
  var upiRefId = '';

  Timer? countdownTimer;
  var timeInSecFor5Min = 180.obs;
  var timeInSec = 10.obs;
  var isApi = false.obs;
  var paymentStatus = 'Processing'.obs;
  var paymentType = ''.obs;
  var transactionId = 0;

  var paymentId = '';

  @override
  void onInit() {
    //createIntentData.value = Get.arguments['intentData'];
    paymentType.value = Get.arguments['paymentType'];
    paymentId = Get.arguments['paymentId'];
    startTimer();
    if(paymentType.value == "intent"){
      Future.delayed(Duration.zero, () async {
        try {
            launchUrl((Uri.parse(createIntentData.value.payment!.intentUrl.toString())));

        } catch (exception) {
          debugPrint('exception error $exception');
        }
      });
    }

    //print("Get_arguments ${createIntentData.value.payment.toString()}");
    super.onInit();
  }

  startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      await setCountDown();
    });
  }

  void stopTimer() {
    countdownTimer!.cancel();
  }

  Future<void> setCountDown() async {
    if (timeInSec.value == 0) {
      if (!isApi.value) {
        isApi.value = true;
        await paymentStatusCheck(timeInSecFor5Min.value);
      }
    } else {
      if(timeInSecFor5Min.value == 0 ){
        stopTimer();
        paymentStatus.value = 'Failed';
        pDescription.value = "Your session is timeout. Please try again";
      }else {
        timeInSecFor5Min.value--;
        timeInSec.value--;
        print('myDuration');
        print(timeInSec);
        print(timeInSecFor5Min);
      }

    }
  }

  paymentStatusCheck(apiCheckTime) async {
    try {
      var accessToken = await PrefManager.getString(AppConstants.accessToken);
      Map<String, dynamic> dataParams = {
        "payment_id": paymentId//createIntentData.value.payment!.paymentId,
      };
      ApiResponseModel<CreateIntentModel> paymentStatusCheck = await DioClient.base(accessToken: accessToken).funCheckIntentStatusApi(dataParams);

      if (paymentStatusCheck.success!) {
        if (paymentStatusCheck.data!.payment!.status == 'completed') {
          pDescription.value = "Congratulations! Your payment has been successfully processed. Thank you for choosing us.";
          transactionId = paymentStatusCheck.data!.payment!.transactionId!;
          paymentStatus.value = 'Success';
          countdownTimer!.cancel();
        }
        else if (paymentStatusCheck.data!.payment!.status == 'failed') {

          paymentStatus.value = 'Failed';
          pDescription.value = "Oops! It seems like there was an issue processing your payment. Please check your payment details and try again.";
        } else {
          timeInSec.value = 10;
          isApi.value = false;
          paymentStatus.value = 'Processing';
          pDescription.value = "It may take a few seconds for the transaction to be finalized, so please do not refresh the page or go back. \n\n We appreciate your patience and understanding during the process";

        }
      }
    } on CustomHttpException catch (exception) {
      paymentStatus.value = 'Failed';
      pDescription.value = "Oops! It seems like there was an issue processing your payment. Please check your payment details and try again.";
      errorScreen(
          error: handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
    } catch (exception) {
      paymentStatus.value = 'Failed';
      pDescription.value = "Oops! It seems like there was an issue processing your payment. Please check your payment details and try again.";
    }
  }
}
