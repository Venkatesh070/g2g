import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/presentation/payment_status/payment_status_controller.dart';
import 'package:lottie/lottie.dart';

import '../../infrastructure/theme/colors.theme.dart';
import '../../infrastructure/theme/text.theme.dart';
import '../../res.dart';

class PaymentStatusPage extends BaseView<PaymentStatusController> {
  PaymentStatusPage({super.key});

  @override
  bool onBackPressed() => false;

  @override
  Widget body(BuildContext context) {
    return SafeArea(
        child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() => SizedBox(
              height: 200,
              child: Lottie.asset(controller.paymentStatus.value == "Processing"
                  ? Res.pendingJson
                  : controller.paymentStatus.value == "Success"
                      ? Res.successOrder
                      : Res.cancelOrder))),
          Obx(() => Text(controller.paymentStatus.value,
            style: boldTextStyle(fontSize: dimen16, color: Colors.black),
          )),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Obx(() => Text(
              controller.pDescription.value,
              textAlign: TextAlign.center,
              style: regularTextStyle(fontSize: dimen14, color: Colors.black),
            ),)
          ),
          const SizedBox(
            height: 30,
          ),
          Obx(
            () => Visibility(
              visible: controller.paymentStatus.value == "Processing" ? false : true,
              child: GestureDetector(
                onTap: () {
                  if (controller.paymentStatus.value == "Success") {
                    Get.back(result: {"result": true, "transactionId": controller.transactionId});
                    Get.back(result: true);
                  } else {
                    Get.back(result: false);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(color: ColorsTheme.colPrimary, borderRadius: BorderRadius.circular(50)),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  margin: const EdgeInsets.only(left: 45, right: 45),
                  child: Text(
                    'Back'.tr,
                    style: semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colWhite),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    ));
  }
}
