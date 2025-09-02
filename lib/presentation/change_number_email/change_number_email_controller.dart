import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/models/country_model.dart';
import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/progress_dialog.dart';

class ChangeNumberEmailController extends GetxController{

  String title = '';
  var isSearch = false.obs;

  var screenType = '';

  var selectedCountryCode = "91".obs;
  var countryList = <CountryList>[].obs;
  var searchCountriesList = <CountryList>[].obs;
  var countryCode = '91'.obs;
  var countryName = 'India'.obs;
  var searchController = TextEditingController();

  var emailController = TextEditingController();
  var numberController = TextEditingController();

  var isFillColor = false.obs;

  @override
  void onInit() {
    screenType = Get.arguments['screenType'];
    title = Get.arguments['title'];
    Future.delayed(Duration.zero,() async {
      if(screenType != 'email'){
        await getCountryList();
      }
    });
    super.onInit();
  }

  Future getCountryList() async {
    try {
      ApiResponseModel<CountryModel> countryModel = await DioClient.base().funGetCountriesApi();
      if (countryModel.success!) {
        if (countryModel.data != null) {
          countryList.addAll(countryModel.data!.countryList!);
        }
      }
      else{
        errorScreen(error:  'something_went_wrong'.tr);
      }
    } on CustomHttpException catch (exception) {
      errorScreen(error:handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
    } catch (exception) {
      errorScreen(error:  'something_went_wrong'.tr);
    }
  }

  ///Select And Search Country Code Methods
  selectCountryCode(index) {
    selectedCountryCode.value = countryList[index].dialingCode!;
    countryName.value = countryList[index].country!;
    Get.back();
  }

  selectSearchCode(index) {
    selectedCountryCode.value = searchCountriesList[index].dialingCode!;
    searchCountriesList.value = [];
    isSearch.value = false;
    searchController.clear();
    refresh();
    Get.back();
  }

  getSearchCountriesList(value) {
    if (value.toString().isEmpty) {
      isSearch.value = false;
      searchController.clear();
      refresh();
    } else {
      searchCountriesList.value = countryList.where((user) {
        return user.country.toString().toLowerCase().contains(value.toString().toLowerCase());
      }).toList();
      searchCountriesList.refresh();
      isSearch.value = true;
      update();
    }
  }

  clearSearchData() {
    searchController.text = '';
    isSearch.value = false;
    searchCountriesList.clear();
    searchCountriesList.refresh();
  }

  isCheckNumberAndEmailApi() async {
    ProgressDialog progressDialog = ProgressDialog();
    progressDialog.show();
    try {
      Map<String,dynamic> params = {};
      if(screenType == 'number') {
        params['type'] = "mobile";
        params['source'] = numberController.text;
      }
      else{
        params['type'] = "email";
        params['source'] = emailController.text;
      }
      ApiResponseModel baseModel =  await DioClient.base().funIsEmailNumberApi(params);
      if(baseModel.success!){
        progressDialog.dismiss();
        Map<String,dynamic> params1 = {};
        params1['mobile'] =  numberController.text.trim();
        params1['login_type'] = screenType;
        params1['country_code'] = countryCode.value;
        params1['country_id'] = countryName.value;
        params1['email'] =  emailController.text.trim();
        Future.delayed(const Duration(milliseconds: 500),(){
          Get.toNamed(Routes.otpVerify, arguments: {
            'screenType': 'change',
            'params' : params1
          });
        });
      }
      else{
        progressDialog.dismiss();
      errorScreen(error:  baseModel.message!);
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