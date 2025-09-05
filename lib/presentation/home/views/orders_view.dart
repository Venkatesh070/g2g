import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/navigation/routes.dart';
import 'package:good_grab/presentation/home/home_controller.dart';

import '../../../infrastructure/shared/custom_shimmer_widget.dart';
import '../../../infrastructure/shared/no_data_screen.dart';
import '../../../infrastructure/theme/colors.theme.dart';
import '../../../infrastructure/theme/text.theme.dart';
import '../../../res.dart';

class OrdersView extends GetView<HomeController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 18, right: 18, top: 15, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: Text(
                'Your Orders',
                style: boldTextStyle(
                    fontSize: dimen21, color: ColorsTheme.colBlack),
              ),
            ),
            Expanded(
              child: Obx(() => controller.orderLoader.value
                  ? ListView.builder(
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 4),
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
                          subtitle:
                              const CustomShimmerWidget.rectangular(height: 14),
                        );
                      })
                  : controller.orderList.isEmpty
                      ? SingleChildScrollView(
                          child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: Get.height * 0.2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  noDataScreen(
                                      noDataImage: Res.icRestaurant,
                                      title: '${'no_orders_title'.tr}?'.tr,
                                      subtitle: 'no_orders_subtitle'.tr),
                                  GestureDetector(
                                      onTap: () {
                                        controller.onSelectIndex(0);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: ColorsTheme.colPrimary,
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        alignment: Alignment.center,
                                        width: 250,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        margin: const EdgeInsets.only(
                                            left: 28, right: 28, top: 25),
                                        child: Text(
                                          'Save your First Magic Bag'.tr,
                                          style: semiBoldTextStyle(
                                              fontSize: dimen13,
                                              color: ColorsTheme.colWhite),
                                        ),
                                      )),
                                ],
                              )),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => Visibility(
                                visible: controller.totalOrderItem.value != 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: ColorsTheme.colBAEEE0),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            child: Image.asset(
                                              Res.icRestaurant,
                                              width: 40,
                                              height: 40,
                                            ),
                                          ),
                                          Text(
                                            'Total Magical Bag',
                                            style: mediumTextStyle(
                                                fontSize: dimen12,
                                                color: ColorsTheme.colBlack),
                                          )
                                        ],
                                      ),
                                      Text(
                                        controller.totalOrderItem.value
                                            .toString(),
                                        style: semiBoldTextStyle(
                                            fontSize: dimen17,
                                            color: ColorsTheme.colBlack),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                controller: controller.pagingListController,
                                itemCount: controller.orderList.length + 1,
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  if (index == controller.orderList.length) {
                                    return controller.buildProgressIndicator();
                                  } else {
                                    return GestureDetector(
                                      onTap: () async {
                                        var result = await Get.toNamed(
                                            Routes.orderDetails,
                                            arguments: {
                                              'orderId': controller
                                                  .orderList[index].orderId,
                                              'currency': controller
                                                  .orderList[index].currency,
                                              'resId': controller
                                                  .orderList[index]
                                                  .restaurantId,
                                              'orderStatus': controller
                                                  .orderList[index].orderStatus,
                                            });
                                        if (result != null && result) {
                                          controller.currentPage.value = 1;
                                          controller.getOrdersList();
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            top: 4, bottom: 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Stack(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 10),
                                                  width: 50,
                                                  height: 50,
                                                  child: ClipOval(
                                                    child: controller
                                                                .orderList[
                                                                    index]
                                                                .restaurantProfile ==
                                                            null
                                                        ? Image.asset(
                                                            Res.icDummyBanner,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.network(
                                                            controller
                                                                .orderList[
                                                                    index]
                                                                .restaurantProfile!,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, obj,
                                                                    stackTrace) {
                                                            return Image.asset(
                                                              Res.icDummyBanner,
                                                              fit: BoxFit.cover,
                                                            );
                                                          }),
                                                  ),
                                                ),
                                                Positioned(
                                                    bottom: 5,
                                                    left: 5,
                                                    child: controller
                                                                .orderList[
                                                                    index]
                                                                .restaurantCoverProfile ==
                                                            null
                                                        ? Image.asset(
                                                            Res.icDummyLogo,
                                                            width: 25,
                                                            height: 25,
                                                          )
                                                        : ClipOval(
                                                            child: Image.network(
                                                                controller
                                                                    .orderList[
                                                                        index]
                                                                    .restaurantCoverProfile!,
                                                                width: 25,
                                                                height: 25,
                                                                errorBuilder:
                                                                    (context,
                                                                        obj,
                                                                        stackTrace) {
                                                              return Image
                                                                  .asset(
                                                                Res.icDummyLogo,
                                                                width: 25,
                                                                height: 25,
                                                              );
                                                            }),
                                                          ))
                                              ],
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 3),
                                                    child: Text(
                                                      '${controller.orderList[index].restaurantName} - ${controller.orderList[index].restaurantAddress}',
                                                      maxLines: 2,
                                                      style: semiBoldTextStyle(
                                                          fontSize: dimen13,
                                                          color: ColorsTheme
                                                              .colBlack),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 3),
                                                    child: Text.rich(
                                                        TextSpan(children: [
                                                      TextSpan(
                                                        text:
                                                            '${'Order ID'.tr} : ',
                                                        style: regularTextStyle(
                                                            fontSize: dimen11,
                                                            color: ColorsTheme
                                                                .colBlack),
                                                      ),
                                                      TextSpan(
                                                        text: controller
                                                            .orderList[index]
                                                            .orderId
                                                            .toString(),
                                                        style: boldTextStyle(
                                                            fontSize: dimen14,
                                                            color: ColorsTheme
                                                                .colBlack),
                                                      )
                                                    ])),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 8),
                                                    child: Text(
                                                      '${controller.orderList[index].currency ?? '₹ '}'
                                                      '${double.tryParse(controller.orderList[index].totalPaid ?? '0')! 
                                                      + double.tryParse(controller.orderList[index].gst ?? '0')!
                                                      + double.tryParse(controller.orderList[index].platformGst ?? '0')!
                                                      + double.tryParse(controller.orderList[index].platformFee ?? '0')!
                                                      }'
                                                      ' | ${controller.orderList[index].createdAt ?? ''}',
                                                      style: regularTextStyle(
                                                        fontSize: dimen11,
                                                        color: ColorsTheme
                                                            .colBlack,
                                                      ),
                                                    ),
                                                  ),
                                                  getStatus(index),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return Divider(
                                    color: ColorsTheme.colC4D9D4,
                                    thickness: 1,
                                  );
                                },
                              ),
                            ),
                          ],
                        )),
            )
          ],
        ),
      ),
    );
  }

  getStatus(index) {
    // log("Status: ${controller.orderList[1].orderStatus}");
    if (controller.orderList[index].orderStatus! == 'pending_pick_up') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsTheme.col8FA19C,
              ),
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 10),
              child: Image.asset(
                Res.icCheck,
                color: Colors.white,
                width: 10,
                height: 10,
              )),
          Text(
            'Pending pick-up',
            style:
                boldTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
          ),
        ],
      );
    } else if (controller.orderList[index].orderStatus! == 'completd_pick_up') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsTheme.colPrimary,
              ),
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 10),
              child: Image.asset(
                Res.icCheck,
                color: Colors.white,
                width: 10,
                height: 10,
              )),
          Text(
            'Completed pick-up',
            style:
                boldTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
          ),
        ],
      );
    } else if (controller.orderList[index].orderStatus! == 'order_cancel' ||
        controller.orderList[index].orderStatus == 'not_picked_up') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsTheme.colFF4E4E,
              ),
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 10),
              child: Image.asset(
                Res.icWhiteCancel,
                color: Colors.white,
                width: 8,
                height: 8,
              )),
          Text(
            controller.orderList[index].orderStatus == 'not_picked_up'
                ? 'Not pick-up'
                : 'Order Cancelled',
            style:
                boldTextStyle(fontSize: dimen11, color: ColorsTheme.colFF4E4E),
          ),
        ],
      );
    }else if (controller.orderList[index].orderStatus! == 'confirmation_pending' ||
        controller.orderList[index].orderStatus == 'confirmation_pending') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsTheme.colF59E0B,
              ),
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 10),
              child: Image.asset(
                Res.icConfirmPending,
                color: Colors.white,
                width: 8,
                height: 8,
              )),
          Text(
            controller.orderList[index].orderStatus == 'confirmation_pending'
                ? 'Confirmation Pending'
                : 'Order Cancelled',
            style:
                boldTextStyle(fontSize: dimen11, color: ColorsTheme.colF59E0B),
          ),
        ],
      );
    }  
    
    else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsTheme.colFF4E4E,
              ),
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 10),
              child: Image.asset(
                Res.icWhiteCancel,
                color: Colors.white,
                width: 8,
                height: 8,
              )),
          Text(
            controller.orderList[index].orderStatus == "payment_pending"
                ? 'Payment Pending'
                : controller.orderList[index].orderStatus,
            style:
                boldTextStyle(fontSize: dimen11, color: ColorsTheme.colFF4E4E),
          ),
        ],
      );
    }
    return Container();
  }
}
