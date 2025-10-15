import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/analytics/meta_pixel.dart';
import 'package:good_grab/infrastructure/constants/app_constants.dart';
import 'package:good_grab/infrastructure/navigation/routes.dart';
import 'package:good_grab/infrastructure/shared/pref_manager.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/models/cart_model.dart';
import '../../infrastructure/models/home_details_model.dart';
import '../../infrastructure/models/restro_link_model.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/permission_fun.dart';
import '../../infrastructure/shared/progress_dialog.dart';
import '../../infrastructure/shared/snackbar.util.dart';
import '../../infrastructure/theme/text.theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class HomeDetailsController extends GetxController
    with GetTickerProviderStateMixin {
  var totalQuantity = 0.obs;
  var totalAmount = (0.0).obs;

  Rx<RestroDetail> homeData = RestroDetail().obs;
  var currency = '';
  var resId = 0;
  var isLoad = true.obs;
  var isHomeData = false.obs;
  var userId = Rx(-1);

  var selectFoodPref = Rx(-1);

  var title = ''.obs;
  var dynamicLink = ''.obs;
  var screenType = null;
  var isBackResult = false.obs;

  TabController? tabController;
  var selectedTabIndex = 0.obs;

  var magicMenuList = <MenuDataList>[].obs;
  var magicMenuCategories = <CategoriesMagic>[].obs;
  var selectedMagicMenuCategoryIndex = Rx(-1);

  var foodPrefList = ['Veg', 'Non-Veg'];

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    resId = Get.arguments['resId'];
    currency = Get.arguments['currency'];
    screenType = Get.arguments['type'];

    log("screenType....${screenType}");

    Future.delayed(Duration.zero, () async {
      var userCheckId = await PrefManager.getInt(AppConstants.userId);
      userId.value = userCheckId == 0 ? -1 : userCheckId;
      await getHomeDetails();
    });
    super.onInit();
  }

  getHomeDetails() async {
    try {
      magicMenuCategories.clear();
      magicMenuList.clear();
      var cartId = await PrefManager.getInt(AppConstants.cartId);
      Map<String, dynamic> params = {
        'restro_id': resId,
      };
      if (userId.value != -1) {
        params['user_id'] = userId.value;
      }
      if (cartId != 0) {
        params['cart_id'] = cartId;
      }

      ApiResponseModel<HomeDetailsModel> homeDetailsModel =
          await DioClient.base().funHomeDetailsApi(params);

      if (homeDetailsModel.success! &&
          homeDetailsModel.data != null &&
          homeDetailsModel.data!.restroDetail != null) {
        /*  print("rstweafhsdfh");
        print(jsonEncode(homeDetailsModel.data));*/
        log("response ${homeDetailsModel.data?.restroDetail?.restaurantStatus}");
        homeData.value = homeDetailsModel.data!.restroDetail!;
        totalQuantity.value = 0;
        totalAmount.value = 0;

        log("preference data full --->11 ${jsonEncode(homeData.value.menuData!)}  {}");
        if (homeData.value.menuData != null &&
            homeData.value.menuData!.magic != null &&
            homeData.value.menuData!.magic!.isNotEmpty) {
          for (int j = 0; j < homeData.value.menuData!.magic!.length; j++) {
            log("preference data ---> ${homeData.value.menuData!.magic![j].food_preference_type ?? "n\a"}");
            magicMenuCategories.add(CategoriesMagic(
                homeData.value.menuData!.magic![j].title!,
                "${homeData.value.menuData!.magic![j].food_preference_type ?? "0"}"));
            if (homeData.value.menuData!.magic![j].list != null &&
                homeData.value.menuData!.magic![j].list!.isNotEmpty) {
              magicMenuList.addAll(homeData.value.menuData!.magic![j].list!);
              for (int i = 0;
                  i < homeData.value.menuData!.magic![j].list!.length;
                  i++) {
                if (homeData
                        .value.menuData!.magic![j].list![i].selectedQuantity !=
                    0) {
                  totalQuantity.value = totalQuantity.value +
                      homeData
                          .value.menuData!.magic![j].list![i].selectedQuantity!;
                  totalAmount.value = totalAmount.value +
                      (homeData.value.menuData!.magic![j].list![i]
                              .selectedQuantity! *
                          homeData
                              .value.menuData!.magic![j].list![i].finalPrice!);
                }
              }
            }
          }
        }

        if (homeData.value.menuData != null &&
            homeData.value.menuData!.preDefined != null &&
            homeData.value.menuData!.preDefined!.isNotEmpty) {
          for (int j = 0;
              j < homeData.value.menuData!.preDefined!.length;
              j++) {
            if (homeData.value.menuData!.preDefined![j].list != null &&
                homeData.value.menuData!.preDefined![j].list!.isNotEmpty) {
              for (int i = 0;
                  i < homeData.value.menuData!.preDefined![j].list!.length;
                  i++) {
                if (homeData.value.menuData!.preDefined![j].list![i]
                        .selectedQuantity !=
                    0) {
                  totalQuantity.value = totalQuantity.value +
                      homeData.value.menuData!.preDefined![j].list![i]
                          .selectedQuantity!;
                  totalAmount.value = totalAmount.value +
                      (homeData.value.menuData!.preDefined![j].list![i]
                              .selectedQuantity! *
                          homeData.value.menuData!.preDefined![j].list![i]
                              .finalPrice!);
                }
              }
            }
          }
        }

        homeData.refresh();
        Future.delayed(const Duration(milliseconds: 500), () {
          isLoad.value = false;
          isHomeData.value = true;
        });
      } else {
        isLoad.value = false;
        isHomeData.value = false;
        errorScreen(error: 'something_went_wrong'.tr);
      }
    } on CustomHttpException catch (exception) {
      log("CustomHttpException in magic-restaurant-details api ${exception}");
      isLoad.value = false;
      isHomeData.value = false;
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      log("exception in magic-restaurant-details api ${exception}");
      isLoad.value = false;
      isHomeData.value = false;
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  addFav() async {
    ProgressDialog progressDialog = ProgressDialog();
    progressDialog.show();
    try {
      var accessToken = await PrefManager.getString(AppConstants.accessToken);
      Map<String, dynamic> params = {
        'restro_id': homeData.value.restaurantId,
      };
      ApiResponseModel addFavModel =
          await DioClient.base(accessToken: accessToken).funAddFavApi(params);
      if (addFavModel.success!) {
        isBackResult.value = true;
        homeData.value.isLiked = homeData.value.isLiked == "0" ? "1" : "0";
        homeData.refresh();
        progressDialog.dismiss();
      } else {
        progressDialog.dismiss();
        errorScreen(error: 'something_went_wrong'.tr);
      }
    } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      progressDialog.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  addCart(MenuDataList menuData) async {
    if (menuData.selectedQuantity! < menuData.quantity!) {
      var tempQuantity = menuData.selectedQuantity! + 1;
      await addRemoveCartApi(menuData, tempQuantity);
    } else {
      SnackBarUtil.showError(
          message: 'Your magic bag quantity has been maxed out');
    }
  }

  removeCart(MenuDataList menuData) async {
    if (menuData.selectedQuantity! != 0) {
      var tempQuantity = menuData.selectedQuantity! - 1;
      await addRemoveCartApi(menuData, tempQuantity);
    }
  }

  addRemoveCartApi(MenuDataList menuData, tempQuantity) async {
    try {
      var cartId = await PrefManager.getInt(AppConstants.cartId);
      var deviceId = await PrefManager.getString(AppConstants.deviceId);
      Map<String, dynamic> params = {
        'restro_id': resId,
        "menu_data": [
          {"menu_id": menuData.menuId, "quantity": tempQuantity}
        ],
      };
      if (cartId != 0) {
        params['cart_id'] = cartId;
      } else {
        params['device_id'] = deviceId;
      }

      ApiResponseModel<CartModel> cartModel =
          await DioClient.base().funAddCartApi(params);

      if (cartModel.success! && cartModel.data != null) {
        isBackResult.value = true;

        totalQuantity.value = 0;
        totalAmount.value = 0;
        final prevQty = menuData.selectedQuantity ?? 0;
        menuData.selectedQuantity = tempQuantity;
        funTotalQuantityAndAmount();
        homeData.refresh();
        // Analytics: AddToCart when quantity increases on details page
        try {
          if (tempQuantity > prevQty) {
            final item = AnalyticsEventItem(
              itemId: (menuData.menuId ?? '').toString(),
              itemName: menuData.menuName ?? 'menu_item',
              itemBrand: homeData.value.restaurantName ??
                  '', // vendor_name mapped to GA4 item_brand
              price: menuData.finalPrice ?? 0.0,
              quantity: 1,
            );
            await FirebaseAnalytics.instance.logAddToCart(
              currency: (currency.isNotEmpty ? currency : 'INR'),
              value: (menuData.finalPrice ?? 0.0) * 1,
              items: [item],
              parameters: {
                'vendor_name': homeData.value.restaurantName ?? '',
                'item_id': (menuData.menuId ?? '').toString(),
                'price': menuData.finalPrice ?? 0.0,
                'quantity': 1,
              },
            );

            // Mirror to Meta (Facebook)
            await AnalyticsService.logAddToCart(
              itemId: (menuData.menuId ?? '').toString(),
              vendorName: homeData.value.restaurantName ?? '',
              price: menuData.finalPrice ?? 0.0,
              quantity: 1,
            );
            
          }
        } catch (_) {}
        if (cartId == 0) {
          if (cartModel.data!.cartDetails != null) {
            PrefManager.putInt(
                AppConstants.cartId, cartModel.data!.cartDetails!.cartId);
          }
        }
      } else {
        errorScreen(error: cartModel.message!);
      }
    } on CustomHttpException catch (exception) {
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      print(exception.toString());
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  funTotalQuantityAndAmount() {
    if (homeData.value.menuData != null &&
        homeData.value.menuData!.magic != null &&
        homeData.value.menuData!.magic!.isNotEmpty) {
      for (int j = 0; j < homeData.value.menuData!.magic!.length; j++) {
        if (homeData.value.menuData!.magic![j].list != null &&
            homeData.value.menuData!.magic![j].list!.isNotEmpty) {
          for (int i = 0;
              i < homeData.value.menuData!.magic![j].list!.length;
              i++) {
            if (homeData.value.menuData!.magic![j].list![i].selectedQuantity !=
                0) {
              totalQuantity.value = totalQuantity.value +
                  homeData.value.menuData!.magic![j].list![i].selectedQuantity!;
              totalAmount.value = totalAmount.value +
                  (homeData.value.menuData!.magic![j].list![i]
                          .selectedQuantity! *
                      homeData.value.menuData!.magic![j].list![i].finalPrice!);
            }
          }
        }
      }
    }

    if (homeData.value.menuData != null &&
        homeData.value.menuData!.preDefined != null &&
        homeData.value.menuData!.preDefined!.isNotEmpty) {
      for (int j = 0; j < homeData.value.menuData!.preDefined!.length; j++) {
        if (homeData.value.menuData!.preDefined![j].list != null &&
            homeData.value.menuData!.preDefined![j].list!.isNotEmpty) {
          for (int i = 0;
              i < homeData.value.menuData!.preDefined![j].list!.length;
              i++) {
            if (homeData
                    .value.menuData!.preDefined![j].list![i].selectedQuantity !=
                0) {
              totalQuantity.value = totalQuantity.value +
                  homeData.value.menuData!.preDefined![j].list![i]
                      .selectedQuantity!;
              totalAmount.value = totalAmount.value +
                  (homeData.value.menuData!.preDefined![j].list![i]
                          .selectedQuantity! *
                      homeData
                          .value.menuData!.preDefined![j].list![i].finalPrice!);
            }
          }
        }
      }
    }
  }

  Future<void> openMap(double latitude, double longitude) async {
    var googleUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }

  onBack() async {
    if (title.isNotEmpty) {
      title.value = '';
    } else {
      if (screenType == null) {
        Get.back(result: isBackResult.value);
      } else {
        navigateScreen();
      }
    }
  }

  navigateScreen() async {
    var locationStatus = await getLocationPermissionStatus();
    var notificationStatus = await getNotificationPermissionStatus();
    if (locationStatus == 1 && notificationStatus == 1) {
      Get.offAllNamed(Routes.home, arguments: {'permission': 1});
    } else {
      Get.offAllNamed(Routes.allowPermission);
    }
  }

  onCart() async {
    var result = await Get.toNamed(Routes.cart, arguments: {
      'total_quantity': totalQuantity.value,
      'resId': resId,
      'pickupStartTime': homeData.value.openTime,
      'pickupCloseTime': homeData.value.closeTime,
      'pickupLocation': homeData.value.restaurantAddress,
      'vendorName': homeData.value.restaurantName,
    });
    if (result != null && result) {
      isLoad.value = true;
      isHomeData.value = false;
      isBackResult.value = true;
      await getHomeDetails();
    }
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

  getRestroLink() async {
    ProgressDialog progressDialog = ProgressDialog();
    progressDialog.show();
    try {
      Map<String, dynamic> params = {};

      params['restro_id'] = resId;

      ApiResponseModel<RestroLinkModel> restroModel =
          await DioClient.base().getRestroLinkApi(params);

      if (restroModel.success! && restroModel.data != null) {
        progressDialog.dismiss();
        dynamicLink.value = restroModel.data!.dynamicLink.toString();
        Share.share(dynamicLink.value);
      } else {
        progressDialog.dismiss();
        errorScreen(error: restroModel.message!);
      }
    } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      progressDialog.dismiss();
      print(exception.toString());
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }
}

class CategoriesMagic {
  String title;
  String food_preference_type;
  CategoriesMagic(this.title, this.food_preference_type);
}
