import 'dart:async';

import 'package:get/get.dart';
import 'package:good_grab/infrastructure/models/order_details_model.dart';
import 'package:good_grab/infrastructure/shared/common_functions.dart';
import 'package:good_grab/infrastructure/shared/snackbar.util.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../infrastructure/constants/app_constants.dart';
import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/pref_manager.dart';
import '../../infrastructure/shared/progress_dialog.dart';
import 'package:intl/intl.dart';

class OrderDetailsController extends GetxController {
  var orderStatus = ''.obs;
  var loadingData = true.obs;
  var is2HoursLess = true.obs;
  var isOrderData = false.obs;
  var orderId = 0;
  var resId = 0;
  var currency = '';
  var pickupCode = 0000.obs;


  var backResult = false.obs;

  OrderDetailsModel? orderDetailsModel;

  var subTotalPrice = (0.0).obs;
  var subTotalOfferPrice = (0.0).obs;
  var otherTotalPrice = (0.0).obs;
  var combinedGst = (0.0).obs;
  var platformGst = (0.0).obs;
  var platformFee = (0.0).obs;
  var totalPrice = (0.0).obs;

  var isRated = false.obs;

  var cancelDiffMinutes = 0.obs; // Add this observable

  @override
  void onInit() {
    orderId = Get.arguments['orderId'];
    resId = Get.arguments['resId'];
    currency = Get.arguments['currency'] ?? "₹";
    orderStatus.value = Get.arguments['orderStatus'];

    Future.delayed(Duration.zero, () async {
      if (orderStatus.value == 'completd_pick_up') {
        // appReview();
      }

      await getOrderDetails();
      calculateCancelDiffMinutes();
    });
    super.onInit();
  }

  getOrderDetails() async {
    loadingData.value = true;
    isOrderData.value = false;
    var accessToken = await PrefManager.getString(AppConstants.accessToken);
    try {
      Map<String, dynamic> params = {'order_id': orderId};
      ApiResponseModel<OrderDetailsModel> orderModel =
          await DioClient.base(accessToken: accessToken)
              .funGetOrderDetailsApi(params);
      if (orderModel.success! && orderModel.data != null) {
        loadingData.value = false;
        isOrderData.value = true;
        orderStatus.value = orderModel.data!.orderStatus!;
        orderDetailsModel = orderModel.data!;
        subTotalPrice.value = double.parse(orderModel.data!.totalPaid.toString());
        subTotalOfferPrice.value = double.parse(orderModel.data!.price.toString());
        otherTotalPrice.value = double.parse(orderModel.data!.gstCharge.toString());
        pickupCode.value = orderModel.data!.pickupCode!;
        platformFee.value= await PrefManager.getDouble(AppConstants.platformFee);
        platformGst.value = await PrefManager.getDouble(AppConstants.platformGst);  
        combinedGst.value = otherTotalPrice.value + platformGst.value;
        totalPrice.value = subTotalPrice.value + combinedGst.value + platformFee.value;
        isRated.value = orderDetailsModel!.isRated!;
        getCancelTime();
      } else {
        loadingData.value = false;
        isOrderData.value = false;
      }
    } on CustomHttpException catch (exception) {
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
      loadingData.value = false;
      isOrderData.value = false;
    } catch (exception) {
      print("sdlkjfd ${exception}");
      loadingData.value = false;
      isOrderData.value = false;
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      errorScreen(error: 'Could not open the map.'.tr);
    }
  }

  appReview() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      errorScreen(error: 'Could not find the app.'.tr);
    }
  }

  // add order rating

  funAddOrderRating(rating, comment) async {
    var progressDialog = ProgressDialog();
    progressDialog.show();
    var accessToken = await PrefManager.getString(AppConstants.accessToken);
    try {
      Map<String, dynamic> params = {
        'order_id': orderId,
        'restro_id': resId,
        'rating': rating,
      };
      if (comment.toString().isNotEmpty) {
        params['comment'] = comment;
      }
      ApiResponseModel baseModel =
          await DioClient.base(accessToken: accessToken)
              .funAddOrderRatingApi(params);
      if (baseModel.success!) {
        progressDialog.dismiss();
        SnackBarUtil.showSuccess(message: baseModel.message!);
        isRated.value = true;
        orderDetailsModel!.rating = rating;
        isRated.refresh();
      } else {
        progressDialog.dismiss();
        errorScreen(error: baseModel.message!);
      }
    } on CustomHttpException catch (exception) {
      print("sdlkjfd ${exception}");
      progressDialog.dismiss();

      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
      return false;
    } catch (exception) {
      progressDialog.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
      return false;
    }
  }

  Timer? cancelTimer;
  RxInt remainingSeconds = 300.obs; // 5 minutes

  void startCancelTimer(DateTime? createdAt, Duration maxDuration) {
    cancelTimer?.cancel();
    if (createdAt == null) return;
    final now = DateTime.now();
    int secondsLeft = maxDuration.inSeconds - now.difference(createdAt).inSeconds;
    if (secondsLeft <= 0) {
      remainingSeconds.value = 0;
      return;
    }
    remainingSeconds.value = secondsLeft;
    cancelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      int secondsLeft = maxDuration.inSeconds - now.difference(createdAt).inSeconds;
      if (secondsLeft <= 0) {
        remainingSeconds.value = 0;
        timer.cancel();
        cancelTimer = null;
      } else {
        remainingSeconds.value = secondsLeft;
      }
    });
  }

  @override
  void onClose() {
    cancelTimer?.cancel();
    super.onClose();
  }

  getCancelTime() {
    DateTime currentTime = DateTime.now();
    DateTime pickupDateTime = DateTime.parse(
        "${orderDetailsModel!.pickupDate!} ${orderDetailsModel!.pickupTime}");
    Duration timeDifference = pickupDateTime.difference(currentTime);
    is2HoursLess.value = timeDifference.inHours == 2;
    print("pickuptime ${is2HoursLess.value}");
  }

  void calculateCancelDiffMinutes() {
    try {
      final diffMinutes = CommonFunction.getDiffMinutesFromDateTime(
        orderDetailsModel!.createdDate.toString(),
        orderDetailsModel!.createdTime.toString(),
      );
      cancelDiffMinutes.value = diffMinutes;
    } catch (e) {
      cancelDiffMinutes.value = -9999; // fallback value
    }
  }
}
