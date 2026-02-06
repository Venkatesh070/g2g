import 'package:get/get.dart';
import 'package:good_grab/presentation/order_picked/order_picked_controller.dart';

class OrderPickedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderPickedController());
  }
}
