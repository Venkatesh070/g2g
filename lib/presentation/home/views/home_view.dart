import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/shared/custom_shimmer_widget.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'package:good_grab/presentation/home/home_controller.dart';
import 'package:intl/intl.dart';
import 'package:upgrader/upgrader.dart';
import 'package:video_player/video_player.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../../infrastructure/shared/common_functions.dart';
import '../../../infrastructure/shared/no_data_screen.dart';
import '../../../res.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: UpgradeAlert(
        upgrader: Upgrader(
          dialogStyle: UpgradeDialogStyle.cupertino,
          debugLogging: true,
          showLater: true,
          showIgnore: true,
          cupertinoButtonTextStyle:
              mediumTextStyle(fontSize: dimen15, color: Colors.white),
        ),
        child: Stack(
          children: [
            Container(
              color: ColorsTheme.colF3FFFB,
              width: Get.width,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: locationWidget(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                        controller: controller.pagingListController,
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 20, left: 20, right: 20),
                              child: bannerView(),
                            ),
                            Obx(() => controller.homeList.isEmpty &&
                                    !controller.homeLoader.value
                                ? Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical:
                                            controller.bannerHomeList.isEmpty
                                                ? Get.height * 0.2
                                                : Get.height * 0.04),
                                    child: noDataScreen(
                                        title: 'no_place_here'.tr,
                                        subtitle: 'we_expanding'.tr,
                                        isShown: true))
                                : mainWidget(context))
                          ],
                        )),
                  )
                ],
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,

                ///by client changes
                child: Obx(() => controller.cartHomeList
                        .isNotEmpty //|| controller.orderHomeList.isNotEmpty
                    ? Column(
                        children: [
                          Container(
                            color: ColorsTheme.colPrimary,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() => controller.cartHomeList.isEmpty
                                    ? Container()
                                    : cartWidget()),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Container())),
          ],
        ),
      ),
    );
  }

  locationWidget(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              Res.icLocation,
              width: 40,
              height: 40,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your location'.tr,
                      style: regularTextStyle(
                          fontSize: dimen11, color: ColorsTheme.col8FA19C),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.searchLocation();
                      },
                      child: Container(
                          margin: const EdgeInsets.only(top: 4),
                          child: Obx(
                            () => Text(
                              controller.address.value.isEmpty
                                  ? 'Enter Location Manually'.tr
                                  : controller.address.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: mediumTextStyle(
                                  fontSize: dimen12,
                                  color: ColorsTheme.colBlack),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (controller.isLoggedIn.value) {
                  Get.toNamed(Routes.notification);
                } else {
                  controller.loginBottomSheet();
                }
              },
              child: Image.asset(
                Res.icNotification,
                width: 40,
                height: 40,
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 15, bottom: 15),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: ColorsTheme.colHint,
                      ),
                      borderRadius: BorderRadius.circular(32)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  margin: const EdgeInsets.only(right: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: TextField(
                            controller: controller.searchController,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              hintText: 'Search restaurants and cafe'.tr,
                              hintStyle: regularTextStyle(
                                  fontSize: dimen13,
                                  color: ColorsTheme.col8FA19C),
                            ),
                            style: regularTextStyle(
                                fontSize: dimen13, color: ColorsTheme.colBlack),
                            onChanged: (value) async {
                              controller.searchText.value = value;
                              if (value.isEmpty) {
                                CommonFunction.keyboardDismiss(context);
                                controller.homeLoader.value = true;
                                controller.homeList.clear();
                                await controller.getHomeData();
                              }
                            },
                            onSubmitted: (value) async {
                              controller.searchText.value = value;
                              CommonFunction.keyboardDismiss(context);
                              controller.homeList.clear();
                              controller.homeLoader.value = true;
                              await controller.getHomeData();
                            },
                          ),
                        ),
                      ),
                      Obx(() => Visibility(
                            visible: controller.searchText.isNotEmpty,
                            child: Container(
                              margin: const EdgeInsets.only(left: 12),
                              child: InkWell(
                                onTap: () async {
                                  CommonFunction.keyboardDismiss(context);
                                  controller.homeList.clear();
                                  controller.homeLoader.value = true;
                                  await controller.getHomeData();
                                },
                                child: Image.asset(
                                  Res.icSearch,
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              Stack(
                children: [
                  Obx(
                    () => Visibility(
                      visible: controller.isFilter.value,
                      child: InkWell(
                        onTap: () {
                          filterBottomSheet(context);
                          // filterBottomSheet(context);
                        },
                        child: Image.asset(
                          Res.icFilter,
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      top: 0,
                      right: 5,
                      child: Obx(
                        () => controller.isAppliedFilter.value
                            ? Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                    color: Colors.red, shape: BoxShape.circle),
                              )
                            : Container(),
                      ))
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  noLocationWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          noDataScreen(
            noDataImage: Res.icLocation,
            title: 'Location'.tr,
            subtitle: 'location_permission_subtitle'.tr,
          ),
          GestureDetector(
              onTap: () async {
                int locationStatus =
                    await controller.checkAndAllowLocationPermission();
                await controller.checkLocationStatus(locationStatus);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: ColorsTheme.colPrimary,
                    borderRadius: BorderRadius.circular(50)),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 14),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                width: Get.width / 2.1,
                child: Text(
                  '${'Allow Location'.tr} →',
                  style: semiBoldTextStyle(
                      fontSize: dimen13, color: ColorsTheme.colWhite),
                ),
              )),
          InkWell(
            onTap: () {
              controller.searchLocation();
            },
            child: Text(
              'Enter Location Manually'.tr,
              style: semiBoldTextStyle(
                  fontSize: dimen13, color: ColorsTheme.colPrimary),
            ),
          ),
        ],
      ),
    );
  }

  cartWidget() {
    return GestureDetector(
      onTap: () async {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 30,
                        height: 30,
                        child: ClipOval(
                            child: controller.cartHomeList.isNotEmpty &&
                                    controller.cartHomeList[0].restroDetail !=
                                        null &&
                                    controller.cartHomeList[0].restroDetail!
                                            .restaurantProfile !=
                                        null
                                ? Image.network(
                                    controller.cartHomeList[0].restroDetail!
                                        .restaurantProfile!,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.low,
                                    errorBuilder: (context, obj, stackTrace) {
                                    return Image.asset(
                                      Res.icDummyBanner,
                                      fit: BoxFit.cover,
                                    );
                                  })
                                : Image.asset(
                                    Res.icDummyBanner,
                                    fit: BoxFit.cover,
                                  )),
                      ),
                      Positioned(
                          bottom: 5,
                          left: 5,
                          child: ClipOval(
                            child: controller.cartHomeList.isNotEmpty &&
                                    controller.cartHomeList[0].restroDetail !=
                                        null &&
                                    controller.cartHomeList[0].restroDetail!
                                            .restaurantCoverProfile !=
                                        null
                                ? Image.network(
                                    controller.cartHomeList[0].restroDetail!
                                        .restaurantCoverProfile!,
                                    width: 15,
                                    height: 15,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.low,
                                    errorBuilder: (context, obj, stackTrace) {
                                    return Image.asset(
                                      Res.icDummyLogo,
                                      width: 15,
                                      height: 15,
                                      fit: BoxFit.cover,
                                    );
                                  })
                                : Image.asset(
                                    Res.icDummyLogo,
                                    width: 15,
                                    height: 15,
                                    fit: BoxFit.cover,
                                  ),
                          ))
                    ],
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      var result = await Get.toNamed(Routes.cart, arguments: {
                        'total_quantity':
                            controller.cartHomeList[0].totalQuantity,
                        'resId': controller
                            .cartHomeList[0].restroDetail!.restaurantId,
                        'pickupStartTime':
                            controller.cartHomeList[0].restroDetail!.openAt,
                        'pickupCloseTime':
                            controller.cartHomeList[0].restroDetail!.closeAt,
                        'pickupLocation': controller
                            .cartHomeList[0].restroDetail!.restaurantAddress
                            .toString(),
                      });
                      if (result != null && result) {
                        await controller.getUserHomeData();
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            controller.cartHomeList.isNotEmpty &&
                                    controller.cartHomeList[0].restroDetail !=
                                        null
                                ? '${controller.cartHomeList[0].restroDetail!.restaurantName}-${controller.cartHomeList[0].restroDetail!.restaurantAddress}'
                                : '',
                            maxLines: 1,
                            style: semiBoldTextStyle(
                                fontSize: dimen13, color: ColorsTheme.colWhite),
                          ),
                        ),
                        Text(
                          'Magical Bag x ${controller.cartHomeList[0].totalQuantity}',
                          style: regularTextStyle(
                              fontSize: dimen11, color: ColorsTheme.colWhite),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      var result = await Get.toNamed(Routes.cart, arguments: {
                        'total_quantity':
                            controller.cartHomeList[0].totalQuantity,
                        'resId': controller
                            .cartHomeList[0].restroDetail!.restaurantId,
                        'pickupStartTime':
                            controller.cartHomeList[0].restroDetail!.openAt,
                        'pickupCloseTime':
                            controller.cartHomeList[0].restroDetail!.closeAt,
                        'pickupLocation': controller
                            .cartHomeList[0].restroDetail!.restaurantAddress
                            .toString(),
                      });
                      if (result != null && result) {
                        await controller.getUserHomeData();
                      }
                    },
                    child: Text(
                      'Cart'.tr,
                      style: semiBoldTextStyle(
                          fontSize: dimen11, color: ColorsTheme.colWhite),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.white,
                    size: 12,
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  controller.alertBoxRemoveCart();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Text(
                    'Remove Cart'.tr,
                    style: semiBoldTextStyle(
                        fontSize: dimen11, color: ColorsTheme.colWhite),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  orderWidget() {
    return ListView.separated(
      itemCount: 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            controller.onSelectIndex(2);
          },
          child: Container(
            margin: const EdgeInsets.only(top: 2, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 30,
                              height: 30,
                              child: ClipOval(
                                child: controller
                                            .orderHomeList[index]
                                            .restaurantDetail!
                                            .restaurantProfile ==
                                        null
                                    ? Image.asset(
                                        Res.icDummyBanner,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        controller
                                            .orderHomeList[index]
                                            .restaurantDetail!
                                            .restaurantProfile!,
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.low,
                                        errorBuilder:
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
                                            .orderHomeList[index]
                                            .restaurantDetail!
                                            .restaurantCoverProfile ==
                                        null
                                    ? Image.asset(
                                        Res.icDummyLogo,
                                        width: 15,
                                        height: 15,
                                      )
                                    : Image.network(
                                        controller
                                            .orderHomeList[index]
                                            .restaurantDetail!
                                            .restaurantCoverProfile!,
                                        width: 15,
                                        height: 15,
                                        filterQuality: FilterQuality.low,
                                        errorBuilder:
                                            (context, obj, stackTrace) {
                                        return Image.asset(
                                          Res.icDummyLogo,
                                          width: 15,
                                          height: 15,
                                        );
                                      }))
                          ],
                        ),
                      ),
                      Text(
                        'Your order'.tr,
                        style: semiBoldTextStyle(
                            fontSize: dimen13, color: ColorsTheme.colWhite),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.white,
                  size: 12,
                )
              ],
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          margin: const EdgeInsets.only(top: 2, bottom: 2),
          child: Divider(
            color: ColorsTheme.colWhite,
          ),
        );
      },
    );
  }

  orderInstructionWidget() {
    return Container(
      decoration: BoxDecoration(
          color: ColorsTheme.colWhite.withOpacity(0.95),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: ColorsTheme.colSecondary.withOpacity(0.2),
              blurRadius: 300,
            )
          ]),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Text(
            'What\'s Next',
            style: boldTextStyle(
                fontSize: dimen13, color: ColorsTheme.colBlack, height: 2.0),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 15),
                  child: Image.asset(
                    Res.icRes,
                    width: 35,
                    height: 35,
                  ),
                ),
                Expanded(
                  child: Text(
                    'It\'s magic bag will be filled with delicious things that are left at the end of the day.',
                    style: regularTextStyle(
                        fontSize: dimen12,
                        color: ColorsTheme.colBlack,
                        height: 2.0),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 15),
                  child: Image.asset(
                    Res.icPickupTime,
                    width: 35,
                    height: 35,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Keep an eye on the time you need to collect your meal with in the time shown below.',
                    style: regularTextStyle(
                        fontSize: dimen12,
                        color: ColorsTheme.colBlack,
                        height: 2.0),
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              controller.isOrderInstruction.value = false;
            },
            child: Container(
              decoration: BoxDecoration(
                  color: ColorsTheme.colPrimary,
                  borderRadius: BorderRadius.circular(50)),
              alignment: Alignment.center,
              width: 150,
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'Got It'.tr,
                style: semiBoldTextStyle(
                    fontSize: dimen13, color: ColorsTheme.colWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///by client changes
  mainWidget(context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => controller.homeLoader.value
          ? ListView.builder(
              itemCount: 6,
              shrinkWrap: true,
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
              })
          : controller.homeList.isEmpty
              ? Container(
                  margin: EdgeInsets.symmetric(vertical: Get.height * 0.2),
                  child: noDataScreen(
                      noDataImage: Res.icRestaurant,
                      title: 'no_res_title'.tr,
                      subtitle: 'no_res_subtitle'.tr),
                )
              : Container(
                  margin: EdgeInsets.only(
                      bottom: controller.cartHomeList.isNotEmpty &&
                              controller.orderHomeList.isNotEmpty
                          ? 40
                          : controller.cartHomeList.isNotEmpty ||
                                  controller.orderHomeList.isNotEmpty
                              ? 0
                              : 0),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.homeList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == controller.homeList.length) {
                          return controller.buildProgressIndicator();
                        } else {
                          return GestureDetector(
                            onTap: () async {
                              if (controller.isLoggedIn.value) {
                                if (controller.homeList[index].totalQuantity != 0 &&
                                    controller.homeList[index].soldOutStatus != true &&
                                    !(() {
                                      final closeAt = controller.homeList[index].closeAt;
                                      if (closeAt == null || closeAt.isEmpty) return false;
                                      final now = DateTime.now();
                                      try {
                                        final t1 = DateFormat('HH:mm').parse(closeAt);
                                        final close = DateTime(now.year, now.month, now.day, t1.hour, t1.minute);
                                        return now.isAfter(close);
                                      } catch (_) {
                                        try {
                                          final t2 = DateFormat('hh:mm a').parse(closeAt);
                                          final close = DateTime(now.year, now.month, now.day, t2.hour, t2.minute);
                                          return now.isAfter(close);
                                        } catch (_) {
                                          return false;
                                        }
                                      }
                                    })()) {
                                  var result = await Get.toNamed(
                                      Routes.homeDetails,
                                      arguments: {
                                        'resId': controller.homeList[index].id,
                                        'currency': controller.currency.value,
                                        'user_id': controller.userId.value
                                      });
                                  print("result:::::::${result}");
                                  if (result != null && result) {
                                    controller.homeList.clear();
                                    controller.homeLoader.value = true;
                                    controller.getHomeData();
                                  }
                                }
                              } else {
                                controller.loginBottomSheet();
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 4, bottom: 4),
                              // padding: const EdgeInsets.symmetric(
                              //     vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: ColorsTheme.colWhite,
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  right: 15),
                                              width: 100,
                                              height: 100,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  child: controller
                                                              .homeList[index]
                                                              .restaurantImage ==
                                                          null
                                                      ? Image.asset(
                                                          Res.icDummyBanner,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image.network(
                                                          controller
                                                              .homeList[index]
                                                              .restaurantImage!,
                                                          fit: BoxFit.cover,
                                                          filterQuality:
                                                              FilterQuality.low,
                                                          errorBuilder: (context,
                                                              obj, stackTrace) {
                                                          return Image.asset(
                                                            Res.icDummyBanner,
                                                            fit: BoxFit.cover,
                                                          );
                                                        })),
                                            ),
                                            Positioned(
                                                top: 5,
                                                right: 20,
                                                child: Visibility(
                                                  visible: false,
                                                  child: InkWell(
                                                    onTap: () {
                                                      if (controller
                                                          .isLoggedIn.value) {
                                                        controller.addFav(
                                                            index, 'home');
                                                      } else {
                                                        controller
                                                            .loginBottomSheet();
                                                      }
                                                    },
                                                    child: controller
                                                                .homeList[index]
                                                                .isLiked ==
                                                            "0"
                                                        ? Container(
                                                            decoration:
                                                                const BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    shape: BoxShape
                                                                        .circle),
                                                            width: 30,
                                                            height: 30,
                                                            alignment:
                                                                Alignment.center,
                                                            child: Image.asset(
                                                              Res.icHeart,
                                                              width: 18,
                                                              height: 18,
                                                            ))
                                                        : Image.asset(
                                                            Res.icFillHeart,
                                                            width: 30,
                                                            height: 30,
                                                          ),
                                                  ),
                                                )),
                                            Positioned(
                                                bottom: 5,
                                                left: 5,
                                                child: controller.homeList[index]
                                                            .restaurantCoverImage ==
                                                        null
                                                    ? Image.asset(
                                                        Res.icDummyLogo,
                                                        width: 35,
                                                        height: 35,
                                                      )
                                                    : ClipOval(
                                                        child: Image.network(
                                                            controller
                                                                .homeList[index]
                                                                .restaurantCoverImage!,
                                                            width: 45,
                                                            height: 45,
                                                            filterQuality:
                                                                FilterQuality.low,
                                                            errorBuilder:
                                                                (context, obj,
                                                                    stackTrace) {
                                                          return Image.asset(
                                                            Res.icDummyLogo,
                                                            width: 45,
                                                            height: 45,
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
                                              Text(
                                                controller.homeList[index]
                                                    .restaurantName!, //- ${controller.homeList[index].restaurantLocation!}
                                                style: semiBoldTextStyle(
                                                    fontSize: dimen13,
                                                    color: ColorsTheme.colBlack),
                                                maxLines: 2,
                                              ),
                                              Container(
                                                margin:
                                                    const EdgeInsets.only(top: 5),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                                right: 5),
                                                        child: Text(
                                                          '${controller.homeList[index].distance!} km',
                                                          style: mediumTextStyle(
                                                              fontSize: dimen12,
                                                              color: ColorsTheme
                                                                  .colBlack),
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 5),
                                                      child: Text(
                                                        '${controller.currency.value}${controller.homeList[index].finalPrice!}',
                                                        style: boldTextStyle(
                                                            fontSize: dimen15,
                                                            color: ColorsTheme
                                                                .colPrimary),
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${controller.currency.value}${controller.homeList[index].offerPrice!}',
                                                      style: TextStyle(
                                                          fontSize: dimen11,
                                                          color: ColorsTheme
                                                              .col8FA19C,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          decorationColor:
                                                              ColorsTheme
                                                                  .col8FA19C,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough),
                                                      maxLines: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 10),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    // Expanded(
                                                    //     child: Container(
                                                    //   margin: const EdgeInsets.only(right: 2),
                                                    //   child: Text(
                                                    //     '${'Total Magic Bags'.tr}:\n${controller.homeList[index].totalQuantity!} ${'left'.tr}',
                                                    //     style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                                                    //     maxLines: 2,
                                                    //   ),
                                                    // )),
                                                    Expanded(child: Container()),
                                                    Row(
                                                      children: [
                                                        Visibility(
                                                          visible: controller
                                                                      .homeList[
                                                                          index]
                                                                      .isVeg ==
                                                                  2 ||
                                                              controller
                                                                      .homeList[
                                                                          index]
                                                                      .isVeg ==
                                                                  0,
                                                          child: Image.asset(
                                                            Res.icVeg,
                                                            width: 20,
                                                            height: 20,
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: controller
                                                                      .homeList[
                                                                          index]
                                                                      .isVeg ==
                                                                  1 ||
                                                              controller
                                                                      .homeList[
                                                                          index]
                                                                      .isVeg ==
                                                                  0,
                                                          child: const SizedBox(
                                                            width: 10,
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: controller
                                                                      .homeList[
                                                                          index]
                                                                      .isVeg ==
                                                                  1 ||
                                                              controller
                                                                      .homeList[
                                                                          index]
                                                                      .isVeg ==
                                                                  0,
                                                          child: Image.asset(
                                                            Res.icNonVeg,
                                                            width: 20,
                                                            height: 20,
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                visible: false,
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            color: ColorsTheme
                                                                .colPrimary,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16)),
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8,
                                                            vertical: 6),
                                                        margin:
                                                            const EdgeInsets.only(
                                                                right: 5),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 5),
                                                              child: Icon(
                                                                Icons.star,
                                                                color: ColorsTheme
                                                                    .colWhite,
                                                                size: 14,
                                                              ),
                                                            ),
                                                            Text(
                                                              controller
                                                                  .homeList[index]
                                                                  .rating!
                                                                  .toStringAsFixed(
                                                                      1),
                                                              style: regularTextStyle(
                                                                  fontSize:
                                                                      dimen10,
                                                                  color: ColorsTheme
                                                                      .colWhite),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          '${CommonFunction.formatPickupTime(controller.homeList[index].openAt!)} to ${CommonFunction.formatPickupTime(controller.homeList[index].closeAt!)}',
                                                          style: regularTextStyle(
                                                              fontSize: dimen11,
                                                              color: ColorsTheme
                                                                  .col8FA19C),
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: (() {
                                      final item = controller.homeList[index];
                                      final bool isSoldOut = item.totalQuantity == 0 || item.soldOutStatus != false;
                                      bool isClosedNow = false;
                                      final closeAt = item.closeAt;
                                      if (closeAt != null && closeAt.isNotEmpty) {
                                        final now = DateTime.now();
                                        try {
                                          final t1 = DateFormat('HH:mm').parse(closeAt);
                                          final close = DateTime(now.year, now.month, now.day, t1.hour, t1.minute);
                                          isClosedNow = now.isAfter(close);
                                        } catch (_) {
                                          try {
                                            final t2 = DateFormat('hh:mm a').parse(closeAt);
                                            final close = DateTime(now.year, now.month, now.day, t2.hour, t2.minute);
                                            isClosedNow = now.isAfter(close);
                                          } catch (_) {}
                                        }
                                      }
                                      if (isSoldOut || isClosedNow) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            color: ColorsTheme.colWhite.withOpacity(0.5),
                                          ),
                                        );
                                      }
                                      return Container();
                                    })(),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    // top:0,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: Get.width * 0.25,
                                        maxWidth: Get.width * 0.60,
                                      ),
                                      child: (() {
                                        final item = controller.homeList[index];
                                        final bool isSoldOut = item.totalQuantity == 0 || (item.soldOutStatus ?? false);
                                        bool isClosedNow = false;
                                        final closeAt = item.closeAt;
                                        if (closeAt != null && closeAt.isNotEmpty) {
                                          final now = DateTime.now();
                                          try {
                                            final t1 = DateFormat('HH:mm').parse(closeAt);
                                            final close = DateTime(now.year, now.month, now.day, t1.hour, t1.minute);
                                            isClosedNow = now.isAfter(close);
                                          } catch (_) {
                                            try {
                                              final t2 = DateFormat('hh:mm a').parse(closeAt);
                                              final close = DateTime(now.year, now.month, now.day, t2.hour, t2.minute);
                                              isClosedNow = now.isAfter(close);
                                            } catch (_) {}
                                          }
                                        }
                                          if (isClosedNow) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: ColorsTheme.colD0F0BF,
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                topRight: Radius.circular(0),
                                                bottomLeft: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                            child: Text(
                                              'Closed Now. Will be back soon',
                                              style: regularTextStyle(
                                                fontSize: dimen11,
                                                color: ColorsTheme.colBlack,
                                              ),
                                            ),
                                          );
                                        }else if (isSoldOut) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: ColorsTheme.colD0F0BF,
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                topRight: Radius.circular(0),
                                                bottomLeft: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                            child: Text(
                                              (item.soldOutStatus ?? false) ? (item.soldOutTxt ?? 'sold_out'.tr) : 'sold_out'.tr,
                                              style: regularTextStyle(
                                                fontSize: dimen11,
                                                color: ColorsTheme.colBlack,
                                              ),
                                            ),
                                          );
                                        }
                                        return Container();
                                      })(),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                      }),
                )),
    );
  }

  filterBottomSheet(context) {
    return Get.bottomSheet(StatefulBuilder(builder: (context, setState) {
      return Wrap(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
                color: ColorsTheme.colWhite),
            width: Get.width,
            height: Get.height / 1.2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  child: Text(
                    'Filters'.tr,
                    style: semiBoldTextStyle(
                        fontSize: dimen17, color: ColorsTheme.colBlack),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => controller.foodTypeList.isEmpty
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 20, left: 20, right: 20),
                                    child: Text(
                                      'Food Type'.tr,
                                      style: mediumTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: foodTypeChipList()),
                                ],
                              )),
                        Obx(() => controller.foodPrefList.isEmpty
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Text(
                                      'Food Preferences'.tr,
                                      style: mediumTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: foodPrefChipList()),
                                ],
                              )),
                        Obx(() => controller.pickupDistanceMax.value == 0
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Text(
                                      'Pickup Distance'.tr,
                                      style: mediumTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'O Km',
                                          style: regularTextStyle(
                                              fontSize: dimen11,
                                              color: ColorsTheme.colBlack),
                                        ),
                                        Text(
                                          '${controller.selectedPickupDistance.value}',
                                          style: regularTextStyle(
                                              fontSize: dimen11,
                                              color: ColorsTheme.colBlack),
                                        ),
                                        Text(
                                          '${controller.pickupDistanceMax.value} Km',
                                          style: regularTextStyle(
                                              fontSize: dimen11,
                                              color: ColorsTheme.colBlack),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: Obx(
                                        () => SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                              thumbShape:
                                                  const RoundSliderThumbShape(),
                                              activeTrackColor:
                                                  ColorsTheme.colPrimary,
                                              inactiveTrackColor:
                                                  ColorsTheme.col8FA19C,
                                              overlayShape:
                                                  const RoundSliderOverlayShape(
                                                      overlayRadius: 1),
                                              trackHeight: 3),
                                          child: Slider(
                                            value: controller
                                                .selectedPickupDistance.value,
                                            min: 0,
                                            max: controller
                                                .pickupDistanceMax.value,
                                            divisions: controller
                                                .pickupDistanceMax.value
                                                .toInt(),
                                            onChanged: (double value) {
                                              controller.selectedPickupDistance
                                                  .value = value;
                                            },
                                          ),
                                        ),
                                      )),
                                ],
                              )),
                        Obx(() => controller.pickupDayList.isEmpty
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Text(
                                      'Pick-up Day'.tr,
                                      style: mediumTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: pickupDayChipList()),
                                ],
                              )),
                        Obx(() => controller.pickupStockList.isEmpty
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Text(
                                      'Availability'.tr,
                                      style: mediumTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: pickupStockChipList()),
                                ],
                              )),
                        Obx(() => controller.isPickupHoursList.value
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Text(
                                      'Pick-up window'.tr,
                                      style: mediumTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('hh:mm a').format(DateTime
                                              .fromMicrosecondsSinceEpoch(
                                                  controller.pickupSelectMinTime
                                                          .toInt() *
                                                      1000)),
                                          style: regularTextStyle(
                                              fontSize: dimen11,
                                              color: ColorsTheme.colBlack),
                                        ),
                                        Text(
                                          DateFormat('hh:mm a').format(DateTime
                                              .fromMicrosecondsSinceEpoch(
                                                  controller.pickupSelectMaxTime
                                                          .toInt() *
                                                      1000)),
                                          style: regularTextStyle(
                                              fontSize: dimen11,
                                              color: ColorsTheme.colBlack),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, left: 20, right: 20),
                                      child: Obx(
                                        () => SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                              thumbShape:
                                                  const RoundSliderThumbShape(),
                                              activeTrackColor:
                                                  ColorsTheme.colPrimary,
                                              inactiveTrackColor:
                                                  ColorsTheme.col8FA19C,
                                              disabledActiveTickMarkColor:
                                                  Colors.transparent,
                                              disabledInactiveTickMarkColor:
                                                  Colors.transparent,
                                              activeTickMarkColor:
                                                  Colors.transparent,
                                              inactiveTickMarkColor:
                                                  Colors.transparent,
                                              overlayShape:
                                                  const RoundSliderOverlayShape(
                                                      overlayRadius: 1),
                                              trackHeight: 3),
                                          child: RangeSlider(
                                            values: RangeValues(
                                                controller
                                                    .pickupSelectMinTime.value,
                                                controller
                                                    .pickupSelectMaxTime.value),
                                            min: controller.pickupMinTime.value,
                                            max: controller.pickupMaxTime.value,
                                            divisions: 48,
                                            onChanged: (RangeValues value) {
                                              controller.pickupSelectMinTime
                                                      .value =
                                                  value.start.toPrecision(0);
                                              controller.pickupSelectMaxTime
                                                      .value =
                                                  value.end.toPrecision(0);
                                              print(controller
                                                  .pickupSelectMinTime.value
                                                  .toString());
                                              //print(controller.pickupSelectMaxTime.value.toString());
                                            },
                                          ),
                                        ),
                                      )),
                                ],
                              )
                            : Container()),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    controller.clearFilter();
                                    Get.back();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: ColorsTheme.colBlack,
                                            width: 1),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      'Clear All'.tr,
                                      style: semiBoldTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Get.back();
                                    controller.isAppliedFilter.value = true;
                                    controller.homeList.clear();
                                    controller.homeLoader.value = true;
                                    controller.getHomeData();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: ColorsTheme.colPrimary,
                                        border: Border.all(
                                            color: Colors.transparent,
                                            width: 1),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      'Apply'.tr,
                                      style: semiBoldTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colWhite),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }), isScrollControlled: true);
  }

  Widget labelChip({
    String? label,
    bool? isSelect,
  }) {
    return Container(
      decoration: isSelect!
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: ColorsTheme.colPrimary,
              border: Border.all(width: 1, color: Colors.transparent))
          : BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.transparent,
              border: Border.all(width: 1, color: ColorsTheme.colBlack)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label!,
        style: regularTextStyle(
          fontSize: dimen11,
          color: isSelect ? ColorsTheme.colWhite : ColorsTheme.colBlack,
        ),
      ),
    );
  }

  Widget bannerView() {
    return Obx(() => Column(
          children: [
            controller.homeLoader.value
                ? ListView.builder(
                    itemCount: 2,
                    shrinkWrap: true,
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
                        subtitle:
                            const CustomShimmerWidget.rectangular(height: 14),
                      );
                    })
                : controller.bannerHomeList.isNotEmpty
                    ? Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: Obx(() => CarouselSlider(
                                  options: CarouselOptions(
                                    height: 230.0,
                                    viewportFraction:
                                        controller.bannerHomeList.length > 1
                                            ? 0.8
                                            : 1.0,
                                    enableInfiniteScroll:
                                        controller.bannerHomeList.length > 1
                                            ? true
                                            : false,
                                    autoPlay: false,
                                    // onPageChanged: (index, changeReason) {
                                    //
                                    //   controller.bannerHomeList.refresh();
                                    //
                                    //   if (!controller.isVideoPause.value && changeReason.toString() == "CarouselPageChangedReason.manual") {
                                    //     print("changeReason $changeReason $index");
                                    //
                                    //     if (index > controller.currentBannerIndex.value) {
                                    //
                                    //       // Scrolling from left to right (next slide)
                                    //       print("Scrolling from left to right");
                                    //       controller.isVideoPause.value = true;
                                    //       controller.bannerHomeList[index -1].videoPlayerController!.pause();
                                    //       controller.currentBannerIndex.value = index;
                                    //     } else if (index < controller.currentBannerIndex.value) {
                                    //
                                    //       // Scrolling from right to left (previous slide)
                                    //       print("Scrolling from right to left");
                                    //       controller.isVideoPause.value = true;
                                    //       controller.bannerHomeList[index+1].videoPlayerController!.pause();
                                    //       controller.currentBannerIndex.value = index;
                                    //     }
                                    //
                                    //     // Update the previous index
                                    //     controller.currentBannerIndex.value = index;
                                    //   }
                                    // },
                                    onPageChanged: (index, changeReason) {
                                      controller.currentBannerIndex.value =
                                          index;
                                      controller.bannerHomeList.refresh();

                                      if (!controller.isVideoPause.value &&
                                          changeReason.toString() ==
                                              "CarouselPageChangedReason.manual") {
                                        print(
                                            "changeReason $changeReason $index");
                                        controller.isVideoPause.value = true;
                                        controller.bannerHomeList[index - 1]
                                            .videoPlayerController!
                                            .pause();
                                      }
                                    },
                                  ),
                                  items:
                                      controller.bannerHomeList.map((banner) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: controller
                                                          .bannerHomeList
                                                          .length >
                                                      1
                                                  ? 5.0
                                                  : 0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: banner == null
                                                  ? Image.asset(
                                                      Res.icDummyBanner,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : banner.mediaType == "video"
                                                      ? banner.videoPlayerController !=
                                                              null
                                                          ? Stack(
                                                              children: [
                                                                Obx(
                                                                  () => !controller
                                                                          .isVideoInitialize
                                                                          .value
                                                                      ? const Center(
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        )
                                                                      : InkWell(
                                                                          onTap:
                                                                              () {
                                                                            if (banner.videoPlayerController !=
                                                                                null) {
                                                                              controller.onTapVideoPause();
                                                                            }
                                                                          },
                                                                          child:
                                                                              VideoPlayer(banner.videoPlayerController!)),
                                                                ),
                                                                Positioned(
                                                                  bottom: 10,
                                                                  // top: 0,
                                                                  // left: 0,
                                                                  right: 10,
                                                                  child: Obx(
                                                                    () => controller
                                                                            .isVideoLoad
                                                                            .value
                                                                        ? SizedBox()
                                                                        : InkWell(
                                                                            onTap:
                                                                                () {
                                                                              controller.onTapVideoPause();
                                                                            },
                                                                            child: controller.isVideoPause.value
                                                                                ? Icon(
                                                                                    Icons.play_circle,
                                                                                    color: Colors.white.withOpacity(0.7),
                                                                                    size: 30,
                                                                                  )
                                                                                : Icon(
                                                                                    Icons.pause_circle_filled,
                                                                                    color: Colors.white.withOpacity(0.7),
                                                                                    size: 30,
                                                                                  )),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                    bottom: 0,
                                                                    left: 0,
                                                                    right: 0,
                                                                    child:
                                                                        VideoProgressIndicator(
                                                                      banner
                                                                          .videoPlayerController!,
                                                                      allowScrubbing:
                                                                          false,
                                                                      colors: VideoProgressColors(
                                                                          backgroundColor: Colors
                                                                              .grey,
                                                                          playedColor:
                                                                              ColorsTheme.colPrimary),
                                                                    )),
                                                              ],
                                                            )
                                                          : Container()
                                                      : Image.network(
                                                          banner.media!,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, obj,
                                                                  stackTrace) {
                                                          return Image.asset(
                                                            Res.icDummyBanner,
                                                            fit: BoxFit.cover,
                                                          );
                                                        })),
                                        );
                                      },
                                    );
                                  }).toList(),
                                )),
                          ),
                          controller.bannerHomeList.isNotEmpty &&
                                  controller.bannerHomeList.length > 1
                              ? Container(
                                  height: 30,
                                  alignment: Alignment.center,
                                  child: ListView.builder(
                                      itemCount:
                                          controller.bannerHomeList.length,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          child: index ==
                                                  controller
                                                      .currentBannerIndex.value
                                              ? Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: ColorsTheme
                                                          .colPrimary),
                                                )
                                              : Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: ColorsTheme
                                                          .col404040),
                                                ),
                                        );
                                      }),
                                )
                              : Container(),
                        ],
                      )
                    : Container(),
          ],
        ));
  }

  Widget imageLabelChip({String? label, bool? isSelect, String? image}) {
    return Container(
      decoration: isSelect!
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: ColorsTheme.colPrimary,
              border: Border.all(width: 1, color: Colors.transparent))
          : BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.transparent,
              border: Border.all(width: 1, color: ColorsTheme.colBlack)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Image.network(
              image!,
              width: 20,
              height: 20,
              filterQuality: FilterQuality.low,
              errorBuilder: (context, obj, stack) {
                return Image.asset(
                  Res.icDummyFoodType,
                  width: 20,
                  height: 20,
                );
              },
            ),
          ),
          Text(
            label!,
            style: regularTextStyle(
              fontSize: dimen11,
              color: isSelect ? ColorsTheme.colWhite : ColorsTheme.colBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget foodTypeChipList() {
    return Wrap(
      spacing: 0,
      children: List.generate(
        controller.foodTypeList.length,
        (index) {
          return GestureDetector(
            onTap: () {
              controller.onSelectFoodType(index);
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Obx(() => labelChip(
                    label: controller.foodTypeList[index].name!,
                    isSelect: controller.foodTypeList[index].isSelect!))),
          );
        },
      ),
    );
  }

  Widget foodPrefChipList() {
    return Wrap(
      spacing: 10,
      children: List.generate(
        controller.foodPrefList.length,
        (index) {
          return GestureDetector(
            onTap: () {
              controller.onSelectFoodPref(index);
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Obx(
                  () => imageLabelChip(
                    label: controller.foodPrefList[index].name!,
                    isSelect: controller.foodPrefList[index].isSelect!,
                    image: controller.foodPrefList[index].image!,
                  ),
                )),
          );
        },
      ),
    );
  }

  Widget pickupDayChipList() {
    return Wrap(
      spacing: 10,
      children: List.generate(
        controller.pickupDayList.length,
        (index) {
          return GestureDetector(
            onTap: () {
              controller.onSelectPickupDay(index);
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Obx(
                  () => labelChip(
                      label: controller.pickupDayList[index],
                      isSelect: controller.selectedPickupDay.value == index),
                )),
          );
        },
      ),
    );
  }

  Widget pickupStockChipList() {
    return Wrap(
      spacing: 10,
      children: List.generate(
        controller.pickupStockList.length,
        (index) {
          return GestureDetector(
            onTap: () {
              controller.onSelectAvailability(index);
              print("onSelectAvailability $index");
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Obx(
                  () => labelChip(
                      label: controller.pickupStockList[index],
                      isSelect:
                          controller.selectedStockAvailability.value == index),
                )),
          );
        },
      ),
    );
  }
}
