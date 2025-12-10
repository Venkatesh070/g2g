import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';

class PaymentFailedWidget extends StatelessWidget {
  final VoidCallback onClose;

  const PaymentFailedWidget({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 5),
          // Icon / Illustration (replace with Image.asset if you have an image)
          // SizedBox(
          //   height: 80,
          //   child: Icon(Icons.receipt_long_sharp, size: 70, color: Colors.redAccent),
          // ),
          SizedBox(
  height: 80,
  child: Image.asset(
    'assets/images/payment_cancel.png', // put your image in assets
    height: 70,
    width: 70,
    fit: BoxFit.contain,
  ),
),

          const SizedBox(height: 12),

          // Title
          Text(
            'Payment Failed'.tr,
            style:
                boldTextStyle(fontSize: dimen18, color: ColorsTheme.colBlack),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Text(
              'If amount was deducted, refund will be initiated within 24 hours'
                  .tr,
              textAlign: TextAlign.center,
              style: regularTextStyle(
                  fontSize: dimen13, color: ColorsTheme.col475751),
            ),
          ),
          const SizedBox(height: 20),

          // Retry Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsTheme.colPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onClose,
              child: Text(
                'Close'.tr,
                style: boldTextStyle(
                    
                    fontSize: dimen15, color: ColorsTheme.colWhite),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
