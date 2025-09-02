import 'package:get/get.dart';
import 'package:good_grab/presentation/payment_status/payment_status_controller.dart';

class PaymentStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentStatusController>(() => PaymentStatusController());
  }
}
