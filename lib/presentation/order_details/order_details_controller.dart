import 'dart:async';

import 'package:get/get.dart';
import 'package:good_grab/infrastructure/models/order_details_model.dart';
import 'package:good_grab/infrastructure/models/app_content_model.dart';
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
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:typed_data';

class OrderDetailsController extends GetxController {
  var orderStatus = ''.obs;
  var loadingData = true.obs;
  var is2HoursLess = true.obs;
  var isOrderData = false.obs;
  var orderId = 0;
  var resId = 0;
  var currency = '';
  var pickupCode = 0000.obs;

  //Pickup countdown Timer
  var isCountingToStart = false.obs;
  var pickupRemainingSeconds = 0.obs;
  var pickupTotalSeconds = 0.obs;
  Timer? pickupTimer;

  var backResult = false.obs;

  OrderDetailsModel? orderDetailsModel;

  // Support contact details
  var supportEmail = ''.obs;
  var supportPhone = ''.obs;

  var subTotalPrice = (0.0).obs;
  var subTotalOfferPrice = (0.0).obs;
  var otherTotalPrice = (0.0).obs;
  var combinedGst = (0.0).obs;
  var platformGst = (0.0).obs;
  var platformFee = (0.0).obs;
  var totalPrice = (0.0).obs;

  // order cancel


  var pickupDate;
  var pickupTime;
  var pickupEndTime;

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
      await _loadSupportContact();
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
        subTotalPrice.value =
            double.parse(orderModel.data!.totalPaid.toString());
        subTotalOfferPrice.value =
            double.parse(orderModel.data!.price.toString());
        otherTotalPrice.value =
            double.parse(orderModel.data!.gstCharge.toString());
        pickupCode.value = orderModel.data!.pickupCode!;
        platformFee.value =
            await PrefManager.getDouble(AppConstants.platformFee);
        platformGst.value =
            await PrefManager.getDouble(AppConstants.platformGst);
        combinedGst.value = otherTotalPrice.value + platformGst.value;
        totalPrice.value =
            subTotalPrice.value + combinedGst.value + platformFee.value;
        isRated.value = orderDetailsModel!.isRated!;
        getCancelTime();
        // getCancelOrderTime();

        // Start continuous 5-minute cancel countdown from order creation time
        try {
          final createdDate = orderDetailsModel!.createdDate?.trim();
          final createdTime = orderDetailsModel!.createdTime?.trim();
          if (createdDate != null &&
              createdTime != null &&
              createdDate.isNotEmpty &&
              createdTime.isNotEmpty) {
            // Normalize cases like "16:04 PM" -> "04:04 PM" (API sometimes sends 24h with AM/PM)
            String timeStr = createdTime;
            final parts = timeStr.split(':');
            if (parts.isNotEmpty) {
              final hour = int.tryParse(parts[0]) ?? 0;
              if (hour > 12) {
                timeStr =
                    '${(hour - 12).toString().padLeft(2, '0')}:${parts[1]}';
              }
            }
            // Parse using expected format: e.g., "Sep 02,2025 04:04 PM"
            final createdAt = DateFormat('MMM dd,yyyy hh:mm a')
                .parse('$createdDate $timeStr');
            startCancelTimer(createdAt, const Duration(minutes: 5));
          }
        } catch (_) {
          // ignore parsing issues
        }

        // Countdown timer Call
        if (orderStatus.value == 'pending_pick_up') {
          startPickupCountdown();
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

  Future<void> _loadSupportContact() async {
    try {
      ApiResponseModel<AppContentModel> appContentModel =
          await DioClient.base().funAppContentApi();
      final contact = appContentModel.data?.content?.contactUs;
      if (appContentModel.success == true && contact != null) {
        supportEmail.value = contact.email ?? '';
        supportPhone.value = contact.mobile ?? '';
      }
    } catch (_) {
      // no-op
    }
  }

  Future<void> launchSupportEmail() async {
    final email = supportEmail.value.trim();
    final uri = email.isEmpty
        ? Uri(scheme: 'mailto')
        : Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      errorScreen(error: 'Could not open the mail app.'.tr);
    }
  }

  Future<void> launchSupportPhone() async {
    final phone = supportPhone.value.trim();
    final uri = phone.isEmpty
        ? Uri(scheme: 'tel')
        : Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      errorScreen(error: 'Could not open the phone app.'.tr);
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

// Countdown timer logic
// Add this method to calculate pickup countdown
// order_details_controller.dart
// order_details_controller.dart
void startPickupCountdown() {
  final pickupDate = orderDetailsModel?.pickupDate;
  final pickupTime = orderDetailsModel?.pickupTime;
  final pickupEndTime = orderDetailsModel?.pickupEndTime;

  if (pickupDate == null || pickupTime == null || pickupEndTime == null) return;

  try {
    // Parse dates using the new method
    final now = DateTime.now();
    final pickupDateTime = CommonFunction.parsePickupDateTime(pickupDate, pickupTime);
    final pickupEndDateTime = CommonFunction.parsePickupDateTime(pickupDate, pickupEndTime);

    // Determine which countdown to show
    if (now.isBefore(pickupDateTime)) {
      // Countdown to pickup start
      isCountingToStart.value = true;
      pickupTotalSeconds.value = pickupDateTime.difference(now).inSeconds;
      pickupRemainingSeconds.value = pickupTotalSeconds.value.clamp(0, pickupTotalSeconds.value);
    } else if (now.isBefore(pickupEndDateTime)) {
      // Countdown to pickup end
      isCountingToStart.value = false;
      pickupTotalSeconds.value = pickupEndDateTime.difference(now).inSeconds;
      pickupRemainingSeconds.value = pickupTotalSeconds.value.clamp(0, pickupTotalSeconds.value);
    } else {
      // Pickup time has passed
      isCountingToStart.value = false;
      pickupRemainingSeconds.value = 0;
      pickupTotalSeconds.value = 1;
    }

    // Start timer to update countdown
    pickupTimer?.cancel();
    pickupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (pickupRemainingSeconds.value > 0) {
        pickupRemainingSeconds.value--;
      } else {
        // Check if we need to switch from start to end countdown
        final now = DateTime.now();
        if (now.isAfter(pickupDateTime) && now.isBefore(pickupEndDateTime)) {
          isCountingToStart.value = false;
          pickupTotalSeconds.value = pickupEndDateTime.difference(now).inSeconds;
          pickupRemainingSeconds.value = pickupTotalSeconds.value.clamp(0, pickupTotalSeconds.value);
        } else {
          timer.cancel();
        }
      }
    });
  } catch (e) {
    print('Error parsing pickup time: $e');
  }
}
// Don't forget to cancel the timer in onClose()


  @override
  void onClose() {
    cancelTimer?.cancel();
    pickupTimer?.cancel();
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


  // funCancelOrder() async {
  //   var progressDialog = ProgressDialog();
  //   progressDialog.show();
  //   var accessToken = await PrefManager.getString(AppConstants.accessToken);
  //   try {
  //     Map<String, dynamic> params = {
  //       'order_id': orderId,
  //       'restaurant_id': resId,
  //       'amount': totalPrice,
  //       // 'reason_id': reasonList[selectReason.value].id
  //     };
  //     print(params);
  //     ApiResponseModel orderCancelModel =
  //         await DioClient.multipartBase(accessToken: accessToken)
  //             .funOrderCancelApi(params);
  //     if (orderCancelModel.success!) {
  //       progressDialog.dismiss();
  //       return true;
  //     } else {
  //       progressDialog.dismiss();
  //       errorScreen(error: orderCancelModel.message!);
  //       return false;
  //     }
  //   } on CustomHttpException catch (exception) {
  //     progressDialog.dismiss();
  //     errorScreen(
  //         error: handleApiException(
  //             exception.code, exception.response, exception.exception,
  //             type: exception.type));
  //     return false;
  //   } catch (exception) {
  //     print(exception);
  //     progressDialog.dismiss();
  //     errorScreen(error: 'something_went_wrong'.tr);
  //     return false;
  //   }
  // }

Future<bool> funCancelOrder() async {
  final progressDialog = ProgressDialog();
  progressDialog.show();

  final accessToken = await PrefManager.getString(AppConstants.accessToken);

  try {
    // ✅ Only required fields
    final Map<String, dynamic> params = {

      'order_id': orderId,
      'restaurant_id': resId,
      'amount': totalPrice.value,
    };

    print("Request Data (JSON): ${params}");

    final ApiResponseModel orderCancelModel =
        await DioClient.base(accessToken: accessToken)
            .funOrderCancelApi(params); // send JSON body

    progressDialog.dismiss();

    if (orderCancelModel.success == true) {
      return true;
    } else {
      errorScreen(error: orderCancelModel.message ?? 'Failed to cancel order');
      return false;
    }
  } on CustomHttpException catch (exception) {
    progressDialog.dismiss();
    errorScreen(
      error: handleApiException(
        exception.code,
        exception.response,
        exception.exception,
        type: exception.type,
      ),
    );
    return false;
  } catch (exception) {
    print(exception);
    progressDialog.dismiss();
    errorScreen(error: 'something_went_wrong'.tr);
    return false;
  }
}

 funDownloadRefundInvoice() async {
    final progressDialog = ProgressDialog();
    progressDialog.show();
    var accessToken = await PrefManager.getString(AppConstants.accessToken);
    try {
      Map<String, dynamic> params = {'order_id': orderId};
      final ApiResponseModel<InvoiceModel> invoiceModel =
          await DioClient.base(accessToken: accessToken)
              .funDownloadRefundInvoiceApi(params);
      if (invoiceModel.success == true && invoiceModel.data != null) {
        print('success');
        String? pdfBase64 = invoiceModel.data!.pdfBase64;
        final String fileName = (invoiceModel.data!.fileName ?? 'invoice_${orderId}').toString();
        if (pdfBase64 == null || pdfBase64.isEmpty) {
          progressDialog.dismiss();
          errorScreen(error: 'Invoice data missing'.tr);
          return;
        }
        // Strip data URL prefix if present
        final int commaIndex = pdfBase64.indexOf(',');
        if (commaIndex > 0 && pdfBase64.substring(0, commaIndex).contains('base64')) {
          pdfBase64 = pdfBase64.substring(commaIndex + 1);
        }
        final Uint8List bytes = base64Decode(pdfBase64);
        await saveAndOpenPdf(bytes, fileName.endsWith('.pdf') ? fileName : '$fileName.pdf');
        progressDialog.dismiss();
        SnackBarUtil.showSuccess(message: 'Invoice downloaded'.tr);
      } else {
        progressDialog.dismiss();
        errorScreen(error: (invoiceModel.message ?? 'Failed to download invoice').tr);
      }
    } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      progressDialog.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  funDownloadInvoice() async {
    final progressDialog = ProgressDialog();
    progressDialog.show();
    var accessToken = await PrefManager.getString(AppConstants.accessToken);
    try {
      Map<String, dynamic> params = {'order_id': orderId};
      final ApiResponseModel<InvoiceModel> invoiceModel =
          await DioClient.base(accessToken: accessToken)
              .funDownloadInvoiceApi(params);
      if (invoiceModel.success == true && invoiceModel.data != null) {
        print('success');
        String? pdfBase64 = invoiceModel.data!.pdfBase64;
        final String fileName = (invoiceModel.data!.fileName ?? 'invoice_${orderId}').toString();
        if (pdfBase64 == null || pdfBase64.isEmpty) {
          progressDialog.dismiss();
          errorScreen(error: 'Invoice data missing'.tr);
          return;
        }
        // Strip data URL prefix if present
        final int commaIndex = pdfBase64.indexOf(',');
        if (commaIndex > 0 && pdfBase64.substring(0, commaIndex).contains('base64')) {
          pdfBase64 = pdfBase64.substring(commaIndex + 1);
        }
        final Uint8List bytes = base64Decode(pdfBase64);
        await saveAndOpenPdf(bytes, fileName.endsWith('.pdf') ? fileName : '$fileName.pdf');
        progressDialog.dismiss();
        SnackBarUtil.showSuccess(message: 'Invoice downloaded'.tr);
      } else {
        progressDialog.dismiss();
        errorScreen(error: (invoiceModel.message ?? 'Failed to download invoice').tr);
      }
    } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      progressDialog.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }



Future<void> saveAndOpenPdf(Uint8List pdfBytes, String fileName) async {
  try {
    Directory dir;

    if (Platform.isAndroid) {
      dir = (await getExternalStorageDirectory())!;
      dir = Directory('${dir.path.split("Android")[0]}Download');

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);

    await file.writeAsBytes(pdfBytes, flush: true);
    print('✅ PDF saved at: $filePath');

    await OpenFilex.open(filePath);
  } catch (e) {
    print('❌ Error saving/opening PDF: $e');
  }
}





// Future<void> funDownloadInvoice() async {
//   final String url = 'https://pdfobject.com/pdf/sample.pdf';
//   final String fileName = 'Invoice';
//   try {
//     Directory? dir;

//     if (Platform.isAndroid) {
//       // Get public Downloads folder
//       dir = await DownloadsPathProvider.downloadsDirectory;
//       if (dir == null) dir = await getApplicationDocumentsDirectory();
//     } else {
//       dir = await getApplicationDocumentsDirectory();
//     }

//     String path = '${dir.path}/$fileName.pdf';

//     // Download the PDF
//     Dio dio = Dio();
//     await dio.download(
//       url,
//       path,
//       onReceiveProgress: (received, total) {
//         if (total != -1) {
//           print('Downloading: ${(received / total * 100).toStringAsFixed(0)}%');
//         }
//       },
//     );

//     print('PDF saved at: $path');

//     // Open the PDF
//     await OpenFilex.open(path);
//   } catch (e) {
//     print('Download error: $e');
//   }
// }
// void funDownloadInvoice() async {
//   // Base64 representation of your PDF
//   String pdfBase64 = "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";
  
//   Uint8List pdfBytes = base64Decode(pdfBase64);

//   await saveAndOpenPdf(pdfBytes, "invoice_123");
// }



}



