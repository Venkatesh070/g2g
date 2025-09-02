import 'package:get/get.dart';
import 'package:good_grab/presentation/intro/intro_controller.dart';

class IntroBinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut(() => IntroController());
  }

}