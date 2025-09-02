import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/models/country_model.dart';
import 'package:good_grab/infrastructure/shared/firebase_messaging.dart';
import 'package:good_grab/infrastructure/shared/progress_dialog.dart';

import '../../infrastructure/constants/app_constants.dart';
import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/common_functions.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/pref_manager.dart';
import '../../infrastructure/shared/snackbar.util.dart';
import '../../infrastructure/theme/colors.theme.dart';
import '../../infrastructure/theme/text.theme.dart';

class LoginController extends GetxController {
  ProgressDialog progressDialog = ProgressDialog();

  var nameController = TextEditingController();
  var numberController = TextEditingController();
  var emailAddressController = TextEditingController();
  var searchController = TextEditingController();

  var isFillColor = false.obs;
  var isSearch = false.obs;

  var screenType = ''.obs;
  var selectedCountryCode = "91".obs;

  var countryList = <CountryList>[].obs;
  var searchCountriesList = <CountryList>[].obs;
  var countryCode = '91'.obs;
  var countryName = 'India'.obs;
  var checkNumberValid = false.obs;
  var checkEmailValid = false.obs;

  @override
  void onInit() {
    screenType.value = Get.arguments['screenType'];
    Future.delayed(Duration.zero, () async {
      await getFcmToken();
      await getCountryList();
    });
    super.onInit();
  }

  // onChangeText(text) {
  //   changeButtonColor();
  // }

  onTapRegister() async {
    screenType.value = "signup";
    if (numberController.text.isNotEmpty) {
      checkNumberValid.value = false;
      await isCheckNumberApi('mobile');
    }
  }

  changeButtonColor() {
    if (screenType.value == 'signup') {
      if (nameController.text.trim().isEmpty ||
          numberController.text.trim().isEmpty ||
          // emailAddressController.text.isEmpty ||
          // !isEmailValid(emailAddressController.text.trim()) ||
          // checkEmailValid.value == false ||
          checkNumberValid.value == false) {
        isFillColor.value = false;
      } else {
        isFillColor.value = true;
      }
    } else {
      if (numberController.text.trim().isEmpty) {
        isFillColor.value = false;
      } else {
        isFillColor.value = true;
      }
    }
  }

  /// Getting Country List Data
  Future getCountryList() async {
    try {
      ApiResponseModel<CountryModel> countryModel =
          await DioClient.base().funGetCountriesApi();
      if (countryModel.success!) {
        if (countryModel.data != null) {
          countryList.addAll(countryModel.data!.countryList!);
        }
      }
    } on CustomHttpException catch (exception) {
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      progressDialog.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
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
        return user.country
            .toString()
            .toLowerCase()
            .contains(value.toString().toLowerCase());
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

  isValid(context) {
    CommonFunction.keyboardDismiss(context);
    if (screenType.value == 'signup') {
      if (nameController.text.trim().isEmpty) {
        SnackBarUtil.showError(message: 'Enter name');
      } else if (numberController.text.trim().isEmpty) {
        SnackBarUtil.showError(message: 'Enter number');
      } else if (checkNumberValid.value == false) {
        SnackBarUtil.showError(
            message:
                'The number you entered already exists. Please proceed to Log in');
      }
      // else if (emailAddressController.text.trim().isEmpty) {
      //   SnackBarUtil.showError(message: 'Enter email');
      // } else if (!isEmailValid(emailAddressController.text.trim())) {
      //   SnackBarUtil.showError(message: 'Enter a valid email');
      // }else if (checkEmailValid.value == false) {
      //   SnackBarUtil.showError(message: 'The email you entered already exists. Please proceed to Log in');
      // }
      else if (emailAddressController.text.trim().isNotEmpty &&
          checkEmailValid.value == false) {
        SnackBarUtil.showError(message: 'Enter a valid email');
      } else {
        onContinue(context);
      }
    } else {
      if (numberController.text.trim().isEmpty) {
        SnackBarUtil.showError(message: 'Enter number');
      } else {
        checkLoginByApi(context);
      }
    }
  }

  bool isEmailValid(String email) {
    // Regular expression for email validation
    final emailRegex = RegExp(r'^[\w-\.]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    //final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return emailRegex.hasMatch(email);
  }

  /// check number is exit or not
  isCheckNumberApi(type) async {
    try {
      Map<String, dynamic> params = {};
      if (type == 'mobile') {
        params['type'] = "mobile";
        params['source'] = numberController.text;
      } else {
        params['type'] = "email";
        params['source'] = emailAddressController.text;
      }

      ApiResponseModel baseModel =
          await DioClient.base().funIsEmailNumberApi(params);
      if (baseModel.success!) {
        if (type == 'mobile') {
          checkNumberValid.value = true;
        } else {
          checkEmailValid.value = true;
        }
      } else {
        if (type == 'mobile') {
          checkNumberValid.value = false;
        } else {
          checkEmailValid.value = false;
        }
      }
      changeButtonColor();
    } on CustomHttpException catch (_) {
      if (type == 'mobile') {
        checkNumberValid.value = false;
      } else {
        checkEmailValid.value = false;
      }
      changeButtonColor();
    } catch (_) {
      if (type == 'mobile') {
        checkNumberValid.value = false;
      } else {
        checkEmailValid.value = false;
      }
      changeButtonColor();
    }
  }

  checkLoginByApi(context) async {
    print('Update');
    ProgressDialog progressDialog = ProgressDialog();
    progressDialog.show();
    Map<String, dynamic> apiParams = {};
    apiParams['type'] = "mobile";
    apiParams['source'] = numberController.text;
    try {
      ApiResponseModel baseModel =
          await DioClient.base().funIsEmailNumberApi(apiParams);

      if (baseModel.success!) {
        FirebaseAnalytics analytics = FirebaseAnalytics.instance;

        analytics.logEvent(
          name: 'login',
          parameters: {'method': 'email'},
        );
        progressDialog.dismiss();
        Future.delayed(const Duration(milliseconds: 500), () {
          userNotRegisteredBottomSheet();
        });
      } else {
        progressDialog.dismiss();
        Future.delayed(const Duration(milliseconds: 500), () {
          onContinue(context);
        });
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

  onContinue(context) async {
    var appVersion = await CommonFunction.getVersionDetails();
    var fcmToken = await PrefManager.getString(AppConstants.fcmToken);

    CommonFunction.keyboardDismiss(context);
    Map<String, dynamic> params = {};
    params['mobile'] = numberController.text.trim();
    params['device_type'] = CommonFunction.getDeviceType();
    params['login_type'] = 'mobile';
    params['device_token'] = fcmToken;
    params['country_code'] = countryCode.value;
    params['country_id'] = countryName.value;
    params['version'] = appVersion;
    if (screenType.value == 'signup') {
      params['username'] = nameController.text.trim();
      params['email'] = emailAddressController.text.trim();
    }
    Get.toNamed(Routes.otpVerify,
        arguments: {'screenType': screenType.value, 'params': params});
  }

  /// Change by client 9feb
  userNotRegisteredBottomSheet() {
    return Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
            color: ColorsTheme.colWhite,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'You need to register now'.tr,
                    style: boldTextStyle(
                        fontSize: dimen15, color: ColorsTheme.colBlack),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'app_name'.tr,
                          style: regularTextStyle(
                              fontSize: dimen15, color: ColorsTheme.colBlack),
                        ),
                        TextSpan(
                          text: 'Registered First'.tr,
                          style: regularTextStyle(
                              fontSize: dimen12, color: ColorsTheme.colBlack),
                        )
                      ]),
                    )),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: ColorsTheme.colBlack, width: 1),
                              borderRadius: BorderRadius.circular(40)),
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Cancel'.tr,
                            style: semiBoldTextStyle(
                                fontSize: dimen13, color: ColorsTheme.colBlack),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          onTapRegister();
                          Get.back();
                          print(screenType.value);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 15),
                          decoration: BoxDecoration(
                              color: ColorsTheme.colPrimary,
                              borderRadius: BorderRadius.circular(40)),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          alignment: Alignment.center,
                          child: Text(
                            '${'Sign up Now'.tr} →',
                            style: semiBoldTextStyle(
                                fontSize: dimen13, color: ColorsTheme.colWhite),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
