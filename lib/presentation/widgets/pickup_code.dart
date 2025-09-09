import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'package:good_grab/presentation/widgets/otp_display.dart';

class PickupCodeWidget extends StatelessWidget {
  final String pickupCode;

  const PickupCodeWidget({super.key, required this.pickupCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: ColorsTheme.colFBF09D.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: ColorsTheme.colFCFFFC,
              shape: BoxShape.circle,
              border: Border.all(color: ColorsTheme.col5dD6E68, width: 1),
            ),
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: 0 * pi / 180, // Convert degrees to radians (π/4)
              child: Icon(
                Icons.lock_clock_outlined,
                size: 20,
                color: ColorsTheme.colBlack.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Pickup Code: ',
                              style: semiBoldTextStyle(
                                fontSize: dimen14,
                                color: ColorsTheme.colBlack.withOpacity(0.8),
                              ),
                            ),
                            // TextSpan(
                            //   text: pickupCode,
                            //   style: semiBoldTextStyle(
                            //     fontSize: dimen14,
                            //     color: ColorsTheme.colBlack,
                            //   ).copyWith(
                            //     letterSpacing:
                            //         1.2, // Only apply letter spacing here
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                                                           OtpDisplay(otp: pickupCode),

                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Show this code at the restuarant to collect your order.'.tr,
                    style: regularTextStyle(
                        fontSize: dimen11,
                        color: ColorsTheme.colBlack.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
