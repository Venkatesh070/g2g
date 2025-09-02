import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/navigation/routes.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'package:good_grab/presentation/home/home_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../infrastructure/shared/common_functions.dart';
import '../../../res.dart';

class MeView extends GetView<HomeController> {
  const MeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: Get.width,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: ColorsTheme.colE7F8F3,
                borderRadius:
                    const BorderRadius.only(bottomRight: Radius.circular(30), bottomLeft: Radius.circular(30))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 20),
                  child: Text(
                    'Profile'.tr,
                    style: boldTextStyle(fontSize: dimen21, color: ColorsTheme.colBlack),
                  ),
                ),
                SizedBox(
                  width: Get.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            controller.onMoneyTap(
                                title: 'Money Saved'.tr,
                                flag: 'money',
                                totalValue: controller.moneySaved.value,
                                unit: controller.currency.value);
                          },
                          child: Container(
                            decoration:
                                BoxDecoration(color: ColorsTheme.colBAEEE0, borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            margin: const EdgeInsets.only(right: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: Image.asset(
                                    Res.icProfileMoney,
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          'Money\nSaved'.tr,
                                          overflow: TextOverflow.ellipsis,
                                          style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                                        ),
                                      ),
                                      Obx(() => Text(
                                            '${controller.currency.value}${controller.money.value.toString()}',
                                            style: semiBoldTextStyle(fontSize: dimen15, color: ColorsTheme.colPrimary),
                                          ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            controller.onMoneyTap(
                                title: 'CO2e Saved'.tr, flag: 'co2', totalValue: controller.co2Saved.value, unit: 'Kg');
                          },
                          child: Container(
                            decoration:
                                BoxDecoration(color: ColorsTheme.colBAEEE0, borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            margin: const EdgeInsets.only(left: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: Image.asset(
                                    Res.icProfileCo2,
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          'CO2e\nSaved'.tr,
                                          overflow: TextOverflow.ellipsis,
                                          style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                                        ),
                                      ),
                                      Obx(() => Text(
                                            '${controller.co2Saved.value.toString()}',
                                            style: semiBoldTextStyle(fontSize: dimen15, color: ColorsTheme.colPrimary),
                                          ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          userProfile(),
          Container(
            margin: const EdgeInsets.only(left: 18, right: 18, top: 16, bottom: 16),
            child: Divider(
              color: ColorsTheme.colC4D9D4,
              thickness: 1,
            ),
          ),
           Visibility(
              visible: false,
              // visible: controller.isLoggedIn.value,
              child: Container(
                margin: const EdgeInsets.only(left: 18, right: 18, bottom: 24),
                child: commonBodyWidget(image: Res.icProfilePaymentMethod, title: 'Payment Method'.tr),
              ),
            ),
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.appContents, arguments: {'title': 'Help Center'.tr, 'flag': 'help'});
            },
            child: Container(
              margin: const EdgeInsets.only(left: 18, right: 18, bottom: 24),
              child: commonBodyWidget(image: Res.icProfileHelp, title: 'Help Center'.tr),
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.appContents, arguments: {'title': 'About us'.tr, 'flag': 'about'});
            },
            child: Container(
              margin: const EdgeInsets.only(left: 18, right: 18, bottom: 24),
              child: commonBodyWidget(image: Res.icProfileAbout, title: 'About us'.tr),
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.appSettings,
                  arguments: {'isLoggedIn': controller.isLoggedIn.value, 'userId': controller.userId.value});
            },
            child: Container(
              margin: const EdgeInsets.only(left: 18, right: 18, bottom: 24),
              child: commonBodyWidget(image: Res.icProfileSettings, title: 'Setting'.tr),
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.appContents, arguments: {'title': 'Contact us'.tr, 'flag': 'contact'});
            },
            child: Container(
              margin: const EdgeInsets.only(left: 18, right: 18, bottom: 24),
              child: commonBodyWidget(image: Res.icProfileContact, title: 'Contact us'.tr),
            ),
          ),
          GestureDetector(
            onTap: () async {
              var deviceType = CommonFunction.getDeviceType();
              if (deviceType == "android") {
                await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.good.grab'),
                    mode: LaunchMode.externalApplication);
              } else {
                await launchUrl(Uri.parse('https://apps.apple.com/gb/app/good-to-grab/id6451374378'),
                    mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(left: 18, right: 18, bottom: 24),
              child: commonBodyWidget(image: Res.icProfileRating, title: 'Enjoy App! Rate us'.tr),
            ),
          ),
          Obx(
            () => Visibility(
              visible: controller.isLoggedIn.value,
              child: GestureDetector(
                onTap: () {
                  logoutBottomSheet();
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 18, right: 18, bottom: 24),
                  child: commonBodyWidget(image: Res.icProfileLogout, title: 'Log out'.tr),
                ),
              ),
            ),
          ),
          Obx(
            () => Container(
              margin: const EdgeInsets.only(left: 18, right: 18, bottom: 24),
              child: Text(
                'App Version ${controller.appVersion.value}',
                maxLines: 2,
                style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.col8FA19C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  userProfile() {
    print(controller.userProfile.value);
    return GestureDetector(
      onTap: () async {
        if (controller.isLoggedIn.value) {
          var result = await Get.toNamed(Routes.editProfile);
          if (result != null && result) {
            controller.getUpdatedUserData();
          }
        } else {
          controller.loginBottomSheet();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Obx(() => controller.userProfile.isEmpty
                          ? Image.asset(
                              Res.icProfileUser,
                              width: 50,
                              height: 50,
                            )
                          : ClipOval(
                              child: Image.network(controller.userProfile.value,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover, errorBuilder: (context, object, stackTrace) {
                                print(stackTrace);
                                return Image.asset(
                                  Res.icProfileUser,
                                  width: 50,
                                  height: 50,
                                );
                              }),
                            ))),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.userName.value,
                            maxLines: 2,
                            style: mediumTextStyle(fontSize: dimen15, color: ColorsTheme.colBlack),
                          ),
                        ),
                        Obx(
                          () => controller.userNumber.isEmpty
                              ? Container()
                              : Text(
                                  "${controller.userCountryCode.value}-${controller.userNumber.value}",
                                  style: regularTextStyle(fontSize: dimen10, color: ColorsTheme.colBlack),
                                ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
                decoration: BoxDecoration(
                  border: Border.all(color: ColorsTheme.colBlack, width: 1),
                  borderRadius: BorderRadius.circular(35),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                child: Obx(
                  () => Text(
                    controller.isLoggedIn.value ? 'Edit'.tr : 'Login'.tr,
                    style: mediumTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  commonBodyWidget({required String image, required String title, Color? textColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: Image.asset(
            image,
            width: 40,
            height: 40,
          ),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            style: regularTextStyle(fontSize: dimen12, color: textColor ?? ColorsTheme.colBlack),
          ),
        )
      ],
    );
  }

  logoutBottomSheet() {
    return Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
            color: ColorsTheme.colWhite,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Log out'.tr,
                    style: boldTextStyle(fontSize: dimen15, color: ColorsTheme.colBlack),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    'logout_subtitle'.tr,
                    style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                              border: Border.all(color: ColorsTheme.colBlack, width: 1),
                              borderRadius: BorderRadius.circular(40)),
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Cancel'.tr,
                            style: semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {

                          controller.logOut();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 15),
                          decoration:
                              BoxDecoration(color: ColorsTheme.colPrimary, borderRadius: BorderRadius.circular(40)),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          alignment: Alignment.center,
                          child: Text(
                            '${'Yes'.tr}, ${'Log out'.tr}',
                            style: semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colWhite),
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
