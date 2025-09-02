import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';

import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/theme/colors.theme.dart';
import '../../res.dart';
import 'intro_controller.dart';

class IntroPage extends BaseView<IntroController> {
  IntroPage({super.key});

  @override
  Color pageBackgroundColor() {
    return ColorsTheme.colF3FFFB;
  }

  @override
  Widget body(BuildContext context) {
    return SafeArea(
        child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// change  by client 9Feb
          Container(),
          Expanded(
            child: SizedBox(
              width: Get.width,
              child: Stack(
                children: [
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Image.asset(
                      Res.introLogo,
                      width: Get.width,
                      fit: BoxFit.cover,
                    ),
                  ),
                  /// change  by client 9Feb
                  Visibility(
                    visible: true,
                    child: Positioned(
                      right: 8,
                      top: 8,
                      child: Obx(() => !controller.isSkip.value?Container():GestureDetector(
                        onTap: () {
                          controller.getUniqueID();

                        },
                        child: Container(
                          decoration: BoxDecoration(color: ColorsTheme.colWhite, borderRadius: BorderRadius.circular(50)),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                          child: Text(
                            'SKIP'.tr,
                            style: mediumTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                          ),
                        ),
                      ),)
                    ),
                  )
                ],
              ),
            ),
          ),
          // Expanded(
          //   child: Image.asset(
          //     Res.introLogo,
          //     width: Get.width,
          //     fit: BoxFit.fill,
          //   ),
          // ),
          SizedBox(
            width: Get.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Text(
                    'intro_title'.tr,
                    style: boldTextStyle(fontSize: dimen23, color: ColorsTheme.colBlack),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text(
                    'intro_subtitle'.tr,
                    style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Row(
                    children: [
                      /// change by client 13 Feb
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.login, arguments: {'screenType': 'signup'});
                          },
                          child: Container(
                            decoration: BoxDecoration(color: ColorsTheme.colPrimary, borderRadius: BorderRadius.circular(50)),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Text(
                              '${'Sign up Now'.tr} →',
                              style: semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colWhite),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.login, arguments: {'screenType': 'login'});
                          },
                          child: Container(
                            decoration: BoxDecoration(color: ColorsTheme.colPrimary, borderRadius: BorderRadius.circular(50)),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Text(
                              '${'Log in'.tr} →',
                              style: semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colWhite),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// change by client 13 Feb
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                          child: Container(
                        width: Get.width,
                        height: 1,
                        color: ColorsTheme.colBlack.withOpacity(0.2),
                      )),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "or",
                          style: semiBoldTextStyle(fontSize: dimen14, color: ColorsTheme.colBlack),
                        ),
                      ),
                      Expanded(
                          child: Container(
                        width: Get.width,
                        height: 1,
                        color: ColorsTheme.colBlack.withOpacity(0.2),
                      )),
                    ],
                  ),
                ),

                /// change by client 13 Feb
                GetPlatform.isIOS
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          googleLogoWidget(),
                          GestureDetector(
                            onTap: () {
                              controller.signInWithApple();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorsTheme.colBlack,
                              ),
                              alignment: Alignment.center,
                              child: Image.asset(
                                Res.appleLogo,
                                width: 60,
                                height: 19,
                              ),
                            ),
                          )
                        ],
                      )
                    : googleLogoWidget(),
                // Container(
                //   margin: const EdgeInsets.only(top: 30),
                //   child: Text.rich(
                //     TextSpan(
                //       children: [
                //         TextSpan(
                //           text: 'dont have an account yet'.tr,
                //           style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                //         ),
                //         TextSpan(
                //           text: ', ${'Please'.tr} ',
                //           style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                //         ),
                //         TextSpan(
                //             text: 'Sign up Now'.tr,
                //             style: semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colPrimary),
                //             recognizer: TapGestureRecognizer()
                //               ..onTap = () {
                //                 Get.toNamed(Routes.login, arguments: {'screenType': 'signup'});
                //               }),
                //       ],
                //     ),
                //   ),
                // ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text.rich(TextSpan(children: [
                    TextSpan(
                      text: 'agree_title'.tr,
                      style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                    ),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.toNamed(Routes.appContents, arguments: {'title': 'Terms of Service'.tr, 'flag': 'term'});
                        },
                      text: ' ${'Terms of Service'.tr}',
                      style: semiBoldTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                    ),
                    TextSpan(
                      text: ' ${'and'.tr} ',
                      style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                    ),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.toNamed(Routes.appContents, arguments: {'title': 'Privacy Policy'.tr, 'flag': 'privacy'});
                        },
                      text: 'Privacy Policy'.tr,
                      style: semiBoldTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                    ),
                    TextSpan(
                      text: ' ${'.'} ',
                      style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                    ),
                  ])),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  googleLogoWidget() {
    return GestureDetector(
      onTap: () {
        controller.signInWithGmail();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ColorsTheme.colBlack,
            )),
        alignment: Alignment.center,
        child: Image.asset(
          Res.googleLogo,
          width: 60,
          height: 19,
        ),
      ),
    );
  }
}
