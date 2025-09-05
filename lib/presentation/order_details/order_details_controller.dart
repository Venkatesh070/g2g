import 'dart:async';

import 'package:flutter/material.dart';
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
        platformGst.value = double.parse(orderModel.data!.platformGst.toString());
        combinedGst.value = otherTotalPrice.value + platformGst.value;
        platformFee.value = orderModel.data!.platformFee!;
        totalPrice.value = subTotalPrice.value + combinedGst.value + platformFee.value;
        isRated.value = orderDetailsModel!.isRated!;
        getCancelTime();

        // Start continuous 5-minute cancel countdown from order creation time
        try {
          final createdDate = orderDetailsModel!.createdDate?.trim();
          final createdTime = orderDetailsModel!.createdTime?.trim();
          if (createdDate != null && createdTime != null && createdDate.isNotEmpty && createdTime.isNotEmpty) {
            // Normalize cases like "16:04 PM" -> "04:04 PM" (API sometimes sends 24h with AM/PM)
            String timeStr = createdTime;
            final parts = timeStr.split(':');
            if (parts.isNotEmpty) {
              final hour = int.tryParse(parts[0]) ?? 0;
              if (hour > 12) {
                timeStr = '${(hour - 12).toString().padLeft(2, '0')}:${parts[1]}';
              }
            }
            debugPrint('Parsed timeStr: $timeStr');
            // Parse using expected format: e.g., "Sep 02,2025 04:04 PM"
            final createdAt = DateFormat('MMM dd,yyyy hh:mm a').parse('$createdDate $timeStr');
                        debugPrint('Parsed createdAt: $createdAt');
            startCancelTimer(createdAt, const Duration(minutes: 5));
          }
        } catch (_) {
          // ignore parsing issues
        }
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

    // Align ticks to wall-clock seconds to keep animation smooth and consistent
    void scheduleTick() {
      final now = DateTime.now();
      final elapsed = now.difference(createdAt).inSeconds;
      final secondsLeft = maxDuration.inSeconds - elapsed;
      remainingSeconds.value = secondsLeft <= 0 ? 0 : secondsLeft;
      if (remainingSeconds.value <= 0) {
        cancelTimer?.cancel();
        cancelTimer = null;
        return;
      }
      final int msToNextSecond = 1000 - now.millisecond;
      cancelTimer = Timer(Duration(milliseconds: msToNextSecond), scheduleTick);
    }

    scheduleTick();
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
