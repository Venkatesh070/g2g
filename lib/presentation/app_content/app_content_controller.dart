import 'package:get/get.dart';
import 'package:good_grab/infrastructure/models/app_content_model.dart';


import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/http_exception.dart';


class AppContentController extends GetxController {

  String title = '';
  String flag = '';

  var email = ''.obs;
  var phoneNumber = ''.obs;

  var helpList = <HelpCenter>[].obs;

  var htmlContent = ''.obs;
  var isLoadData = true.obs;

  @override
  void onInit() {
    title = Get.arguments['title'];
    flag = Get.arguments['flag'];
    Future.delayed(Duration.zero,() async {
      await getAppContentData();
    });
    super.onInit();
  }

  getAppContentData() async {
    try {
      helpList.clear();
      ApiResponseModel<AppContentModel> appContentModel = await DioClient.base().funAppContentApi();
      if (appContentModel.success! && appContentModel.data != null && appContentModel.data!.content != null) {
        if(flag == 'help'){
          if(appContentModel.data!.content!.helpCenter != null){
            helpList.addAll(appContentModel.data!.content!.helpCenter!);
          }
        }
        else if(flag == 'contact'){
          if(appContentModel.data!.content!.contactUs != null){
            phoneNumber.value = appContentModel.data!.content!.contactUs!.mobile??'';
            email.value = appContentModel.data!.content!.contactUs!.email??'';
          }
        }
        else if(flag == 'about'){
          if(appContentModel.data!.content!.aboutus != null){
            htmlContent.value = appContentModel.data!.content!.aboutus!.content??'';
          }
        }
        else if(flag == 'term'){
          if(appContentModel.data!.content!.termsAndCondition != null){
            htmlContent.value = appContentModel.data!.content!.termsAndCondition!.content??'';
          }
        }
        else if(flag == 'privacy'){
          if(appContentModel.data!.content!.privacyPolicy != null){
            htmlContent.value = appContentModel.data!.content!.privacyPolicy!.content??'';
          }
        }
      }
      else{
        errorScreen(error:  'something_went_wrong'.tr);
      }
      Future.delayed(const Duration(milliseconds: 500),(){
        isLoadData.value = false;
      });
    } on CustomHttpException catch (exception) {
      isLoadData.value = false;
      errorScreen(error:handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
    } catch (exception) {
      isLoadData.value = false;
      errorScreen(error:  'something_went_wrong'.tr);
    }
  }



}

