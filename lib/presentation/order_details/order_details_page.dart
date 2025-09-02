import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/shared/common_functions.dart';

import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/shared/custom_shimmer_widget.dart';
import '../../infrastructure/shared/no_data_screen.dart';
import '../../infrastructure/theme/colors.theme.dart';
import '../../infrastructure/theme/text.theme.dart';
import '../../res.dart';
import 'order_details_controller.dart';

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
              child: Obx(() => controller.loadingData.value
                  ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
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
              ):!controller.isOrderData.value
                  ? SingleChildScrollView(
                child: Container(
                    margin: EdgeInsets.symmetric(vertical: Get.height * 0.2),
                    child: noDataScreen(
                        noDataImage: Res.icRestaurant, title: '${'no_orders_title'.tr}?'.tr, subtitle: 'no_orders_subtitle'.tr)),
              ):SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getStatus(),

                      Visibility(
                        visible: controller.orderStatus.value == 'pending_pick_up',
                        child: Container(
                          margin: const EdgeInsets.only(left: 18, right: 18, bottom: 15),
                          child: Text(
                            'pickup_note'.tr,
                            style: regularTextStyle(fontSize: dimen10, color: ColorsTheme.col8FA19C),
                          ),
                        ),
                      ),
                      Visibility(
                          visible: controller.orderStatus.value == 'completd_pick_up',
                          child: rateOrder()
                      ),
                      controller.orderDetailsModel!.menuDetails != null && controller.orderDetailsModel!.menuDetails!.isNotEmpty?
                      orderDetails():Container(),
                      billDetails(),
                      Visibility(
                        visible: controller.orderStatus.value == 'pending_pick_up',
                        child: GestureDetector(
                          onTap: () async {
                            var result = await Get.toNamed(Routes.orderCancel,arguments: {
                              'orderId':controller.orderId,'amount':controller.totalPrice.value,'resId':controller.resId,
                              'pickupDate' : controller.orderDetailsModel!.pickupDate!,
                              'pickupTime' : controller.orderDetailsModel!.pickupTime!,
                              'pickupEndTime' : controller.orderDetailsModel!.pickupEndTime!,
                            });
                            if(result != null && result){
                              controller.backResult.value = true;
                              controller.getOrderDetails();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8,left: 18,right: 18),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order Cancel'.tr,
                                      style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
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
                          visible: controller.orderStatus.value == 'order_cancel',
                          child: cancelOrder()),
                      Visibility(
                        visible: controller.orderStatus.value != 'pending_pick_up',
                        child: InkWell(onTap: (){
                          Get.toNamed(Routes.appContents, arguments: {'title': 'Contact us'.tr, 'flag': 'contact'});
                        },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: ColorsTheme.colPrimary
                            ),
                            margin: const EdgeInsets.only(bottom: 15,left: 18,right: 18),
                            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 18),
                            child: Text(
                              'Contact us'.tr,
                              style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colWhite),
                            ),
                          ),
                        ),
                      ),
                      controller.orderDetailsModel!.restaurantDetail!=null?restaurantDetails():Container(),
                      paymentType()
                    ],
                  ),
                ),
              ),)
            ),
          ],
        ));
  }

  getStatus() {
    return Obx (() {
      if (controller.orderStatus.value == 'pending_pick_up') {
        return Container(
          width: Get.width,
          decoration: BoxDecoration(color: ColorsTheme.col007752, borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          margin: const EdgeInsets.symmetric(horizontal: 18,vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Order Status'.tr,
                  style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colWhite),
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
                      style: boldTextStyle(fontSize: dimen11, color: ColorsTheme.colWhite),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                    text: '${'Order ID'.tr} : ',
                    style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colWhite),
                  ),
                  TextSpan(
                    text: controller.orderId.toString(),
                    style: boldTextStyle(fontSize: dimen14, color: ColorsTheme.colWhite),
                  )
                ])),
              ),
            ],
          ),
        );
      } else if (controller.orderStatus.value == 'completd_pick_up') {
        return Container(
          width: Get.width,
          decoration: BoxDecoration(color: ColorsTheme.col007752, borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          margin: const EdgeInsets.symmetric(horizontal: 18,vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Order Status'.tr,
                  style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colWhite),
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
                      style: boldTextStyle(fontSize: dimen11, color: ColorsTheme.colWhite),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                    text: '${'Order ID'.tr} : ',
                    style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colWhite),
                  ),
                  TextSpan(
                    text: controller.orderId.toString(),
                    style: boldTextStyle(fontSize: dimen14, color: ColorsTheme.colWhite),
                  )
                ])),
              ),
            ],
          ),
        );
      } else if ( controller.orderStatus.value == 'order_cancel' || controller.orderStatus.value == 'not_picked_up') {
        return Container(
          width: Get.width,
          decoration: BoxDecoration(color: ColorsTheme.colSecondary, borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          margin: const EdgeInsets.symmetric(horizontal: 18,vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Order Status'.tr,
                  style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
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
                      controller.orderStatus.value == 'not_picked_up'?'Not pick-up':'Order Cancelled',
                      style: boldTextStyle(fontSize: dimen11, color: ColorsTheme.colFF4E4E),
                    ),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 2),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                    text: '${'Order ID'.tr} : ',
                    style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                  ),
                  TextSpan(
                    text: controller.orderId.toString(),
                    style: boldTextStyle(fontSize: dimen14, color: ColorsTheme.colBlack),
                  )
                ])),
              ),
            ],
          ),
        );
      }
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 18,vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              child: Text.rich(TextSpan(children: [
                TextSpan(
                  text: '${'Order ID'.tr} : ',
                  style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                ),
                TextSpan(
                  text: controller.orderId.toString(),
                  style: boldTextStyle(fontSize: dimen14, color: ColorsTheme.colBlack),
                )
              ])),
            ),
          ],
        ),
      );
    });
  }

  rateOrder(){
    return Container(
      margin: const EdgeInsets.only(bottom: 15,left: 18,right: 18),
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: ColorsTheme.colC4D9D4,
                  width: 1
              ),
              borderRadius: BorderRadius.circular(16)
          ),

          padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
          width: Get.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 9),
                child: Text(
                  'Rate the order'.tr,
                  style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                ),
              ),
              controller.isRated.value?Container(
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
              ):Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: RatingBar(
                  initialRating: 0,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 22,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                  ratingWidget: RatingWidget(
                    full:  Icon(
                      Icons.star,
                      color: ColorsTheme.colPrimary,
                    ),
                    empty:  Icon(
                      Icons.star,
                      color: ColorsTheme.colC4D9D4,
                    ),
                    half: Container()
                  ),
                  onRatingUpdate: (rating) {

                    controller.funAddOrderRating(rating, '');
                  },
                ),
              )

            ],
          )
      ),
    );
  }

  orderDetails() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15,left: 18,right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Details'.tr,
            style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: ColorsTheme.colC4D9D4,
                width: 1
              ),
              borderRadius: BorderRadius.circular(16)
            ),
            margin: const EdgeInsets.only(top: 15,),
            padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 10),
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
                                    controller.orderDetailsModel!.menuDetails![index].foodPreference == 'non-veg'?Res.icNonVeg:Res.icVeg,
                                    width: 16,
                                    height: 16,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${controller.orderDetailsModel!.menuDetails![index].menuName!} : ${controller.orderDetailsModel!.menuDetails![index].menuType!}',
                                        maxLines: 2,
                                        style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${controller.currency}${controller.orderDetailsModel!.menuDetails![index].offerPrice!}',
                                            style: TextStyle(
                                                fontSize: dimen11,
                                                color: ColorsTheme.col8FA19C,
                                                fontWeight: FontWeight.w500,
                                                decorationColor: ColorsTheme.col8FA19C,
                                                decoration: TextDecoration.lineThrough),
                                            maxLines: 2,
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 5),
                                            child: Text(
                                              '${controller.currency}${controller.orderDetailsModel!.menuDetails![index].finalPrice!}',
                                              style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
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
                          padding: const EdgeInsets.symmetric(horizontal: 9,vertical: 7),
                          child:Text(
                          '${controller.orderDetailsModel!.menuDetails![index].quantity!}',
                            style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
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
      margin: const EdgeInsets.only(bottom: 15,left: 18,right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Details'.tr,
            style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: ColorsTheme.colC4D9D4,
                    width: 1
                ),
                borderRadius: BorderRadius.circular(16)
            ),
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal'.tr,
                        style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                      ),
                      Row(
                        children: [
                          Text(
                            '${controller.currency}${controller.subTotalOfferPrice.value}',
                            style: TextStyle(
                                fontSize: dimen11,
                                color: ColorsTheme.col8FA19C,
                                fontWeight: FontWeight.w500,
                                decorationColor: ColorsTheme.col8FA19C,
                                decoration: TextDecoration.lineThrough),
                            maxLines: 2,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 5),
                            child: Text(
                              '${controller.currency}${controller.subTotalPrice.value}',
                              style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
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
                      Text(
                        'GST'.tr,
                        style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                      ),
                      Text(
                        '${controller.currency}${controller.otherTotalPrice.value}',
                        style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                      )
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
                        style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                      ),
                      Text(
                        '${controller.currency}${controller.platformFee.value}',
                        style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pay'.tr,
                      style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                    ),
                    Text(
                      '${controller.currency}${controller.totalPrice.value}',
                      style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                      maxLines: 2,
                    )
                  ],
                ),
              ],
            )
          ),
        ],
      ),
    );
  }

  cancelOrder(){
    return Container(
      margin: const EdgeInsets.only(bottom: 6,left: 18,right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          controller.orderDetailsModel!.refundData != null &&  controller.orderDetailsModel!.refundData!.reason != null &&  controller.orderDetailsModel!.refundData!.reason!.isNotEmpty?Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Cancelled'.tr,
                style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15),
                child: Text(
                  controller.orderDetailsModel!.refundData!.reason!,
                  style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8,bottom: 8),
                child: Divider(
                  color: ColorsTheme.colC4D9D4,
                  thickness: 1,
                ),
              ),
            ],
          ):Container(),
          controller.orderDetailsModel!.paymentMethod != 'cod'?Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Refund Status'.tr,
                style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15),
                child: Text(
                  'Refund will be credited in 1-2 business days',
                  style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
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
          ):Container()
        ],
      ),
    );
  }

  restaurantDetails() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15,left: 18,right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restaurant Details'.tr,
            style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
          ),
          Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: ColorsTheme.colC4D9D4,
                      width: 1
                  ),
                  borderRadius: BorderRadius.circular(16)
              ),
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
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
                                child: controller.orderDetailsModel!.restaurantDetail!.restaurantProfile == null
                                    ? Image.asset(
                                  Res.icDummyBanner,
                                  fit: BoxFit.cover,
                                )
                                    : Image.network(controller.orderDetailsModel!.restaurantDetail!.restaurantProfile!, fit: BoxFit.cover,
                                    errorBuilder: (context, obj, stackTrace) {
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
                                child: controller.orderDetailsModel!.restaurantDetail!.restaurantCoverProfile == null
                                    ? Image.asset(
                                  Res.icDummyLogo,
                                  width: 16,
                                  height: 16,
                                )
                                    : Image.network(controller.orderDetailsModel!.restaurantDetail!.restaurantCoverProfile!, width: 16, height: 16,
                                    errorBuilder: (context, obj, stackTrace) {
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
                                    style: semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    controller.orderDetailsModel!.restaurantDetail!.avgRating!.toString() == "" ?Container():Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(color: ColorsTheme.colPrimary, borderRadius: BorderRadius.circular(16)),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                          margin: const EdgeInsets.only(right: 10),
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(right: 5),
                                                child: Icon(
                                                  Icons.star,
                                                  color: ColorsTheme.colWhite,
                                                  size: 14,
                                                ),
                                              ),
                                              Text(
                                             '${controller.orderDetailsModel!.restaurantDetail!.avgRating!.toStringAsFixed(1)}',
                                                style: regularTextStyle(fontSize: dimen10, color: ColorsTheme.colWhite),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        controller.orderDetailsModel!.restaurantDetail!.totalReview==0?Container():Text(
                                          '(${controller.orderDetailsModel!.restaurantDetail!.totalReview})',
                                          style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Visibility(
                                          visible:  controller.orderDetailsModel!.restaurantDetail!.isVeg == 2 ||  controller.orderDetailsModel!.restaurantDetail!.isVeg == 0,
                                          child: Image.asset(
                                            Res.icVeg,
                                            width: 18,
                                            height: 18,
                                          ),
                                        ),
                                        Visibility(
                                          visible:  controller.orderDetailsModel!.restaurantDetail!.isVeg == 1 ||  controller.orderDetailsModel!.restaurantDetail!.isVeg == 0,
                                          child: const SizedBox(
                                            width: 10,
                                          ),
                                        ),
                                        Visibility(
                                          visible:  controller.orderDetailsModel!.restaurantDetail!.isVeg == 1 ||  controller.orderDetailsModel!.restaurantDetail!.isVeg == 0,
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
                                  margin: const EdgeInsets.only(left:10,right: 10),
                                  child: Text(
                                    controller.orderDetailsModel!.restaurantDetail!.restaurantAddress!,
                                    maxLines: 2,
                                    style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            if(controller.orderDetailsModel!.restaurantDetail!.latitude != 0 &&
                                controller.orderDetailsModel!.restaurantDetail!.longitude != 0 ){
                              controller.openMap(controller.orderDetailsModel!.restaurantDetail!.latitude!, controller.orderDetailsModel!.restaurantDetail!.longitude! );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: ColorsTheme.colPrimary
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                            child: Text(
                              'View Map'.tr,
                              style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colWhite),
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
                            margin: const EdgeInsets.only(left:10,right: 10),
                            child: Text(
                              'Pickup ${CommonFunction.formatOrderPickupDate(controller.orderDetailsModel!.pickupDate!)} at ${CommonFunction.formatPickupTime(controller.orderDetailsModel!.pickupTime!)}-${CommonFunction.formatPickupTime(controller.orderDetailsModel!.pickupEndTime!)  ?? ""}',
                              style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
          ),
        ],
      ),
    );
  }

  paymentType(){
    return Container(
      margin: const EdgeInsets.only(bottom: 15,left: 18,right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment'.tr,
            style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
          ),
          Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: ColorsTheme.colC4D9D4,
                      width: 1
                  ),
                  borderRadius: BorderRadius.circular(16)
              ),
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
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
                            controller.orderDetailsModel!.paymentMethod.toString().toUpperCase(),
                            style: mediumTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                          ),
                        ),
                        Text(
                          '${ controller.orderDetailsModel!.createdDate.toString()} at ${ controller.orderDetailsModel!.createdTime?? ""}',
                          style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      child: Text(
                        '${controller.currency}${controller.totalPrice.value}',
                        style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                        maxLines: 2,
                      ),
                    )
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }

}
