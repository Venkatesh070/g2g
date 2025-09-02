import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../infrastructure/constants/app_constants.dart';
import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/models/notification_model.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/pref_manager.dart';

class NotificationController extends GetxController {
  var isLoadingData = false.obs;
  var notificationData = <NotificationData>[].obs;
  var pagingListController = ScrollController();
  var page = 1.obs;
  var totalPage = 1.obs;
  var currentPage = 1.obs;
  var isPageLoad = false.obs;

  @override
  void onInit() {
    listScrollListener();
    Future.delayed(Duration.zero, () async {
      notificationData.clear();
      isLoadingData.value = true;
      await getNotificationReasons();
    });
    super.onInit();
  }

  ///paging
  listScrollListener() {
    pagingListController.addListener(() {
      if (pagingListController.position.pixels == pagingListController.position.maxScrollExtent) {
        print('listnerCalled>>>>');
        isPageLoad.value = true;
        loadNextPage();
      }
    });
  }

  void loadNextPage() {
    if (totalPage.value != page.value) {
      currentPage.value = page.value + 1;
      getNotificationReasons();
      // markers.refresh();
    } else {
      isPageLoad.value = false;
    }
  }

  getNotificationReasons() async {
    // isLoadingData.value = true;
    var accessToken = await PrefManager.getString(AppConstants.accessToken);
    try {
      Map<String, dynamic> params = {'page': currentPage.value};
      ApiResponseModel<NotificationResponseModel> reasonModel =
          await DioClient.base(accessToken: accessToken).funGetNotificationReasonsApi(params);
      if (reasonModel.success! && reasonModel.data != null) {
        isLoadingData.value = false;
        isPageLoad.value = false;
        notificationData.addAll(reasonModel.data!.data!);
        totalPage.value = reasonModel.data!.lastPage!;
        page.value = reasonModel.data!.currentPage!;
      } else {
        isLoadingData.value = false;
        isPageLoad.value = false;
      }
    } on CustomHttpException catch (exception) {
      errorScreen(
          error: handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
      isLoadingData.value = false;
      isPageLoad.value = false;
    } catch (exception) {
      isLoadingData.value = false;
      isPageLoad.value = false;
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }
}
