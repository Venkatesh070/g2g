import 'dart:async';

import 'package:get/get.dart';
import 'package:good_grab/presentation/cart/cart_controller.dart';
import 'package:good_grab/presentation/home-details/home_details_controller.dart';
import 'package:good_grab/presentation/home/home_controller.dart';

import '../../infrastructure/navigation/routes.dart';
import '../../res.dart';

class OrderStatusController extends GetxController {
  var orderStatus = ''.obs;
  var orderStatusTitle = ''.obs;
  var orderStatusSubtitle = ''.obs;
  var orderFile = ''.obs;
  //  var orderId = 0;
  // var resId = 0;
  // var currency = '';

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
        // print('$orderId $orderStatus $resId' );
        // Get.offAllNamed(
        //      Routes.orderDetails,
        //                                   arguments: {
        //                                     'orderId':orderId ,
        //                                     'resId': resId,
        //                                     'orderStatus': orderStatus,
        //                                   },
        // );
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
      // orderStatusSubtitle.value = Get.arguments['message'];
      orderStatusTitle.value = "You’re a Sustainable Hero!";
      orderStatusSubtitle.value = "Thanks for saving food and fight for a healthier planet. Every order you place makes a real difference. See you on the next mission! ";
      // orderId = Get.arguments['orderId'];
      // resId = Get.arguments['resId'];
      // orderStatus.value = 'confirmation_pending';
      orderFile.value = Res.successOrder;
    } else if (orderStatus.value == 'failed') {
      orderStatusSubtitle.value = Get.arguments['message'];
      orderFile.value = Res.cancelOrder;
    }
    super.onInit();
  }
}
