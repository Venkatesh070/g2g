import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lottie/lottie.dart';
import '../theme/colors.theme.dart';
import '../theme/text.theme.dart';
import '../../res.dart';

class SnackBarUtil {
  static void showSuccess({required String message}) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      title: 'Success',
      message: message,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green.shade600,
    );
  }

  static void showOrderConfirmation({
    required String message,
    required VoidCallback onOrderDetails,
    required VoidCallback onOrdersHistory,
    required VoidCallback onCancel,
  }) {
    Get.dialog(
      Center(
        child: UnconstrainedBox(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                width: Get.width * 0.82,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: ColorsTheme.colPrimary, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Order Confirmed',
                              style: semiBoldTextStyle(
                                  fontSize: dimen16,
                                  color: ColorsTheme.colBlack),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Icon(Icons.close,
                              color: ColorsTheme.col8FA19C, size: 20),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: Lottie.asset(
                        Res.orderConfirmed,
                        repeat: true,
                        animate: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: regularTextStyle(
                          fontSize: dimen14, color: ColorsTheme.colBlack),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: onOrderDetails,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: ColorsTheme.colPrimary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Go To Orders',
                                style: mediumTextStyle(
                                    fontSize: dimen13,
                                    color: ColorsTheme.colWhite),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static void showOrderCancellation({
    required String message,
    required VoidCallback onOrderDetails,
    required VoidCallback onCancel,
  }) {
    Get.dialog(
      Center(
        child: UnconstrainedBox(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                width: Get.width * 0.82,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.cancel,
                                color: Colors.red, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Order Cancelled',
                              style: semiBoldTextStyle(
                                  fontSize: dimen16,
                                  color: ColorsTheme.colBlack),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Icon(Icons.close,
                              color: ColorsTheme.col8FA19C, size: 20),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: Lottie.asset(
                        Res.cancelOrder,
                        repeat: true,
                        animate: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: regularTextStyle(
                          fontSize: dimen14, color: ColorsTheme.colBlack),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: onOrderDetails,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: ColorsTheme.colPrimary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Go To Orders',
                                style: mediumTextStyle(
                                    fontSize: dimen13,
                                    color: ColorsTheme.colWhite),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static void showWarning({required String message}) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      title: 'Warning',
      message: message,
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.orange.shade900,
    );
  }

  static void showError({required String message}) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      title: 'Error',
      message: message,
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.redAccent.shade700,
    );
  }

  static void showPaymentError({required String message}) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      title: 'Failed',
      message: message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.redAccent.shade700,
    );
  }
}
