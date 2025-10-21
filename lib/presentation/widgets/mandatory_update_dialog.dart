import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../infrastructure/theme/colors.theme.dart';
import '../../infrastructure/theme/text.theme.dart';
import '../../res.dart';

class MandatoryUpdateDialog extends StatelessWidget {
  final VoidCallback onUpdateNow;

  const MandatoryUpdateDialog({super.key, required this.onUpdateNow});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: UnconstrainedBox(
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: SizedBox(
              width: Get.width * 0.78,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.system_update,
                          color: ColorsTheme.colPrimary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Update Required',
                        style: semiBoldTextStyle(
                            fontSize: dimen16, color: ColorsTheme.colBlack),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: Lottie.asset(
                      Platform.isIOS ? Res.appstore : Res.playstore,
                      repeat: true,
                      animate: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A newer version of the app is available. Please update to continue using the app.',
                    textAlign: TextAlign.center,
                    style: regularTextStyle(
                        fontSize: dimen14, color: ColorsTheme.colBlack),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onUpdateNow,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: ColorsTheme.colPrimary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Update Now',
                              style: mediumTextStyle(
                                  fontSize: dimen15,
                                  color: ColorsTheme.colWhite),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
