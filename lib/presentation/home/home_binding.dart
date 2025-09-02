import 'package:get/get.dart';
import 'package:good_grab/presentation/home/home_controller.dart';

class HomeBinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }

}