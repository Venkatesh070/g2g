import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'package:good_grab/presentation/order_cancel/order_cancel_controller.dart';
import 'package:image_picker/image_picker.dart';

import '../../infrastructure/shared/custom_shimmer_widget.dart';
import '../../infrastructure/shared/no_data_screen.dart';
import '../../res.dart';

class OrderCancelPage extends BaseView<OrderCancelController> {
  OrderCancelPage({super.key});

  @override
  Widget body(BuildContext context) {
    return SafeArea(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
                    'Order Cancel'.tr,
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
            child: Obx(
          () => controller.isLoadingData.value
              ? Container(
                  margin: const EdgeInsets.only(left: 18, right: 18, top: 8, bottom: 8),
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
              : controller.reasonList.isEmpty
                  ? SingleChildScrollView(
                      child: Container(
                          margin: EdgeInsets.symmetric(vertical: Get.height * 0.2),
                          child: noDataScreen(noDataImage: Res.icRestaurant, title: '${'no_data_found'.tr}?'.tr)),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 18, right: 18, top: 12),
                          child: Text(
                            'choose_reason'.tr,
                            style: mediumTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 18, right: 18, top: 8, bottom: 8),
                            child: ListView.builder(
                                itemCount: controller.reasonList.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            controller.selectReason.value = index;
                                          },
                                          child: Row(
                                            children: [
                                              Obx(
                                                () => index == controller.selectReason.value
                                                    ? Container(
                                                        width: 24,
                                                        height: 24,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: ColorsTheme.colPrimary,
                                                        ),
                                                        alignment: Alignment.center,
                                                        margin: const EdgeInsets.only(right: 10),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: ColorsTheme.colWhite,
                                                          ),
                                                          width: 10,
                                                          height: 10,
                                                        ),
                                                      )
                                                    : Container(
                                                        decoration: BoxDecoration(
                                                            shape: BoxShape.circle, border: Border.all(color: ColorsTheme.col8FA19C, width: 1)),
                                                        width: 24,
                                                        height: 24,
                                                        margin: const EdgeInsets.only(right: 10),
                                                      ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  controller.reasonList[index].reason!,
                                                  style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Obx(() => index == controller.selectReason.value
                                            ? GestureDetector(
                                                onTap: () {
                                                  uploadProfileBottomSheet(index);
                                                },
                                                child:  controller.reasonList[index].reasonImage != null &&
                                                    controller.reasonList[index].reasonImage!.isNotEmpty
                                                    ? Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: ColorsTheme.col8FA19C),
                                                  ),

                                                  margin: const EdgeInsets.only(top: 18),
                                                  width: 75,
                                                  height: 75,
                                                  child:ClipRRect(
                                                      borderRadius: BorderRadius.circular(20),
                                                      child: Image.file(File(controller.reasonList[index].reasonImage!),fit: BoxFit.cover,)),
                                                ):Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: ColorsTheme.col8FA19C),
                                                  ),
                                                  alignment: Alignment.center,
                                                  padding: const EdgeInsets.all(20),
                                                  margin: const EdgeInsets.only(top: 18),
                                                  width: 70,
                                                  child:Image.asset(Res.icProfileCamera, width: 30, height: 30, color: ColorsTheme.col8FA19C),
                                                ),
                                              )
                                            : Container())
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ],
                    ),
        )),
        GestureDetector(
            onTap: () async {
              if(controller.selectReason.value != -1){
                // Skip the 2-hour check when order status is confirmation_pending
                final skipTimeCheck = controller.orderStatus.value == 'confirmation_pending';
                if(!skipTimeCheck && controller.is2HoursLess.value && controller.reasonList[controller.selectReason.value].isPopup == "1"){
                  dontCancelOrderBottomSheet();
                }
                else{
                  var result = await controller.funCancelOrder();
                  if(result){
                    cancelOrderBottomSheet();
                  }
                }
              }
            },
            child: Obx(
              () => Container(
                decoration: BoxDecoration(
                    color: controller.selectReason.value != -1 ? ColorsTheme.colPrimary : ColorsTheme.colSecondary,
                    borderRadius: BorderRadius.circular(50)),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 18),
                margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                child: Text(
                  'Order Cancel'.tr,
                  style:
                      semiBoldTextStyle(fontSize: dimen13, color: controller.selectReason.value != -1 ? ColorsTheme.colWhite : ColorsTheme.colBlack),
                ),
              ),
            )),
      ],
    ));
  }

  uploadProfileBottomSheet(index) {
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
                    'Upload'.tr,
                    style: boldTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Get.back();
                        controller.getImage(index,ImageSource.camera);
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
                        controller.getImage(index, ImageSource.gallery);
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

  cancelOrderBottomSheet() {
    return Get.bottomSheet(
        WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: Container(
            decoration: BoxDecoration(
                color: ColorsTheme.colWhite, borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Wrap(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Image.asset(
                        Res.icCancelOrder,
                        width: 70,
                        height: 70,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        'Cancelled order successfully'.tr,
                        style: boldTextStyle(fontSize: dimen17, color: ColorsTheme.colBlack),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        'cancelled_order_refund'.tr,
                        textAlign: TextAlign.center,
                        style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack, height: 2.0),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          Get.back();
                          Get.back(result: true);
                        },
                        child: Obx(
                          () => Container(
                            decoration: BoxDecoration(
                                color: controller.selectReason.value != -1 ? ColorsTheme.colPrimary : ColorsTheme.colSecondary,
                                borderRadius: BorderRadius.circular(50)),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            child: Text(
                              'Got It'.tr,
                              style: semiBoldTextStyle(
                                  fontSize: dimen13, color: controller.selectReason.value != -1 ? ColorsTheme.colWhite : ColorsTheme.colBlack),
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
        ignoreSafeArea: false,
        isDismissible: false,
        enableDrag: false);
  }

  dontCancelOrderBottomSheet() {
    return Get.bottomSheet(
        WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: Container(
            decoration: BoxDecoration(
                color: ColorsTheme.colWhite, borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Wrap(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Image.asset(
                        Res.icCancelOrder,
                        width: 70,
                        height: 70,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        'This order is unable to be cancelled'.tr,
                        style: boldTextStyle(fontSize: dimen17, color: ColorsTheme.colBlack),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        'This option doesn\'t allow you to cancel it because you have crossed the 2 hour limit'.tr,
                        textAlign: TextAlign.center,
                        style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack, height: 2.0),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Obx(
                              () => Container(
                            decoration: BoxDecoration(
                                color: controller.selectReason.value != -1 ? ColorsTheme.colPrimary : ColorsTheme.colSecondary,
                                borderRadius: BorderRadius.circular(50)),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            child: Text(
                              'Got It'.tr,
                              style: semiBoldTextStyle(
                                  fontSize: dimen13, color: controller.selectReason.value != -1 ? ColorsTheme.colWhite : ColorsTheme.colBlack),
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
        ignoreSafeArea: false,
        isDismissible: false,
        enableDrag: false);
  }
}
