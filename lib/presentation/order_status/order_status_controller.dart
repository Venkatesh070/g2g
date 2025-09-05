import 'dart:async';

import 'package:get/get.dart';
import 'package:good_grab/presentation/cart/cart_controller.dart';
import 'package:good_grab/presentation/home-details/home_details_controller.dart';
import 'package:good_grab/presentation/home/home_controller.dart';

import '../../infrastructure/navigation/routes.dart';
import '../../res.dart';

class OrderStatusController extends GetxController {
  var orderStatus = ''.obs;
  var orderStatusSubtitle = ''.obs;
  var orderFile = ''.obs;

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
        Get.offNamed(Routes.home);
      } else {
        seconds = seconds - 1;
      }
    });
  }

  @override
  void onInit() {
    initTimer();
    orderStatus.value = Get.arguments['status'];
    if (orderStatus.value == 'success') {
      orderStatusSubtitle.value = Get.arguments['message'];
      orderFile.value = Res.successOrder;
    } else if (orderStatus.value == 'failed') {
      orderStatusSubtitle.value = Get.arguments['message'];
      orderFile.value = Res.cancelOrder;
    }
    super.onInit();
  }
}
