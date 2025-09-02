import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
}