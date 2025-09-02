import 'package:get/get.dart';
import 'package:good_grab/presentation/order_cancel/order_cancel_controller.dart';

class OrderCancelBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => OrderCancelController());
  }

}