import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/presentation/widgets/payment_failed.dart';
import 'package:good_grab/res.dart';
import 'package:lottie/lottie.dart';
import 'package:good_grab/infrastructure/models/cart_model.dart';
import 'package:good_grab/infrastructure/models/restaurant_availability_model.dart';
import 'package:good_grab/infrastructure/shared/common_functions.dart';
import 'package:good_grab/infrastructure/shared/progress_dialog.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'package:intl/intl.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:good_grab/infrastructure/analytics/meta_pixel.dart';
// import 'package:firebase_analytics/observer.dart';

import '../../infrastructure/constants/app_constants.dart';
import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/models/order_data.dart';
import '../../infrastructure/models/create_intent_model.dart';
import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/pref_manager.dart';
import '../../infrastructure/shared/snackbar.util.dart';

import 'package:dio/dio.dart' as dio;

class CartController extends GetxController {
  var cartLoader = true.obs;
  var currency = ''.obs;
  var isCartData = false.obs;
  var upiIdController = TextEditingController();
  var cardNoController = TextEditingController();
  var cardNameController = TextEditingController();
  var cardCvvController = TextEditingController();
  var expireMonthController = TextEditingController();
  var expireYearController = TextEditingController();
  var subTotalFinalPrice = (0.0).obs;
  var subTotalOfferPrice = (0.0).obs;
  var totalGst = (0.0).obs;
  var platformGst = (0.0).obs;
  var platformFee = (0.0).obs;
  var combinedGst = (0.0).obs;
  var totalPay = (0.0).obs;
  var totalQuantity = (0).obs;
  var isFillColor = false.obs;
  var menuList = <MenuDetail>[].obs;
  var resId = Rx(-1);
  var cartId = Rx(-1);
  var userId = Rx(-1);

  var pickupDayList = <PickupDateModel>[].obs;
  List months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  List weeks = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  var pickupDayIndex = 0.obs;

  var title = ''.obs;

  var isBack = false.obs;
  var isPayed = false.obs;

  var pickupStartTime = ''.obs;
  var pickupCloseTime = ''.obs;
  var pickupDate = ''.obs;
  var pickupLocation = ''.obs;
  var paymentType = ''.obs;
  var transactionId = 0.obs;

  var userPhoneNumber = ''.obs;
  var userEmail = ''.obs;
  var userName = ''.obs;
  var countryCode = ''.obs;

  var isNumberAdd = false.obs;
  var isProceedClicked = false.obs;
  var isPhonePe = false.obs;
  var isRazorpay = false.obs;

  /// phonepe
  var phonePeBody = ''.obs;
  var phonePeCallBack = 'https://goodtograb.com/callback-url'
      .obs; //'https://webhook.site/callback-url'.obs;
  Object? phonePeResult;
  var phonePeCheckSum = ''.obs;

  var phonePeTId = ''.obs;

  /// razor pay
  var razorpay = Razorpay();
  var apiCalling = false.obs;

  var rApiKey = ''.obs;
  var rSecretApiKey = 'u3FtMReoFcKlpsWfPwVzHza8'.obs;

  var newOrderId = Rx<dynamic>('');

  @override
  void onInit() {
    title.value = (Get.arguments['vendorName']?.toString() ?? '').isNotEmpty
        ? Get.arguments['vendorName'].toString()
        : 'cart';
    totalQuantity.value = int.parse(Get.arguments['total_quantity'].toString());
    resId.value = int.parse(Get.arguments['resId'].toString());
    pickupStartTime.value = Get.arguments['pickupStartTime'].toString();
    pickupCloseTime.value = Get.arguments['pickupCloseTime'].toString();
    pickupLocation.value = Get.arguments["pickupLocation"].toString();
    Future.delayed(Duration.zero, () async {
      cartId.value = await PrefManager.getInt(AppConstants.cartId);
      userId.value = await PrefManager.getInt(AppConstants.userId);
      await getUserData();
      await getPickupDaysApi();
    });
    super.onInit();
  }

  void showTakeawayReminderDialog() {
    Get.dialog(
      Center(
        child: UnconstrainedBox(
          child: Material(
            color: Colors.white, // ✅ Force solid white background
            borderRadius: BorderRadius.circular(18),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: SizedBox(
                width: Get.width * 0.65, // Adjust width
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            color: ColorsTheme.colPrimary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Takeaway Reminder',
                          style: semiBoldTextStyle(
                            fontSize: dimen16,
                            color: ColorsTheme.colBlack,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 100,
                      child: Lottie.asset(
                        Res.takeAway,
                        repeat: true,
                        animate: true,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Message
                    Text(
                      'Please collect your order directly from this outlet at mentioned pickup time.',
                      textAlign: TextAlign.center,
                      style: regularTextStyle(
                        fontSize: dimen14,
                        color: ColorsTheme.colBlack,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsTheme.colPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 10),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        'Got it',
                        style: semiBoldTextStyle(
                          fontSize: dimen13,
                          color: Colors.white,
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
      barrierDismissible: false,
    );
  }

  getRandomNumber() {
    const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random r = Random();
    return String.fromCharCodes(
        Iterable.generate(22, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
  }

  getUserData() async {
    var currentUser = await PrefManager.getUser();
    if (currentUser != null) {
      countryCode.value = currentUser.countryCode.toString();
      userPhoneNumber.value = currentUser.mobile.toString();
      userName.value = currentUser.username.toString();
      userEmail.value = currentUser.email.toString();
      isProceedClicked.value = userPhoneNumber.value.isNotEmpty;
    }
  }

  getPickupDaysApi() async {
    cartLoader.value = true;
    try {
      Map<String, dynamic> params = {'restro_id': resId.value};
      ApiResponseModel<RestaurantAvailabilityModel> cartModel =
          await DioClient.base().funRestaurantAvailabilityApi(params);
      if (cartModel.success! &&
          cartModel.data != null &&
          cartModel.data!.availability != null) {
        getPickupDays(cartModel.data!.availability!);
        await getCartData();
      } else {
        cartLoader.value = false;
        errorScreen(error: cartModel.message!);
        isCartData.value = false;
      }
    } on CustomHttpException catch (exception) {
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
      cartLoader.value = false;
      isCartData.value = false;
    } catch (exception) {
      cartLoader.value = false;
      isCartData.value = false;
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  getPickupDays(List<Availability> availableList) {
    for (int i = 0; i < availableList.length; i++) {
      var date = DateFormat('yyyy-MM-dd').parse(availableList[i].date!);
      print(date.month);
      print(date.weekday);
      if (CommonFunction.isToday(date.day, date.month, date.year)) {
        pickupDayList.add(PickupDateModel(
            title:
                'Today | ${weeks[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}',
            pickupDate: availableList[i].date,
            isSelect: availableList[i].isAvailable));
      } else if (CommonFunction.isTomorrow(date.day, date.month, date.year)) {
        pickupDayList.add(PickupDateModel(
            title:
                'Tomorrow | ${weeks[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}',
            pickupDate: availableList[i].date,
            isSelect: availableList[i].isAvailable));
      } else {
        pickupDayList.add(PickupDateModel(
            title:
                '${weeks[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}',
            pickupDate: availableList[i].date,
            isSelect: availableList[i].isAvailable));
      }
    }
    pickupDayIndex.value = 0;
    pickupDate.value = pickupDayList[pickupDayIndex.value].title!;
  }

  // cart data
  getCartData() async {
    cartLoader.value = true;
    currency.value = await PrefManager.getString(AppConstants.currency);
    try {
      Map<String, dynamic> params = {'cart_id': cartId.value};
      ApiResponseModel<CartModel> cartModel =
          await DioClient.base().funGetCartApi(params);
      if (cartModel.success! &&
          cartModel.data != null &&
          cartModel.data!.cartDetails != null) {
        phonePeCallBack.value = cartModel.data!.callBackUrl!;
        rApiKey.value = cartModel.data!.rApiKey!;
        rApiKey.value = cartModel.data!.rApiKey!;
        isPhonePe.value = cartModel.data!.cartDetails!.phonePe!;
        isRazorpay.value = cartModel.data!.cartDetails!.razorPay!;
        subTotalOfferPrice.value = cartModel.data!.cartDetails!.offerPrice!;
        subTotalFinalPrice.value = cartModel.data!.cartDetails!.finalPrice!;
        totalGst.value = cartModel.data!.cartDetails!.gstCharge!;
        // platformGst.value = cartModel.data!.cartDetails!.platformGst!;
        // platformFee.value = cartModel.data!.cartDetails!.platformFee ?? 0.0;
        //getting platformFee and platformGst from PrefManager
        platformFee.value =
            await PrefManager.getDouble(AppConstants.platformFee);
        platformGst.value =
            await PrefManager.getDouble(AppConstants.platformGst);
        combinedGst.value = totalGst.value + platformGst.value;
        menuList.addAll(cartModel.data!.cartDetails!.menuDetail!);
        // totalPay.value = subTotalFinalPrice.value + combinedGst.value + platformFee.value;
        totalPay.value = 1;

        print("sjkdfk ${menuList.length}");

        Future.delayed(const Duration(milliseconds: 500), () {
          cartLoader.value = false;
          isCartData.value = true;
          // Show alert dialog automatically when page opens
          showTakeawayReminderDialog();
        });
      } else {
        cartLoader.value = false;
        errorScreen(error: cartModel.message!);
        isCartData.value = false;
      }
    } on CustomHttpException catch (exception) {
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
      cartLoader.value = false;
      isCartData.value = false;
    } catch (exception) {
      print("sjkdfk ${exception}");
      cartLoader.value = false;
      isCartData.value = false;
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

// remove and add cart
  addCart(index) async {
    print("manue menuQuantity${menuList[index].menuQuantity}");
    if (menuList[index].menuSelectedQuantity! < menuList[index].menuQuantity!) {
      var tempQuantity = menuList[index].menuSelectedQuantity! + 1;
      menuList[index].menuSelectedQuantity =
          menuList[index].menuSelectedQuantity! + 1;
      menuList.refresh();

      // Analytics: AddToCart at the moment user increments in cart UI
      try {
        final item = AnalyticsEventItem(
          itemId: (menuList[index].menuId ?? '').toString(),
          itemName: menuList[index].menuName ?? 'menu_item',
          itemBrand: title.value, // vendor_name mapped to GA4 item_brand
          price: menuList[index].menuFinalPrice ?? 0.0,
          quantity: 1,
        );
        await FirebaseAnalytics.instance.logAddToCart(
          currency: (currency.value.isNotEmpty ? currency.value : 'INR'),
          value: (menuList[index].menuFinalPrice ?? 0.0) * 1,
          items: [item],
          parameters: {
            'vendor_name': title.value,
            'item_id': (menuList[index].menuId ?? '').toString(),
            'price': menuList[index].menuFinalPrice ?? 0.0,
            'quantity': 1,
          },
        );
        // Mirror to Meta (Facebook)
        await AnalyticsService.logAddToCart(
          itemId: (menuList[index].menuId ?? '').toString(),
          vendorName: title.value,
          price: menuList[index].menuFinalPrice ?? 0.0,
          quantity: 1,
        );
        debugPrint('Meta AddToCart logged');
      } catch (_) {}

      addRemoveCartApi(index, tempQuantity);
    } else {
      SnackBarUtil.showError(
          message: 'Your magic bag quantity has been maxed out');
    }
  }

  removeCart(index) {
    if (menuList[index].menuSelectedQuantity! != 0) {
      var tempQuantity = menuList[index].menuSelectedQuantity! - 1;
      menuList[index].menuSelectedQuantity =
          menuList[index].menuSelectedQuantity! - 1;
      menuList.refresh();
      addRemoveCartApi(index, tempQuantity);
    }
  }

  addRemoveCartApi(index, tempQuantity) async {
    try {
      var deviceId = await PrefManager.getString(AppConstants.deviceId);
      Map<String, dynamic> params = {
        'restro_id': resId.value,
        "menu_data": [
          {"menu_id": menuList[index].menuId, "quantity": tempQuantity}
        ],
      };
      if (cartId.value != 0 && cartId.value != -1) {
        params['cart_id'] = cartId.value;
      } else {
        params['device_id'] = deviceId;
      }

      ApiResponseModel<CartModel> cartModel =
          await DioClient.base().funAddCartApi(params);

      if (cartModel.success! && cartModel.data != null) {
        if (cartModel.data!.cartDetails != null) {
          if (cartId.value != 0 && cartId.value != -1) {
            cartId.value = cartModel.data!.cartDetails!.cartId!;
            PrefManager.putInt(
                AppConstants.cartId, cartModel.data!.cartDetails!.cartId);
          }

          subTotalOfferPrice.value = cartModel.data!.cartDetails!.offerPrice!;
          subTotalFinalPrice.value = cartModel.data!.cartDetails!.finalPrice!;
          totalGst.value = cartModel.data!.cartDetails!.gstCharge!;

          // platformGst.value = cartModel.data!.cartDetails!.platformGst!;
          // platformFee.value = cartModel.data!.cartDetails!.platformFee!;
          platformFee.value =
              await PrefManager.getDouble(AppConstants.platformFee);
          platformGst.value =
              await PrefManager.getDouble(AppConstants.platformGst);
          combinedGst.value = totalGst.value + platformGst.value;
          //  totalPay.value = subTotalFinalPrice.value + combinedGst.value + platformFee.value;
          totalPay.value = 1;

          menuList.refresh();
        } else {
          menuList.clear();
          isCartData.value = false;
        }
      } else {
        errorScreen(error: cartModel.message!);
      }
      isBack.value = true;
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

  changeButtonColor() {
    if (upiIdController.text.trim().isEmpty) {
      isFillColor.value = false;
    } else {
      isFillColor.value = true;
    }
  }

// place order upi phonepe By Backend old code
  placeOrderUpi() async {
    var progressDialog = ProgressDialog();
    progressDialog.show();

    try {
      var accessToken = await PrefManager.getString(AppConstants.accessToken);
      Map<String, dynamic> params = {};
      params['amount'] = totalPay.value;
      params['deviceOs'] =
          CommonFunction.getDeviceType().toString().toUpperCase();
      params['type'] = paymentType.value;
      if (upiIdController.value.text.trim().isNotEmpty) {
        params['upi'] = upiIdController.value.text;
      }
      if (paymentType.value == "card") {
        params['card_number'] = cardNoController.value.text.trim();
        params['card_holder_name'] = cardNameController.value.text.trim();
        params['exp_month'] = expireMonthController.value.text.trim();
        params['exp_year'] = expireYearController.value.text.trim();
        params['card_cvv'] = cardCvvController.value.text.trim();
      }

      print(params);
      ApiResponseModel<CreateIntentModel> createIntentData =
          await DioClient.base(accessToken: accessToken)
              .funCreateIntentApi(params);
      progressDialog.dismiss();
      if (createIntentData.success!) {
        checkPayment(createIntentData);
      } else {
        progressDialog.dismiss();
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

  checkPayment(ApiResponseModel<CreateIntentModel> createIntentData) async {
    var result = await Get.toNamed(Routes.paymentStatus, arguments: {
      'intentData': createIntentData.data!,
      'paymentType': paymentType.value
    });
    if (result['result']) {
      isPayed.value = true;
      paymentType.value = "";
      transactionId.value = result["transactionId"];
      print("transaction:- ${result["transactionId"]}");
      placeOrder();
    } else {
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  // place order
  placeOrder() async {
    var progressDialog = ProgressDialog();
    progressDialog.show();
    try {
      var accessToken = await PrefManager.getString(AppConstants.accessToken);
      Map<String, dynamic> params = {
        'restro_id': resId.value,
        'cart_id': cartId.value,
        'price': subTotalOfferPrice.value,
        'total_paid': subTotalFinalPrice.value,
        'pickup_date': pickupDayList[pickupDayIndex.value].pickupDate!,
        'pickup_time': pickupStartTime.value,
        'pickup_end_time': pickupCloseTime.value,
        'gst_charge': combinedGst.value,
        'payment_type': "ONLINE",
        'payment_status': 'paid',
        "payment_method": "phone_pe",
        "transaction_id": transactionId.value,
      };

      if (isNumberAdd.value) {
        params['country_code'] = countryCode.value;
        params['mobile'] = userPhoneNumber.value;
      }

      print(params);
      ApiResponseModel baseModel =
          await DioClient.base(accessToken: accessToken)
              .funPlaceOrderApi(params);
      progressDialog.dismiss();
      if (baseModel.success!) {
        // Analytics: Purchase (legacy placeOrder path)
        try {
          final items = menuList
              .map((m) => AnalyticsEventItem(
                    itemId: (m.menuId ?? '').toString(),
                    itemName: m.menuName ?? 'menu_item',
                    itemBrand: title.value,
                    price: m.menuFinalPrice ?? 0.0,
                    quantity: m.menuSelectedQuantity ?? 1,
                  ))
              .toList();
          await FirebaseAnalytics.instance.logPurchase(
            transactionId: (transactionId.value).toString(),
            currency: (currency.value.isNotEmpty ? currency.value : 'INR'),
            value: totalPay.value,
            items: items,
            parameters: {
              'transaction_id': (transactionId.value).toString(),
              'value': totalPay.value,
              'currency': (currency.value.isNotEmpty ? currency.value : 'INR'),
              'items': items.map((e) => e.asMap()).toList(),
            },
          );
          // Mirror to Meta (Facebook)
          await AnalyticsService.logPurchase(
            transactionId: (transactionId.value).toString(),
            value: totalPay.value,
            currency: (currency.value.isNotEmpty ? currency.value : 'INR'),
            items: menuList
                .map((m) => {
                      'item_id': (m.menuId ?? '').toString(),
                      'vendor_name': title.value,
                      'price': m.menuFinalPrice ?? 0.0,
                      'quantity': m.menuSelectedQuantity ?? 1,
                    })
                .toList(),
          );
        } catch (_) {}
        PrefManager.remove(AppConstants.cartId);
        Get.toNamed(Routes.orderStatus,
            arguments: {'status': 'success', 'message': baseModel.message!});
      } else {
        Get.toNamed(Routes.orderStatus,
            arguments: {'status': 'failed', 'message': baseModel.message!});
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

  getTotalPay() {
    ///changes by krishna
    var payableValue = totalPay.value;
    var fractionalPart = payableValue - payableValue.floor();
    if (fractionalPart <= 0.5) {
      payableValue = payableValue.floorToDouble();
    } else if (fractionalPart > 0.5) {
      payableValue = payableValue.ceilToDouble();
    }
    print(payableValue.toInt() * 100);
    return payableValue;
  }

  /// phone pe integration

  phonePeInit() {
    PhonePePaymentSdk.init(AppConstants.environmentValue, AppConstants.appId,
            AppConstants.phonePeMerchantId, AppConstants.enableLogging)
        .then((val) async => {
              phonePeResult = 'PhonePe SDK Initialized - $val',
              print('PhonePe SDK Initialized - $val'),
            })
        .catchError((error) {
      handlePhonePeError(error);
      return <dynamic>{};
    });
  }

  void startPgTransaction() async {
    phonePeInit();
    phonePeBody.value = getPhonePeCheckSum();
    PhonePePaymentSdk.startTransaction(phonePeBody.value, phonePeCallBack.value,
            phonePeCheckSum.value, "com.good.grab")
        .then((response) => {phonePeTransactionResponse(response)})
        .catchError((error) {
      handlePhonePeError(error);
      return <dynamic>{};
    });
  }

  getPhonePeCallBackUrl() {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(userId.value.toString());

    String validBaseUrl = phonePeCallBack.value.endsWith('/')
        ? phonePeCallBack.value
        : '${phonePeCallBack.value}/';

    // Generate the final callback URL
    return '$validBaseUrl$encoded/';
  }

  getPhonePeCheckSum() {
    getPhonePeCallBackUrl();
    phonePeTId.value = getRandomNumber();

    ///changes by krishna

    final requestData = {
      "merchantId": AppConstants.phonePeMerchantId,
      "merchantTransactionId": phonePeTId.value,
      "merchantUserId": userId.value.toString(),
      "amount": (getTotalPay().toInt() * 100),
      "callbackUrl":
          'https://goodtograb.com/callback-url', //'https://webhook.site/99e62550-a8dd-4550-b324-5f2627be9ec5',//phonePeCallBack.value,
      "mobileNumber": userPhoneNumber.value,
      "paymentInstrument": {"type": "PAY_PAGE"},
    };

    String base64Body = base64.encode(utf8.encode(jsonEncode(requestData)));
    print('base64Body ${requestData}');
    print(base64Body);
    phonePeCheckSum.value =
        '${sha256.convert(utf8.encode('$base64Body/pg/v1/pay${AppConstants.phonePeSaltKey}')).toString()}###${AppConstants.phonePeSaltIndex}';

    return base64Body;
  }

  phonePeTransactionResponse(response) async {
    await checkPhonePeStatusApi();
  }

  handlePhonePeError(error) {
    SnackBarUtil.showError(message: error.toString());
  }

  checkPhonePeStatusApi() async {
    var checkStatusUrl =
        '${AppConstants.phonePeCheckStatusUrl}/${AppConstants.phonePeMerchantId}/${phonePeTId.value}';
    var xVerify =
        '${sha256.convert(utf8.encode('/pg/v1/status/${AppConstants.phonePeMerchantId}/${phonePeTId.value}${AppConstants.phonePeSaltKey}')).toString()}###${AppConstants.phonePeSaltIndex}';
    var headers = {
      'Content-Type': 'application/json',
      'X-VERIFY': xVerify,
      'X-MERCHANT-ID': AppConstants.phonePeMerchantId
    };
    dio.Dio dio1 = dio.Dio();
    dio1
        .get(checkStatusUrl, options: dio.Options(headers: headers))
        .then((res) async {
      if (res.data != null &&
          res.data['success'] &&
          res.data['code'] == 'PAYMENT_SUCCESS' &&
          res.data['data']['state'] == 'COMPLETED') {
        // old code
        // var result = await Get.toNamed(Routes.paymentStatus, arguments: { 'paymentId': phonePeTId.value,'paymentType': paymentType.value});
        // if (result != null && result['result']) {
        //   // isPayed.value = true;
        //   // paymentType.value = "";
        //   // transactionId.value = result["transactionId"];
        //   // print("transaction:- ${result["transactionId"]}");
        //   // placeOrder();
        //
        // } else {
        //   errorScreen(error: 'something_went_wrong'.tr);
        // }

        // old code 21 Nov
        placeOrderWithPayment(res.data['data']['transactionId'], 'phonePe');

        // latest code 21 Nov

        //placeOrderComplementPayment(res.data['data']['transactionId']);
      } else {
        var msg = (res.data != null && res.data['message'] != null)
            ? res.data['message']
            : 'Something went wrong';

        print('error in phonepay sdk $msg');

        // SnackBarUtil.showPaymentError(message: msg);
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => PaymentFailedWidget(
            onClose: () {
              Navigator.pop(Get.context!);
            },
          ),
        );

        await removeOrderData();
      }
    }).catchError((error) {
      SnackBarUtil.showError(message: 'Something went wrong');
    });
  }

  getPhonePeSign() async {
    await PhonePePaymentSdk.getPackageSignatureForAndroid();
  }

  /// razor pay create order
  Future<dynamic> rCreateOrder() async {
    // var progressDialog = ProgressDialog();
    // progressDialog.show();
    try {
      var mapHeader = <String, String>{};
      mapHeader['Authorization'] =
          "Basic cnpwX2xpdmVfU1k3R1p5d1NGOGVFOUc6dTNGdE1SZW9GY0tscHNXZlB3VnpIemE4";
      mapHeader['Content-Type'] = "application/json";
      var map = <String, String>{};
      map['amount'] =
          (getTotalPay().toInt() * 100).toString(); //change by krishna;
      map['currency'] = "INR";
      map['receipt'] = "receipt1";
      dio.BaseOptions dioOptions = dio.BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          // 10 seconds
          receiveTimeout: const Duration(seconds: 10),
          receiveDataWhenStatusError: true,
          followRedirects: false,
          baseUrl: 'https://api.razorpay.com/v1/');
      var dioNew = dio.Dio(dioOptions);
      dioOptions.headers = mapHeader;
      var response = await dioNew.post("orders", data: json.encode(map));
      if (response.statusCode == 200) {
        // progressDialog.dismiss();
        print('razorpay 200');
        razorOption(response.data['id']);
      } else {
        print('razorpay 200 error');
        // progressDialog.dismiss();
        errorScreen(error: 'something_went_wrong'.tr);
      }
    } catch (exception) {
              print('razorpay  error');
      print(exception);
      // progressDialog.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  razorOption(orderId) {
    apiCalling.value = true;

    ///changes by krishna
    phonePeTId.value = orderId;
    var options = {
      'key': rApiKey.value,
      "amount": (getTotalPay().toInt() * 100), //change by krishna
      'currency': 'INR',
      'send_sms_hash': true,
      'payment_capture': 1,
      'order_id': orderId,
      'name': userName.value,
      'description': 'New Order',
      'prefill': {"contact": userPhoneNumber.value, 'email': userEmail.value},
      'external': {
      'wallets': ['paytm']
      }
    };
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    razorpay.open(options);
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (apiCalling.value) {
      await placeOrderWithPayment(
          response.data!['razorpay_payment_id'], 'razorpay');
    }
  }
bool _isPaymentSheetOpen = false;

  void _handlePaymentError(PaymentFailureResponse response) {
    // debugPrint(
    //     '_handlePaymentError: code=${response.code}, message=${response.error}');

    // if (response.error!['description'] == 'payment_error') {
    //   errorScreen(error: 'Payment cancelled by user');
    //   return;
    // }
      if (_isPaymentSheetOpen) {
    return; // ✅ Already open, do nothing
  }
  showModalBottomSheet(
    context: Get.context!,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PaymentFailedWidget(
      onClose: () {
        Navigator.pop(Get.context!);
      },
    ),
  ).whenComplete(() {
    // ✅ Reset when sheet is dismissed
    _isPaymentSheetOpen = false;
  });

    var message = response.error == null
        ? 'something_went_wrong'.tr
        : response.error!['description'].toString();
        print('razorpay failed message $message');
    //  SnackBarUtil.showError(message: message);
      // debugPrint(
      //   '_handlePaymentError: code=${response.code}, message=${response.error}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }

  // place order for phonepe and razorpay
  /// old code
  // placeOrderWithPayment(transId, paymentMethodType) async {
  //   apiCalling.value = false;
  //   var progressDialog = ProgressDialog();
  //   progressDialog.show();
  //   try {
  //     var accessToken = await PrefManager.getString(AppConstants.accessToken);
  //     Map<String, dynamic> params = {
  //       'restro_id': resId.value,
  //       'cart_id': cartId.value,
  //       'price': subTotalOfferPrice.value,
  //       'total_paid': subTotalFinalPrice.value,
  //       'pickup_date': pickupDayList[pickupDayIndex.value].pickupDate!,
  //       'pickup_time': pickupStartTime.value,
  //       'pickup_end_time': pickupCloseTime.value,
  //       'gst_charge': totalGst.value,
  //       'payment_type': "ONLINE",
  //       'payment_status': 'paid',
  //       "payment_method": paymentMethodType,
  //       "transaction_amount": totalPay.value,
  //       "transaction_payment_type": "online",
  //       "original_transaction_id": transId,
  //       "payment_id": phonePeTId.value,
  //     };

  //     if (isNumberAdd.value) {
  //       params['country_code'] = countryCode.value;
  //       params['mobile'] = userPhoneNumber.value;
  //     }

  //     print(params);
  //     ApiResponseModel baseModel =
  //         await DioClient.base(accessToken: accessToken)
  //             .funPlaceOrderPaymentApi(params);
  //     progressDialog.dismiss();
  //     if (baseModel.success!) {
  //       PrefManager.remove(AppConstants.cartId);
  //       Get.toNamed(Routes.orderStatus,
  //           arguments: {'status': 'success', 'message': baseModel.message!});
  //     } else {
  //       Get.toNamed(Routes.orderStatus,
  //           arguments: {'status': 'failed', 'message': baseModel.message!});
  //     }
  //   } on CustomHttpException catch (exception) {
  //     progressDialog.dismiss();
  //     errorScreen(
  //         error: handleApiException(
  //             exception.code, exception.response, exception.exception,
  //             type: exception.type));
  //   } catch (exception) {
  //     progressDialog.dismiss();
  //     errorScreen(error: 'something_went_wrong'.tr);
  //   }
  // }

  placeOrderWithPayment(transId, paymentMethodType) async {
    apiCalling.value = false;
    var progressDialog = ProgressDialog();
    progressDialog.show();
    try {
      var accessToken = await PrefManager.getString(AppConstants.accessToken);
      Map<String, dynamic> params = {
        'order_id': newOrderId.value,
        "payment_status": 'paid',
        "original_transaction_id": transId,
        'cart_id': cartId.value,
        "payment_id": phonePeTId.value,
        'payment_type': "ONLINE",
        "transaction_status": "success",
        "payment_method": paymentMethodType,
        "transaction_payment_type": "online",
      };

      ApiResponseModel<OrderSuccessData> baseModel =
          await DioClient.base(accessToken: accessToken)
              .funPlaceOrderPaymentApi(params);
      progressDialog.dismiss();
      if (baseModel.success!) {
        // Analytics: Purchase (new flow with payment confirmation)
               print('payment success api hitted');
       try {
          final items = menuList
              .map((m) => AnalyticsEventItem(
                    itemId: (m.menuId ?? '').toString(),
                    itemName: m.menuName ?? 'menu_item',
                    price: m.menuFinalPrice ?? 0.0,
                    quantity: m.menuSelectedQuantity ?? 1,
                  ))
              .toList();
          await FirebaseAnalytics.instance.logPurchase(
            transactionId: (transId ?? '').toString(),
            currency: (currency.value.isNotEmpty ? currency.value : 'INR'),
            value: totalPay.value,
            items: items,
          );
        } catch (_) {}
        PrefManager.remove(AppConstants.cartId);
        var message = baseModel.message;
        var paymentOrderId = baseModel.data?.orderId;
        print('paymentOrderId $paymentOrderId');
        Get.toNamed(Routes.orderStatus,
            arguments: {
              'status': 'success',
              'message': baseModel.message!,
              'orderId': paymentOrderId,
              'resId': resId.value,
              'orderStatus': 'confirmation_pending',
            });
      } else {
        print('phone pay failed cancelled2222');
        Get.toNamed(Routes.orderStatus,
            arguments: {'status': 'failed', 'message': baseModel.message!});
      }
     } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      print('phone pay failed cancelled');
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      print('phone pay failed cancelled11');
      progressDialog.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  /// new code
  placeOrderWithoutPayment(paymentMethodType) async {
    apiCalling.value = false;

    // Analytics: BeginCheckout before creating pending order
    try {
      final items = menuList
          .map((m) => AnalyticsEventItem(
                itemId: (m.menuId ?? '').toString(),
                itemName: m.menuName ?? 'menu_item',
                price: m.menuFinalPrice ?? 0.0,
                quantity: m.menuSelectedQuantity ?? 1,
              ))
          .toList();
      debugPrint(
          "Begin Checkout Event Fire: $currency, $totalPay, $items $paymentMethodType");
      await FirebaseAnalytics.instance.logBeginCheckout(
        currency: (currency.value.isNotEmpty ? currency.value : 'INR'),
        value: totalPay.value,
        items: items,
        parameters: {
          'cart_value': totalPay.value,
          'item_ids':
              menuList.map((m) => (m.menuId ?? '').toString()).join(','),
          'payment_method': paymentMethodType ?? 'unknown',
        },
      );
      // Mirror to Meta (Facebook)
      await AnalyticsService.logBeginCheckout(
        cartValue: totalPay.value,
        itemIds: menuList.map((m) => (m.menuId ?? '').toString()).toList(),
        paymentMethod: (paymentMethodType ?? 'unknown').toString(),
      );
      debugPrint("Begin Checkout Event Fired");
    } catch (_) {}

    var progressDialog = ProgressDialog();
    progressDialog.show();
    phonePeBody.value = getPhonePeCheckSum();
    try {
      var accessToken = await PrefManager.getString(AppConstants.accessToken);
      Map<String, dynamic> params = {
        'restro_id': resId.value,
        'cart_id': cartId.value,
        'price': subTotalOfferPrice.value,
        'total_paid': subTotalFinalPrice.value,
        'pickup_date': pickupDayList[pickupDayIndex.value].pickupDate!,
        'pickup_time': pickupStartTime.value,
        'pickup_end_time': pickupCloseTime.value,
        'gst_charge': combinedGst.value,
        'payment_type': "ONLINE",
        'payment_status': 'pending',
        "payment_method": paymentMethodType,
        "transaction_amount": totalPay.value,
        "transaction_payment_type": "online",
        "payment_id": phonePeTId.value,
      };

      if (isNumberAdd.value) {
        params['country_code'] = countryCode.value;
        params['mobile'] = userPhoneNumber.value;
      }
      debugPrint('Calling funPlaceOrderWithoutPaymentApi with params: ');
      final dynamic createdOrderId = await DioClient.base(accessToken: accessToken)
          .funPlaceOrderWithoutPaymentApi(params);
      debugPrint('funPlaceOrderWithoutPaymentApi returned: $createdOrderId (type: ${createdOrderId.runtimeType})');

      if (createdOrderId == null) {
        progressDialog.dismiss();
        errorScreen(error: 'something_went_wrong'.tr);
        return;
      }
      if (createdOrderId is int) {
        newOrderId.value = createdOrderId;
      } else if (createdOrderId is String) {
        final parsed = int.tryParse(createdOrderId);
        if (parsed == null) {
          progressDialog.dismiss();
          errorScreen(error: 'something_went_wrong'.tr);
          return;
        }
        newOrderId.value = parsed;
      } else {
        newOrderId.value = int.tryParse(createdOrderId.toString()) ?? 0;
      }

      debugPrint('Starting to payment with orderId: ${newOrderId.value}');
      if (paymentMethodType == "phonePe") {
        startPgTransaction();
      } else {
        rCreateOrder();
      }
    } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      progressDialog.dismiss();
      print('getting error in fun');
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  placeOrderComplementPayment(transId) async {
    apiCalling.value = false;
    var progressDialog = ProgressDialog();
    progressDialog.show();
    debugPrint("vgregregregreg ");

    try {
      var accessToken = await PrefManager.getString(AppConstants.accessToken);
      Map<String, dynamic> params = {
        "original_transaction_id": transId,
        "merchant_transaction_id": phonePeTId.value,
      };
      ApiResponseModel baseModel =
          await DioClient.base(accessToken: accessToken)
              .funPlaceCompleteOrderApi(params);

      progressDialog.dismiss();
      if (baseModel.success!) {
        // Analytics: Purchase after completion callback
        try {
          final items = menuList
              .map((m) => AnalyticsEventItem(
                    itemId: (m.menuId ?? '').toString(),
                    itemName: m.menuName ?? 'menu_item',
                    price: m.menuFinalPrice ?? 0.0,
                    quantity: m.menuSelectedQuantity ?? 1,
                  ))
              .toList();
          await FirebaseAnalytics.instance.logPurchase(
            transactionId: (transId ?? '').toString(),
            currency: (currency.value.isNotEmpty ? currency.value : 'INR'),
            value: totalPay.value,
            items: items,
          );
          // Mirror to Meta (Facebook)
          await AnalyticsService.logPurchase(
            transactionId: (transId ?? '').toString(),
            value: totalPay.value,
            currency: (currency.value.isNotEmpty ? currency.value : 'INR'),
            items: menuList
                .map((m) => {
                      'item_id': (m.menuId ?? '').toString(),
                      'vendor_name': title.value,
                      'price': m.menuFinalPrice ?? 0.0,
                      'quantity': m.menuSelectedQuantity ?? 1,
                    })
                .toList(),
          );
        } catch (_) {}
        PrefManager.remove(AppConstants.cartId);
        Get.toNamed(Routes.orderStatus,
            arguments: {'status': 'success', 'message': baseModel.message!});
      } else {
        Get.toNamed(Routes.orderStatus,
            arguments: {'status': 'failed', 'message': baseModel.message!});
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

  removeOrderData() async {
    try {
      var accessToken = await PrefManager.getString(AppConstants.accessToken);
      await DioClient.base(accessToken: accessToken).funPlaceCompleteOrderApi({
        "order_id": newOrderId.value,
      });
    } on CustomHttpException catch (_) {
    } catch (_) {}
  }
}
