import 'package:get/get.dart';
import 'package:good_grab/infrastructure/models/order_cancel_reasons_model.dart';
import 'package:good_grab/infrastructure/shared/progress_dialog.dart';
import 'package:image_picker/image_picker.dart';

import '../../infrastructure/constants/app_constants.dart';
import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/pref_manager.dart';

import 'package:dio/dio.dart' as dio;

class OrderCancelController extends GetxController {
  var selectReason = Rx(-1);

  var reasonList = <CancelReasons>[].obs;
  var isLoadingData = false.obs;

  var orderId = 0;
  var amount = (0.0);
  var resId = 0;

  var pickupDate;
  var pickupTime;
  var pickupEndTime;
  var is2HoursLess = true.obs;
  var orderStatus = ''.obs;

  @override
  void onInit() {
    orderId = Get.arguments['orderId'];
    amount = Get.arguments['amount'];
    resId = Get.arguments['resId'];
    pickupDate = Get.arguments['pickupDate'];
    pickupTime = Get.arguments['pickupTime'];
    pickupEndTime = Get.arguments['pickupEndTime'];
    orderStatus.value = (Get.arguments['orderStatus'] ?? '').toString();
    getCancelTime();
    Future.delayed(Duration.zero, () async {
      await getOrderCancelReasons();
    });
    super.onInit();
  }

  getOrderCancelReasons() async {
    isLoadingData.value = true;
    reasonList.clear();
    var accessToken = await PrefManager.getString(AppConstants.accessToken);
    try {
      ApiResponseModel<OrderCancelReasonsModel> reasonModel =
          await DioClient.base(accessToken: accessToken)
              .funGetOrderCancelReasonsApi();
      if (reasonModel.success! &&
          reasonModel.data != null &&
          reasonModel.data!.cancelReasons != null) {
        isLoadingData.value = false;
        reasonList.addAll(reasonModel.data!.cancelReasons!);
      } else {
        isLoadingData.value = false;
      }
    } on CustomHttpException catch (exception) {
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
      isLoadingData.value = false;
    } catch (exception) {
      isLoadingData.value = false;
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  getImage(index, source) async {
    try {
      var picker =
          await ImagePicker().pickImage(source: source, imageQuality: 60);
      if (picker != null && (picker.path.isNotEmpty)) {
        reasonList[index].reasonImage = picker.path;
        reasonList.refresh();
      }
    } catch (e) {
      print(e);
    }
  }

  funCancelOrder() async {
    var progressDialog = ProgressDialog();
    progressDialog.show();
    var accessToken = await PrefManager.getString(AppConstants.accessToken);
    try {
      Map<String, dynamic> params = {
        'order_id': orderId,
        'restaurant_id': resId,
        'amount': amount,
        'reason_id': reasonList[selectReason.value].id
      };
      print(params);
      dio.FormData formData = dio.FormData.fromMap(params);
      if (reasonList[selectReason.value].reasonImage != null &&
          reasonList[selectReason.value].reasonImage!.isNotEmpty) {
        print(params);
        var file = dio.MultipartFile.fromFileSync(
            reasonList[selectReason.value].reasonImage!);
        formData.files.add(MapEntry("refund_image", file));
      }
      ApiResponseModel orderCancelModel =
          await DioClient.multipartBase(accessToken: accessToken)
              .funOrderCancelApi(formData);
      if (orderCancelModel.success!) {
        progressDialog.dismiss();
        return true;
      } else {
        progressDialog.dismiss();
        errorScreen(error: orderCancelModel.message!);
        return false;
      }
    } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
      return false;
    } catch (exception) {
      print(exception);
      progressDialog.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
      return false;
    }
  }

  getCancelTime() {
    DateTime currentTime = DateTime.now();
    //before
    // DateTime pickupDateTime = DateTime.parse("$pickupDate $pickupEndTime");
    //after code change
    DateTime pickupDateTime = DateTime.parse("$pickupDate $pickupTime");

    Duration timeDifference = pickupDateTime.difference(currentTime);
    is2HoursLess.value = timeDifference.inMinutes < 121;
  }
}
