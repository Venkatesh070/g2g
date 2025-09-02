import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/presentation/splash/splash_controller.dart';
import 'package:lottie/lottie.dart';
import 'package:upgrader/upgrader.dart';

import '../../res.dart';

class SplashPage extends BaseView<SplashController> {
  SplashPage({super.key});

  @override
  Color pageBackgroundColor() {
    return ColorsTheme.colF3FFFB;
  }

  @override
  Widget body(BuildContext context) {
    return SafeArea(
        child: Center(
      child: Obx(() =>
          //Lottie.asset(
        //Res.splashLogoJson,
       Image.asset(
         Res.splashLogiGif,
        width: controller.width.value,
        height: controller.width.value,
      ),)
    ));
  }


}
