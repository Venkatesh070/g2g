import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/presentation/home/home_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../../infrastructure/shared/common_functions.dart';
import '../../../infrastructure/shared/custom_shimmer_widget.dart';
import '../../../infrastructure/shared/no_data_screen.dart';
import '../../../infrastructure/theme/colors.theme.dart';
import '../../../infrastructure/theme/text.theme.dart';
import '../../../res.dart';

class MapView extends GetView<HomeController> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
    // controller.mapHomeList.isEmpty
    //     ? noLocationWidget() :
    Stack(
            children: [
              Container(
                child: !controller.homeLoader.value
                    ? GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(controller.lat.value, controller.lng.value),
                          zoom: 13.4746,
                        ),
                        markers: controller.markerSets.value,
                        myLocationButtonEnabled: false,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: true,
                        trafficEnabled: true,
                        indoorViewEnabled: true,
                        compassEnabled: false,
                        onCameraMove: controller.manager?.onCameraMove,
                        onCameraIdle: controller.manager?.updateMap,
                        onMapCreated: controller.onMapCreated,
                      )
                    : const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.grey),
                  ),
                ),
              ),
              Positioned(
                  bottom: 15,
                  right: 15,
                  child: Visibility(
                    visible: false,
                    child: Image.asset(
                      Res.icCurrentLocation,
                      width: 50,
                      height: 50,
                    ),
                  )),
              Positioned(top: 40, right: 10, left: 10, child: locationWidget(context)),
              Positioned(
                  bottom: 0,
                  height: 130,
                  child: SizedBox(
                      // height: Get.height / 3.9,
                      // color: Colors.white,
                      width: Get.width,
                      child: Obx(
                        () => controller.homeLoader.value
                            ? Container(
                                width: Get.width - 20,
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: ColorsTheme.colWhite,
                                ),
                                child: ListView.builder(
                                    itemCount: 1,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                        leading: const CustomShimmerWidget.rectangular(
                                          height: 170,
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
                            : ListView.builder(
                                // controller: controller.homeListController,
                                itemCount: controller.mapHomeList.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      if (controller.isLoggedIn.value) {
                                        if (controller.mapHomeList[index].totalQuantity != 0) {
                                          var result = await Get.toNamed(Routes.homeDetails, arguments: {
                                            'resId': controller.mapHomeList[index].id,
                                            'currency': controller.currency.value,
                                            'user_id': controller.userId.value
                                          });
                                          if (result != null && result) {
                                            controller.mapHomeList.clear();
                                            controller.homeLoader.value = true;
                                            controller.getMapData();
                                          }
                                        }
                                      }
                                      else{
                                        controller.loginBottomSheet();
                                      }

                                    },
                                    child: Container(
                                      width: Get.width - 20,
                                      margin: const EdgeInsets.only(top: 4, bottom: 4, left: 10, right: 10),
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: ColorsTheme.colWhite,
                                      ),
                                      child: Stack(
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.only(right: 15),
                                                    width: 100,
                                                    height: 100,
                                                    child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(16),
                                                        child: controller.mapHomeList[index].restaurantImage == null
                                                            ? Image.asset(
                                                                Res.icDummyBanner,
                                                                fit: BoxFit.cover,
                                                              )
                                                            : Image.network(controller.mapHomeList[index].restaurantImage!,
                                                                fit: BoxFit.cover,
                                                                errorBuilder: (context, obj, stackTrace) {
                                                                return Image.asset(
                                                                  Res.icDummyBanner,
                                                                  fit: BoxFit.cover,
                                                                );
                                                              })),
                                                  ),
                                                  Positioned(
                                                    top: 5,
                                                    right: 20,
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (controller.isLoggedIn.value) {
                                                          controller.addFav(index, 'map');
                                                        } else {
                                                          controller.loginBottomSheet();
                                                        }
                                                      },
                                                      child: controller.mapHomeList[index].isLiked == "0"
                                                          ? Container(
                                                              decoration: const BoxDecoration(
                                                                  color: Colors.white, shape: BoxShape.circle),
                                                              width: 30,
                                                              height: 30,
                                                              alignment: Alignment.center,
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
                                                  ),
                                                  Positioned(
                                                      bottom: 5,
                                                      left: 5,
                                                      child: ClipOval(
                                                        child: controller.mapHomeList[index].restaurantCoverImage == null
                                                            ? Image.asset(
                                                                Res.icDummyLogo,
                                                                width: 35,
                                                                height: 35,
                                                              )
                                                            : Image.network(
                                                                controller.mapHomeList[index].restaurantCoverImage!,
                                                            width: 45,
                                                            height: 45, errorBuilder: (context, obj, stackTrace) {
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
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${controller.mapHomeList[index].restaurantName!} - ${controller.mapHomeList[index].restaurantLocation!}',
                                                      style: semiBoldTextStyle(
                                                          fontSize: dimen13, color: ColorsTheme.colBlack),
                                                      maxLines: 2,
                                                    ),
                                                    Container(
                                                      margin: const EdgeInsets.only(top: 5),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            margin: const EdgeInsets.only(right: 5),
                                                            child: Text(
                                                              '${controller.mapHomeList[index].distance!} km',
                                                              style: mediumTextStyle(
                                                                  fontSize: dimen12, color: ColorsTheme.colBlack),
                                                              maxLines: 2,
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: const EdgeInsets.only(right: 5),
                                                            child: Text(
                                                              '${controller.currency.value}${controller.mapHomeList[index].finalPrice!}',
                                                              style: boldTextStyle(
                                                                  fontSize: dimen15, color: ColorsTheme.colPrimary),
                                                              maxLines: 2,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${controller.currency.value}${controller.mapHomeList[index].offerPrice!}',
                                                            style: TextStyle(
                                                                fontSize: dimen11,
                                                                color: ColorsTheme.col8FA19C,
                                                                fontWeight: FontWeight.w400,
                                                                decorationColor: ColorsTheme.col8FA19C,
                                                                decoration: TextDecoration.lineThrough),
                                                            maxLines: 2,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: const EdgeInsets.only(top: 10),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          // Expanded(
                                                          //     child: Container(
                                                          //   margin: const EdgeInsets.only(right: 2),
                                                          //   child: Text(
                                                          //     '${'Total Magic Bags'.tr}:\n${controller.mapHomeList[index].totalQuantity!} ${'left'.tr}',
                                                          //     style: regularTextStyle(
                                                          //         fontSize: dimen11, color: ColorsTheme.colBlack),
                                                          //     maxLines: 2,
                                                          //   ),
                                                          // )),
                                                          Expanded(child: Container()),
                                                          Row(
                                                            children: [
                                                              Visibility(
                                                                visible: controller.mapHomeList[index].isVeg == 2 ||
                                                                    controller.mapHomeList[index].isVeg == 0,
                                                                child: Image.asset(
                                                                  Res.icVeg,
                                                                  width: 20,
                                                                  height: 20,
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible: controller.mapHomeList[index].isVeg == 1 ||
                                                                    controller.mapHomeList[index].isVeg == 0,
                                                                child: const SizedBox(
                                                                  width: 10,
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible: controller.mapHomeList[index].isVeg == 1 ||
                                                                    controller.mapHomeList[index].isVeg == 0,
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
                                                        margin: const EdgeInsets.only(top: 5),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: ColorsTheme.colPrimary,
                                                                  borderRadius: BorderRadius.circular(16)),
                                                              padding:
                                                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                              margin: const EdgeInsets.only(right: 5),
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
                                                                    controller.mapHomeList[index].rating!.toStringAsFixed(2),
                                                                    style: regularTextStyle(
                                                                        fontSize: dimen10, color: ColorsTheme.colWhite),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '${CommonFunction.formatPickupTime(controller.mapHomeList[index].openAt!)} to ${CommonFunction.formatPickupTime(controller.mapHomeList[index].closeAt!)}',
                                                                style: regularTextStyle(
                                                                    fontSize: dimen11, color: ColorsTheme.col8FA19C),
                                                                maxLines: 2,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            top: 0,
                                            left: 0,
                                            right: 0,
                                            child: controller.mapHomeList[index].totalQuantity ==
                                                    0  
                                                    /*|| !controller.homeList[index].isTodayAvailable!*/
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(16),
                                                        color: ColorsTheme.colWhite.withOpacity(0.5)),
                                                  )
                                                : Container(),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minWidth: Get.width * 0.25,
                                                maxWidth: Get.width * 0.66,
                                              ),
                                              child: controller.mapHomeList[index].totalQuantity ==
                                                      0 /*|| !controller.homeList[index].isTodayAvailable!*/
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                          color: ColorsTheme.colD0F0BF,
                                                          borderRadius: BorderRadius.circular(16)),
                                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                                      child: Text.rich(TextSpan(children: [
                                                        TextSpan(
                                                          text: controller
                                                              .homeList[index]
                                                              .soldOutStatus!
                                                               ? controller
                                                              .homeList[index]
                                                              .soldOutTxt
                                                               :
                                                          'sold_out'.tr,
                                                          style: regularTextStyle(
                                                              fontSize: dimen11, color: ColorsTheme.colBlack),
                                                        ),
                                                        // TextSpan(
                                                        //   text: ' Tomorrow.',
                                                        //   style: semiBoldTextStyle(
                                                        //       fontSize: dimen11, color: ColorsTheme.colBlack),
                                                        // )
                                                      ])),
                                                    )
                                                  : Container(),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                      ))),
            ],
          )
    )
    ;
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
                int locationStatus = await controller.checkAndAllowLocationPermission();
                await controller.checkLocationStatus(locationStatus);
              },
              child: Container(
                decoration: BoxDecoration(color: ColorsTheme.colPrimary, borderRadius: BorderRadius.circular(50)),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 14),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                width: Get.width / 2.1,
                child: Text(
                  '${'Allow Location'.tr} →',
                  style: semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colWhite),
                ),
              )),
          InkWell(
            onTap: () {
              controller.searchLocation();
            },
            child: Text(
              'Enter Location Manually'.tr,
              style: semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colPrimary),
            ),
          ),
        ],
      ),
    );
  }

  locationWidget(BuildContext context) {
    return Container(               margin: const EdgeInsets.only(top: 4, bottom: 4,),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ColorsTheme.colWhite,
      ),
      child: Column(
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
                        style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.col8FA19C),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.searchLocation();
                        },
                        child: Container(
                            margin: const EdgeInsets.only(top: 4),
                            child: Obx(
                                  () => Text(
                                controller.address.value.isEmpty ? 'Enter Location Manually'.tr : controller.address.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: mediumTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
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
            margin: const EdgeInsets.only(top: 15, ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: ColorsTheme.colHint, borderRadius: BorderRadius.circular(32)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                                hintStyle: regularTextStyle(fontSize: dimen13, color: ColorsTheme.col8FA19C),
                              ),
                              style: regularTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                              onChanged: (value) async {
                                controller.searchText.value = value;
                                if (value.isEmpty) {
                                  CommonFunction.keyboardDismiss(context);
                                  controller.homeLoader.value = true;
                                  controller.mapHomeList.clear();
                                  await controller.getMapData();
                                }
                              },
                              onSubmitted: (value) async {
                                controller.searchText.value = value;
                                CommonFunction.keyboardDismiss(context);
                                controller.mapHomeList.clear();
                                controller.homeLoader.value = true;
                                await controller.getMapData();
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
                                controller.mapHomeList.clear();
                                controller.homeLoader.value = true;
                                await controller.getMapData();
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
                            controller.filterBottomSheet(context);
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
                              () => controller.isMapAppliedFilter.value
                              ? Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          )
                              : Container(),
                        ))
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  searchWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15, bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: ColorsTheme.colWhite, borderRadius: BorderRadius.circular(32)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                          hintStyle: regularTextStyle(fontSize: dimen13, color: ColorsTheme.col8FA19C),
                        ),
                        style: regularTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                        onChanged: (value) async {
                          controller.searchText.value = value;
                          if (value.isEmpty) {
                            CommonFunction.keyboardDismiss(context);
                            controller.homeLoader.value = true;
                            controller.mapHomeList.clear();
                            await controller.getMapData();
                          }
                        },
                        onSubmitted: (value) async {
                          controller.searchText.value = value;
                          CommonFunction.keyboardDismiss(context);
                          controller.mapHomeList.clear();
                          controller.homeLoader.value = true;
                          await controller.getMapData();
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
                              controller.mapHomeList.clear();
                              controller.homeLoader.value = true;
                              await controller.getMapData();
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
                      controller.filterBottomSheet(context);
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
                    () => controller.isMapAppliedFilter.value
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          )
                        : Container(),
                  ))
            ],
          )
        ],
      ),
    );
  }
}
