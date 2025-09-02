import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../res.dart';
import '../theme/colors.theme.dart';
import '../theme/text.theme.dart';

errorScreen({error}) {
  return Get.bottomSheet(
    Wrap(
      children: [
        Align(
          alignment: Alignment.center,
          child: InkWell(
            onTap: () {
              Get.back();
            },
            child: Container(
              decoration: BoxDecoration(color: ColorsTheme.colWhite, shape: BoxShape.circle),
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 20),
              alignment: Alignment.center,
              width: 40,
              height: 40,
              child: Image.asset(
                Res.icCancel,
                color: ColorsTheme.colPrimary,
                width: 15,
                height: 15,
              ),
            ),
          ),
        ),
        Container(
          color: ColorsTheme.colWhite,
          width: Get.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Lottie.asset(
                  Res.errorFoundNewJson,
                  // Res.errorFound,
                  height: 100),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Error!",
                style: boldTextStyle(fontSize: dimen17, color: ColorsTheme.colBlack),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: regularTextStyle(fontSize: dimen14, color: ColorsTheme.colBlack),
              ),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
