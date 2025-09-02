import 'package:get/get.dart';

import '../../infrastructure/constants/app_constants.dart';
import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/pref_manager.dart';
import '../../infrastructure/shared/progress_dialog.dart';

class AppSettingController extends GetxController{

  var isLoggedIn = false;
  var userId = 0;

  @override
  void onInit() {
    isLoggedIn = Get.arguments['isLoggedIn'];
    userId = Get.arguments['userId'];
    super.onInit();
  }

  deleteAccountApi() async {
    ProgressDialog progressDialog = ProgressDialog();
    progressDialog.show();
    try {
      Map<String,dynamic> params = {
        'user_id' : userId,
      };
      ApiResponseModel baseModel =  await DioClient.base().funDeleteAccountApi(params);
      if(baseModel.success!){

        PrefManager.remove(AppConstants.deviceId);
        PrefManager.remove(AppConstants.userProfile);
        PrefManager.remove(AppConstants.userId);
        PrefManager.remove(AppConstants.accessToken);
        PrefManager.remove(AppConstants.cartId);
        PrefManager.putBool(AppConstants.loggedIn, false);
        progressDialog.dismiss();
        Get.offAllNamed(Routes.intro);
      }
      else{
        progressDialog.dismiss();
        errorScreen(error:  'something_went_wrong'.tr);
      }
    } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      errorScreen(error:handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
    } catch (exception) {
      progressDialog.dismiss();
      errorScreen(error:  'something_went_wrong'.tr);
    }
  }
}