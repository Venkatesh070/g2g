import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'package:good_grab/presentation/app_content/app_content_controller.dart';
import 'package:good_grab/res.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../infrastructure/shared/custom_shimmer_widget.dart';
import '../../infrastructure/shared/no_data_screen.dart';

class AppContentPage extends BaseView<AppContentController> {
  AppContentPage({super.key});

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
                    controller.title,
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
          child: Obx(() => controller.isLoadData.value
              ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: const CustomShimmerWidget.rectangular(
                          height: 64,
                          width: 64,
                          borderRadius: 16,
                        ),
                        title: Align(
                          alignment: Alignment.centerLeft,
                          child: CustomShimmerWidget.rectangular(
                            height: 16,
                            width: Get.size.width * 0.3,
                          ),
                        ),
                        subtitle: const CustomShimmerWidget.rectangular(height: 14),
                      );
                    }),
              )
              : getWidget()),
        )
      ],
    ));
  }

  getWidget() {
    if (controller.flag == 'contact') {
      print("lksjdfkl ");
      return contactWidget();
    } else if (controller.flag == 'help') {
      return helpWidget();
    } else {
      return aboutTermPrivacyWidget();
    }
  }

  aboutTermPrivacyWidget() {
    return Obx(
      () => controller.htmlContent.isNotEmpty
          ? SingleChildScrollView(
              child: Container(
              margin: const EdgeInsets.only(left: 18, right: 18, bottom: 20),
              child: Html(
                data: controller.htmlContent.value,
                onLinkTap: (url, attributes, element) async {
                  if (url != null) {
                    Uri uri = Uri.parse(url);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                style: {"body": Style(fontFamily: 'SF-Pro', fontSize: FontSize.medium, color: ColorsTheme.colBlack)},
              ),
            ))
          : SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: Get.height * 0.2),
                child: noDataScreen(noDataImage: Res.splashLogo1, title: 'no_data_found'.tr),
              ),
            ),
    );
  }

  contactWidget() {
    return Obx(() => controller.email.isNotEmpty && controller.phoneNumber.isNotEmpty?SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(left: 18, right: 18, bottom: 20, top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
                  () => Visibility(
                visible: controller.email.isNotEmpty,
                child: GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse("mailto:${controller.email.value}"));
                  },
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: ColorsTheme.colC4D9D4, width: 1)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 25),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 15),
                                child: Image.asset(
                                  Res.icMail,
                                  width: 45,
                                  height: 45,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${'Email'.tr} ${'us'.tr}',
                                      maxLines: 2,
                                      style: boldTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                                    ),
                                    Obx(
                                          () => Text(
                                        controller.email.value,
                                        style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(color: ColorsTheme.colPrimary, borderRadius: BorderRadius.circular(30)),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                child: Text(
                                  'Email'.tr,
                                  style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colWhite),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Obx(
                  () => Visibility(
                visible: controller.phoneNumber.isNotEmpty,
                child: GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse("tel://${controller.phoneNumber.value}"));
                  },
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: ColorsTheme.colC4D9D4, width: 1)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 15),
                                child: Image.asset(
                                  Res.icCall,
                                  width: 45,
                                  height: 45,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Call'.tr,
                                      maxLines: 2,
                                      style: boldTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                                    ),
                                    Obx(
                                          () => Text(
                                        controller.phoneNumber.value,
                                        style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(color: ColorsTheme.colPrimary, borderRadius: BorderRadius.circular(30)),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                child: Text(
                                  'Call'.tr,
                                  style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colWhite),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ):SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: Get.height * 0.2),
        child: noDataScreen(noDataImage: Res.splashLogo1, title: 'no_data_found'.tr),
      ),
    ));
  }

  helpWidget() {
    return Obx(() => controller.helpList.isNotEmpty?Container(
        margin: const EdgeInsets.only(left: 18, right: 18, bottom: 20),
        child: Obx(
              () => ListView.builder(
              itemCount: controller.helpList.length,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    controller.helpList[index].isSelect = !controller.helpList[index].isSelect!;
                    controller.helpList.refresh();
                  },
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                controller.helpList[index].faqQuestion!,
                                style: mediumTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                              ),
                            ),
                            !controller.helpList[index].isSelect!
                                ? Icon(
                              Icons.arrow_forward_ios,
                              color: ColorsTheme.colBlack,
                              size: 18,
                            )
                                : Image.asset(
                              Res.icCancel,
                              width: 14,
                              height: 14,
                            )
                          ],
                        ),
                      ),
                      Visibility(
                        visible: controller.helpList[index].isSelect!,
                        child: Text(
                          controller.helpList[index].faqAnswer!,
                          style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                        ),
                      )
                    ],
                  ),
                );
              }),
        )):SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: Get.height * 0.2),
        child: noDataScreen(noDataImage: Res.splashLogo1, title: 'no_data_found'.tr),
      ),
    ));
  }
}
