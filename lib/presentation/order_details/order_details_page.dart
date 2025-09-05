import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/shared/common_functions.dart';
import 'package:intl/intl.dart';

import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/shared/custom_shimmer_widget.dart';
import '../../infrastructure/shared/no_data_screen.dart';
import '../../infrastructure/theme/colors.theme.dart';
import '../../infrastructure/theme/text.theme.dart';
import '../../res.dart';
import 'order_details_controller.dart';
import 'countdown_progree.dart';

class OrderDetailsPage extends BaseView<OrderDetailsController> {
  OrderDetailsPage({super.key});

  @override
  bool onBackPressed() {
    Get.back(result: controller.backResult.value);
    return false;
  }

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
                  Get.back(result: controller.backResult.value);
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
                    'Order Details'.tr,
                    style: boldTextStyle(
                        fontSize: dimen16, color: ColorsTheme.colBlack),
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
          () => controller.loadingData.value
              ? Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: ListView.builder(
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
                      }),
                )
              : !controller.isOrderData.value
                  ? SingleChildScrollView(
                      child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: Get.height * 0.2),
                          child: noDataScreen(
                              noDataImage: Res.icRestaurant,
                              title: '${'no_orders_title'.tr}?'.tr,
                              subtitle: 'no_orders_subtitle'.tr)),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getStatus(),
                            // Highlight message for confirmation pending
                            Visibility(
                              visible: controller.orderStatus.value ==
                                      'confirmation_pending' ||
                                  controller.orderStatus.value ==
                                      'Confirmation Pending',
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 18, right: 18, bottom: 15),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      ColorsTheme.colPrimary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: ColorsTheme.colPrimary
                                          .withOpacity(0.2)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.hourglass_top_rounded,
                                        color: ColorsTheme.colPrimary,
                                        size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        controller.cancelDiffMinutes.value > 5
                                            ? 'It’s taking a little longer than expected. Please hold on for some more time.'
                                            : 'Waiting for restaurant partner acceptance. Please wait and do not start your journey until accepted.',
                                        style: regularTextStyle(
                                            fontSize: dimen11,
                                            color: ColorsTheme.colBlack),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: controller.orderStatus.value ==
                                  'pending_pick_up',
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 18, right: 18, bottom: 15),
                                child: Text(
                                  'pickup_note'.tr,
                                  style: regularTextStyle(
                                      fontSize: dimen10,
                                      color: ColorsTheme.col8FA19C),
                                ),
                              ),
                            ),
                            Visibility(
                                visible: controller.orderStatus.value ==
                                    'completd_pick_up',
                                child: rateOrder()),
                            controller.orderDetailsModel!.menuDetails != null &&
                                    controller.orderDetailsModel!.menuDetails!
                                        .isNotEmpty
                                ? orderDetails()
                                : Container(),
                            billDetails(),
                            Visibility(
                              visible:
                                  controller.orderStatus.value == 'initiate' ||
                                      controller.orderStatus.value == 'intiate',
                              child: GestureDetector(
                                onTap: _openCancelSummaryDialog,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 8, left: 18, right: 18),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Order Cancel'.tr,
                                            style: semiBoldTextStyle(
                                                fontSize: dimen12,
                                                color: ColorsTheme.colBlack),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_outlined,
                                            size: 15,
                                            color: ColorsTheme.colBlack,
                                          )
                                        ],
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        child: Divider(
                                          color: ColorsTheme.colC4D9D4,
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                                visible: controller.orderStatus.value ==
                                    'order_cancel',
                                child: cancelOrder()),
                            Visibility(
                              visible: controller.orderStatus.value !=
                                  'pending_pick_up',
                              child: InkWell(
                                onTap: () {
                                  Get.toNamed(Routes.appContents, arguments: {
                                    'title': 'Contact us'.tr,
                                    'flag': 'contact'
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: ColorsTheme.colPrimary),
                                  margin: const EdgeInsets.only(
                                      bottom: 15, left: 18, right: 18),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 18),
                                  child: Text(
                                    'Contact us'.tr,
                                    style: regularTextStyle(
                                        fontSize: dimen11,
                                        color: ColorsTheme.colWhite),
                                  ),
                                ),
                              ),
                            ),
                            controller.orderDetailsModel!.restaurantDetail !=
                                    null
                                ? restaurantDetails()
                                : Container(),
                            paymentType()
                          ],
                        ),
                      ),
                    ),
        )),
      ],
    ));
  }

  getStatus() {
    return Obx(() {
      if (controller.orderStatus.value == 'pending_pick_up') {
        return Container(
          width: Get.width,
          decoration: BoxDecoration(
              color: ColorsTheme.col007752,
              borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Order Status'.tr,
                  style: regularTextStyle(
                      fontSize: dimen11, color: ColorsTheme.colWhite),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorsTheme.col8FA19C,
                        ),
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 5),
                        child: Image.asset(
                          Res.icCheck,
                          color: Colors.white,
                          width: 10,
                          height: 10,
                        )),
                    Text(
                      'Pending pick-up',
                      style: boldTextStyle(
                          fontSize: dimen11, color: ColorsTheme.colWhite),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                    text: '${'Order ID'.tr} : ',
                    style: regularTextStyle(
                        fontSize: dimen11, color: ColorsTheme.colWhite),
                  ),
                  TextSpan(
                    text: controller.orderId.toString(),
                    style: boldTextStyle(
                        fontSize: dimen14, color: ColorsTheme.colWhite),
                  )
                ])),
              ),
            ],
          ),
        );
      } else if (controller.orderStatus.value == 'completd_pick_up') {
        return Container(
          width: Get.width,
          decoration: BoxDecoration(
              color: ColorsTheme.col007752,
              borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Order Status'.tr,
                  style: regularTextStyle(
                      fontSize: dimen11, color: ColorsTheme.colWhite),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorsTheme.colWhite,
                        ),
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 5),
                        child: Image.asset(
                          Res.icCheck,
                          color: ColorsTheme.colPrimary,
                          width: 10,
                          height: 10,
                        )),
                    Text(
                      'Completed pick-up',
                      style: boldTextStyle(
                          fontSize: dimen11, color: ColorsTheme.colWhite),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                    text: '${'Order ID'.tr} : ',
                    style: regularTextStyle(
                        fontSize: dimen11, color: ColorsTheme.colWhite),
                  ),
                  TextSpan(
                    text: controller.orderId.toString(),
                    style: boldTextStyle(
                        fontSize: dimen14, color: ColorsTheme.colWhite),
                  )
                ])),
              ),
            ],
          ),
        );
      } else if (controller.orderStatus.value == 'order_cancel' ||
          controller.orderStatus.value == 'not_picked_up') {
        return Container(
          width: Get.width,
          decoration: BoxDecoration(
              color: ColorsTheme.colSecondary,
              borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Order Status'.tr,
                  style: regularTextStyle(
                      fontSize: dimen11, color: ColorsTheme.colBlack),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorsTheme.colFF4E4E,
                        ),
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 5),
                        child: Image.asset(
                          Res.icWhiteCancel,
                          color: Colors.white,
                          width: 8,
                          height: 8,
                        )),
                    Text(
                      controller.orderStatus.value == 'not_picked_up'
                          ? 'Not pick-up'
                          : 'Order Cancelled',
                      style: boldTextStyle(
                          fontSize: dimen11, color: ColorsTheme.colFF4E4E),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                    text: '${'Order ID'.tr} : ',
                    style: regularTextStyle(
                        fontSize: dimen11, color: ColorsTheme.colBlack),
                  ),
                  TextSpan(
                    text: controller.orderId.toString(),
                    style: boldTextStyle(
                        fontSize: dimen14, color: ColorsTheme.colBlack),
                  )
                ])),
              ),
            ],
          ),
        );
      }
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              child: Text.rich(TextSpan(children: [
                TextSpan(
                  text: '${'Order ID'.tr} : ',
                  style: regularTextStyle(
                      fontSize: dimen11, color: ColorsTheme.colBlack),
                ),
                TextSpan(
                  text: controller.orderId.toString(),
                  style: boldTextStyle(
                      fontSize: dimen14, color: ColorsTheme.colBlack),
                )
              ])),
            ),
          ],
        ),
      );
    });
  }

  rateOrder() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 18, right: 18),
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: ColorsTheme.colC4D9D4, width: 1),
              borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          width: Get.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 9),
                child: Text(
                  'Rate the order'.tr,
                  style: semiBoldTextStyle(
                      fontSize: dimen12, color: ColorsTheme.colBlack),
                ),
              ),
              controller.isRated.value
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: RatingBarIndicator(
                        rating: controller.orderDetailsModel!.rating!,
                        itemSize: 22,
                        direction: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return Icon(
                            Icons.star,
                            color: ColorsTheme.colPrimary,
                          );
                        },
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: RatingBar(
                        initialRating: 0,
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: 22,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 2.0),
                        ratingWidget: RatingWidget(
                            full: Icon(
                              Icons.star,
                              color: ColorsTheme.colPrimary,
                            ),
                            empty: Icon(
                              Icons.star,
                              color: ColorsTheme.colC4D9D4,
                            ),
                            half: Container()),
                        onRatingUpdate: (rating) {
                          controller.funAddOrderRating(rating, '');
                        },
                      ),
                    )
            ],
          )),
    );
  }

  orderDetails() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Details'.tr,
            style: semiBoldTextStyle(
                fontSize: dimen12, color: ColorsTheme.colBlack),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: ColorsTheme.colC4D9D4, width: 1),
                borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(
              top: 15,
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: ListView.builder(
                itemCount: controller.orderDetailsModel!.menuDetails!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: Image.asset(
                                    controller
                                                .orderDetailsModel!
                                                .menuDetails![index]
                                                .foodPreference ==
                                            'non-veg'
                                        ? Res.icNonVeg
                                        : Res.icVeg,
                                    width: 16,
                                    height: 16,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${controller.orderDetailsModel!.menuDetails![index].menuName!} : ${controller.orderDetailsModel!.menuDetails![index].menuType!}',
                                        maxLines: 2,
                                        style: regularTextStyle(
                                            fontSize: dimen11,
                                            color: ColorsTheme.colBlack),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${controller.currency}${controller.orderDetailsModel!.menuDetails![index].offerPrice!}',
                                            style: TextStyle(
                                                fontSize: dimen11,
                                                color: ColorsTheme.col5dD6E68,
                                                fontWeight: FontWeight.w500,
                                                decorationColor:
                                                    ColorsTheme.col5dD6E68,
                                                decoration:
                                                    TextDecoration.lineThrough),
                                            maxLines: 2,
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 5),
                                            child: Text(
                                              '${controller.currency}${controller.orderDetailsModel!.menuDetails![index].finalPrice!}',
                                              style: semiBoldTextStyle(
                                                  fontSize: dimen12,
                                                  color: ColorsTheme.colBlack),
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorsTheme.colD0F0BF,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 7),
                          child: Text(
                            '${controller.orderDetailsModel!.menuDetails![index].quantity!}',
                            style: regularTextStyle(
                                fontSize: dimen11, color: ColorsTheme.colBlack),
                          ),
                        )
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  billDetails() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Details'.tr,
            style: semiBoldTextStyle(
                fontSize: dimen12, color: ColorsTheme.colBlack),
          ),
          Container(
              decoration: BoxDecoration(
                  border: Border.all(color: ColorsTheme.colC4D9D4, width: 1),
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Item Charges'.tr,
                          style: semiBoldTextStyle(
                              fontSize: dimen12, color: ColorsTheme.colBlack),
                        ),
                        Row(
                          children: [
                            Text(
                              '${controller.currency}${controller.subTotalOfferPrice.value}',
                              style: TextStyle(
                                  fontSize: dimen11,
                                  color: ColorsTheme.col5dD6E68,
                                  fontWeight: FontWeight.w500,
                                  decorationColor: ColorsTheme.col5dD6E68,
                                  decoration: TextDecoration.lineThrough),
                              maxLines: 2,
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 5),
                              child: Text(
                                '${controller.currency}${controller.subTotalPrice.value}',
                                style: semiBoldTextStyle(
                                    fontSize: dimen12,
                                    color: ColorsTheme.colBlack),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total GST'.tr,
                              style: regularTextStyle(
                                  fontSize: dimen11,
                                  color: ColorsTheme.colBlack),
                            ),
                            SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Get.dialog(
                                  Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    insetPadding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 24),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Header with icon + title
                                          Row(
                                            children: [
                                              Icon(Icons.receipt_long,
                                                  color: ColorsTheme.colPrimary,
                                                  size: 26),
                                              const SizedBox(width: 8),
                                              Text(
                                                'GST Details'.tr,
                                                style: semiBoldTextStyle(
                                                  fontSize: dimen16,
                                                  color: ColorsTheme.colBlack,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),

                                          // Item GST
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Item GST'.tr,
                                                style: regularTextStyle(
                                                  fontSize: dimen13,
                                                  color: ColorsTheme.colBlack
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                              Text(
                                                '${controller.currency}${controller.otherTotalPrice.value}',
                                                style: semiBoldTextStyle(
                                                  fontSize: dimen13,
                                                  color: ColorsTheme.colBlack,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(height: 20),

                                          // Platform GST
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Platform GST'.tr,
                                                style: regularTextStyle(
                                                  fontSize: dimen13,
                                                  color: ColorsTheme.colBlack
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                              Text(
                                                '${controller.currency}${controller.platformGst.value}',
                                                style: semiBoldTextStyle(
                                                  fontSize: dimen13,
                                                  color: ColorsTheme.colBlack,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 20),

                                          // Close Button
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    ColorsTheme.colPrimary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                              ),
                                              onPressed: () => Get.back(),
                                              child: Text(
                                                'Close'.tr,
                                                style: semiBoldTextStyle(
                                                  fontSize: dimen13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.info_outline,
                                size: 16,
                                color: ColorsTheme.colPrimary,
                              ),
                            ),
                          ],
                        ),
                        Obx(() => Text(
                              '${controller.currency}${controller.combinedGst.value}',
                              style: regularTextStyle(
                                  fontSize: dimen11,
                                  color: ColorsTheme.colBlack),
                            ))
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Platform Fee'.tr,
                          style: regularTextStyle(
                              fontSize: dimen11, color: ColorsTheme.colBlack),
                        ),
                        Obx(() => Text(
                              '${controller.currency}${controller.platformFee.value}',
                              style: regularTextStyle(
                                  fontSize: dimen11,
                                  color: ColorsTheme.colBlack),
                            ))
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Divider(
                      color: ColorsTheme.colC4D9D4,
                      thickness: 1,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Pay'.tr,
                        style: semiBoldTextStyle(
                            fontSize: dimen12, color: ColorsTheme.colBlack),
                      ),
                      Text(
                        '${controller.currency}${controller.totalPrice.value}',
                        style: semiBoldTextStyle(
                            fontSize: dimen12, color: ColorsTheme.colBlack),
                        maxLines: 2,
                      )
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }

  cancelOrder() {
    return Container(
      margin: const EdgeInsets.only(bottom: 6, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          controller.orderDetailsModel!.refundData != null &&
                  controller.orderDetailsModel!.refundData!.reason != null &&
                  controller.orderDetailsModel!.refundData!.reason!.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Cancelled'.tr,
                      style: semiBoldTextStyle(
                          fontSize: dimen12, color: ColorsTheme.colBlack),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: Text(
                        controller.orderDetailsModel!.refundData!.reason!,
                        style: regularTextStyle(
                            fontSize: dimen12, color: ColorsTheme.colBlack),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Divider(
                        color: ColorsTheme.colC4D9D4,
                        thickness: 1,
                      ),
                    ),
                  ],
                )
              : Container(),
          controller.orderDetailsModel!.paymentMethod != 'cod'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refund Status'.tr,
                      style: semiBoldTextStyle(
                          fontSize: dimen12, color: ColorsTheme.colBlack),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: Text(
                        'Refund will be credited in 1-2 business days',
                        style: regularTextStyle(
                            fontSize: dimen12, color: ColorsTheme.colBlack),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Divider(
                        color: ColorsTheme.colC4D9D4,
                        thickness: 1,
                      ),
                    ),
                  ],
                )
              : Container()
        ],
      ),
    );
  }

  restaurantDetails() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restaurant Details'.tr,
            style: semiBoldTextStyle(
                fontSize: dimen12, color: ColorsTheme.colBlack),
          ),
          Container(
              decoration: BoxDecoration(
                  border: Border.all(color: ColorsTheme.colC4D9D4, width: 1),
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 35,
                              height: 35,
                              child: ClipOval(
                                child: controller
                                            .orderDetailsModel!
                                            .restaurantDetail!
                                            .restaurantProfile ==
                                        null
                                    ? Image.asset(
                                        Res.icDummyBanner,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        controller
                                            .orderDetailsModel!
                                            .restaurantDetail!
                                            .restaurantProfile!,
                                        fit: BoxFit.cover, errorBuilder:
                                            (context, obj, stackTrace) {
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
                                            .orderDetailsModel!
                                            .restaurantDetail!
                                            .restaurantCoverProfile ==
                                        null
                                    ? Image.asset(
                                        Res.icDummyLogo,
                                        width: 16,
                                        height: 16,
                                      )
                                    : Image.network(
                                        controller
                                            .orderDetailsModel!
                                            .restaurantDetail!
                                            .restaurantCoverProfile!,
                                        width: 16,
                                        height: 16, errorBuilder:
                                            (context, obj, stackTrace) {
                                        return Image.asset(
                                          Res.icDummyLogo,
                                          width: 16,
                                          height: 16,
                                        );
                                      }))
                          ],
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    '${controller.orderDetailsModel!.restaurantDetail!.restaurantName} - ${controller.orderDetailsModel!.restaurantDetail!.restaurantAddress}',
                                    maxLines: 2,
                                    style: semiBoldTextStyle(
                                        fontSize: dimen13,
                                        color: ColorsTheme.colBlack),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    controller.orderDetailsModel!
                                                .restaurantDetail!.avgRating!
                                                .toString() ==
                                            ""
                                        ? Container()
                                        : Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    color:
                                                        ColorsTheme.colPrimary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 5),
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 5),
                                                      child: Icon(
                                                        Icons.star,
                                                        color: ColorsTheme
                                                            .colWhite,
                                                        size: 14,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${controller.orderDetailsModel!.restaurantDetail!.avgRating!.toStringAsFixed(1)}',
                                                      style: regularTextStyle(
                                                          fontSize: dimen10,
                                                          color: ColorsTheme
                                                              .colWhite),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              controller
                                                          .orderDetailsModel!
                                                          .restaurantDetail!
                                                          .totalReview ==
                                                      0
                                                  ? Container()
                                                  : Text(
                                                      '(${controller.orderDetailsModel!.restaurantDetail!.totalReview})',
                                                      style: regularTextStyle(
                                                          fontSize: dimen12,
                                                          color: ColorsTheme
                                                              .colBlack),
                                                    ),
                                            ],
                                          ),
                                    Row(
                                      children: [
                                        Visibility(
                                          visible: controller
                                                      .orderDetailsModel!
                                                      .restaurantDetail!
                                                      .isVeg ==
                                                  2 ||
                                              controller
                                                      .orderDetailsModel!
                                                      .restaurantDetail!
                                                      .isVeg ==
                                                  0,
                                          child: Image.asset(
                                            Res.icVeg,
                                            width: 18,
                                            height: 18,
                                          ),
                                        ),
                                        Visibility(
                                          visible: controller
                                                      .orderDetailsModel!
                                                      .restaurantDetail!
                                                      .isVeg ==
                                                  1 ||
                                              controller
                                                      .orderDetailsModel!
                                                      .restaurantDetail!
                                                      .isVeg ==
                                                  0,
                                          child: const SizedBox(
                                            width: 10,
                                          ),
                                        ),
                                        Visibility(
                                          visible: controller
                                                      .orderDetailsModel!
                                                      .restaurantDetail!
                                                      .isVeg ==
                                                  1 ||
                                              controller
                                                      .orderDetailsModel!
                                                      .restaurantDetail!
                                                      .isVeg ==
                                                  0,
                                          child: Image.asset(
                                            Res.icNonVeg,
                                            width: 18,
                                            height: 18,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Divider(
                      color: ColorsTheme.colC4D9D4,
                      thickness: 1,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Image.asset(
                                Res.icLocation,
                                width: 35,
                                height: 35,
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Text(
                                    controller.orderDetailsModel!
                                        .restaurantDetail!.restaurantAddress!,
                                    maxLines: 2,
                                    style: regularTextStyle(
                                        fontSize: dimen11,
                                        color: ColorsTheme.colBlack),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (controller.orderDetailsModel!.restaurantDetail!
                                        .latitude !=
                                    0 &&
                                controller.orderDetailsModel!.restaurantDetail!
                                        .longitude !=
                                    0) {
                              controller.openMap(
                                  controller.orderDetailsModel!
                                      .restaurantDetail!.latitude!,
                                  controller.orderDetailsModel!
                                      .restaurantDetail!.longitude!);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: ColorsTheme.colPrimary),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: Text(
                              'View Map'.tr,
                              style: regularTextStyle(
                                  fontSize: dimen11,
                                  color: ColorsTheme.colWhite),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Divider(
                      color: ColorsTheme.colC4D9D4,
                      thickness: 1,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        Image.asset(
                          Res.icPickupTime,
                          width: 35,
                          height: 35,
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              'Pickup ${CommonFunction.formatOrderPickupDate(controller.orderDetailsModel!.pickupDate!)} at ${CommonFunction.formatPickupTime(controller.orderDetailsModel!.pickupTime!)}-${CommonFunction.formatPickupTime(controller.orderDetailsModel!.pickupEndTime!) ?? ""}',
                              style: regularTextStyle(
                                  fontSize: dimen11,
                                  color: ColorsTheme.colBlack),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  paymentType() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment'.tr,
            style: semiBoldTextStyle(
                fontSize: dimen12, color: ColorsTheme.colBlack),
          ),
          Container(
              decoration: BoxDecoration(
                  border: Border.all(color: ColorsTheme.colC4D9D4, width: 1),
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            controller.orderDetailsModel!.paymentMethod
                                .toString()
                                .toUpperCase(),
                            style: mediumTextStyle(
                                fontSize: dimen12, color: ColorsTheme.colBlack),
                          ),
                        ),
                        Text(
                          '${controller.orderDetailsModel!.createdDate.toString()} at ${controller.orderDetailsModel!.createdTime ?? ""}',
                          style: regularTextStyle(
                              fontSize: dimen11, color: ColorsTheme.colBlack),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      child: Text(
                        '${controller.currency}${controller.totalPrice.value}',
                        style: semiBoldTextStyle(
                            fontSize: dimen12, color: ColorsTheme.colBlack),
                        maxLines: 2,
                      ),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // Bottom cancel button and cancel summary popup
  @override
  Widget? bottomNavigationBar() {
    return Obx(() {
      final status = controller.orderStatus.value;
      final diffMinutes = controller.cancelDiffMinutes.value;
      final secondsLeft = controller.remainingSeconds.value;

      final bool show = (status == 'confirmation_pending' ||
              status == 'Confirmation Pending') &&
          secondsLeft > 0 &&
          (diffMinutes <= 96 && diffMinutes >= 0);

      debugPrint(
          "Cancel Diff Minutes in ODP $diffMinutes, secondsLeft=$secondsLeft, show=$show");

      if (!show) return const SizedBox.shrink();

      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top countdown progress bar (shrinks right->left) with tortoise and MM:SS
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
              child: CountdownProgressBar(
                diffMinutes: controller.cancelDiffMinutes.value,
                remainingSecondsExternal: controller.remainingSeconds.value,
                totalMinutes: 5,
                onFinished: () {
                  // Optionally react when finished (e.g., hide UI or update controller)
                },
                barHeight: 6,
              ),
            ),
            // Existing cancel button
            Container(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              decoration:
                  BoxDecoration(color: ColorsTheme.colWhite, boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2))
              ]),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ColorsTheme.colFF4E4E, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: ColorsTheme.colFF4E4E,
                  ),
                  onPressed: _openCancelSummaryDialog,
                  child: Text(
                    'Cancel Order'.tr,
                    style: semiBoldTextStyle(
                        fontSize: dimen12, color: ColorsTheme.colFF4E4E),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _openCancelSummaryDialog() {
    if (controller.orderDetailsModel == null) return;

    final order = controller.orderDetailsModel!;
    final status = controller.orderStatus.value;

    debugPrint('message: confirmation: $status');

    // For confirmation_pending (and payment_pending), show the custom-styled popup matching the reference
    if (status == 'confirmation_pending' || status == 'Confirmation Pending') {
      final String method = (order.paymentMethod ?? '').toUpperCase();
      final int totalQty = (order.menuDetails ?? [])
          .map((m) => m.quantity ?? 0)
          .fold(0, (a, b) => a + b);
      final double orderTotal = controller.totalPrice.value;
      String fmt(double v) => v.toStringAsFixed(2);

      Get.dialog(
        Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Warning icon inside a soft red circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ColorsTheme.colFF4E4E.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.report_rounded,
                      color: ColorsTheme.colFF4E4E, size: 22),
                ),
                const SizedBox(height: 10),
                Text('Cancel order'.tr,
                    style: semiBoldTextStyle(
                        fontSize: dimen16, color: ColorsTheme.colBlack)),
                const SizedBox(height: 6),
                Text(
                  'Are you sure you want to cancel this order?'.tr,
                  textAlign: TextAlign.center,
                  style: regularTextStyle(
                      fontSize: dimen12, color: ColorsTheme.colBlack),
                ),
                const SizedBox(height: 14),
                // Payment method + qty + total amount pill
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          method.isEmpty ? '—' : method,
                          style: semiBoldTextStyle(
                              fontSize: dimen12, color: ColorsTheme.colBlack),
                        ),
                      ),
                      Text(
                        '${totalQty} Qty at ${controller.currency}${fmt(orderTotal)}',
                        style: regularTextStyle(
                            fontSize: dimen11, color: ColorsTheme.colBlack),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Buttons row matching visual weight
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Colors.black.withOpacity(0.15),
                              width: 1.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: ColorsTheme.colBlack,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () => Get.back(),
                        child: Text('Go back'.tr,
                            style: semiBoldTextStyle(
                                fontSize: dimen12,
                                color: ColorsTheme.colBlack)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: ColorsTheme.colPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        onPressed: () async {
                          Get.back();
                          var result = await Get.toNamed(
                            Routes.orderCancel,
                            arguments: {
                              'orderId': controller.orderId,
                              'amount': controller.totalPrice.value,
                              'resId': controller.resId,
                              'pickupDate': order.pickupDate ?? '',
                              'pickupTime': order.pickupTime ?? '',
                              'pickupEndTime': order.pickupEndTime ?? '',
                              'orderStatus': status,
                            },
                          );
                          if (result != null && result) {
                            controller.backResult.value = true;
                            controller.getOrderDetails();
                          }
                        },
                        child: Text('Yes, Cancel'.tr,
                            style: semiBoldTextStyle(
                                fontSize: dimen12, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Note (do not remove)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorsTheme.colFF4E4E.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'You may not be eligible for full refund. Processing charges will be deducted.'
                        .tr,
                    style: semiBoldTextStyle(
                        fontSize: dimen11, color: ColorsTheme.colFF4E4E),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      );
      return;
    }

    // Default confirmation dialog (with note)
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cancel Order'.tr,
            style: semiBoldTextStyle(
                fontSize: dimen14, color: ColorsTheme.colBlack)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this order?'.tr,
              style: regularTextStyle(
                  fontSize: dimen12, color: ColorsTheme.colBlack),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorsTheme.colFF4E4E.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'You may not be eligible for full refund. Processing charges will be deducted.'
                    .tr,
                style: semiBoldTextStyle(
                    fontSize: dimen11, color: ColorsTheme.colFF4E4E),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('No'.tr,
                style: semiBoldTextStyle(
                    fontSize: dimen12, color: ColorsTheme.colBlack)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              var result = await Get.toNamed(
                Routes.orderCancel,
                arguments: {
                  'orderId': controller.orderId,
                  'amount': controller.totalPrice.value,
                  'resId': controller.resId,
                  'pickupDate': order.pickupDate ?? '',
                  'pickupTime': order.pickupTime ?? '',
                  'pickupEndTime': order.pickupEndTime ?? '',
                  'orderStatus': status,
                },
              );
              if (result != null && result) {
                controller.backResult.value = true;
                controller.getOrderDetails();
              }
            },
            child: Text('Yes'.tr,
                style: semiBoldTextStyle(
                    fontSize: dimen12, color: ColorsTheme.colFF4E4E)),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Widget _cancelSummaryDialog({
    required int orderId,
    required String currency,
    required double orderTotal,
    required double cancellationFee,
    required double expectedRefund,
    required String pickupDate,
    required String pickupTime,
    required String pickupEndTime,
    required VoidCallback onProceed,
  }) {
    String pickupLabel = '';
    try {
      final dateStr = CommonFunction.formatOrderPickupDate(pickupDate);
      final start = CommonFunction.formatPickupTime(pickupTime);
      final end = CommonFunction.formatPickupTime(pickupEndTime);
      pickupLabel = 'Pickup $dateStr at $start-${end ?? ''}';
    } catch (_) {}

    String fmt(double v) => v.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cancel Order'.tr,
                  style: semiBoldTextStyle(
                      fontSize: dimen14, color: ColorsTheme.colBlack)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              )
            ],
          ),
          const SizedBox(height: 4),

          // Order details section
          Text('Order Details'.tr,
              style: semiBoldTextStyle(
                  fontSize: dimen12, color: ColorsTheme.colBlack)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: ColorsTheme.colC4D9D4, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order ID'.tr,
                        style: regularTextStyle(
                            fontSize: dimen11, color: ColorsTheme.colBlack)),
                    Text('#$orderId',
                        style: semiBoldTextStyle(
                            fontSize: dimen12, color: ColorsTheme.colBlack)),
                  ],
                ),
                const SizedBox(height: 8),
                if (pickupLabel.isNotEmpty)
                  Text(pickupLabel,
                      style: regularTextStyle(
                          fontSize: dimen11, color: ColorsTheme.colBlack)),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Payment details section
          Text('Payment Details'.tr,
              style: semiBoldTextStyle(
                  fontSize: dimen12, color: ColorsTheme.colBlack)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: ColorsTheme.colC4D9D4, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order total'.tr,
                        style: regularTextStyle(
                            fontSize: dimen11, color: ColorsTheme.colBlack)),
                    Text('$currency${fmt(orderTotal)}',
                        style: semiBoldTextStyle(
                            fontSize: dimen12, color: ColorsTheme.colBlack)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cancellation fee'.tr,
                        style: regularTextStyle(
                            fontSize: dimen11, color: ColorsTheme.colBlack)),
                    Text('- $currency${fmt(cancellationFee)}',
                        style: semiBoldTextStyle(
                            fontSize: dimen12, color: ColorsTheme.colFF4E4E)),
                  ],
                ),
                const SizedBox(height: 6),
                Divider(color: ColorsTheme.colC4D9D4, thickness: 1),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Expected Refund'.tr,
                        style: semiBoldTextStyle(
                            fontSize: dimen12, color: ColorsTheme.colBlack)),
                    Text('$currency${fmt(expectedRefund)}',
                        style: semiBoldTextStyle(
                            fontSize: dimen12, color: ColorsTheme.colBlack)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ColorsTheme.colC4D9D4, width: 1.2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Get.back(),
                  child: Text('Close'.tr,
                      style: semiBoldTextStyle(
                          fontSize: dimen12, color: ColorsTheme.colBlack)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsTheme.colFF4E4E,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: ColorsTheme.colWhite,
                  ),
                  onPressed: onProceed,
                  child: Text('Proceed to cancel'.tr,
                      style: semiBoldTextStyle(
                          fontSize: dimen12, color: ColorsTheme.colWhite)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
