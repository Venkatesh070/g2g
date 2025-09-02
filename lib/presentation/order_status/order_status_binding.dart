import 'package:get/get.dart';
import 'package:good_grab/presentation/order_status/order_status_controller.dart';

class OrderStatusBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => OrderStatusController());
  }

}