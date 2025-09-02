import 'package:get/get.dart';
import 'package:good_grab/presentation/cart/cart_controller.dart';

class CartBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => CartController());
  }

}