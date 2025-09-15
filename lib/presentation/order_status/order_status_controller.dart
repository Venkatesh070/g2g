import 'dart:async';

import 'package:get/get.dart';
import 'package:good_grab/presentation/cart/cart_controller.dart';
import 'package:good_grab/presentation/home-details/home_details_controller.dart';
// import 'package:good_grab/presentation/home/home_controller.dart';

import '../../infrastructure/navigation/routes.dart';
import '../../res.dart';

class OrderStatusController extends GetxController {
  var orderStatus = ''.obs;
  var orderStatusTitle = ''.obs;
  var orderStatusSubtitle = ''.obs;
  var orderFile = ''.obs;
  var orderId = 0;
  var resId = 0;
  var currency = '';
  var redirectStatus = ''.obs;

  Timer? timer;

  initTimer() {
    var seconds = 2;
    timer = Timer.periodic(const Duration(milliseconds: 1000), (t) {
      if (seconds == 0) {
        timer!.cancel();
        // Get.back(result:  true);
        // Get.back(result:  true);
        if (Get.isRegistered<HomeDetailsController>()) {
          Get.delete<HomeDetailsController>();
        }
        if (Get.isRegistered<CartController>()) {
          Get.delete<CartController>();
        }
        print('$orderId $orderStatus $resId');
        Get.offAllNamed(
          Routes.orderDetails,
          arguments: {
            'orderId': orderId,
            'resId': resId,
            'orderStatus': redirectStatus.value.isNotEmpty
                ? redirectStatus.value
                : 'confirmation_pending',
          },
        );
      } else {
        seconds = seconds - 1;
      }
    });
  }

  @override
  void onInit() {
    initTimer();
    // UI status should be success/failed only
    orderStatus.value = Get.arguments['status'];
    // Redirect/order tracking status defaults to confirmation_pending
    redirectStatus.value =
        Get.arguments['orderStatus'] ?? 'confirmation_pending';
    if (orderStatus.value == 'success') {
      // orderStatusSubtitle.value = Get.arguments['message'];
      orderStatusTitle.value = "You’re a Sustainable Hero!";
      orderStatusSubtitle.value =
          "Thanks for saving food and fight for a healthier planet. Every order you place makes a real difference. See you on the next mission! ";
      orderId = Get.arguments['orderId'] ?? 0;
      resId = Get.arguments['resId'] ?? 0;
      orderFile.value = Res.successOrder;
    } else if (orderStatus.value == 'failed') {
      orderStatusSubtitle.value = Get.arguments['message'];
      orderFile.value = Res.cancelOrder;
    }
    super.onInit();
  }
}
