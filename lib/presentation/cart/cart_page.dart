import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/shared/common_functions.dart';
import 'package:good_grab/infrastructure/shared/snackbar.util.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'package:good_grab/presentation/cart/cart_controller.dart';
import 'package:good_grab/res.dart';

import '../../infrastructure/constants/app_constants.dart';
import '../../infrastructure/models/user_model.dart';
import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/shared/custom_shimmer_widget.dart';
import '../../infrastructure/shared/no_data_screen.dart';
import '../../infrastructure/shared/pref_manager.dart';

class CartPage extends BaseView<CartController> {
  CartPage({super.key});

  @override
  bool onBackPressed() {
    var controller = Get.find<CartController>();
    Get.back(result: controller.isBack.value);
    return false;
  }

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
                  var controller = Get.find<CartController>();
                  Get.back(result: controller.isBack.value);
                },
                child: Icon(
                  Icons.arrow_back,
                  size: 25,
                  color: ColorsTheme.colBlack,
                ),
              ),
              Expanded(
                child: Center(
                  child: Obx(
                    () => Text(
                      controller.title.value == 'pickup'
                          ? 'Pickup'.tr
                          : 'Cart'.tr,
                      style: boldTextStyle(
                          fontSize: dimen16, color: ColorsTheme.colBlack),
                    ),
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
            child: Obx(() => controller.cartLoader.value
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
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
                            subtitle: const CustomShimmerWidget.rectangular(
                                height: 14),
                          );
                        }),
                  )
                : controller.title.value == 'pickup'
                    ? pickupWidget()
                    : SingleChildScrollView(
                        child: !controller.isCartData.value
                            ? Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: Get.height * 0.2),
                                child: noDataScreen(
                                  noDataImage: Res.icRestaurant,
                                  title: 'no_data_found'.tr,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(
                                    () => controller.menuList.isNotEmpty
                                        ? cartDetails()
                                        : Container(),
                                  ),
                                  billDetails(),
                                  pickupDetails(),
                                  cancellationWidget(),
                                  numberWidget(),
                                  // cancellationWidget(),
                                  Obx(() => controller.userPhoneNumber.isEmpty
                                      ? proceedButton()
                                      : Container()),
                                  Obx(() =>
                                      controller.userPhoneNumber.isNotEmpty
                                          ? codPayment()
                                          : Container()),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  // cancellationWidget(),
                                ],
                              ),
                      )))
      ],
    ));
  }

  cartDetails() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 18, right: 18, top: 10),
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
              child: Obx(
                () => ListView.builder(
                    itemCount: controller.menuList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                        controller.menuList[index]
                                                    .foodPrefrence ==
                                                'veg'
                                            ? Res.icVeg
                                            : controller.menuList[index]
                                                        .foodPrefrence ==
                                                    'non-veg'
                                                ? Res.icNonVeg
                                                : Res.icDummyFoodType,
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
                                            '${controller.menuList[index].menuName} : ${controller.menuList[index].menuType == 'preDefined' ? "Menu" : "Magic Bag"}',
                                            maxLines: 2,
                                            style: regularTextStyle(
                                                fontSize: dimen11,
                                                color: ColorsTheme.colBlack),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '${controller.currency.value}${controller.menuList[index].menuOfferPrice}',
                                                style: TextStyle(
                                                    fontSize: dimen11,
                                                    color:
                                                        ColorsTheme.col5dD6E68,
                                                    fontWeight: FontWeight.w500,
                                                    decorationColor:
                                                        ColorsTheme.col5dD6E68,
                                                    decoration: TextDecoration
                                                        .lineThrough),
                                                maxLines: 2,
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 5),
                                                child: Text(
                                                  '${controller.currency.value}${controller.menuList[index].menuFinalPrice}',
                                                  style: semiBoldTextStyle(
                                                      fontSize: dimen12,
                                                      color:
                                                          ColorsTheme.colBlack),
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ],
                                          ),

                                          ///client changes
                                          Visibility(
                                            visible: true,
                                            child: Text(
                                              'Pickup Time ${CommonFunction.formatPickupTime(controller.menuList[index].menuStartTime.toString())} - ${CommonFunction.formatPickupTime(controller.menuList[index].menuEndTime.toString())}',
                                              maxLines: 2,
                                              style: regularTextStyle(
                                                  fontSize: dimen11,
                                                  color: ColorsTheme.colBlack),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: ColorsTheme.colD0F0BF,
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 7),
                              margin: const EdgeInsets.only(left: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      controller.removeCart(index);
                                    },
                                    child: Image.asset(
                                      Res.icMinus,
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      controller
                                          .menuList[index].menuSelectedQuantity
                                          .toString(),
                                      style: regularTextStyle(
                                          fontSize: dimen14,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      controller.addCart(index);
                                    },
                                    child: Image.asset(
                                      Res.icPluse,
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }),
              )),
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
            'Payment Details'.tr,
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
                            Obx(
                              () => Text(
                                '${controller.currency.value}${controller.subTotalOfferPrice.value.toString()}',
                                style: TextStyle(
                                    fontSize: dimen11,
                                    color: ColorsTheme.col5dD6E68,
                                    fontWeight: FontWeight.w500,
                                    decorationColor: ColorsTheme.col5dD6E68,
                                    decoration: TextDecoration.lineThrough),
                                maxLines: 2,
                              ),
                            ),
                            Obx(
                              () => Container(
                                margin: const EdgeInsets.only(left: 5),
                                child: Text(
                                  '${controller.currency.value}${controller.subTotalFinalPrice.value.toString()}',
                                  style: semiBoldTextStyle(
                                      fontSize: dimen12,
                                      color: ColorsTheme.colBlack),
                                  maxLines: 2,
                                ),
                              ),
                            )
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
                                color: ColorsTheme.colBlack,
                              ),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Get.dialog(
                                  Center(
                                    child: UnconstrainedBox(
                                      child: Material(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        elevation: 10,
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: SizedBox(
                                            width: Get.width *
                                                0.80, // Dialog width
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Title text
                                                Text(
                                                  "Taxes as per Government regulations and restaurant charges"
                                                      .tr,
                                                  style: lightTextStyle(
                                                    fontSize: dimen13,
                                                    color: ColorsTheme.colBlack,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Divider(
                                                  height: 1,
                                                  color: ColorsTheme.colA3A8A4
                                                      .withOpacity(0.2),
                                                ), // compact divider
                                                const SizedBox(height: 10),
                                                // GST on item total
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "GST on item total".tr,
                                                      style: semiBoldTextStyle(
                                                        fontSize: dimen12,
                                                        color: ColorsTheme
                                                            .colBlack,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${controller.currency.value}${controller.totalGst.value.toStringAsFixed(2)}',
                                                      style: semiBoldTextStyle(
                                                        fontSize: dimen12,
                                                        color: ColorsTheme
                                                            .colBlack,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),

                                                // GST on platform fee
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "GST on platform fee".tr,
                                                      style: semiBoldTextStyle(
                                                        fontSize: dimen12,
                                                        color: ColorsTheme
                                                            .colBlack,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${controller.currency.value}${controller.platformGst.value.toStringAsFixed(2)}',
                                                      style: semiBoldTextStyle(
                                                        fontSize: dimen12,
                                                        color: ColorsTheme
                                                            .colBlack,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Divider(
                                                  height: 1,
                                                  color: ColorsTheme.colA3A8A4
                                                      .withOpacity(0.2),
                                                ),
                                                const SizedBox(height: 6),

                                                // Total
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Total".tr,
                                                      style: semiBoldTextStyle(
                                                        fontSize: dimen12,
                                                        color: ColorsTheme
                                                            .colBlack,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${controller.currency.value}${controller.combinedGst.value.toStringAsFixed(2)}',
                                                      style: semiBoldTextStyle(
                                                        fontSize: dimen12,
                                                        color: ColorsTheme
                                                            .colBlack,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 16),

                                                // OK Button (full width)
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          ColorsTheme
                                                              .colPrimary,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 10,
                                                      ),
                                                    ),
                                                    onPressed: () => Get.back(),
                                                    child: Text(
                                                      'OKAY'.tr,
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
                                      ),
                                    ),
                                  ),
                                  barrierDismissible: true,
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

                        // GST value beside info icon
                        Obx(() => Text(
                              '${controller.currency.value}${controller.combinedGst.value.toStringAsFixed(2)}',
                              style: regularTextStyle(
                                fontSize: dimen11,
                                color: ColorsTheme.colBlack,
                              ),
                            )),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Platform Fee'.tr,
                                style: regularTextStyle(
                                  fontSize: dimen11,
                                  color: ColorsTheme.colBlack,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  "(This keeps us maintaining our service)",
                                  style: regularTextStyle(
                                    fontSize: dimen10,
                                    color: ColorsTheme.colBlack,
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // ✅ avoids overflow
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(() => Text(
                              '${controller.currency.value}${controller.platformFee.value.toStringAsFixed(2)}',
                              style: regularTextStyle(
                                fontSize: dimen11,
                                color: ColorsTheme.colBlack,
                              ),
                            )),
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
                      Obx(() => Text(
                            '${controller.currency.value}${controller.totalPay.value.toStringAsFixed(2)}', //change by krishna
                            style: semiBoldTextStyle(
                                fontSize: dimen12, color: ColorsTheme.colBlack),
                            maxLines: 2,
                          ))
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }

  pickupDetails() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pickup Details'.tr,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pickup Date'.tr,
                          style: semiBoldTextStyle(
                              fontSize: dimen12, color: ColorsTheme.colBlack),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          child: Obx(
                            () => Text(
                              controller.pickupDate.value,
                              style: regularTextStyle(
                                  fontSize: dimen11,
                                  color: ColorsTheme.colBlack),
                              maxLines: 2,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  ///client changes
                  // Container(
                  //   margin: const EdgeInsets.only(bottom: 2),
                  //   child: Divider(
                  //     color: ColorsTheme.colC4D9D4,
                  //     thickness: 1,
                  //   ),
                  // ),
                  // Container(
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Text(
                  //         'Restaurant Time'.tr,
                  //         style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                  //       ),
                  //       Container(
                  //         margin: const EdgeInsets.only(left: 5),
                  //         child: Obx(
                  //           () => Text(
                  //             '${CommonFunction.formatPickupTime(controller.pickupStartTime.value)} - ${CommonFunction.formatPickupTime(controller.pickupCloseTime.value)}',
                  //             style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                  //             maxLines: 2,
                  //           ),
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // ),
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
                        'Pickup Location'.tr,
                        style: semiBoldTextStyle(
                            fontSize: dimen12, color: ColorsTheme.colBlack),
                      ),
                      Flexible(
                          child: Container(
                        margin: const EdgeInsets.only(left: 15),
                        child: Obx(
                          () => Text(
                            controller.pickupLocation.value,
                            style: regularTextStyle(
                                fontSize: dimen11, color: ColorsTheme.colBlack),
                            maxLines: 2,
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }

  proceedButton() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 18, top: 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (controller.userId.value != -1 &&
                    controller.userId.value != 0) {
                  if (controller.userPhoneNumber.isNotEmpty) {
                    controller.isProceedClicked.value = true;
                  } else {
                    SnackBarUtil.showWarning(
                        message: "Please add mobile number first".tr);
                  }
                } else {
                  loginBottomSheet();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: ColorsTheme.colPrimary, width: 1),
                    borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                margin: const EdgeInsets.only(right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Proceed'.tr,
                      style: semiBoldTextStyle(
                          fontSize: dimen13, color: ColorsTheme.colBlack),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  codPayment() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 18, top: 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (controller.userId.value != -1 &&
                    controller.userId.value != 0) {
                  // controller.startPgTransaction();
                  await controller.placeOrderWithoutPayment('phonePe');
                } else {
                  loginBottomSheet();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: ColorsTheme.colPrimary, width: 1),
                    borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                margin: const EdgeInsets.only(right: 15),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: ColorsTheme.colSecondary, width: 1),
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      child: Text(
                        '₹'.tr,
                        style: boldTextStyle(
                            fontSize: dimen20, color: ColorsTheme.colBlack),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: Text(
                        'PhonePe'.tr,
                        style: semiBoldTextStyle(
                            fontSize: dimen13, color: ColorsTheme.colBlack),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (controller.userId.value != -1 &&
                    controller.userId.value != 0) {
                  // controller.rCreateOrder();
                  await controller.placeOrderWithoutPayment('razorpay');
                } else {
                  loginBottomSheet();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: ColorsTheme.colPrimary, width: 1),
                    borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                margin: const EdgeInsets.only(left: 15),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: ColorsTheme.colSecondary, width: 1),
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      child: Text(
                        '₹'.tr,
                        style: boldTextStyle(
                            fontSize: dimen20, color: ColorsTheme.colBlack),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 15),
                        child: Text(
                          'RazorPay'.tr,
                          style: semiBoldTextStyle(
                              fontSize: dimen13, color: ColorsTheme.colBlack),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  codPayment1() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Others'.tr,
            style: semiBoldTextStyle(
                fontSize: dimen12, color: ColorsTheme.colBlack),
          ),
          Container(
              decoration: BoxDecoration(
                  border: Border.all(color: ColorsTheme.colC4D9D4, width: 1),
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      controller.paymentType.value =
                          controller.paymentType.value == 'intent'
                              ? ''
                              : 'intent';
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 18, top: 18),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: ColorsTheme.colC4D9D4, width: 1),
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 3),
                            child: Text(
                              '₹'.tr,
                              style: boldTextStyle(
                                  fontSize: dimen20,
                                  color: ColorsTheme.colBlack),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: Text(
                              'Pay Via Online',
                              style: mediumTextStyle(
                                  fontSize: dimen12,
                                  color: ColorsTheme.colBlack),
                              maxLines: 2,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Obx(
                    () => Visibility(
                      visible: controller.paymentType.value == 'intent',
                      child: GestureDetector(
                        onTap: () {
                          if (controller.userId.value != -1 &&
                              controller.userId.value != 0) {
                            controller.placeOrderUpi();
                          } else {
                            loginBottomSheet();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: ColorsTheme.colPrimary,
                              borderRadius: BorderRadius.circular(50)),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          margin: const EdgeInsets.only(
                              left: 45, right: 45, bottom: 18),
                          child: Text(
                            'Pay'.tr,
                            style: semiBoldTextStyle(
                                fontSize: dimen13, color: ColorsTheme.colWhite),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )),
          Container(
              decoration: BoxDecoration(
                  border: Border.all(color: ColorsTheme.colC4D9D4, width: 1),
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      controller.paymentType.value =
                          controller.paymentType.value == 'upi' ? '' : 'upi';
                    },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 18, top: 18),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: ColorsTheme.colC4D9D4, width: 1),
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 3),
                            child: Text(
                              '₹'.tr,
                              style: boldTextStyle(
                                  fontSize: dimen20,
                                  color: ColorsTheme.colBlack),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: Text(
                              'Pay Via UPI',
                              style: mediumTextStyle(
                                  fontSize: dimen12,
                                  color: ColorsTheme.colBlack),
                              maxLines: 2,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Obx(() => Visibility(
                        visible: controller.paymentType.value == 'upi',
                        child: payWithUpi(),
                      )),
                  Obx(
                    () => Visibility(
                      visible: controller.paymentType.value == "upi",
                      child: GestureDetector(
                        onTap: () {
                          if (controller.userId.value != -1 &&
                              controller.userId.value != 0) {
                            if (controller.upiIdController.text
                                .trim()
                                .isNotEmpty) {
                              controller.placeOrderUpi();
                            }
                          } else {
                            loginBottomSheet();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: controller.isFillColor.value
                                  ? ColorsTheme.colPrimary
                                  : ColorsTheme.colHint,
                              borderRadius: BorderRadius.circular(50)),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          margin: const EdgeInsets.only(
                              left: 45, right: 45, bottom: 18),
                          child: Text(
                            'Pay'.tr,
                            style: semiBoldTextStyle(
                                fontSize: dimen13, color: ColorsTheme.colWhite),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )),
          // Container(
          //     decoration: BoxDecoration(
          //         border: Border.all(color: ColorsTheme.colC4D9D4, width: 1), borderRadius: BorderRadius.circular(16)),
          //     margin: const EdgeInsets.only(top: 15),
          //     padding: const EdgeInsets.only(left: 10, right: 10),
          //     child: Column(
          //       children: [
          //         InkWell(
          //           onTap: () {
          //             controller.paymentType.value = controller.paymentType.value == 'card' ? '' : 'card';
          //           },
          //           highlightColor: Colors.transparent,
          //           splashColor: Colors.transparent,
          //           child: Container(
          //             margin: const EdgeInsets.only(bottom: 18, top: 18),
          //             child: Row(
          //               children: [
          //                 Container(
          //                   decoration: BoxDecoration(
          //                       border: Border.all(color: ColorsTheme.colC4D9D4, width: 1),
          //                       borderRadius: BorderRadius.circular(14)),
          //                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          //                   child: Text(
          //                     '₹'.tr,
          //                     style: boldTextStyle(fontSize: dimen20, color: ColorsTheme.colBlack),
          //                   ),
          //                 ),
          //                 Container(
          //                   margin: const EdgeInsets.only(left: 15),
          //                   child: Text(
          //                     'Pay Via Card',
          //                     style: mediumTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
          //                     maxLines: 2,
          //                   ),
          //                 )
          //               ],
          //             ),
          //           ),
          //         ),
          //         Obx(() => Visibility(
          //               visible: controller.paymentType.value == 'card',
          //               child: payWithCard(),
          //             )),
          //         Obx(
          //           () => Visibility(
          //             visible: controller.paymentType.value == "card",
          //             child: GestureDetector(
          //               onTap: () {
          //                 if (controller.userId.value != -1 && controller.userId.value != 0) {
          //                   if (controller.cardNoController.text.trim().length > 15 &&
          //                       controller.cardNameController.text.trim().isNotEmpty &&
          //                       controller.cardCvvController.text.trim().isNotEmpty &&
          //                       controller.expireMonthController.text.trim().length > 1 &&
          //                       controller.expireYearController.text.trim().length > 3) {
          //                     controller.placeOrderUpi();
          //                   }
          //                 } else {
          //                   loginBottomSheet();
          //                 }
          //               },
          //               child: Container(
          //                 decoration:
          //                     BoxDecoration(color: ColorsTheme.colPrimary, borderRadius: BorderRadius.circular(50)),
          //                 alignment: Alignment.center,
          //                 padding: const EdgeInsets.symmetric(vertical: 15),
          //                 margin: const EdgeInsets.only(left: 45, right: 45, bottom: 18),
          //                 child: Text(
          //                   'Pay'.tr,
          //                   style: semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colWhite),
          //                 ),
          //               ),
          //             ),
          //           ),
          //         )
          //       ],
          //     )),

          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  numberWidget() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phone Number'.tr,
            style:
                mediumTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
          ),
          GestureDetector(
            onTap: () async {
              var result = await Get.toNamed(Routes.changeNumber, arguments: {
                'title': '${'Add'.tr} ${'Mobile Number'.tr}',
                'screenType': 'number'
              });
              if (result != null) {
                controller.isNumberAdd.value = true;
                Map<String, dynamic> resultData =
                    result as Map<String, dynamic>;
                controller.userPhoneNumber.value = resultData['mobile'];
                controller.countryCode.value = resultData['country_code'];
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
                          controller.userPhoneNumber.isEmpty
                              ? '9999999999'
                              : controller.countryCode.isNotEmpty &&
                                      controller.userPhoneNumber.isNotEmpty
                                  ? '+${controller.countryCode.value} ${controller.userPhoneNumber.value}'
                                  : '',
                          style: mediumTextStyle(
                              fontSize: dimen11,
                              color: controller.userPhoneNumber.isEmpty
                                  ? ColorsTheme.colHint
                                  : ColorsTheme.colBlack),
                        )),
                  ),
                  Obx(() => controller.userPhoneNumber.isEmpty
                      ? Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(36),
                              color: ColorsTheme.colPrimary),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          width: 80,
                          alignment: Alignment.center,
                          child: Text(
                            'Add'.tr,
                            style: regularTextStyle(
                                fontSize: dimen11, color: ColorsTheme.colWhite),
                          ))
                      : Container(
                          height: 36,
                        ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  cancellationWidget() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cancellation Policy'.tr,
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
                    // padding: const EdgeInsets.all(8),
                    child: Text(
                      'Cancellation leads to food wastage. A 100% fee will be charged if orders are cancelled any time after they\'re accepted. However, in case of unusual delays you will not be charged any cancellation fees.'
                          .tr,
                      style: regularTextStyle(
                        fontSize: dimen11,
                        color: ColorsTheme.colBlack,
                      ),
                      softWrap: true,
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }

  payWithUpi() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UPI ID'.tr,
            style:
                mediumTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              border: Border.all(
                color: ColorsTheme.colSecondary,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            alignment: Alignment.center,
            child: TextField(
              controller: controller.upiIdController,
              onChanged: (value) {
                controller.changeButtonColor();
              },
              decoration: InputDecoration.collapsed(
                  hintText: 'Enter Upi Id',
                  hintStyle: mediumTextStyle(
                      fontSize: dimen13, color: ColorsTheme.colHint)),
              style: mediumTextStyle(
                  fontSize: dimen13, color: ColorsTheme.colBlack),
            ),
          ),
        ],
      ),
    );
  }

  payWithCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Details',
            style:
                mediumTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              border: Border.all(
                color: ColorsTheme.colSecondary,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            alignment: Alignment.center,
            child: TextField(
              controller: controller.cardNoController,
              maxLength: 16,
              onChanged: (value) {
                // controller.changeButtonColor();
              },
              decoration: InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Enter Card No.',
                  hintStyle: mediumTextStyle(
                      fontSize: dimen13, color: ColorsTheme.colHint)),
              style: mediumTextStyle(
                  fontSize: dimen13, color: ColorsTheme.colBlack),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorsTheme.colSecondary,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 15),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: controller.cardNameController,
                        onChanged: (value) {
                          // controller.changeButtonColor();
                        },
                        decoration: InputDecoration.collapsed(
                            hintText: 'Enter Card Name',
                            hintStyle: mediumTextStyle(
                                fontSize: dimen13, color: ColorsTheme.colHint)),
                        style: mediumTextStyle(
                            fontSize: dimen13, color: ColorsTheme.colBlack),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Container(
                    width: 100,
                    margin: const EdgeInsets.only(top: 15),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ColorsTheme.colSecondary,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: controller.cardCvvController,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        // controller.changeButtonColor();
                      },
                      decoration: InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                          isDense: true,
                          hintText: 'CVV',
                          hintStyle: mediumTextStyle(
                              fontSize: dimen13, color: ColorsTheme.colHint)),
                      style: mediumTextStyle(
                          fontSize: dimen13, color: ColorsTheme.colBlack),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorsTheme.colSecondary,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: controller.expireMonthController,
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          // controller.changeButtonColor();
                        },
                        decoration: InputDecoration(
                            hintText: 'Expire Month',
                            counterText: "",
                            border: InputBorder.none,
                            isDense: true,
                            hintStyle: mediumTextStyle(
                                fontSize: dimen13, color: ColorsTheme.colHint)),
                        style: mediumTextStyle(
                            fontSize: dimen13, color: ColorsTheme.colBlack),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorsTheme.colSecondary,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: controller.expireYearController,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          // controller.changeButtonColor();
                        },
                        decoration: InputDecoration(
                            hintText: 'Expire Year',
                            counterText: "",
                            border: InputBorder.none,
                            isDense: true,
                            hintStyle: mediumTextStyle(
                                fontSize: dimen13, color: ColorsTheme.colHint)),
                        style: mediumTextStyle(
                            fontSize: dimen13, color: ColorsTheme.colBlack),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pickupWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, left: 18, right: 18),
                child: Text(
                  'Select Pickup Day'.tr,
                  style: semiBoldTextStyle(
                      fontSize: dimen15, color: ColorsTheme.colBlack),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, left: 8, right: 8),
                child: Wrap(
                  spacing: 0,
                  children: List.generate(
                    controller.pickupDayList.length,
                    (index) {
                      return GestureDetector(
                        onTap: () {
                          if (controller.pickupDayList[index].isSelect!) {
                            controller.pickupDayIndex.value = index;
                          }
                        },
                        child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Obx(() => labelChip(
                                label: controller.pickupDayList[index].title!,
                                isDisable:
                                    controller.pickupDayList[index].isSelect!,
                                isSelect:
                                    controller.pickupDayIndex.value == index))),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
        footerWidget()
      ],
    );
  }

  footerWidget() {
    return Container(
      color: ColorsTheme.colPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'Magic Bag'.tr} - ${controller.totalQuantity.value}',
                  style: mediumTextStyle(
                      fontSize: dimen12, color: ColorsTheme.colWhite),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '₹${controller.subTotalFinalPrice.value}',
                  style: mediumTextStyle(
                      fontSize: dimen12, color: ColorsTheme.colWhite),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                controller.title.value = 'cart';
                controller.pickupDate.value = controller
                    .pickupDayList[controller.pickupDayIndex.value].title!;
              },
              child: Container(
                decoration: BoxDecoration(
                    color: ColorsTheme.colWhite,
                    borderRadius: BorderRadius.circular(50)),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  '${'View Cart'.tr} →',
                  style: semiBoldTextStyle(
                      fontSize: dimen13, color: ColorsTheme.colBlack),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget labelChip({
    String? label,
    bool? isDisable,
    bool? isSelect,
  }) {
    return Container(
      decoration: !isDisable!
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: ColorsTheme.colSecondary,
              border: Border.all(width: 1, color: Colors.transparent))
          : isSelect!
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: ColorsTheme.colPrimary,
                  border: Border.all(width: 1, color: Colors.transparent))
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.transparent,
                  border: Border.all(width: 1, color: ColorsTheme.colBlack)),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        isDisable ? label! : '"SOLD OUT"  $label',
        style: mediumTextStyle(
          fontSize: dimen12,
          color: !isDisable
              ? ColorsTheme.col8FA19C
              : isSelect!
                  ? ColorsTheme.colWhite
                  : ColorsTheme.colBlack,
        ),
      ),
    );
  }

  loginBottomSheet() {
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
                    'Log in'.tr,
                    style: boldTextStyle(
                        fontSize: dimen15, color: ColorsTheme.colBlack),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    'login_subtitle'.tr,
                    style: regularTextStyle(
                        fontSize: dimen12, color: ColorsTheme.colBlack),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.offAllNamed(Routes.intro, arguments: false);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                        color: ColorsTheme.colPrimary,
                        borderRadius: BorderRadius.circular(40)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    alignment: Alignment.center,
                    child: Text(
                      '${'Log in'.tr} →',
                      style: semiBoldTextStyle(
                          fontSize: dimen13, color: ColorsTheme.colWhite),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
