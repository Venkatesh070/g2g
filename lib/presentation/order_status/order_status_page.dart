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
    return Column(
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
        Text(
          controller.orderStatusSubtitle.value,
          textAlign: TextAlign.center,
          style: boldTextStyle(fontSize: dimen15, color: ColorsTheme.colBlack),
        )
      ],
    );
  }
}
