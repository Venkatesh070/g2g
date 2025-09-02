import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/navigation/routes.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'package:good_grab/presentation/edit_profile/edit_profile_controller.dart';
import 'package:image_picker/image_picker.dart';

import '../../res.dart';

class EditProfilePage extends BaseView<EditProfileController> {
  EditProfilePage({super.key});

  @override
  Widget body(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: ColorsTheme.colBlack,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Edit Profile'.tr,
                      style: boldTextStyle(fontSize: dimen16, color: ColorsTheme.colBlack),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 30,
                )
              ],
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: (){
                    uploadProfileBottomSheet();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Obx(() => imageWidget(),)
                        ),
                        Text(
                          'Upload profile picture',
                          style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                        )
                      ],
                    ),
                  )
                ),
                nameWidget(),
                numberWidget(),
                emailWidget(),
                loginTypeWidget(),
                GestureDetector(
                    onTap: () {
                      if((controller.isNameUpdate.value || controller.isProfileUpdate.value || controller.isNumberUpdate.value || controller.isEmailUpdate.value) && controller.isFillColor.value ){
                        controller.updateUser();
                      }
                    },
                    child: Obx(
                      () => Container(
                        decoration: BoxDecoration(
                            color: (controller.isNameUpdate.value || controller.isProfileUpdate.value || controller.isNumberUpdate.value || controller.isEmailUpdate.value) && controller.isFillColor.value ? ColorsTheme.colPrimary : ColorsTheme.colSecondary,
                            borderRadius: BorderRadius.circular(50)),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        margin: const EdgeInsets.only(left: 28, right: 28, top: 40,bottom: 20),
                        child: Text(
                          'Save'.tr,
                          style: semiBoldTextStyle(
                              fontSize: dimen13,
                              color: (controller.isNameUpdate.value || controller.isProfileUpdate.value || controller.isNumberUpdate.value || controller.isEmailUpdate.value) && controller.isFillColor.value ? ColorsTheme.colWhite : ColorsTheme.colBlack),
                        ),
                      ),
                    )),
              ],
            ),
          )),
        ],
      ),
    );
  }

  nameWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Full Name'.tr,
            style: mediumTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              border: Border.all(
                color: ColorsTheme.colSecondary,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
            alignment: Alignment.center,
            child: TextField(
              controller: controller.nameController,
              onChanged: (value) {
                controller.isNameUpdate.value = true;
                controller.checkFillOrNot();
              },
              decoration: InputDecoration.collapsed(hintText: 'John Deo', hintStyle: mediumTextStyle(fontSize: dimen11, color: ColorsTheme.colHint)),
              style: mediumTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
            ),
          )
        ],
      ),
    );
  }

  numberWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mobile Number'.tr,
            style: mediumTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
          ),
          GestureDetector(
            onTap: () async {
              var result = await Get.toNamed(Routes.changeNumber,arguments:
              {'title' : controller.number.isEmpty ? '${'Add'.tr} ${'Mobile Number'.tr}' : '${'Change'.tr} ${'Mobile Number'.tr}','screenType':'number'});
              if(result != null){
                print(result);
                Map<String,dynamic> resultData = result as Map<String,dynamic>;
                controller.isNumberUpdate.value = true;
                controller.number.value = resultData['mobile'];
                controller.countryCode.value = resultData['country_code'];
                controller.countryId.value = resultData['country_id'];
                controller.checkFillOrNot();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorsTheme.colSecondary,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => Text(
                      controller.number.isEmpty ? '9999999999' : controller.countryCode.isNotEmpty&&controller.number.isNotEmpty?'+${controller.countryCode.value} ${controller.number.value}':'',
                      style: mediumTextStyle(fontSize: dimen11, color: controller.number.isEmpty ?ColorsTheme.colHint:ColorsTheme.colBlack),
                    )),
                  ),
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(36), color: ColorsTheme.colPrimary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: 80,
                    alignment: Alignment.center,
                    child: Obx(() => Text(
                          controller.number.isEmpty ? 'Add'.tr : 'Change'.tr,
                          style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colWhite),
                        )),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  emailWidget() {
    return Obx(() => Visibility(
      visible: controller.socialId.isEmpty ||
        controller.email.isNotEmpty,
      child: Container(
        margin: const EdgeInsets.only(top: 20, left: 18, right: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email'.tr,
              style: mediumTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
            ),
            GestureDetector(
              onTap: () async {
                if(controller.socialId.isEmpty){
                  var result = await Get.toNamed(Routes.changeNumber,arguments:
                  {'title' : controller.email.isEmpty ? '${'Add'.tr} ${'Email'.tr}' : '${'Change'.tr} ${'Email'.tr}','screenType':'email'});
                  if(result != null){
                    Map<String,dynamic> resultData = result as Map<String,dynamic>;
                    controller.isEmailUpdate.value = true;
                    controller.email.value = resultData['email'];
                    controller.checkFillOrNot();
                  }
                }
              },
              child: Container(
                margin: const EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorsTheme.colSecondary,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(() => Text(
                        controller.email.isEmpty ? 'h@gmail.com' : controller.email.value,
                        style: mediumTextStyle(fontSize: dimen11, color: controller.email.isEmpty ?ColorsTheme.colHint:ColorsTheme.colBlack),
                      )),
                    ),
                    controller.socialId.isNotEmpty?
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      width: 80,
                      alignment: Alignment.center,
                    ):
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(36), color: ColorsTheme.colPrimary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      width: 80,
                      alignment: Alignment.center,
                      child: Obx(() => Text(
                        controller.email.isEmpty ? 'Add'.tr : 'Change'.tr,
                        style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colWhite),
                      )),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  loginTypeWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Account Login with',
              style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(
                () => controller.loginType.value.isNotEmpty
                    ? getLoginType():Container(),
              ),
              Obx(
                () => Text(
                  controller.loginType.value == 'mobile' ? controller.countryCode.isNotEmpty&&controller.number.isNotEmpty?'+${controller.countryCode.value} ${controller.number.value}':'mobile' : controller.loginType.value,
                  style: mediumTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  getLoginType(){
    if(controller.loginType.value.toLowerCase() == 'google'){
      return  Container(
          margin: const EdgeInsets.only(right: 5),
          child: Image.asset(
            Res.googleLogo,
            width: 22,
            height: 22,
          ));
    }
    else if(controller.loginType.value.toLowerCase() == 'apple'){
     return Container(
       margin: const EdgeInsets.only(right: 5),
       padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
       decoration: BoxDecoration(
         shape: BoxShape.circle,
         color: ColorsTheme.colBlack,
       ),
       alignment: Alignment.center,
       child: Image.asset(
         Res.appleLogo,
         width: 15,
         height: 15,
       ),
     );
    }
    else{
      return Container();
    }
  }

  uploadProfileBottomSheet() {
    return Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
            color: ColorsTheme.colWhite, borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    'Upload profile picture'.tr,
                    style: boldTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Get.back();
                        controller.pickImage(ImageSource.camera);
                        // controller.onTapCamera();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Image.asset(
                                Res.icProfileCamera,
                                width: 32,
                                height: 32,
                              ),
                            ),
                            Text(
                              'Camera'.tr,
                              style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        controller.onTapGallery();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Image.asset(
                              Res.icProfileGallery,
                              width: 32,
                              height: 32,
                            ),
                          ),
                          Text(
                            'Gallery'.tr,
                            style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                          ),
                        ],
                      ),
                    )
                  ],
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  imageWidget(){
   if(controller.imageNetworkFile.isNotEmpty){
     return ClipOval(
       child: Image.network(
         controller.imageNetworkFile.value,
         fit: BoxFit.cover,
         height: 100,
         width: 100,

         errorBuilder: (con,obj,stack){
           return Image.asset(
             Res.icProfileUser,
             width: 100,
             height: 100,
           );
         }
       ),
     );
   }
   else{
     if(controller.imageLoading.value){
       return SizedBox(
         height: 100,
         width: 100,
         child: CircularProgressIndicator(
           color: ColorsTheme.colPrimary,
         ),
       );
     }
     else{
       if(controller.imageFile.isNotEmpty){
         return ClipOval(
           child: Image.file(
             File(controller.imageFile.value),
             fit: BoxFit.cover,
             height: 100,
             width: 100,
           ),
         );
       }
       return Image.asset(
         Res.icProfileUser,
         width: 100,
         height: 100,
       );
     }
   }
  }
}
