import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'package:good_grab/presentation/order_status/order_status_controller.dart';
import 'package:lottie/lottie.dart';

import '../../res.dart';

class OrderStatusPage extends BaseView<OrderStatusController> {
  OrderStatusPage({super.key});

  @override
  bool onBackPressed() {
    return false;
  }

  @override
  Widget body(BuildContext context) {
    return SafeArea(child: Obx(() => controller.orderStatus.value.isNotEmpty ? paymentSuccess() : Container()));
  }

  paymentSuccess() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Lottie.asset(
              controller.orderFile.value,
              width: 150,
              height: 150
            ),
          ),
                  // const SizedBox(height: 10),
          Text(
            controller.orderStatusTitle.value,
            textAlign: TextAlign.center,
            style: boldTextStyle(fontSize: dimen17, color: ColorsTheme.colBlack),
          ),
          const SizedBox(height: 15),
          Text(
            controller.orderStatusSubtitle.value,
            textAlign: TextAlign.center,
            style: semiBoldTextStyle(fontSize: dimen14, color: ColorsTheme.colBlack.withOpacity(0.7)),
          )
        ],
      ),
    );
  }
}
