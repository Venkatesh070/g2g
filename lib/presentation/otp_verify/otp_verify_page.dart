import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/presentation/otp_verify/otp_verify_controller.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../infrastructure/theme/colors.theme.dart';
import '../../infrastructure/theme/text.theme.dart';

class OtpVerifyPage extends BaseView<OtpVerifyController> {
  OtpVerifyPage({super.key});


  @override
  Widget body(BuildContext context) {
    return SafeArea(
        child: Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.arrow_back,
                      size: 25,
                      color: ColorsTheme.colBlack,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: Text(
                      'OTP Verification'.tr,
                      style: boldTextStyle(fontSize: dimen21, color: ColorsTheme.colBlack),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: subtitleWidget()
                  ),
                  pinTextField(context),
                  Center(
                    child: InkWell(
                      onTap: () {
                        controller.resendOtp();
                      },
                      child: Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: Obx(
                            () => Text(
                              controller.seconds.value != 0
                                  ? '00:${controller.seconds.value.toString().length == 1 ? '0${controller.seconds.value}' : controller.seconds.value}'
                                  : 'Resend code'.tr,
                              style: mediumTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                            ),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
              onTap: () {
                if (controller.isFillColor.value) {
                  controller.verifyOtp(controller.otpController.text);
                }
              },
              child: Obx(
                () => Container(
                  decoration: BoxDecoration(
                      color: controller.isFillColor.value ? ColorsTheme.colPrimary : ColorsTheme.colSecondary,
                      borderRadius: BorderRadius.circular(50)),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Text(
                    '${'Verify'.tr} →',
                    style: semiBoldTextStyle(fontSize: dimen13, color: controller.isFillColor.value ? ColorsTheme.colWhite : ColorsTheme.colBlack),
                  ),
                ),
              )),
        ],
      ),
    ));
  }

  pinTextField(context) {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      alignment: Alignment.center,
      child: PinCodeTextField(
        appContext: context,
        controller: controller.otpController,
        length: 6,
        animationDuration: Duration.zero,
        pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(14),
            activeFillColor: ColorsTheme.colSecondary,
            disabledColor: ColorsTheme.colSecondary,
            inactiveFillColor: ColorsTheme.colSecondary,
            activeColor: ColorsTheme.colSecondary,
            inactiveColor: ColorsTheme.colSecondary,
            selectedColor: ColorsTheme.colSecondary,
            selectedFillColor: ColorsTheme.colSecondary),
        textStyle: mediumTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          controller.onChangeText(value);
        },
        onCompleted: (code) {
          controller.verifyOtp(code);
        },
      ),
    );
  }


  subtitleWidget(){
    return Obx(() => controller.number.isEmpty?Container():Text.rich(TextSpan(children: [
      TextSpan(
        text: 'We have sent a verification code to'.tr,
        style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
      ),
      controller.countryCode.isEmpty?TextSpan(
        text: ' ${controller.number.value}',
        style: mediumTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
      ):TextSpan(
        text: ' +${controller.countryCode.value} ${controller.number.value}',
        style: mediumTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
      )
    ])),);
  }

}
