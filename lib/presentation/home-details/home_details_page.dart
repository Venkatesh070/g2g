import 'dart:developer';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/navigation/routes.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'package:good_grab/presentation/home-details/home_details_controller.dart';
import 'package:share_plus/share_plus.dart';

import '../../infrastructure/models/home_details_model.dart';
import '../../infrastructure/shared/common_functions.dart';
import '../../infrastructure/shared/custom_shimmer_widget.dart';
import '../../infrastructure/shared/no_data_screen.dart';
import '../../res.dart';

class HomeDetailsPage extends BaseView<HomeDetailsController> {
  HomeDetailsPage({super.key});

  // Normalize food preference strings to stable keys: veg | nonveg | egg
  String _normalizePref(String? pref) {
    final raw = (pref ?? '').toLowerCase();
    final compact = raw.replaceAll(RegExp(r'[^a-z]'), '');
    if (compact.contains('nonveg')) return 'nonveg';
    if (compact.contains('egg')) return 'egg';
    if (compact.contains('veg')) return 'veg';
    return compact;
  }

  String _selectedPrefKey() {
    if (controller.selectFoodPref.value == -1) return '';
    return _normalizePref(
        controller.foodPrefList[controller.selectFoodPref.value]);
  }

  // Determines if an item's preference matches the selected filter.
  bool _matchesSelected(String? itemPref) {
    final itemKey = _normalizePref(itemPref);
    final sel = _selectedPrefKey();
    if (sel.isEmpty) return true;
    return itemKey == sel;
  }

  @override
  bool onBackPressed() {
    controller.onBack();
    return false;
  }

  @override
  Widget body(BuildContext context) {
    return Obx(() => controller.isLoad.value
        ? loadingWidget()
        : controller.isHomeData.value
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Obx(() => controller.title.isEmpty
                          ? customScrollWidget()
                          : Container())),
                  Obx(() => controller.totalQuantity.value == 0
                      ? Container()
                      : footerWidget(0))
                ],
              )
            : noWidget());
  }

  loadingWidget() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                controller.onBack();
              },
              child: Container(
                  width: 35,
                  height: 35,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 18),
                  child: Image.asset(
                    Res.icBack,
                    height: 18,
                    width: 18,
                  )),
            ),
            Expanded(
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
                      subtitle:
                          const CustomShimmerWidget.rectangular(height: 14),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  noWidget() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                controller.onBack();
              },
              child: Container(
                  width: 35,
                  height: 35,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 18),
                  child: Image.asset(
                    Res.icBack,
                    height: 18,
                    width: 18,
                  )),
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: Get.height * 0.2),
                child: noDataScreen(
                  noDataImage: Res.icRestaurant,
                  title: 'no_res_details_title'.tr,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  customScrollWidget() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: false,
          pinned: true,
          automaticallyImplyLeading: false,
          expandedHeight: Get.height * 0.3,
          title: headerWidget(),
          backgroundColor: ColorsTheme.colWhite,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: false,
            background: SizedBox(
              width: Get.width,
              child: Stack(
                children: [
                  Container(
                    color: ColorsTheme.colWhite,
                    margin: const EdgeInsets.only(bottom: 50),
                    child: controller.homeData.value.restaurantProfile == null
                        ? Image.asset(
                            Res.icDummyBanner,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            controller.homeData.value.restaurantProfile!,
                            width: Get.width,
                            fit: BoxFit.cover,
                            errorBuilder: (context, obj, stackTrace) {
                            return Image.asset(
                              Res.icDummyBanner,
                              fit: BoxFit.cover,
                            );
                          }),
                  ),
                  Positioned(
                      bottom: 0,
                      left: 10,
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        width: 120,
                        height: 120,
                        padding: const EdgeInsets.all(6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(80),
                          child: controller
                                      .homeData.value.restaurantCoverProfile ==
                                  null
                              ? Image.asset(
                                  Res.icDummyLogo,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  controller
                                      .homeData.value.restaurantCoverProfile!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, obj, stackTrace) {
                                  return Image.asset(
                                    Res.icDummyLogo,
                                    fit: BoxFit.cover,
                                  );
                                }),
                        ),
                      ))
                ],
              ),
            ),
            collapseMode: CollapseMode.parallax,
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            width: Get.width,
            decoration: BoxDecoration(
                color: ColorsTheme.colWhite,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    left: 18,
                    right: 18,
                  ),
                  child: Text(
                    controller.homeData.value.restaurantName!,
                    style: semiBoldTextStyle(
                        fontSize: dimen19, color: ColorsTheme.colBlack),
                  ),
                ),

                ///change by client
                Visibility(
                  visible: false,
                  child: Container(
                    margin: const EdgeInsets.only(left: 18, right: 18, top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: ColorsTheme.colPrimary,
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          margin: const EdgeInsets.only(right: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                                controller.homeData.value.avgRating!
                                    .toStringAsFixed(1),
                                style: regularTextStyle(
                                    fontSize: dimen10,
                                    color: ColorsTheme.colWhite),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "(${controller.homeData.value.totalReview!})",
                          style: regularTextStyle(
                              fontSize: dimen12, color: ColorsTheme.colBlack),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(left: 18, right: 18, top: 15),
                  child: Text(
                    "What others people are saying",
                    style: semiBoldTextStyle(
                        fontSize: dimen13, color: ColorsTheme.colBlack),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 18, right: 18, top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.star,
                                color: ColorsTheme.colPrimary,
                                size: 25,
                              ),
                            ),
                            Text(
                              '${controller.homeData.value.avgRating!.toStringAsFixed(1)} / 5.0',
                              style: semiBoldTextStyle(
                                  fontSize: dimen13,
                                  color: ColorsTheme.colBlack),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${controller.homeData.value.totalReview!} People rated",
                        style: regularTextStyle(
                            fontSize: dimen12, color: ColorsTheme.colBlack),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Divider(
                    color: ColorsTheme.colSecondary,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 18, right: 18, top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: Image.asset(
                                  Res.icLocation,
                                  width: 40,
                                  height: 40,
                                )),
                            Expanded(
                              child: Text(
                                controller.homeData.value.restaurantAddress!,
                                style: regularTextStyle(
                                    fontSize: dimen12,
                                    color: ColorsTheme.colBlack),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (controller.homeData.value.latitude != 0 &&
                              controller.homeData.value.latitude != 0) {
                            controller.openMap(
                                controller.homeData.value.latitude!,
                                controller.homeData.value.longitude!);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: ColorsTheme.colPrimary,
                              borderRadius: BorderRadius.circular(50)),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'View Map'.tr,
                            style: regularTextStyle(
                                fontSize: dimen11, color: ColorsTheme.colWhite),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                ///by client changes
                Visibility(
                  visible: false,
                  child: Container(
                    margin: const EdgeInsets.only(left: 18, right: 18, top: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: Image.asset(
                              Res.icPickupTime,
                              width: 40,
                              height: 40,
                            )),
                        Text(
                          '${CommonFunction.formatPickupTime(controller.homeData.value.openTime!)} to ${CommonFunction.formatPickupTime(controller.homeData.value.closeTime!)}',
                          style: regularTextStyle(
                              fontSize: dimen12, color: ColorsTheme.colBlack),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Divider(
                    color: ColorsTheme.colSecondary,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10, top: 10),
                  child: foodPreferencesList(),
                ),
                TabBar(
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.zero,
                  controller: controller.tabController,
                  dividerColor: Colors.transparent,
                  labelColor: ColorsTheme.colPrimary,
                  labelStyle: boldTextStyle(
                      fontSize: dimen15, color: ColorsTheme.colBlack),
                  unselectedLabelStyle: boldTextStyle(
                      fontSize: dimen15, color: ColorsTheme.colBlack),
                  unselectedLabelColor: ColorsTheme.colBlack,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: ColorsTheme.colPrimary,
                  indicatorWeight: 2.5,
                  labelPadding: const EdgeInsets.only(
                      bottom: 12, right: 15, left: 15, top: 12),
                  isScrollable: true,
                  tabs: [
                    Text(
                      'Menu'.tr,
                    ),
                    // Text(
                    //   'Magic Bag'.tr,
                    // ),
                  ],
                  onTap: (index) {
                    controller.selectedTabIndex.value = index;
                  },
                ).marginOnly(left: 15),
                Obx(() => controller.selectedTabIndex.value == 0
                    ? predefinedMainMenuWidget()
                    : checkFoodPrefWithMagic()),
                contentList()
              ],
            ),
          ),
        )
      ],
    );
  }

  headerWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 34),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              controller.onBack();
              // Get.delete<HomeDetailsController>();
            },
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(14)),
                width: 35,
                height: 35,
                alignment: Alignment.center,
                child: Image.asset(
                  Res.icBack,
                  height: 18,
                  width: 18,
                )),
          ),
          Row(
            children: [
              InkWell(
                onTap: () async {
                  // controller.getRestroLink();
                  FirebaseDynamicLinks dynamicLinks =
                      FirebaseDynamicLinks.instance;
                  var parameters = DynamicLinkParameters(
                    uriPrefix: 'https://goodtograb.page.link',
                    link: Uri.parse(
                        'https://goodtograb.com/homeDetails?resId=${controller.resId}&currency=${controller.currency}'),
                    androidParameters: const AndroidParameters(
                      packageName: "com.good.grab",
                    ),
                    socialMetaTagParameters: SocialMetaTagParameters(
                      title: controller.homeData.value.restaurantName,
                      imageUrl: Uri.parse(
                          controller.homeData.value.restaurantProfile ?? ''),
                    ),
                    iosParameters: const IOSParameters(
                      bundleId: "com.good.grab",
                      appStoreId: '6451374378',
                    ),
                  );
                  var dynamicUrl = await dynamicLinks.buildLink(parameters);
                  var shortLink = await dynamicLinks.buildShortLink(parameters,
                      shortLinkType: ShortDynamicLinkType.unguessable);
                  var shortUrl = shortLink.shortUrl;
                  print('create short link');
                  print(shortUrl);
                  print(dynamicUrl);

                  Share.share(shortUrl.toString());
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(14)),
                    width: 35,
                    height: 35,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(right: 15),
                    child: Image.asset(
                      Res.icShare,
                      height: 18,
                      width: 18,
                    )),
              ),
              InkWell(
                  onTap: () {
                    if (controller.userId.value != -1) {
                      controller.addFav();
                    } else {
                      controller.loginBottomSheet();
                    }
                  },
                  child: Obx(() => Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(14)),
                        width: 35,
                        height: 35,
                        alignment: Alignment.center,
                        child: controller.homeData.value.isLiked == "0"
                            ? Image.asset(
                                Res.icHeart,
                                height: 18,
                                width: 18,
                              )
                            : Image.asset(
                                Res.icFillHeart,
                                width: 30,
                                height: 30,
                              ),
                      ))),
            ],
          )
        ],
      ),
    );
  }

  footerWidget(int type) {
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
                  '${'Total Quantity'.tr} ${controller.totalQuantity.value}',
                  style: mediumTextStyle(
                      fontSize: dimen12, color: ColorsTheme.colWhite),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '₹${controller.totalAmount.value}',
                  style: mediumTextStyle(
                      fontSize: dimen12, color: ColorsTheme.colWhite),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (type == 1) {
                  Get.back();
                }
                controller.onCart();
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: ColorsTheme.colWhite,
                      borderRadius: BorderRadius.circular(50)),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Obx(
                    () => Text(
                      '${controller.title.isEmpty ? 'Next'.tr : 'View Cart'.tr} →',
                      style: semiBoldTextStyle(
                          fontSize: dimen13, color: ColorsTheme.colBlack),
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  foodPreferencesList() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // if (controller.selectFoodPref.value != index) {
              // controller.selectFoodPref.value = index;
              // controller.selectedMagicMenuCategoryIndex.value = -1;
              // controller.homeData.refresh();
              // controller.magicMenuList.refresh();
              // } else {
              controller.selectFoodPref.value = -1;
              controller.selectedMagicMenuCategoryIndex.value = -1;
              // }
            },
            child: Obx(
              () => Container(
                decoration: controller.selectFoodPref.value == -1
                    ? BoxDecoration(
                        color: ColorsTheme.colPrimary,
                        border: Border.all(color: Colors.transparent, width: 1),
                        borderRadius: BorderRadius.circular(50))
                    : BoxDecoration(
                        color: Colors.transparent,
                        border:
                            Border.all(color: ColorsTheme.colBlack, width: 1),
                        borderRadius: BorderRadius.circular(50)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.only(left: 6, right: 6, top: 5),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    // Container(
                    //   margin: const EdgeInsets.only(right: 8),
                    //   child: Image.asset(
                    //     width: 20,
                    //     height: 20,
                    //   ),
                    // ),
                    Text(
                      "All",
                      style: regularTextStyle(
                          fontSize: dimen13,
                          color: controller.selectFoodPref.value == -1
                              ? ColorsTheme.colWhite
                              : ColorsTheme.colBlack),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: controller.foodPrefList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    if (controller.selectFoodPref.value != index) {
                      print('first tap $index');
                      controller.selectFoodPref.value = index;
                      controller.selectedMagicMenuCategoryIndex.value = -1;
                      // controller.homeData.refresh();
                      // controller.magicMenuList.refresh();
                    } else {
                      print('second tap');
                      controller.selectFoodPref.value = -1;
                      controller.selectedMagicMenuCategoryIndex.value = -1;
                    }
                  },
                  child: Obx(
                    () => Container(
                      decoration: controller.selectFoodPref.value == index
                          ? BoxDecoration(
                              color: ColorsTheme.colPrimary,
                              border: Border.all(
                                  color: Colors.transparent, width: 1),
                              borderRadius: BorderRadius.circular(50))
                          : BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                  color: ColorsTheme.colBlack, width: 1),
                              borderRadius: BorderRadius.circular(50)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      margin: const EdgeInsets.only(left: 6, right: 6, top: 5),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            child: Image.asset(
                              index == 0
                                  ? Res.icVeg
                                  : index == 1
                                      ? Res.icEgg
                                      : Res.icNonVeg,
                              width: 20,
                              height: 20,
                            ),
                          ),
                          Text(
                            controller.foodPrefList[index],
                            style: regularTextStyle(
                                fontSize: dimen11,
                                color: controller.selectFoodPref.value == index
                                    ? ColorsTheme.colWhite
                                    : ColorsTheme.colBlack),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  checkFoodPrefWithMagic() {
    if (controller.homeData.value.menuData != null &&
        controller.homeData.value.menuData!.magic != null) {
      if (controller.selectFoodPref.value == -1) {
        return controller.homeData.value.menuData!.magic!.isNotEmpty
            ? magicBagWidget()
            : magicBagNotAvailable();
      } else {
        return controller.magicMenuList
                .where((p0) => _matchesSelected(p0.foodPrefrence))
                .isNotEmpty
            ? magicBagWidget()
            : magicBagNotAvailable();
      }
    } else {
      return magicBagNotAvailable();
    }
  }

  magicBagWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            child: controller.magicMenuCategories.length == 1
                ? Container()
                : Container(
                    height: 50,
                    margin: const EdgeInsets.only(
                        left: 6, right: 6, top: 8, bottom: 8),
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.magicMenuCategories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            if (controller
                                    .selectedMagicMenuCategoryIndex.value ==
                                index) {
                              controller.selectedMagicMenuCategoryIndex.value =
                                  -1;
                              controller.homeData.refresh();
                            } else {
                              controller.selectedMagicMenuCategoryIndex.value =
                                  index;
                              controller.homeData.refresh();
                            }
                          },
                          child: Obx(
                            () => controller.magicMenuCategories[index]
                                            .food_preference_type ==
                                        "0" ||
                                    controller.selectFoodPref.value == -1 ||
                                    (controller.selectFoodPref.value == 0 &&
                                        controller.magicMenuCategories[index]
                                                .food_preference_type ==
                                            "2") ||
                                    (controller.selectFoodPref.value == 1 &&
                                        controller.magicMenuCategories[index]
                                                .food_preference_type ==
                                            "1") ||
                                    // Egg selection should include only Egg ("3") categories
                                    (controller.selectFoodPref.value == 2 &&
                                        controller.magicMenuCategories[index]
                                                .food_preference_type ==
                                            "3")
                                ? Container(
                                    decoration: controller
                                                .selectedMagicMenuCategoryIndex
                                                .value ==
                                            index
                                        ? BoxDecoration(
                                            color: ColorsTheme.colPrimary,
                                            border: Border.all(
                                                color: Colors.transparent,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(50))
                                        : BoxDecoration(
                                            color: Colors.transparent,
                                            border: Border.all(
                                                color: ColorsTheme.colBlack,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    margin: const EdgeInsets.only(
                                        left: 6, right: 6, top: 5),
                                    alignment: Alignment.center,
                                    child: Text(
                                      controller
                                          .magicMenuCategories[index].title,
                                      style: regularTextStyle(
                                          fontSize: dimen11,
                                          color: controller
                                                      .selectedMagicMenuCategoryIndex
                                                      .value ==
                                                  index
                                              ? ColorsTheme.colWhite
                                              : ColorsTheme.colBlack),
                                    ),
                                  )
                                : Container(),
                          ),
                        );
                      },
                    ),
                  )),
        magicItemList(getMagicList()),
      ],
    );
  }

  /// menu
  predefinedMainMenuWidget() {
    return controller.homeData.value.menuData != null &&
            controller.homeData.value.menuData!.preDefined != null &&
            controller.homeData.value.menuData!.preDefined!.isNotEmpty
        ? checkPCategory()
        : pMenuDataNotAvailable();
  }

  checkPCategory() {
    if (controller.selectFoodPref.value == -1) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: controller.homeData.value.menuData!.preDefined!.length,
        itemBuilder: (BuildContext context, int parentIndex) {
          if (controller
                      .homeData.value.menuData!.preDefined![parentIndex].list !=
                  null &&
              controller.homeData.value.menuData!.preDefined![parentIndex].list!
                  .isNotEmpty) {
            return controller.selectFoodPref.value == -1
                ? predefinedMenuWidget(parentIndex)
                : controller.homeData.value.menuData!.preDefined![parentIndex]
                            .foodPrefrence!
                            .toLowerCase() ==
                        controller.foodPrefList[controller.selectFoodPref.value]
                            .toLowerCase()
                    ? predefinedMenuWidget(parentIndex)
                    : Container();
          } else {
            return Container();
          }
        },
      );
    } else {
      // For selected filter, show "no menus" only if no item in any category matches
      final hasAnyMatchingItem = controller.homeData.value.menuData!.preDefined!
          .any((cat) => (cat.list ?? [])
              .any((item) => _matchesSelected(item.foodPrefrence)));
      return !hasAnyMatchingItem
          ? pMenuDataNotAvailable()
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: controller.homeData.value.menuData!.preDefined!.length,
              itemBuilder: (BuildContext context, int parentIndex) {
                log("new index is ${controller.selectFoodPref.value}");
                if (controller.homeData.value.menuData!.preDefined![parentIndex]
                            .list !=
                        null &&
                    controller.homeData.value.menuData!.preDefined![parentIndex]
                        .list!.isNotEmpty) {
                  return predefinedMenuWidget(parentIndex);
                } else {
                  return Container();
                }
              },
            );
    }
  }

  predefinedMenuWidget(parentIndex) {
    bool hasData = controller.selectFoodPref.value == -1 ||
        controller.homeData.value.menuData!.preDefined![parentIndex].list!
            .any((p0) => _matchesSelected(p0.foodPrefrence));
    if (!hasData) return SizedBox(); // 🔴 skip rendering if no matching data

    return GestureDetector(
      onTap: () {
        controller.homeData.value.menuData!.preDefined![parentIndex].isOpen =
            !controller
                .homeData.value.menuData!.preDefined![parentIndex].isOpen!;
        controller.homeData.refresh();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: ColorsTheme.colF2FFFB,
              border: Border.all(color: Colors.transparent, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            margin: const EdgeInsets.only(bottom: 5),
            width: Get.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    controller.homeData.value.menuData!.preDefined![parentIndex]
                        .title!,
                    style: boldTextStyle(
                        fontSize: dimen14, color: ColorsTheme.colBlack),
                  ),
                )

                // Icon(
                //   controller.homeData.value.menuData!.preDefined![parentIndex].isOpen! ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                //   color: ColorsTheme.colBlack,
                //   size: 40,
                // )
              ],
            ),
          ),
          // controller.homeData.value.menuData!.preDefined![parentIndex].isOpen!
          //     ?
          controller.selectFoodPref.value == -1
              ? magicItemList(controller
                  .homeData.value.menuData!.preDefined![parentIndex].list!)
              : controller
                      .homeData.value.menuData!.preDefined![parentIndex].list!
                      .where((p0) => _matchesSelected(p0.foodPrefrence))
                      .isNotEmpty
                  ? magicItemList(controller
                      .homeData.value.menuData!.preDefined![parentIndex].list!
                      .where((p0) => _matchesSelected(p0.foodPrefrence))
                      .toList())
                  : Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: pMenuDataNotAvailable(),
                    )
          // : Container(),
        ],
      ),
    );
  }

  pMenuDataNotAvailable() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
      child: Text(
        "No Menus available!",
        style:
            semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
      ),
    );
  }

  /// magic
  getMagicList() {
    if (controller.selectFoodPref.value == -1) {
      return controller.selectedMagicMenuCategoryIndex.value == -1
          ? controller.magicMenuList
          : controller.magicMenuList
              .where((p0) =>
                  p0.categoryId!.toLowerCase() ==
                  controller
                      .magicMenuCategories[
                          controller.selectedMagicMenuCategoryIndex.value]
                      .title
                      .toString()
                      .toLowerCase())
              .toList();
    } else {
      return controller.selectedMagicMenuCategoryIndex.value == -1
          ? controller.magicMenuList
              .where((p0) => _matchesSelected(p0.foodPrefrence))
              .toList()
          : controller.magicMenuList
              .where((p0) =>
                  _matchesSelected(p0.foodPrefrence) &&
                  p0.categoryId!.toLowerCase() ==
                      controller
                          .magicMenuCategories[
                              controller.selectedMagicMenuCategoryIndex.value]
                          .title
                          .toString()
                          .toLowerCase())
              .toList();
    }
  }

  magicBagNotAvailable() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
      child: Text(
        "No Magic Bags available, but enjoy our Menu instead!",
        style:
            semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
      ),
    );
  }

  magicItemList(List<MenuDataList> menuList) {
    return ListView.builder(
        itemCount: menuList.length,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            // color: ColorsTheme.colF2FFFB,
            color: ColorsTheme.colWhite,
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          // Get.toNamed(Routes.imageDetail,
                          //     arguments: [controller.homeData.value.menuData![controller.selectFoodPref.value].list![index].menuImage!]);
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(80),
                            child: menuList[index].menuImage! == ""
                                ? Container()
                                : Image.network(menuList[index].menuImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, obj, stackTrace) {
                                    return Image.asset(
                                      Res.icDummyLogo,
                                      fit: BoxFit.cover,
                                    );
                                  }),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      _normalizePref(menuList[index]
                                                  .foodPrefrence) ==
                                              'veg'
                                          ? Res.icVeg
                                          : _normalizePref(menuList[index]
                                                      .foodPrefrence) ==
                                                  'nonveg'
                                              ? Res.icNonVeg
                                              : _normalizePref(menuList[index]
                                                          .foodPrefrence) ==
                                                      'egg'
                                                  ? Res.icEgg
                                                  : Res.icDummyFoodType,
                                      width: 20,
                                      height: 20,
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          menuList[index].menuName!,
                                          // "spl. chicken biryani(serves 1) best food low price with doorstop delivery",
                                          style: boldTextStyle(
                                              fontSize: dimen13,
                                              color: ColorsTheme.colBlack),
                                          // maxLines: 2,
                                          // overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          if (controller.homeData.value
                                                  .restaurantStatus ==
                                              1) {
                                            controller
                                                .removeCart(menuList[index]);
                                          } else {
                                            showErrorSnackBar(
                                                "Restaurant is closed, currently unavailable!");
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          width: 34,
                                          height: 34,
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            Res.icMinus,
                                            width: 12,
                                            height: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Text(
                                        menuList[index]
                                            .selectedQuantity
                                            .toString(),
                                        style: semiBoldTextStyle(
                                            fontSize: dimen17,
                                            color: ColorsTheme.colBlack),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          if (controller.homeData.value
                                                  .restaurantStatus ==
                                              1) {
                                            qBottomSheet(menuList, index);
                                          } else {
                                            showErrorSnackBar(
                                                "Restaurant is closed, currently unavailable!");
                                          }
                                          //controller.addCart(index);
                                        },
                                        child: Image.asset(
                                          Res.icAdd,
                                          width: 36,
                                          height: 36,
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
                Container(
                  margin: const EdgeInsets.only(left: 15, right: 15, top: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Text(
                            'Qty Left : ${(menuList[index].quantity ?? 0).toString()}',
                            style: regularTextStyle(
                                fontSize: dimen13, color: ColorsTheme.colBlack),
                            maxLines: 2,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 5),
                            child: Text(
                              (menuList[index].finalPrice ?? 0).toString(),
                              style: boldTextStyle(
                                  fontSize: dimen15,
                                  color: ColorsTheme.colBlack),
                              maxLines: 2,
                            ),
                          ),
                          Text(
                            (menuList[index].offerPrice ?? 0).toString(),
                            style: TextStyle(
                                fontSize: dimen11,
                                color: ColorsTheme.col8FA19C,
                                fontWeight: FontWeight.w400,
                                decorationColor: ColorsTheme.col8FA19C,
                                decoration: TextDecoration.lineThrough),
                            maxLines: 2,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: 15, right: 15, top: 5, bottom: 5),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Text(
                          'Pickup Time :',
                          style: mediumTextStyle(
                              fontSize: dimen12, color: ColorsTheme.colBlack),
                        ),
                      ),
                      Text(
                        '${CommonFunction.formatPickupTime(menuList[index].startTime!)} to ${CommonFunction.formatPickupTime(menuList[index].endTime!)}',
                        style: regularTextStyle(
                            fontSize: dimen12, color: ColorsTheme.colBlack),
                      ),
                    ],
                  ),
                ),
                menuList[index].expirtyDate == null ||
                        menuList[index].expirtyDate == ''
                    ? Container()
                    : Container(
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 5),
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Text(
                                'Expiry Date :',
                                style: mediumTextStyle(
                                    fontSize: dimen12,
                                    color: ColorsTheme.colBlack),
                              ),
                            ),
                            Text(
                              (menuList[index].expirtyDate != null &&
                                      menuList[index].expirtyDate!.isNotEmpty)
                                  ? formatDateDMY(menuList[index].expirtyDate!)
                                  : '--',
                              style: regularTextStyle(
                                fontSize: dimen12,
                                color: ColorsTheme.colBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                menuList.length - 1 == index
                    ? Container()
                    : Container(
                        height: 1,
                        margin: const EdgeInsets.only(top: 5),
                        width: Get.width,
                        color: ColorsTheme.colSecondary,
                      ),
              ],
            ),
          );
        });
  }

  contentList() {
    return ListView.separated(
      itemCount: controller.homeData.value.restaurantContent!.length,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: const EdgeInsets.only(top: 5, bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 18, right: 18, bottom: 5),
                child: Text(
                  controller
                      .homeData.value.restaurantContent![index].contentType!,
                  style: semiBoldTextStyle(
                      fontSize: dimen13, color: ColorsTheme.colBlack),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 18, right: 18, top: 5),
                child: Text(
                  controller
                      .homeData.value.restaurantContent![index].description!,
                  style: regularTextStyle(
                      fontSize: dimen11, color: ColorsTheme.colBlack),
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: ColorsTheme.colSecondary,
        );
      },
    );
  }

  qBottomSheet(List<MenuDataList> menuList, index) {
    return Get.bottomSheet(enableDrag: true,
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Container(
        width: Get.width,
        decoration: BoxDecoration(
          color: ColorsTheme.colWhite,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(15),
              child: Text(
                'Add Item',
                style: boldTextStyle(
                    fontSize: dimen15, color: ColorsTheme.colBlack),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 15),
              color: ColorsTheme.colD0F0BF,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Text(
                      'Pickup Time',
                      style: mediumTextStyle(
                          fontSize: dimen12, color: ColorsTheme.colPrimary),
                    ),
                  ),
                  Text(
                    '${CommonFunction.formatPickupTime(menuList[index].startTime!)} to ${CommonFunction.formatPickupTime(menuList[index].endTime!)}',
                    style: regularTextStyle(
                        fontSize: dimen12, color: ColorsTheme.colPrimary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Get.toNamed(Routes.imageDetail,
                                  arguments: [menuList[index].menuImage!]);
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.only(left: 10),
                              // padding: const EdgeInsets.all(6),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(80),
                                child: menuList[index].menuImage! == ""
                                    ? Container()
                                    : Image.network(menuList[index].menuImage!,
                                        fit: BoxFit.cover, errorBuilder:
                                            (context, obj, stackTrace) {
                                        return Image.asset(
                                          Res.icDummyLogo,
                                          fit: BoxFit.cover,
                                        );
                                      }),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 18, right: 18, top: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          _normalizePref(menuList[index]
                                                      .foodPrefrence) ==
                                                  'veg'
                                              ? Res.icVeg
                                              : _normalizePref(menuList[index]
                                                          .foodPrefrence) ==
                                                      'nonveg'
                                                  ? Res.icNonVeg
                                                  : _normalizePref(menuList[
                                                                  index]
                                                              .foodPrefrence) ==
                                                          'egg'
                                                      ? Res.icEgg
                                                      : Res.icDummyFoodType,
                                          width: 20,
                                          height: 20,
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              menuList[index].menuName!,
                                              style: boldTextStyle(
                                                  fontSize: dimen13,
                                                  color: ColorsTheme.colBlack),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              await controller
                                                  .removeCart(menuList[index]);
                                              setState(() {
                                                controller.homeData.refresh();
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 1,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              width: 34,
                                              height: 34,
                                              alignment: Alignment.center,
                                              child: Image.asset(
                                                Res.icMinus,
                                                width: 12,
                                                height: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Text(
                                            menuList[index]
                                                .selectedQuantity
                                                .toString(),
                                            style: semiBoldTextStyle(
                                                fontSize: dimen17,
                                                color: ColorsTheme.colBlack),
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              await controller
                                                  .addCart(menuList[index]);
                                              setState(() {
                                                controller.homeData.refresh();
                                              });
                                            },
                                            child: Image.asset(
                                              Res.icAdd,
                                              width: 36,
                                              height: 36,
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
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: Text(
                                  'Qty Left : ${(menuList[index].quantity ?? 0).toString()}',
                                  style: regularTextStyle(
                                      fontSize: dimen13,
                                      color: ColorsTheme.colBlack),
                                  maxLines: 2,
                                ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 8, right: 18),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 5),
                                child: Text(
                                  '${controller.currency}${(menuList[index].finalPrice ?? 0).toString()}',
                                  style: boldTextStyle(
                                      fontSize: dimen15,
                                      color: ColorsTheme.colBlack),
                                  maxLines: 2,
                                ),
                              ),
                              Text(
                                '${controller.currency}${(menuList[index].offerPrice ?? 0).toString()}',
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
                        )
                      ],
                    ),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(
                        top: 15,
                      ),
                      width: Get.width,
                      color: ColorsTheme.colSecondary,
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 18, right: 18, top: 5),
                      child: Text(
                        menuList[index].menuDescription != null
                            ? menuList[index].menuDescription!.split('Note')[0]
                            : '',
                        style: regularTextStyle(
                            fontSize: dimen12, color: ColorsTheme.colBlack),
                      ),
                    ),
                    menuList[index].menuNote != null &&
                            menuList[index].menuNote!.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 1,
                                margin:
                                    const EdgeInsets.only(top: 10, bottom: 5),
                                width: Get.width,
                                color: ColorsTheme.colSecondary,
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 18, right: 18, top: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 2),
                                      child: Text(
                                        'Note :-',
                                        style: mediumTextStyle(
                                            fontSize: dimen12,
                                            color: ColorsTheme.colBlack),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        menuList[index].menuNote!,
                                        style: regularTextStyle(
                                            fontSize: dimen12,
                                            color: ColorsTheme.colBlack),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        : Container(
                            margin: const EdgeInsets.only(top: 5),
                          ),
                  ],
                ),
              ),
            ),
            controller.totalQuantity.value == 0 ? Container() : footerWidget(1)
          ],
        ),
      );
    }));
  }

  formatDateDMY(String date) {
    if (date.isEmpty) return '';

    // handles both `2025-12-13` and `2025-12-13T00:00:00`
    final pureDate = date.split('T').first;
    final parts = pureDate.split('-');

    if (parts.length != 3) return date;

    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }
}
