import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/shared/progress_dialog.dart';
import 'package:image_picker/image_picker.dart';

import '../../infrastructure/constants/app_constants.dart';
import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/models/user_model.dart';
import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/pref_manager.dart';

import 'package:dio/dio.dart' as dioSuffix;

class EditProfileController extends GetxController {
  var nameController = TextEditingController();

  var number = ''.obs;
  var countryCode = ''.obs;
  var countryId = ''.obs;
  var email = ''.obs;
  var socialId = ''.obs;

  var loginType = ''.obs;

  var isNumberUpdate = false.obs;
  var isNameUpdate = false.obs;
  var isEmailUpdate = false.obs;
  var isProfileUpdate = false.obs;
  var isFillColor = false.obs;

  var imageLoading = false.obs;
  var imageFile = ''.obs;
  var compressImageFile = ''.obs;
  var imageNetworkFile = ''.obs;
  var userId = Rx(-1);

  @override
  void onInit() {
    Future.delayed(Duration.zero, () {
      getUserData();
    });
    super.onInit();
  }

  getUserData() async {
    var currentUser = await PrefManager.getUser();
    if (currentUser != null) {
      userId.value = currentUser.id!;
      nameController.text = currentUser.username ?? '';
      countryCode.value = currentUser.countryCode.toString();
      countryId.value = currentUser.countryId.toString();
      number.value = currentUser.mobile.toString();
      loginType.value = currentUser.loginType ?? '';
      socialId.value = currentUser.socialId ?? '';
      email.value = currentUser.email ?? '';
      imageNetworkFile.value = currentUser.profile ?? '';
    }
  }

  pickImage(ImageSource imageSource) async {
    var date = DateTime.now();
    String imgPath = date.millisecondsSinceEpoch.toString();
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: imageSource);
    print('picked image');
    if (image!.path.isNotEmpty) {
      imageLoading.value = true;
      imageNetworkFile.value = '';
      imageFile.value = image.path;
      print(imageFile.value);
      isProfileUpdate.value = true;
      checkFillOrNot();
      compressImageFile.value = await compressImage(imageFile.value);
      Future.delayed(const Duration(milliseconds: 500), () {
        imageLoading.value = false;
      });
      compressImageFile.value = await compressImage(image.path);
    }
  }

  onTapCamera() async {
    Get.back();
    try {
      var camera = await availableCameras();
      var result = await Get.toNamed(Routes.customCamera, arguments: camera);
      if (result != null) {
        imageLoading.value = true;
        imageNetworkFile.value = '';
        imageFile.value = result[0];
        print(imageFile.value);
        isProfileUpdate.value = true;
        checkFillOrNot();
        compressImageFile.value = await compressImage(imageFile.value);
        Future.delayed(const Duration(milliseconds: 500), () {
          imageLoading.value = false;
        });
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          imageLoading.value = false;
        });
      }
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 500), () {
        imageLoading.value = false;
      });
    }
  }

  onTapGallery() async {
    Get.back();
    try {
      var picker = await ImagePicker().pickImage(source: ImageSource.gallery,imageQuality: 60);
      if (picker != null && (picker.path.isNotEmpty)) {
        imageNetworkFile.value = '';
        imageFile.value = picker.path;
        imageLoading.value = true;
        isProfileUpdate.value = true;
        compressImageFile.value = imageFile.value;
        checkFillOrNot();
        Future.delayed(const Duration(milliseconds: 500), () {
          imageLoading.value = false;
        });
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          imageLoading.value = false;
        });
      }
    } catch (e) {
      Future.delayed(const Duration(seconds: 500), () {
        imageLoading.value = false;
      });
    }
  }

  checkFillOrNot() {

    if (isNameUpdate.value && isNumberUpdate.value && isProfileUpdate.value && isEmailUpdate.value) {
      if (nameController.text.trim().isEmpty && number.isEmpty && email.isEmpty && imageFile.isEmpty) {
        isFillColor.value = false;
      } else {
        isFillColor.value = true;
      }
    } else if (isNameUpdate.value && isNumberUpdate.value && isProfileUpdate.value) {
      if (nameController.text.trim().isEmpty && number.isEmpty && imageFile.isEmpty) {
        isFillColor.value = false;
      } else {
        isFillColor.value = true;
      }
    } else if (isNameUpdate.value && isNumberUpdate.value) {
      if (nameController.text.trim().isEmpty && number.isEmpty) {
        isFillColor.value = false;
      } else {
        isFillColor.value = true;
      }
    } else if (isNameUpdate.value) {
      if (nameController.text.trim().isEmpty) {
        isFillColor.value = false;
      } else {
        isFillColor.value = true;
      }
    } else if (isNumberUpdate.value) {
      if (number.isEmpty) {
        isFillColor.value = false;
      } else {
        isFillColor.value = true;
      }
    } else if (isProfileUpdate.value) {
      if (imageFile.isEmpty) {
        isFillColor.value = false;
      } else {
        isFillColor.value = true;
      }
    } else if (isEmailUpdate.value) {
      if (email.isEmpty) {
        isFillColor.value = false;
      } else {
        isFillColor.value = true;
      }
    } else {
      isFillColor.value = false;
    }
  }

  compressImage(imagePath,) async {
    try {
      final dir = Directory.systemTemp;;
      final targetPath = "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

      var compressedFile = await FlutterImageCompress.compressAndGetFile(imagePath, targetPath, quality: 90);
      print(compressedFile != null ? compressedFile.path : '');
      return compressedFile != null ? compressedFile.path : imagePath;
    } catch (e) {
      return imagePath;
    }
  }

  updateUser() async {
    var progressDialog = ProgressDialog();
    progressDialog.show();
    var accessToken = await PrefManager.getString(AppConstants.accessToken);
    print("accessToken  $accessToken");
    try {
      Map<String, dynamic> params = {};
      if (isNameUpdate.value) {
        params['username'] = nameController.text;
      }
      if (isNumberUpdate.value) {
        params['mobile'] = number.value;
        params['country_code'] = countryCode.value;
      }
      if (isEmailUpdate.value) {
        params['email'] = email.value;
      }
      dioSuffix.FormData fParams = dioSuffix.FormData.fromMap(params);
      if (isProfileUpdate.value) {
        print("compressImageFile ${compressImageFile.value}");

        fParams.files.add(MapEntry('profile', dioSuffix.MultipartFile.fromFileSync(compressImageFile.value)));
      }
      ApiResponseModel<UserModel> userModel = await DioClient.multipartBase(accessToken: accessToken).funUpdateAccountApi(fParams);
      if (userModel.success! && userModel.data != null && userModel.data!.user != null) {
        progressDialog.dismiss();
        PrefManager.putString(AppConstants.userProfile, json.encode(userModel.data!.user!));
        Get.back(result: true);
      } else {
        progressDialog.dismiss();
        errorScreen(error: userModel.message!);
      }
    } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      errorScreen(error: handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
    } catch (e) {
      print(e);
      progressDialog.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }
}
