import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/presentation/app_setting/app_setting_controller.dart';

import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/theme/colors.theme.dart';
import '../../infrastructure/theme/text.theme.dart';
import '../../res.dart';

class AppSettingPage extends BaseView<AppSettingController> {
  AppSettingPage({super.key});

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
                    'Setting'.tr,
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
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
          children: [
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.appContents, arguments: {'title': 'Privacy Policy'.tr, 'flag': 'privacy'});
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 18, right: 18, bottom: 24),
                  child: commonBodyWidget(image: Res.icProfilePrivacy, title: 'Privacy Policy'.tr),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.appContents, arguments: {'title': 'Terms of Service'.tr, 'flag': 'term'});
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 18, right: 18, bottom: 24),
                  child: commonBodyWidget(image: Res.icProfileTerm, title: 'Terms of Service'.tr),
                ),
              ),
              Visibility(
                visible: controller.isLoggedIn,
                child: GestureDetector(
                  onTap: () {
                    deleteBottomSheet();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 18, right: 18, bottom: 24),
                    child: commonBodyWidget(image: Res.icProfileDelete, title: 'Delete Account Permanently'.tr, textColor: ColorsTheme.colFF4E4E),
                  ),
                ),
              ),
          ],
        ),
            ))
      ],
    ));
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

  deleteBottomSheet() {
    return Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
            color: ColorsTheme.colWhite, borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Delete Account Permanently'.tr,
                    style: boldTextStyle(fontSize: dimen15, color: ColorsTheme.colBlack),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    'delete_account_subtitle'.tr,
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
                          decoration:
                              BoxDecoration(border: Border.all(color: ColorsTheme.colBlack, width: 1), borderRadius: BorderRadius.circular(40)),
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
                          Get.back();
                          controller.deleteAccountApi();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 15),
                          decoration: BoxDecoration(color: ColorsTheme.colPrimary, borderRadius: BorderRadius.circular(40)),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          alignment: Alignment.center,
                          child: Text(
                            '${'Yes'.tr}, ${'Delete'.tr}',
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
